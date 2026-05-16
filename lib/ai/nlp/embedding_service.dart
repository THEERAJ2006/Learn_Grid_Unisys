import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'embedding_index.dart';

import '../../data/models/entities.dart';
import '../../data/repositories/repository_interfaces.dart';
import '../runtime/onnx_inference_service.dart';
import '../runtime/flutter_onnxruntime_inference_service.dart';

class ContentChunk {
  final String contentId;
  final int chunkIndex;
  final String text;
  final double similarity;
  final double score;

  const ContentChunk({
    required this.contentId,
    required this.chunkIndex,
    required this.text,
    required this.similarity,
    required this.score,
  });
}

class EmbeddingService {
  static const String _modelAssetPath = 'assets/models/minilm_embeddings.onnx';
  static const String _vocabAssetPath = 'assets/models/minilm_vocab.txt';
  static const int _embeddingDim = 384;

  final EmbeddingRepository _embeddings;
  final OnnxInferenceService _onnx;
  final EmbeddingIndex _index = EmbeddingIndex();

  bool _loaded = false;
  late final _MiniLmTokenizer _tokenizer;

  EmbeddingService({
    required EmbeddingRepository embeddings,
    OnnxInferenceService? onnx,
  })  : _embeddings = embeddings,
        _onnx = onnx ?? FlutterOnnxruntimeInferenceService(assetModelPath: _modelAssetPath);

  Future<void> initialize() async {
    if (_loaded) return;
    
    if (kIsWeb) {
      _loaded = true;
      try {
        if (!_index.isLoaded) await _index.load(_embeddings);
      } catch (_) {}
      return;
    }

    try {
      _tokenizer = await _MiniLmTokenizer.loadFromAssets(_vocabAssetPath);
      await _onnx.load();
    } catch (_) {}
    
    _loaded = true;
    // Load embedding index if repository available
    try {
      if (!_index.isLoaded) {
        await _index.load(_embeddings);
      }
    } catch (_) {
      // ignore if not available yet
    }
  }

  Future<List<double>> embed(String text) async {
    await initialize();

    // NOTE: Proper MiniLM requires attention mask + token type ids.
    // For MVP, we run a naive tokenization path and return a deterministic
    // fallback vector if the runtime fails.
    if (!kIsWeb) {
      try {
        final tokens = _tokenizer.encode(text, maxLength: 128);
        final inputIds = Int64List.fromList(tokens);
        // Some exports expect 2-D tensors. The onnxruntime_flutter wrapper
        // currently accepts flat typed lists; the adapter will map it.
        final outputs = await _onnx.run(
          inputs: {
            'input_ids': inputIds,
          },
          // Model export output name varies. We'll try a common name and fall
          // back to deterministic vectors if it fails.
          outputNames: const ['embedding'],
        );
        final out = outputs['embedding'];
        if (out is Float32List) {
          return _normalize(out).toList(growable: false);
        }
      } catch (_) {
        // fall through
      }
    }
    return _deterministicFallback(text);
  }

  Future<List<ContentChunk>> semanticSearch(
    String query,
    List<EmbeddingEntity> availableEmbeddings, {
    int topK = 5,
  }) async {
    final q = await embed(query);
    if (!_index.isLoaded) {
      await _index.load(_embeddings);
    }

    final indexResults = _index.search(q, topK: topK);

    return indexResults.map((r) {
      final score = (r.score * 100).clamp(0, 100).toDouble();
      return ContentChunk(
        contentId: r.contentId,
        chunkIndex: r.chunkIndex,
        text: r.chunkText,
        similarity: r.score,
        score: score,
      );
    }).toList();
  }

  Future<List<ContentChunk>> semanticSearchForContentId(
    String query,
    String contentId, {
    int topK = 5,
  }) async {
    final q = await embed(query);
    final embeddings = await _embeddings.getByContent(contentId);
    if (embeddings.isEmpty) return const [];
    final scored = <ContentChunk>[];
    for (final entity in embeddings) {
      final vec = _decodeEmbeddingBytes(entity.embeddingBytes);
      final score = _cosineSimilarity(vec, q);
      scored.add(ContentChunk(
        contentId: entity.contentId,
        chunkIndex: entity.chunkIndex,
        text: entity.chunkText,
        similarity: score,
        score: score,
      ));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(topK).toList(growable: false);
  }

  Future<void> rebuildIndex() async {
    _index.invalidate();
    await _index.load(_embeddings);
  }

  Future<int> ensureContentEmbeddings({
    required ContentItemEntity content,
    required String plainText,
  }) async {
    // Build once per content.
    final existing = await _embeddings.getByContent(content.id);
    if (existing.isNotEmpty) return existing.length;

    final chunks = _chunkText(plainText, chunkSize: 350, overlap: 50);
    final entities = <EmbeddingEntity>[];
    for (var i = 0; i < chunks.length; i++) {
      final emb = await embed(chunks[i]);
      final bytes = _encodeEmbedding(Float32List.fromList(emb));
      entities.add(
        EmbeddingEntity(
          id: _uuidFor(content.id, i),
          contentId: content.id,
          chunkIndex: i,
          chunkText: chunks[i],
          embeddingBytes: bytes,
          model: 'minilm-l6-v2',
        ),
      );
    }
    await _embeddings.insertBulk(entities);
    // Update in-memory index after insertion
    for (final e in entities) {
      final embeddingBytes = e.embeddingBytes;
      final floats = _decodeEmbeddingBytes(embeddingBytes);
      _index.addEntry(EmbeddingEntry(
        contentId: e.contentId,
        chunkIndex: e.chunkIndex,
        chunkText: e.chunkText,
        embedding: floats,
      ));
    }
    return entities.length;
  }

  Future<int> ensureFileEmbeddings({
    required int fileId,
    required String plainText,
  }) async {
    final contentId = 'managed_file:$fileId';
    final existing = await _embeddings.getByContent(contentId);
    if (existing.isNotEmpty) return existing.length;

    final chunks = _chunkText(plainText, chunkSize: 1800, overlap: 200);
    final entities = <EmbeddingEntity>[];
    for (var i = 0; i < chunks.length; i++) {
      final emb = await embed(chunks[i]);
      entities.add(
        EmbeddingEntity(
          id: _uuidFor(contentId, i),
          contentId: contentId,
          chunkIndex: i,
          chunkText: chunks[i],
          embeddingBytes: _encodeEmbedding(Float32List.fromList(emb)),
          model: 'minilm-l6-v2',
        ),
      );
    }
    if (entities.isNotEmpty) {
      await _embeddings.insertBulk(entities);
      for (final e in entities) {
        _index.addEntry(EmbeddingEntry(
          contentId: e.contentId,
          chunkIndex: e.chunkIndex,
          chunkText: e.chunkText,
          embedding: _decodeEmbeddingBytes(e.embeddingBytes),
        ));
      }
    }
    return entities.length;
  }

  List<String> _chunkText(String text, {required int chunkSize, required int overlap}) {
    final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return const [];
    final out = <String>[];
    var start = 0;
    while (start < cleaned.length) {
      final end = min(cleaned.length, start + chunkSize);
      out.add(cleaned.substring(start, end));
      if (end == cleaned.length) break;
      start = max(0, end - overlap);
    }
    return out;
  }

  List<int> _encodeEmbedding(Float32List v) {
    final bytes = Uint8List(v.lengthInBytes);
    final bd = ByteData.view(bytes.buffer);
    for (var i = 0; i < v.length; i++) {
      bd.setFloat32(i * 4, v[i], Endian.little);
    }
    return bytes;
  }

  List<double> _decodeEmbedding(List<int> bytes) {
    final u = Uint8List.fromList(bytes);
    final bd = ByteData.view(u.buffer);
    final len = (u.lengthInBytes / 4).floor();
    final out = List<double>.filled(len, 0.0);
    for (var i = 0; i < len; i++) {
      out[i] = bd.getFloat32(i * 4, Endian.little);
    }
    return out;
  }

  List<double> _decodeEmbeddingBytes(List<int> bytes) => _decodeEmbedding(bytes);

  List<double> _deterministicFallback(String text) {
    final hash = sha256.convert(utf8.encode(text));
    final rnd = Random(_bytesToSeed(hash.bytes));
    final v = Float32List(_embeddingDim);
    for (var i = 0; i < v.length; i++) {
      v[i] = (rnd.nextDouble() * 2 - 1).toDouble();
    }
    return _normalize(v).toList(growable: false);
  }

  int _bytesToSeed(List<int> bytes) {
    var s = 0;
    for (final b in bytes.take(4)) {
      s = (s << 8) ^ b;
    }
    return s;
  }

  Float32List _normalize(Float32List v) {
    double sum = 0;
    for (final x in v) {
      sum += x * x;
    }
    final norm = sqrt(sum);
    if (norm <= 0) return v;
    for (var i = 0; i < v.length; i++) {
      v[i] = (v[i] / norm).toDouble();
    }
    return v;
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length || a.isEmpty) return 0.0;
    double dot = 0;
    double na = 0;
    double nb = 0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }
    if (na == 0 || nb == 0) return 0;
    return dot / (sqrt(na) * sqrt(nb));
  }

  String _uuidFor(String contentId, int chunkIndex) {
    final input = utf8.encode('$contentId:$chunkIndex');
    return sha256.convert(input).toString();
  }
}

class _MiniLmTokenizer {
  final Map<String, int> _tokenToId;
  final int unkId;
  final int clsId;
  final int sepId;

  _MiniLmTokenizer(this._tokenToId)
      : unkId = _tokenToId['[UNK]'] ?? 100,
        clsId = _tokenToId['[CLS]'] ?? 101,
        sepId = _tokenToId['[SEP]'] ?? 102;

  static Future<_MiniLmTokenizer> loadFromAssets(String assetPath) async {
    try {
      final text = await rootBundle.loadString(assetPath);
      final lines = const LineSplitter().convert(text);
      final map = <String, int>{};
      for (var i = 0; i < lines.length; i++) {
        final token = lines[i].trim();
        if (token.isEmpty) continue;
        // Preserve first occurrence.
        map.putIfAbsent(token, () => i);
      }
      if (!map.containsKey('[UNK]')) map['[UNK]'] = 100;
      if (!map.containsKey('[CLS]')) map['[CLS]'] = 101;
      if (!map.containsKey('[SEP]')) map['[SEP]'] = 102;
      return _MiniLmTokenizer(map);
    } catch (_) {
      // Minimal fallback vocabulary.
      return _MiniLmTokenizer({
        '[PAD]': 0,
        '[UNK]': 100,
        '[CLS]': 101,
        '[SEP]': 102,
      });
    }
  }

  List<int> encode(String text, {required int maxLength}) {
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList(growable: false);
    final ids = <int>[clsId];
    for (final w in words) {
      ids.add(_tokenToId[w] ?? unkId);
      if (ids.length >= maxLength - 1) break;
    }
    ids.add(sepId);
    while (ids.length < maxLength) {
      ids.add(0);
    }
    return ids;
  }
}

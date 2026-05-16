import 'dart:typed_data';
import 'dart:math';

import '../../data/repositories/repository_interfaces.dart';

// Lightweight, in-memory embedding index for cosine similarity search.

class EmbeddingEntry {
  final String contentId;
  final int chunkIndex;
  final String chunkText;
  final List<double> embedding;

  EmbeddingEntry({
    required this.contentId,
    required this.chunkIndex,
    required this.chunkText,
    required this.embedding,
  });
}

class EmbeddingSearchResult {
  final String contentId;
  final int chunkIndex;
  final String chunkText;
  final double score;

  const EmbeddingSearchResult({
    required this.contentId,
    required this.chunkIndex,
    required this.chunkText,
    required this.score,
  });
}

class EmbeddingIndex {
  final List<EmbeddingEntry> _entries = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;
  int get size => _entries.length;

  Future<void> load(EmbeddingRepository repo) async {
    final entities = await repo.getAll();
    _entries.clear();
    for (final entity in entities) {
      final embedding = _decodeEmbeddingBytes(entity.embeddingBytes);
      _entries.add(EmbeddingEntry(
        contentId: entity.contentId,
        chunkIndex: entity.chunkIndex,
        chunkText: entity.chunkText,
        embedding: embedding,
      ));
    }
    _loaded = true;
  }

  void addEntry(EmbeddingEntry entry) {
    _entries.add(entry);
  }

  List<EmbeddingSearchResult> search(List<double> queryVector, {int topK = 5}) {
    if (_entries.isEmpty) return const [];
    final results = _entries.map((e) {
      final sim = _cosineSimilarity(e.embedding, queryVector);
      return EmbeddingSearchResult(
        contentId: e.contentId,
        chunkIndex: e.chunkIndex,
        chunkText: e.chunkText,
        score: sim,
      );
    }).toList();
    results.sort((a, b) => b.score.compareTo(a.score));
    return results.take(topK).toList(growable: false);
  }

  void invalidate() {
    _entries.clear();
    _loaded = false;
  }

  Future<void> rebuild(EmbeddingRepository repo) async {
    invalidate();
    await load(repo);
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    double dot = 0.0;
    double na = 0.0;
    double nb = 0.0;
    final n = min(a.length, b.length);
    for (int i = 0; i < n; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }
    final naSqrt = sqrt(na);
    final nbSqrt = sqrt(nb);
    if (naSqrt == 0 || nbSqrt == 0) return 0.0;
    return dot / (naSqrt * nbSqrt);
  }

  List<double> _decodeEmbeddingBytes(List<int> bytes) {
    final int len = (bytes.length / 4).floor();
    final floats = List<double>.filled(len, 0.0);
    final bd = ByteData.view(Uint8List.fromList(bytes).buffer);
    for (int i = 0; i < len; i++) {
      floats[i] = bd.getFloat32(i * 4, Endian.little);
    }
    return floats;
  }
}

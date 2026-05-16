import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learngrid/ai/nlp/embedding_index.dart';
import 'package:learngrid/ai/nlp/embedding_service.dart';
import 'package:learngrid/data/database/app_database.dart';
import 'package:learngrid/data/models/entities.dart';
import 'package:learngrid/data/repositories/drift/drift_repositories.dart';
import 'package:learngrid/ai/runtime/onnx_inference_service.dart';

// MockOnnxInferenceService always throws so EmbeddingService falls back
// to its deterministic SHA-256-seeded vector.
class _MockOnnx implements OnnxInferenceService {
  @override
  Future<void> load() async {}

  @override
  void dispose() {}

  @override
  Future<Map<String, Object?>> run({
    required Map<String, Object?> inputs,
    required List<String> outputNames,
  }) async {
    throw Exception('Simulated ONNX unavailable — use fallback');
  }
}

/// Encodes a List<double> as little-endian Float32 bytes (matches EmbeddingService).
List<int> _encodeVector(List<double> v) {
  final floatList = Float32List.fromList(v);
  final bytes = Uint8List(floatList.lengthInBytes);
  final bd = ByteData.view(bytes.buffer);
  for (var i = 0; i < floatList.length; i++) {
    bd.setFloat32(i * 4, floatList[i], Endian.little);
  }
  return bytes;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DriftEmbeddingRepository embeddingRepo;
  late EmbeddingService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    embeddingRepo = DriftEmbeddingRepository(db);
    service = EmbeddingService(
      embeddings: embeddingRepo,
      onnx: _MockOnnx(),
    );
  });

  tearDown(() async {
    await db.close();
  });

  // ── EmbeddingService tests ─────────────────────────────────────────────────

  group('EmbeddingService', () {
    test('embed() returns a list with length 384', () async {
      final vector = await service.embed('photosynthesis');
      expect(vector, isA<List<double>>());
      expect(vector.length, 384);
    });

    test('embed() returns different vectors for different inputs', () async {
      final v1 = await service.embed('photosynthesis');
      final v2 = await service.embed('mitochondria');
      // Two distinct texts should produce different vectors.
      final allEqual = v1.length == v2.length &&
          List.generate(v1.length, (i) => v1[i] == v2[i]).every((b) => b);
      expect(allEqual, isFalse);
    });

    test('embed() with empty string does not throw', () async {
      final vector = await service.embed('');
      expect(vector, isA<List<double>>());
      expect(vector.length, 384);
    });

    test('semanticSearch() returns results sorted by score descending', () async {
      final appleVec = await service.embed('Apple');
      final bananaVec = await service.embed('Banana');
      final catVec = await service.embed('Cat');

      // Insert content items first to satisfy FK constraints.
      final now = DateTime.now().millisecondsSinceEpoch;
      for (final cid in ['c1', 'c2', 'c3']) {
        await db.into(db.contentItems).insert(
          ContentItemsCompanion.insert(
            id: cid,
            title: cid,
            type: 'text',
            filePath: '/test/$cid.txt',
            addedAt: now,
          ),
        );
      }

      final embeddingEntities = [
        EmbeddingEntity(
          id: '1',
          contentId: 'c1',
          chunkIndex: 0,
          chunkText: 'Cat',
          embeddingBytes: _encodeVector(catVec),
          model: 'minilm',
        ),
        EmbeddingEntity(
          id: '2',
          contentId: 'c2',
          chunkIndex: 0,
          chunkText: 'Apple',
          embeddingBytes: _encodeVector(appleVec),
          model: 'minilm',
        ),
        EmbeddingEntity(
          id: '3',
          contentId: 'c3',
          chunkIndex: 0,
          chunkText: 'Banana',
          embeddingBytes: _encodeVector(bananaVec),
          model: 'minilm',
        ),
      ];

      // Insert into DB then rebuild index so semanticSearch() sees them.
      await embeddingRepo.insertBulk(embeddingEntities);
      await service.rebuildIndex();

      // semanticSearch always loads the index from the repo internally.
      final results =
          await service.semanticSearch('Apple', embeddingEntities, topK: 3);

      expect(results.length, 3);
      // Apple-vs-Apple should be the top hit (cosine ≈ 1.0).
      expect(results.first.contentId, 'c2');
      // Scores must be sorted descending.
      for (var i = 0; i < results.length - 1; i++) {
        expect(results[i].similarity,
            greaterThanOrEqualTo(results[i + 1].similarity));
      }
    });

    test('semanticSearch() returns empty list when no embeddings exist', () async {
      final results = await service.semanticSearch('any query', [], topK: 5);
      expect(results, isEmpty);
    });
  });

  // ── EmbeddingIndex tests ───────────────────────────────────────────────────

  group('EmbeddingIndex', () {
    test('starts with isLoaded == false', () {
      final index = EmbeddingIndex();
      expect(index.isLoaded, isFalse);
    });

    test('load() sets isLoaded to true and populates size', () async {
      final index = EmbeddingIndex();
      // Insert one embedding first.
      await embeddingRepo.insert(EmbeddingEntity(
        id: 'e1',
        contentId: 'c1',
        chunkIndex: 0,
        chunkText: 'hello',
        embeddingBytes: _encodeVector(List.filled(384, 0.0)),
        model: 'minilm',
      ));
      await index.load(embeddingRepo);
      expect(index.isLoaded, isTrue);
      expect(index.size, 1);
    });

    test('invalidate() resets isLoaded to false and size to 0', () async {
      final index = EmbeddingIndex();
      await index.load(embeddingRepo);
      index.invalidate();
      expect(index.isLoaded, isFalse);
      expect(index.size, 0);
    });

    test('search() returns at most topK results', () {
      final index = EmbeddingIndex();
      for (var i = 0; i < 10; i++) {
        index.addEntry(EmbeddingEntry(
          contentId: 'c$i',
          chunkIndex: 0,
          chunkText: 'text $i',
          embedding: List.filled(4, i.toDouble()),
        ));
      }
      final results = index.search(List.filled(4, 1.0), topK: 3);
      expect(results.length, 3);
    });

    test('search() on empty index returns empty list', () {
      final index = EmbeddingIndex();
      final results = index.search(List.filled(384, 0.5), topK: 5);
      expect(results, isEmpty);
    });
  });
}

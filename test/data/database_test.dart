import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learngrid/data/database/app_database.dart';
import 'package:learngrid/data/models/entities.dart';
import 'package:learngrid/data/repositories/drift/drift_repositories.dart';

void main() {
  late AppDatabase db;
  late DriftUserRepository userRepo;
  late DriftContentRepository contentRepo;
  late DriftEmbeddingRepository embeddingRepo;
  late DriftProgressRepository progressRepo;
  late DriftCacheRepository cacheRepo;
  late DriftLeaderboardRepository leaderboardRepo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    userRepo = DriftUserRepository(db);
    contentRepo = DriftContentRepository(db);
    embeddingRepo = DriftEmbeddingRepository(db);
    progressRepo = DriftProgressRepository(db);
    cacheRepo = DriftCacheRepository(db);
    leaderboardRepo = DriftLeaderboardRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  // ── ContentRepository ──────────────────────────────────────────────────────

  group('ContentRepository (in-memory)', () {
    ContentItemEntity makeItem(String id, String title) => ContentItemEntity(
          id: id,
          title: title,
          type: 'text',
          filePath: '/test/$id.txt',
          difficultyLevel: 1,
          topicTags: null,
          subject: 'math',
          language: 'en',
          fileSize: 1024,
          addedAt: DateTime.now().millisecondsSinceEpoch,
        );

    test('insert then getById returns the same item', () async {
      await contentRepo.insert(makeItem('c1', 'Math Notes'));
      final fetched = await contentRepo.getById('c1');
      expect(fetched, isNotNull);
      expect(fetched!.id, 'c1');
      expect(fetched.title, 'Math Notes');
    });

    test('getAll returns all inserted items', () async {
      await contentRepo.insertBulk([
        makeItem('c1', 'Item A'),
        makeItem('c2', 'Item B'),
        makeItem('c3', 'Item C'),
      ]);
      final all = await contentRepo.getAllContent();
      expect(all.length, 3);
    });

    test('delete removes the item', () async {
      await contentRepo.insert(makeItem('c1', 'Delete me'));
      await contentRepo.delete('c1');
      final fetched = await contentRepo.getById('c1');
      expect(fetched, isNull);
    });

    test('update changes the field value', () async {
      await contentRepo.insert(makeItem('c1', 'Original Title'));
      final updated = ContentItemEntity(
        id: 'c1',
        title: 'Updated Title',
        type: 'text',
        filePath: '/test/c1.txt',
        difficultyLevel: 2,
        topicTags: null,
        subject: 'science',
        language: 'en',
        fileSize: 2048,
        addedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await contentRepo.update(updated);
      final fetched = await contentRepo.getById('c1');
      expect(fetched!.title, 'Updated Title');
      expect(fetched.difficultyLevel, 2);
    });
  });

  // ── AIResponseCache ────────────────────────────────────────────────────────

  group('AIResponseCache (in-memory)', () {
    test('getByKey returns null for expired entry', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final expired = AIResponseCacheEntity(
        id: 'id2',
        cacheKey: 'k_expired',
        responseJson: 'Stale response',
        source: 'cloud',
        model: 'gemini',
        createdAt: now - const Duration(hours: 2).inMilliseconds,
        expiresAt: now - const Duration(hours: 1).inMilliseconds, // past
      );
      await cacheRepo.set(expired);
      final result = await cacheRepo.get('k_expired');
      // DriftCacheRepository.get() filters by expiresAt > now.
      expect(result, isNull);
    });

    test('getByKey returns entry for non-expired entry', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final valid = AIResponseCacheEntity(
        id: 'id1',
        cacheKey: 'k_valid',
        responseJson: 'Fresh response',
        source: 'cloud',
        model: 'groq',
        createdAt: now,
        expiresAt: now + const Duration(hours: 1).inMilliseconds, // future
      );
      await cacheRepo.set(valid);
      final result = await cacheRepo.get('k_valid');
      expect(result, isNotNull);
      expect(result!.responseJson, 'Fresh response');
    });

    test('clear() removes all cache entries', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await cacheRepo.set(AIResponseCacheEntity(
        id: 'a',
        cacheKey: 'k1',
        responseJson: 'r1',
        source: 'offline',
        createdAt: now,
        expiresAt: now + 3600000,
      ));
      await cacheRepo.set(AIResponseCacheEntity(
        id: 'b',
        cacheKey: 'k2',
        responseJson: 'r2',
        source: 'offline',
        createdAt: now,
        expiresAt: now + 3600000,
      ));
      await cacheRepo.clearAll();
      final count = await cacheRepo.count();
      expect(count, 0);
    });
  });

  // ── Other repositories (smoke tests) ──────────────────────────────────────

  test('User upsert then getById returns entity', () async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await userRepo.upsert(UserEntity(
      id: 'u1',
      deviceId: 'device-1',
      createdAt: now,
      consentOnline: false,
    ));
    final fetched = await userRepo.getById('u1');
    expect(fetched?.deviceId, 'device-1');
  });

  test('Embedding insertBulk then getByContent returns correct count', () async {
    final bytes = List<int>.filled(16, 0); // 4 floats of zeros
    await embeddingRepo.insertBulk([
      EmbeddingEntity(
        id: 'e1',
        contentId: 'c1',
        chunkIndex: 0,
        chunkText: 'Chunk A',
        embeddingBytes: bytes,
        model: 'minilm',
      ),
      EmbeddingEntity(
        id: 'e2',
        contentId: 'c1',
        chunkIndex: 1,
        chunkText: 'Chunk B',
        embeddingBytes: bytes,
        model: 'minilm',
      ),
    ]);
    final list = await embeddingRepo.getByContent('c1');
    expect(list.length, 2);
  });

  test('Progress upsert then get returns entity with correct completionPct', () async {
    await progressRepo.upsert(UserProgressEntity(
      id: 'p1',
      userId: 'u1',
      contentId: 'c1',
      completionPct: 0.75,
      lastAccessedAt: DateTime.now().millisecondsSinceEpoch,
      timeSpentSeconds: 300,
    ));
    final fetched = await progressRepo.get('u1', 'c1');
    expect(fetched?.completionPct, 0.75);
  });

  test('Leaderboard update then getTop returns entry', () async {
    await leaderboardRepo.update(LeaderboardEntryEntity(
      id: 'l1',
      userId: 'u1',
      displayName: 'Alice',
      totalPoints: 200,
      weeklyPoints: 75,
      streakDays: 5,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    ));
    final top = await leaderboardRepo.getTop(limit: 10);
    expect(top.length, 1);
    expect(top.first.displayName, 'Alice');
  });
}

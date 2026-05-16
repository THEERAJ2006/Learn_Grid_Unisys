import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/entities.dart' as entities;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Users,
    ContentItems,
    Transcripts,
    ImageInsights,
    Embeddings,
    EngagementSessions,
    UserProgress,
    AIResponseCache,
    LeaderboardEntries,
    PeerDevices,
    ChatSessions,
    ChatMessages,
    ManagedFiles,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Named constructor for unit tests — accepts any [QueryExecutor]
  /// (typically [NativeDatabase.memory()]).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await customStatement('''
          CREATE TABLE IF NOT EXISTS chat_sessions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            linked_file_ids TEXT NOT NULL DEFAULT '[]'
          );
        ''');
        await customStatement('''
          CREATE TABLE IF NOT EXISTS chat_messages (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER NOT NULL,
            role TEXT NOT NULL,
            content TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            source_chunk_id TEXT NULL
          );
        ''');
        await customStatement('''
          CREATE TABLE IF NOT EXISTS managed_files (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            file_type TEXT NOT NULL,
            local_path TEXT NOT NULL,
            size_bytes INTEGER NOT NULL,
            uploaded_at INTEGER NOT NULL,
            extracted_text_preview TEXT NULL,
            thumbnail_path TEXT NULL,
            embedding_count INTEGER NOT NULL DEFAULT 0
          );
        ''');
        // Performance-critical indexes (STEP 10 — DATABASE).
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_content_items_type ON content_items(type);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_content_items_subject ON content_items(subject);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_engagement_sessions_user_id ON engagement_sessions(user_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_embeddings_content_id ON embeddings(content_id);',
        );
        // STEP 10E: Additional indexes for query performance
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_user_progress_user_id ON user_progress(user_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_user_progress_content_id ON user_progress(content_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_image_insights_content_id ON image_insights(content_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_transcripts_video_id ON transcripts(video_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_a_i_response_cache_cache_key ON a_i_response_cache(cache_key);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_a_i_response_cache_expires_at ON a_i_response_cache(expires_at);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_peer_devices_last_seen ON peer_devices(last_seen_at);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_chat_messages_session ON chat_messages(session_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_chat_sessions_updated ON chat_sessions(updated_at DESC);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_managed_files_type ON managed_files(file_type);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_managed_files_uploaded ON managed_files(uploaded_at DESC);',
        );
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          // Version 1 to 2 migration: adding new tables and corresponding indexes
          await m.createTable(embeddings);
          await m.createTable(aIResponseCache);
          await m.createTable(peerDevices);
          
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_embeddings_content_id ON embeddings(content_id);',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_a_i_response_cache_cache_key ON a_i_response_cache(cache_key);',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_a_i_response_cache_expires_at ON a_i_response_cache(expires_at);',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_peer_devices_last_seen ON peer_devices(last_seen_at);',
          );
        }

        if (from < 3) {
          await customStatement('''
            CREATE TABLE IF NOT EXISTS chat_sessions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              created_at INTEGER NOT NULL,
              updated_at INTEGER NOT NULL,
              linked_file_ids TEXT NOT NULL DEFAULT '[]'
            );
          ''');
          await customStatement('''
            CREATE TABLE IF NOT EXISTS chat_messages (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              session_id INTEGER NOT NULL,
              role TEXT NOT NULL,
              content TEXT NOT NULL,
              timestamp INTEGER NOT NULL,
              source_chunk_id TEXT NULL
            );
          ''');
          await customStatement('''
            CREATE TABLE IF NOT EXISTS managed_files (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT NOT NULL,
              file_type TEXT NOT NULL,
              local_path TEXT NOT NULL,
              size_bytes INTEGER NOT NULL,
              uploaded_at INTEGER NOT NULL,
              extracted_text_preview TEXT NULL,
              thumbnail_path TEXT NULL,
              embedding_count INTEGER NOT NULL DEFAULT 0
            );
          ''');
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_chat_messages_session ON chat_messages(session_id);',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_chat_sessions_updated ON chat_sessions(updated_at DESC);',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_managed_files_type ON managed_files(file_type);',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_managed_files_uploaded ON managed_files(uploaded_at DESC);',
          );
        }

        // Ensure performance indexes always exist after upgrades.
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_content_items_type ON content_items(type);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_content_items_subject ON content_items(subject);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_engagement_sessions_user_id ON engagement_sessions(user_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_embeddings_content_id ON embeddings(content_id);',
        );
        // STEP 10E: Additional indexes for query performance
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_user_progress_user_id ON user_progress(user_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_user_progress_content_id ON user_progress(content_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_image_insights_content_id ON image_insights(content_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_transcripts_video_id ON transcripts(video_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_a_i_response_cache_cache_key ON a_i_response_cache(cache_key);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_a_i_response_cache_expires_at ON a_i_response_cache(expires_at);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_peer_devices_last_seen ON peer_devices(last_seen_at);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_chat_messages_session ON chat_messages(session_id);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_chat_sessions_updated ON chat_sessions(updated_at DESC);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_managed_files_type ON managed_files(file_type);',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_managed_files_uploaded ON managed_files(uploaded_at DESC);',
        );
      },
    );
  }

  // ========================================================================
  // User Methods
  // ========================================================================

  Future<User?> getUserById(String id) async {
    return (select(users)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertUser(User user) async {
    await into(users).insertOnConflictUpdate(user);
  }

  // ========================================================================
  // Content Methods
  // ========================================================================

  Future<List<ContentItem>> getAllContent() async {
    return select(contentItems).get();
  }

  Future<List<ContentItem>> getContentByType(String type) async {
    return (select(contentItems)..where((tbl) => tbl.type.equals(type))).get();
  }

  Future<List<ContentItem>> getContentBySubject(String subject) async {
    return (select(contentItems)..where((tbl) => tbl.subject.equals(subject))).get();
  }

  Future<ContentItem?> getContentById(String id) async {
    return (select(contentItems)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();
  }

  Future<void> insertContent(ContentItem item) async {
    await into(contentItems).insert(item);
  }

  Future<void> updateContent(ContentItem item) async {
    await update(contentItems).replace(item);
  }

  Future<void> deleteContent(String id) async {
    await (delete(contentItems)..where((tbl) => tbl.id.equals(id))).go();
  }

  // ========================================================================
  // Transcript Methods
  // ========================================================================

  Future<List<Transcript>> getTranscriptsByVideo(String videoId) async {
    return (select(transcripts)..where((tbl) => tbl.videoId.equals(videoId)))
        .get();
  }

  Future<void> insertTranscript(Transcript transcript) async {
    await into(transcripts).insert(transcript);
  }

  Future<void> insertTranscripts(List<Transcript> transcripts) async {
    await batch((batch) {
      batch.insertAll(this.transcripts, transcripts);
    });
  }

  // ========================================================================
  // Image Insights Methods
  // ========================================================================

  Future<ImageInsight?> getImageInsightsByContent(String contentId) async {
    return (select(imageInsights)..where((tbl) => tbl.contentId.equals(contentId)))
        .getSingleOrNull();
  }

  Future<void> insertImageInsight(ImageInsight insight) async {
    await into(imageInsights).insert(insight);
  }

  Future<void> updateImageInsight(ImageInsight insight) async {
    await update(imageInsights).replace(insight);
  }

  // ========================================================================
  // Embedding Methods
  // ========================================================================

  Future<List<Embedding>> getEmbeddingsByContent(String contentId) async {
    return (select(embeddings)..where((tbl) => tbl.contentId.equals(contentId)))
        .get();
  }

  Future<void> insertEmbedding(Embedding embedding) async {
    await into(embeddings).insert(embedding);
  }

  Future<void> insertEmbeddings(List<Embedding> embeddings) async {
    await batch((batch) {
      batch.insertAll(this.embeddings, embeddings);
    });
  }

  // ========================================================================
  // Engagement Methods
  // ========================================================================

  Future<List<EngagementSession>> getEngagementByUser(String userId) async {
    return (select(engagementSessions)..where((tbl) => tbl.userId.equals(userId)))
        .get();
  }

  Future<void> insertEngagementSession(EngagementSession session) async {
    await into(engagementSessions).insert(session);
  }

  // ========================================================================
  // Progress Methods
  // ========================================================================

  Future<UserProgressData?> getUserProgress(String userId, String contentId) async {
    return (select(userProgress)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) & tbl.contentId.equals(contentId),
          ))
        .getSingleOrNull();
  }

  Future<List<UserProgressData>> getAllUserProgress(String userId) async {
    return (select(userProgress)..where((tbl) => tbl.userId.equals(userId))).get();
  }

  Future<void> upsertUserProgress(UserProgressData progress) async {
    await into(userProgress).insertOnConflictUpdate(progress);
  }

  // ========================================================================
  // Cache Methods
  // ========================================================================

  Future<AIResponseCacheData?> getCacheEntry(String key) async {
    return (select(aIResponseCache)
          ..where((tbl) => tbl.cacheKey.equals(key)))
        .getSingleOrNull();
  }

  Future<void> setCacheEntry(AIResponseCacheData entry) async {
    await into(aIResponseCache).insertOnConflictUpdate(entry);
  }

  Future<void> clearExpiredCache() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (delete(aIResponseCache)..where((tbl) => tbl.expiresAt.isSmallerThanValue(now)))
        .go();
  }

  // ========================================================================
  // Leaderboard Methods
  // ========================================================================

  Future<List<LeaderboardEntry>> getTopLeaderboard({int limit = 10}) async {
    return (select(leaderboardEntries)
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.totalPoints)])
          ..limit(limit))
        .get();
  }

  Future<LeaderboardEntry?> getUserLeaderboardEntry(String userId) async {
    return (select(leaderboardEntries)..where((tbl) => tbl.userId.equals(userId)))
        .getSingleOrNull();
  }

  Future<void> updateLeaderboardEntry(LeaderboardEntry entry) async {
    // Upsert so new users appear on the board without a prior insert.
    await into(leaderboardEntries).insertOnConflictUpdate(entry);
  }

  // ========================================================================
  // Chat Methods
  // ========================================================================

  Future<entities.ChatSessionEntity?> getChatSessionById(int id) async {
    final row = await customSelect(
      'SELECT id, name, created_at, updated_at, linked_file_ids FROM chat_sessions WHERE id = ? LIMIT 1',
      variables: [Variable<int>(id)],
    ).getSingleOrNull();
    if (row == null) return null;
    return entities.ChatSessionEntity(
      id: row.read<int>('id'),
      name: row.read<String>('name'),
      createdAt: row.read<int>('created_at'),
      updatedAt: row.read<int>('updated_at'),
      linkedFileIds: row.read<String>('linked_file_ids'),
    );
  }

  Future<void> updateChatSessionTouched(int id) async {
    await customStatement(
      'UPDATE chat_sessions SET updated_at = ${DateTime.now().millisecondsSinceEpoch} WHERE id = $id',
    );
  }

  // ========================================================================
  // File Methods
  // ========================================================================

  Future<entities.ManagedFileEntity?> getFileById(int id) async {
    final row = await customSelect(
      'SELECT id, name, file_type, local_path, size_bytes, uploaded_at, extracted_text_preview, thumbnail_path, embedding_count FROM managed_files WHERE id = ? LIMIT 1',
      variables: [Variable<int>(id)],
    ).getSingleOrNull();
    if (row == null) return null;
    return entities.ManagedFileEntity(
      id: row.read<int>('id'),
      name: row.read<String>('name'),
      fileType: row.read<String>('file_type'),
      localPath: row.read<String>('local_path'),
      sizeBytes: row.read<int>('size_bytes'),
      uploadedAt: row.read<int>('uploaded_at'),
      extractedTextPreview: row.readNullable<String>('extracted_text_preview'),
      thumbnailPath: row.readNullable<String>('thumbnail_path'),
      embeddingCount: row.read<int>('embedding_count'),
    );
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'learngrid',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../database/app_database.dart';
import '../../models/entities.dart';
import '../repository_interfaces.dart';
import 'drift_mappers.dart';

class DriftContentRepository implements ContentRepository {
  final AppDatabase db;

  DriftContentRepository(this.db);

  @override
  Future<void> delete(String id) => db.deleteContent(id);

  @override
  Future<List<ContentItemEntity>> getAllContent() async {
    final rows = await db.getAllContent();
    return rows.map(toContentItemEntity).toList(growable: false);
  }

  @override
  Future<ContentItemEntity?> getById(String id) async {
    final row = await db.getContentById(id);
    return row == null ? null : toContentItemEntity(row);
  }

  @override
  Future<List<ContentItemEntity>> getBySubject(String subject) async {
    final rows = await db.getContentBySubject(subject);
    return rows.map(toContentItemEntity).toList(growable: false);
  }

  @override
  Future<List<ContentItemEntity>> getByType(String type) async {
    final rows = await db.getContentByType(type);
    return rows.map(toContentItemEntity).toList(growable: false);
  }

  @override
  Future<void> insert(ContentItemEntity item) => db.insertContent(toContentItemRow(item));

  @override
  Future<void> insertBulk(List<ContentItemEntity> items) async {
    await db.transaction(() async {
      for (final item in items) {
        await insert(item);
      }
    });
  }

  @override
  Future<void> update(ContentItemEntity item) => db.updateContent(toContentItemRow(item));
}

class DriftUserRepository implements UserRepository {
  final AppDatabase db;
  DriftUserRepository(this.db);

  @override
  Future<void> delete(String id) async {
    await (db.delete(db.users)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<UserEntity?> getById(String id) async {
    final row = await db.getUserById(id);
    return row == null ? null : toUserEntity(row);
  }

  @override
  Future<void> upsert(UserEntity user) => db.upsertUser(toUserRow(user));
}

class DriftEngagementRepository implements EngagementRepository {
  final AppDatabase db;
  DriftEngagementRepository(this.db);

  @override
  Future<List<EngagementSessionEntity>> getRecentSessions(
    String userId, {
    int hours = 24,
  }) async {
    final cutoff = DateTime.now().subtract(Duration(hours: hours)).millisecondsSinceEpoch;
    final rows = await (db.select(db.engagementSessions)
          ..where((t) => t.userId.equals(userId) & t.startedAt.isBiggerOrEqualValue(cutoff))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
        .get();

    return rows.map(toEngagementSessionEntity).toList(growable: false);
  }

  @override
  Future<List<EngagementSessionEntity>> getUserSessions(String userId) async {
    final rows = await db.getEngagementByUser(userId);
    return rows.map(toEngagementSessionEntity).toList(growable: false);
  }

  @override
  Future<void> recordSession(EngagementSessionEntity session) =>
      db.insertEngagementSession(toEngagementSessionRow(session));
}

class DriftProgressRepository implements ProgressRepository {
  final AppDatabase db;
  DriftProgressRepository(this.db);

  @override
  Future<UserProgressEntity?> get(String userId, String contentId) async {
    final row = await db.getUserProgress(userId, contentId);
    return row == null ? null : toUserProgressEntity(row);
  }

  @override
  Future<List<UserProgressEntity>> getAllByUser(String userId) async {
    final rows = await db.getAllUserProgress(userId);
    return rows.map(toUserProgressEntity).toList(growable: false);
  }

  @override
  Future<void> upsert(UserProgressEntity progress) =>
      db.upsertUserProgress(toUserProgressRow(progress));
}

class DriftTranscriptRepository implements TranscriptRepository {
  final AppDatabase db;
  DriftTranscriptRepository(this.db);

  @override
  Future<List<TranscriptEntity>> getByVideoId(String videoId) async {
    final rows = await db.getTranscriptsByVideo(videoId);
    return rows.map(toTranscriptEntity).toList(growable: false);
  }

  @override
  Future<void> insert(TranscriptEntity transcript) => db.insertTranscript(toTranscriptRow(transcript));

  @override
  Future<void> insertBulk(List<TranscriptEntity> transcripts) async {
    await db.insertTranscripts(transcripts.map(toTranscriptRow).toList(growable: false));
  }

  @override
  Future<void> deleteByVideoId(String videoId) async {
    await (db.delete(db.transcripts)..where((t) => t.videoId.equals(videoId))).go();
  }
}

class DriftImageInsightsRepository implements ImageInsightsRepository {
  final AppDatabase db;
  DriftImageInsightsRepository(this.db);

  @override
  Future<ImageInsightEntity?> getByContentId(String contentId) async {
    final row = await db.getImageInsightsByContent(contentId);
    return row == null ? null : toImageInsightEntity(row);
  }

  @override
  Future<void> upsert(ImageInsightEntity insight) async {
    await db.into(db.imageInsights).insertOnConflictUpdate(toImageInsightRow(insight));
  }

  @override
  Future<void> deleteByContentId(String contentId) async {
    await (db.delete(db.imageInsights)..where((t) => t.contentId.equals(contentId))).go();
  }
}

class DriftEmbeddingRepository implements EmbeddingRepository {
  final AppDatabase db;
  DriftEmbeddingRepository(this.db);

  @override
  Future<List<EmbeddingEntity>> getByContent(String contentId) async {
    final rows = await db.getEmbeddingsByContent(contentId);
    return rows.map(toEmbeddingEntity).toList(growable: false);
  }

  @override
  Future<List<EmbeddingEntity>> getAll() async {
    final rows = await db.select(db.embeddings).get();
    return rows.map(toEmbeddingEntity).toList(growable: false);
  }

  @override
  Future<void> insert(EmbeddingEntity embedding) => db.insertEmbedding(toEmbeddingRow(embedding));

  @override
  Future<void> insertBulk(List<EmbeddingEntity> embeddings) async {
    await db.transaction(() async {
      for (final embedding in embeddings) {
        await insert(embedding);
      }
    });
  }

  @override
  Future<void> clearAll() async {
    await db.delete(db.embeddings).go();
  }
}

class DriftCacheRepository implements CacheRepository {
  final AppDatabase db;
  DriftCacheRepository(this.db);

  @override
  Future<void> clearExpired() => db.clearExpiredCache();

  @override
  Future<int> count() async {
    final q = db.selectOnly(db.aIResponseCache)..addColumns([db.aIResponseCache.id.count()]);
    final row = await q.getSingle();
    return row.read(db.aIResponseCache.id.count()) ?? 0;
  }

  @override
  Future<void> clearAll() async {
    await db.delete(db.aIResponseCache).go();
  }

  @override
  Future<AIResponseCacheEntity?> get(String key) async {
    final row = await db.getCacheEntry(key);
    if (row == null) return null;
    final entity = toAIResponseCacheEntity(row);
    final now = DateTime.now().millisecondsSinceEpoch;
    if (entity.expiresAt <= now) return null;
    return entity;
  }

  @override
  Future<void> set(AIResponseCacheEntity entry) => db.setCacheEntry(toAIResponseCacheRow(entry));
}

class DriftLeaderboardRepository implements LeaderboardRepository {
  final AppDatabase db;
  DriftLeaderboardRepository(this.db);

  @override
  Future<LeaderboardEntryEntity?> getByUser(String userId) async {
    final row = await db.getUserLeaderboardEntry(userId);
    return row == null ? null : toLeaderboardEntryEntity(row);
  }

  @override
  Future<List<LeaderboardEntryEntity>> getTop({int limit = 10}) async {
    final rows = await db.getTopLeaderboard(limit: limit);
    return rows.map(toLeaderboardEntryEntity).toList(growable: false);
  }

  @override
  Future<void> update(LeaderboardEntryEntity entry) => db.updateLeaderboardEntry(toLeaderboardEntryRow(entry));
}

class DriftChatRepository implements ChatRepository {
  final AppDatabase db;
  DriftChatRepository(this.db);

  List<int> _decodeIds(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded.map((e) => int.tryParse('$e') ?? 0).where((e) => e > 0).toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<ChatSessionEntity> createSession(String name, List<int> fileIds) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final encoded = jsonEncode(fileIds);
    final id = await db.customInsert(
      '''
      INSERT INTO chat_sessions(name, created_at, updated_at, linked_file_ids)
      VALUES (?, ?, ?, ?)
      ''',
      variables: [
        Variable<String>(name),
        Variable<int>(now),
        Variable<int>(now),
        Variable<String>(encoded),
      ],
    );
    return ChatSessionEntity(
      id: id,
      name: name,
      createdAt: now,
      updatedAt: now,
      linkedFileIds: encoded,
    );
  }

  @override
  Future<void> clearSession(int sessionId) async {
    await db.transaction(() async {
      await db.customStatement('DELETE FROM chat_messages WHERE session_id = $sessionId');
      await db.customStatement('DELETE FROM chat_sessions WHERE id = $sessionId');
    });
  }

  @override
  Future<void> deleteSession(int id) => clearSession(id);

  @override
  Future<List<ChatMessageEntity>> getMessages(int sessionId) async {
    final rows = await db.customSelect(
      '''
      SELECT id, session_id, role, content, timestamp, source_chunk_id
      FROM chat_messages
      WHERE session_id = ?
      ORDER BY timestamp ASC
      ''',
      variables: [Variable<int>(sessionId)],
    ).get();
    return rows
        .map(
          (row) => ChatMessageEntity(
            id: row.read<int>('id'),
            sessionId: row.read<int>('session_id'),
            role: row.read<String>('role'),
            content: row.read<String>('content'),
            timestamp: row.read<int>('timestamp'),
            sourceChunkId: row.read<String?>('source_chunk_id'),
          ),
        )
        .toList(growable: false);
  }

  @override
  Stream<List<ChatMessageEntity>> watchMessages(int sessionId) {
    return db
        .customSelect(
          '''
          SELECT id, session_id, role, content, timestamp, source_chunk_id
          FROM chat_messages
          WHERE session_id = ?
          ORDER BY timestamp ASC
          ''',
          variables: [Variable<int>(sessionId)],
          readsFrom: {db.chatMessages},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => ChatMessageEntity(
                  id: row.read<int>('id'),
                  sessionId: row.read<int>('session_id'),
                  role: row.read<String>('role'),
                  content: row.read<String>('content'),
                  timestamp: row.read<int>('timestamp'),
                  sourceChunkId: row.read<String?>('source_chunk_id'),
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Future<List<ChatSessionEntity>> getAllSessions() async {
    final rows = await db.customSelect(
      '''
      SELECT id, name, created_at, updated_at, linked_file_ids
      FROM chat_sessions
      ORDER BY updated_at DESC
      ''',
    ).get();
    return rows
        .map(
          (row) => ChatSessionEntity(
            id: row.read<int>('id'),
            name: row.read<String>('name'),
            createdAt: row.read<int>('created_at'),
            updatedAt: row.read<int>('updated_at'),
            linkedFileIds: row.read<String>('linked_file_ids'),
          ),
        )
        .toList(growable: false);
  }

  @override
  Stream<List<ChatSessionEntity>> watchAllSessions() {
    return db
        .customSelect(
          '''
          SELECT id, name, created_at, updated_at, linked_file_ids
          FROM chat_sessions
          ORDER BY updated_at DESC
          ''',
          readsFrom: {db.chatSessions},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => ChatSessionEntity(
                  id: row.read<int>('id'),
                  name: row.read<String>('name'),
                  createdAt: row.read<int>('created_at'),
                  updatedAt: row.read<int>('updated_at'),
                  linkedFileIds: row.read<String>('linked_file_ids'),
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Future<ChatSessionEntity?> getSessionById(int id) async {
    final rows = await db.customSelect(
      '''
      SELECT id, name, created_at, updated_at, linked_file_ids
      FROM chat_sessions
      WHERE id = ?
      LIMIT 1
      ''',
      variables: [Variable<int>(id)],
    ).get();
    if (rows.isEmpty) return null;
    final row = rows.first;
    return ChatSessionEntity(
      id: row.read<int>('id'),
      name: row.read<String>('name'),
      createdAt: row.read<int>('created_at'),
      updatedAt: row.read<int>('updated_at'),
      linkedFileIds: row.read<String>('linked_file_ids'),
    );
  }

  @override
  Future<ChatMessageEntity> insertMessage(ChatMessageEntity message) async {
    final cols = 'session_id, role, content, timestamp';
    final placeholders = '?, ?, ?, ?';
    final vars = <Variable<Object>>[
      Variable<int>(message.sessionId),
      Variable<String>(message.role),
      Variable<String>(message.content),
      Variable<int>(message.timestamp),
    ];
    final sqlCols = message.sourceChunkId != null ? '$cols, source_chunk_id' : cols;
    final sqlPlaceholders = message.sourceChunkId != null ? '$placeholders, ?' : placeholders;
    if (message.sourceChunkId != null) {
      vars.add(Variable<String>(message.sourceChunkId!));
    }
    final id = await db.customInsert(
      'INSERT INTO chat_messages($sqlCols) VALUES ($sqlPlaceholders)',
      variables: vars,
    );
    await db.updateChatSessionTouched(message.sessionId);
    return ChatMessageEntity(
      id: id,
      sessionId: message.sessionId,
      role: message.role,
      content: message.content,
      timestamp: message.timestamp,
      sourceChunkId: message.sourceChunkId,
    );
  }

  @override
  Future<void> renameSession(int id, String newName) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final safe = newName.replaceAll("'", "''");
    await db.customStatement(
      "UPDATE chat_sessions SET name = '$safe', updated_at = $now WHERE id = $id",
    );
  }

  @override
  Future<void> updateSessionFiles(int sessionId, List<int> fileIds) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final encoded = jsonEncode(fileIds).replaceAll("'", "''");
    await db.customStatement(
      "UPDATE chat_sessions SET linked_file_ids = '$encoded', updated_at = $now WHERE id = $sessionId",
    );
  }
}

class DriftFileManagementRepository implements FileManagementRepository {
  final AppDatabase db;
  DriftFileManagementRepository(this.db);

  @override
  Future<ManagedFileEntity> insertFile(ManagedFileEntity file) async {
    final cols = <String>['name', 'file_type', 'local_path', 'size_bytes', 'uploaded_at', 'embedding_count'];
    final vars = <Variable<Object>>[
      Variable<String>(file.name),
      Variable<String>(file.fileType),
      Variable<String>(file.localPath),
      Variable<int>(file.sizeBytes),
      Variable<int>(file.uploadedAt),
      Variable<int>(file.embeddingCount),
    ];
    if (file.extractedTextPreview != null) {
      cols.insert(5, 'extracted_text_preview');
      vars.insert(5, Variable<String>(file.extractedTextPreview!));
    }
    if (file.thumbnailPath != null) {
      cols.insert(file.extractedTextPreview != null ? 6 : 5, 'thumbnail_path');
      vars.insert(file.extractedTextPreview != null ? 6 : 5, Variable<String>(file.thumbnailPath!));
    }
    final placeholders = List.filled(cols.length, '?').join(', ');
    final id = await db.customInsert(
      'INSERT INTO managed_files(${cols.join(', ')}) VALUES ($placeholders)',
      variables: vars,
    );
    return ManagedFileEntity(
      id: id,
      name: file.name,
      fileType: file.fileType,
      localPath: file.localPath,
      sizeBytes: file.sizeBytes,
      uploadedAt: file.uploadedAt,
      extractedTextPreview: file.extractedTextPreview,
      thumbnailPath: file.thumbnailPath,
      embeddingCount: file.embeddingCount,
    );
  }

  @override
  Future<void> renameFile(int id, String newName) async {
    final safe = newName.replaceAll("'", "''");
    await db.customStatement("UPDATE managed_files SET name = '$safe' WHERE id = $id");
  }

  @override
  Future<void> updateEmbeddingCount(int id, int embeddingCount) async {
    await db.customStatement('UPDATE managed_files SET embedding_count = $embeddingCount WHERE id = $id');
  }

  @override
  Future<ManagedFileEntity?> getFileById(int id) async {
    final rows = await db.customSelect(
      '''
      SELECT id, name, file_type, local_path, size_bytes, uploaded_at, extracted_text_preview, thumbnail_path, embedding_count
      FROM managed_files
      WHERE id = ?
      LIMIT 1
      ''',
      variables: [Variable<int>(id)],
    ).get();
    if (rows.isEmpty) return null;
    final row = rows.first;
    return ManagedFileEntity(
      id: row.read<int>('id'),
      name: row.read<String>('name'),
      fileType: row.read<String>('file_type'),
      localPath: row.read<String>('local_path'),
      sizeBytes: row.read<int>('size_bytes'),
      uploadedAt: row.read<int>('uploaded_at'),
      extractedTextPreview: row.read<String?>('extracted_text_preview'),
      thumbnailPath: row.read<String?>('thumbnail_path'),
      embeddingCount: row.read<int>('embedding_count'),
    );
  }

  @override
  Future<List<ManagedFileEntity>> getAllFiles({String? filterType, String sortBy = 'recent'}) async {
    final where = (filterType != null && filterType != 'all') ? 'WHERE file_type = ?' : '';
    final order = switch (sortBy) {
      'name' => 'ORDER BY name ASC',
      'size' => 'ORDER BY size_bytes DESC',
      _ => 'ORDER BY uploaded_at DESC',
    };
    final sql =
        'SELECT id, name, file_type, local_path, size_bytes, uploaded_at, extracted_text_preview, thumbnail_path, embedding_count FROM managed_files $where $order';
    final rows = await db.customSelect(
      sql,
      variables: filterType != null && filterType != 'all'
          ? [Variable<String>(filterType)]
          : const [],
    ).get();
    return rows
        .map(
          (row) => ManagedFileEntity(
            id: row.read<int>('id'),
            name: row.read<String>('name'),
            fileType: row.read<String>('file_type'),
            localPath: row.read<String>('local_path'),
            sizeBytes: row.read<int>('size_bytes'),
            uploadedAt: row.read<int>('uploaded_at'),
            extractedTextPreview: row.read<String?>('extracted_text_preview'),
            thumbnailPath: row.read<String?>('thumbnail_path'),
            embeddingCount: row.read<int>('embedding_count'),
          ),
        )
        .toList(growable: false);
  }

  @override
  Future<List<ManagedFileEntity>> searchFiles(String query) async {
    final rows = await db.customSelect(
      '''
      SELECT id, name, file_type, local_path, size_bytes, uploaded_at, extracted_text_preview, thumbnail_path, embedding_count
      FROM managed_files
      WHERE name LIKE ? OR extracted_text_preview LIKE ?
      ORDER BY uploaded_at DESC
      ''',
      variables: [
        Variable<String>('%$query%'),
        Variable<String>('%$query%'),
      ],
    ).get();
    return rows
        .map(
          (row) => ManagedFileEntity(
            id: row.read<int>('id'),
            name: row.read<String>('name'),
            fileType: row.read<String>('file_type'),
            localPath: row.read<String>('local_path'),
            sizeBytes: row.read<int>('size_bytes'),
            uploadedAt: row.read<int>('uploaded_at'),
            extractedTextPreview: row.read<String?>('extracted_text_preview'),
            thumbnailPath: row.read<String?>('thumbnail_path'),
            embeddingCount: row.read<int>('embedding_count'),
          ),
        )
        .toList(growable: false);
  }

  @override
  Stream<List<ManagedFileEntity>> watchAllFiles({String? filterType, String sortBy = 'recent'}) {
    final where = (filterType != null && filterType != 'all') ? 'WHERE file_type = ?' : '';
    final order = switch (sortBy) {
      'name' => 'ORDER BY name ASC',
      'size' => 'ORDER BY size_bytes DESC',
      _ => 'ORDER BY uploaded_at DESC',
    };
    final sql =
        'SELECT id, name, file_type, local_path, size_bytes, uploaded_at, extracted_text_preview, thumbnail_path, embedding_count FROM managed_files $where $order';
    return db
        .customSelect(
          sql,
          variables: filterType != null && filterType != 'all'
              ? [Variable<String>(filterType)]
              : const [],
          readsFrom: {db.managedFiles},
        )
        .watch()
        .map(
          (rows) => rows
              .map(
                (row) => ManagedFileEntity(
                  id: row.read<int>('id'),
                  name: row.read<String>('name'),
                  fileType: row.read<String>('file_type'),
                  localPath: row.read<String>('local_path'),
                  sizeBytes: row.read<int>('size_bytes'),
                  uploadedAt: row.read<int>('uploaded_at'),
                  extractedTextPreview: row.read<String?>('extracted_text_preview'),
                  thumbnailPath: row.read<String?>('thumbnail_path'),
                  embeddingCount: row.read<int>('embedding_count'),
                ),
              )
              .toList(growable: false),
        );
  }

  @override
  Future<void> deleteFile(int id) async {
    await db.transaction(() async {
      await db.customStatement("DELETE FROM embeddings WHERE content_id = 'managed_file:$id'");
      final sessions = await db.customSelect('SELECT id, linked_file_ids FROM chat_sessions').get();
      for (final session in sessions) {
        final raw = session.read<String>('linked_file_ids');
        final ids = _decodeIds(raw);
        if (!ids.contains(id)) continue;
        final next = ids.where((v) => v != id).toList(growable: false);
        final sessionId = session.read<int>('id');
        if (next.isEmpty) {
          await db.customStatement('DELETE FROM chat_messages WHERE session_id = $sessionId');
          await db.customStatement('DELETE FROM chat_sessions WHERE id = $sessionId');
        } else {
          final encoded = jsonEncode(next).replaceAll("'", "''");
          final now = DateTime.now().millisecondsSinceEpoch;
          await db.customStatement(
            "UPDATE chat_sessions SET linked_file_ids = '$encoded', updated_at = $now WHERE id = $sessionId",
          );
        }
      }
      await db.customStatement('DELETE FROM managed_files WHERE id = $id');
    });
  }

  List<int> _decodeIds(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded.map((e) => int.tryParse('$e') ?? 0).where((e) => e > 0).toList(growable: false);
    } catch (_) {
      return const [];
    }
  }
}

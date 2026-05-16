// Repository interfaces - backend agnostic
// These allow swapping between SQLite (Drift), Supabase, or MongoDB with no feature code changes

import '../models/entities.dart';

abstract class ContentRepository {
  Future<List<ContentItemEntity>> getAllContent();
  Future<ContentItemEntity?> getById(String id);
  Future<List<ContentItemEntity>> getByType(String type);
  Future<List<ContentItemEntity>> getBySubject(String subject);
  Future<void> insert(ContentItemEntity item);
  Future<void> insertBulk(List<ContentItemEntity> items);
  Future<void> update(ContentItemEntity item);
  Future<void> delete(String id);
}

abstract class UserRepository {
  Future<UserEntity?> getById(String id);
  Future<void> upsert(UserEntity user);
  Future<void> delete(String id);
}

abstract class EngagementRepository {
  Future<void> recordSession(EngagementSessionEntity session);
  Future<List<EngagementSessionEntity>> getUserSessions(String userId);
  Future<List<EngagementSessionEntity>> getRecentSessions(
    String userId, {
    int hours = 24,
  });
}

abstract class ProgressRepository {
  Future<UserProgressEntity?> get(String userId, String contentId);
  Future<List<UserProgressEntity>> getAllByUser(String userId);
  Future<void> upsert(UserProgressEntity progress);
}

abstract class TranscriptRepository {
  Future<List<TranscriptEntity>> getByVideoId(String videoId);
  Future<void> insert(TranscriptEntity transcript);
  Future<void> insertBulk(List<TranscriptEntity> transcripts);
  Future<void> deleteByVideoId(String videoId);
}

abstract class ImageInsightsRepository {
  Future<ImageInsightEntity?> getByContentId(String contentId);
  Future<void> upsert(ImageInsightEntity insight);
  Future<void> deleteByContentId(String contentId);
}

abstract class EmbeddingRepository {
  Future<List<EmbeddingEntity>> getByContent(String contentId);
  Future<List<EmbeddingEntity>> getAll();
  Future<void> insert(EmbeddingEntity embedding);
  Future<void> insertBulk(List<EmbeddingEntity> embeddings);
  Future<void> clearAll();
}

abstract class CacheRepository {
  Future<AIResponseCacheEntity?> get(String key);
  Future<void> set(AIResponseCacheEntity entry);
  Future<void> clearExpired();
  Future<int> count();
  Future<void> clearAll();
}

abstract class LeaderboardRepository {
  Future<List<LeaderboardEntryEntity>> getTop({int limit = 10});
  Future<LeaderboardEntryEntity?> getByUser(String userId);
  Future<void> update(LeaderboardEntryEntity entry);
}

abstract class ChatRepository {
  Future<List<ChatSessionEntity>> getAllSessions();
  Stream<List<ChatSessionEntity>> watchAllSessions();
  Future<ChatSessionEntity> createSession(String name, List<int> fileIds);
  Future<void> renameSession(int id, String newName);
  Future<void> deleteSession(int id);
  Future<List<ChatMessageEntity>> getMessages(int sessionId);
  Stream<List<ChatMessageEntity>> watchMessages(int sessionId);
  Future<ChatMessageEntity> insertMessage(ChatMessageEntity message);
  Future<void> clearSession(int sessionId);
  Future<void> updateSessionFiles(int sessionId, List<int> fileIds);
  Future<ChatSessionEntity?> getSessionById(int id);
}

abstract class FileManagementRepository {
  Future<List<ManagedFileEntity>> getAllFiles({
    String? filterType,
    String sortBy = 'recent',
  });
  Future<List<ManagedFileEntity>> searchFiles(String query);
  Future<ManagedFileEntity> insertFile(ManagedFileEntity file);
  Future<void> renameFile(int id, String newName);
  Future<void> deleteFile(int id);
  Future<ManagedFileEntity?> getFileById(int id);
  Stream<List<ManagedFileEntity>> watchAllFiles({
    String? filterType,
    String sortBy = 'recent',
  });
  Future<void> updateEmbeddingCount(int id, int embeddingCount);
}

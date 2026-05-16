// App-level data models (entities).
//
// Feature code should depend on these models, not on Drift-generated classes,
// so we can swap the persistence layer later (Supabase/MongoDB/etc.).

class UserEntity {
  final String id;
  final String deviceId;
  final int createdAt;
  final String? prefs; // JSON blob
  final bool consentOnline;

  const UserEntity({
    required this.id,
    required this.deviceId,
    required this.createdAt,
    this.prefs,
    required this.consentOnline,
  });
}

class ContentItemEntity {
  final String id;
  final String title;
  final String type; // 'text' | 'video' | 'image' | 'pdf' | 'docx'
  final String filePath;
  final int difficultyLevel;
  final String? topicTags; // JSON array
  final String? subject;
  final String language;
  final int? fileSize;
  final int addedAt;

  const ContentItemEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.filePath,
    required this.difficultyLevel,
    this.topicTags,
    this.subject,
    required this.language,
    this.fileSize,
    required this.addedAt,
  });
}

class TranscriptEntity {
  final String id;
  final String videoId; // references ContentItems(id)
  final String textChunk;
  final double startTime;
  final double endTime;
  final String language;

  const TranscriptEntity({
    required this.id,
    required this.videoId,
    required this.textChunk,
    required this.startTime,
    required this.endTime,
    required this.language,
  });
}

class ImageInsightEntity {
  final String id;
  final String contentId; // references ContentItems(id)
  final String? imageType; // diagram|organ|flowchart|plain|labeled
  final String? caption;
  final String? extractedConcepts; // JSON array of strings
  final String? ocrText;
  final int processedAt;

  const ImageInsightEntity({
    required this.id,
    required this.contentId,
    this.imageType,
    this.caption,
    this.extractedConcepts,
    this.ocrText,
    required this.processedAt,
  });
}

class EngagementSessionEntity {
  final String id;
  final String userId;
  final String contentId;
  final String state; // 'focused' | 'passive' | 'fatigued' | 'absent'
  final int durationSeconds;
  final int tapCount;
  final int scrollEvents;
  final int idleSeconds;
  final int startedAt;

  const EngagementSessionEntity({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.state,
    required this.durationSeconds,
    required this.tapCount,
    required this.scrollEvents,
    required this.idleSeconds,
    required this.startedAt,
  });
}

class UserProgressEntity {
  final String id;
  final String userId;
  final String contentId;
  final double completionPct;
  final int lastAccessedAt;
  final int? difficultyRating; // 1-5
  final int timeSpentSeconds;

  const UserProgressEntity({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.completionPct,
    required this.lastAccessedAt,
    this.difficultyRating,
    required this.timeSpentSeconds,
  });
}

class EmbeddingEntity {
  final String id;
  final String contentId;
  final int chunkIndex;
  final String chunkText;
  final List<int> embeddingBytes; // Float32List encoded as bytes
  final String model;

  const EmbeddingEntity({
    required this.id,
    required this.contentId,
    required this.chunkIndex,
    required this.chunkText,
    required this.embeddingBytes,
    required this.model,
  });
}

class AIResponseCacheEntity {
  final String id;
  final String cacheKey;
  final String responseJson;
  final String source; // 'offline' | 'cloud'
  final String? model;
  final int createdAt;
  final int expiresAt;

  const AIResponseCacheEntity({
    required this.id,
    required this.cacheKey,
    required this.responseJson,
    required this.source,
    this.model,
    required this.createdAt,
    required this.expiresAt,
  });
}

class LeaderboardEntryEntity {
  final String id;
  final String userId;
  final String displayName;
  final int streakDays;
  final int totalPoints;
  final int weeklyPoints;
  final int updatedAt;

  const LeaderboardEntryEntity({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.streakDays,
    required this.totalPoints,
    required this.weeklyPoints,
    required this.updatedAt,
  });
}

class ChatSessionEntity {
  final int id;
  final String name;
  final int createdAt;
  final int updatedAt;
  final String linkedFileIds; // JSON array of ints.

  const ChatSessionEntity({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.linkedFileIds,
  });
}

class ChatMessageEntity {
  final int id;
  final int sessionId;
  final String role; // 'user' | 'assistant' | 'system'
  final String content;
  final int timestamp;
  final String? sourceChunkId;

  const ChatMessageEntity({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.timestamp,
    this.sourceChunkId,
  });
}

class ManagedFileEntity {
  final int id;
  final String name;
  final String fileType; // 'pdf' | 'txt' | 'image'
  final String localPath;
  final int sizeBytes;
  final int uploadedAt;
  final String? extractedTextPreview;
  final String? thumbnailPath;
  final int embeddingCount;

  const ManagedFileEntity({
    required this.id,
    required this.name,
    required this.fileType,
    required this.localPath,
    required this.sizeBytes,
    required this.uploadedAt,
    this.extractedTextPreview,
    this.thumbnailPath,
    required this.embeddingCount,
  });
}



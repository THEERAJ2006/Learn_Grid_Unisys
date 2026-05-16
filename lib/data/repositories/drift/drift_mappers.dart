import 'dart:typed_data';

import '../../database/app_database.dart';
import '../../models/entities.dart';

UserEntity toUserEntity(User row) {
  return UserEntity(
    id: row.id,
    deviceId: row.deviceId,
    createdAt: row.createdAt,
    prefs: row.prefs,
    consentOnline: row.consentOnline,
  );
}

User toUserRow(UserEntity entity) {
  return User(
    id: entity.id,
    deviceId: entity.deviceId,
    createdAt: entity.createdAt,
    prefs: entity.prefs,
    consentOnline: entity.consentOnline,
  );
}

ContentItemEntity toContentItemEntity(ContentItem row) {
  return ContentItemEntity(
    id: row.id,
    title: row.title,
    type: row.type,
    filePath: row.filePath,
    difficultyLevel: row.difficultyLevel,
    topicTags: row.topicTags,
    subject: row.subject,
    language: row.language,
    fileSize: row.fileSize,
    addedAt: row.addedAt,
  );
}

ContentItem toContentItemRow(ContentItemEntity entity) {
  return ContentItem(
    id: entity.id,
    title: entity.title,
    type: entity.type,
    filePath: entity.filePath,
    difficultyLevel: entity.difficultyLevel,
    topicTags: entity.topicTags,
    subject: entity.subject,
    language: entity.language,
    fileSize: entity.fileSize,
    addedAt: entity.addedAt,
  );
}

TranscriptEntity toTranscriptEntity(Transcript row) {
  return TranscriptEntity(
    id: row.id,
    videoId: row.videoId,
    textChunk: row.textChunk,
    startTime: row.startTime,
    endTime: row.endTime,
    language: row.language,
  );
}

Transcript toTranscriptRow(TranscriptEntity entity) {
  return Transcript(
    id: entity.id,
    videoId: entity.videoId,
    textChunk: entity.textChunk,
    startTime: entity.startTime,
    endTime: entity.endTime,
    language: entity.language,
  );
}

ImageInsightEntity toImageInsightEntity(ImageInsight row) {
  return ImageInsightEntity(
    id: row.id,
    contentId: row.contentId,
    imageType: row.imageType,
    caption: row.caption,
    extractedConcepts: row.extractedConcepts,
    ocrText: row.ocrText,
    processedAt: row.processedAt,
  );
}

ImageInsight toImageInsightRow(ImageInsightEntity entity) {
  return ImageInsight(
    id: entity.id,
    contentId: entity.contentId,
    imageType: entity.imageType,
    caption: entity.caption,
    extractedConcepts: entity.extractedConcepts,
    ocrText: entity.ocrText,
    processedAt: entity.processedAt,
  );
}

EngagementSessionEntity toEngagementSessionEntity(EngagementSession row) {
  return EngagementSessionEntity(
    id: row.id,
    userId: row.userId,
    contentId: row.contentId,
    state: row.state,
    durationSeconds: row.durationSeconds,
    tapCount: row.tapCount,
    scrollEvents: row.scrollEvents,
    idleSeconds: row.idleSeconds,
    startedAt: row.startedAt,
  );
}

EngagementSession toEngagementSessionRow(EngagementSessionEntity entity) {
  return EngagementSession(
    id: entity.id,
    userId: entity.userId,
    contentId: entity.contentId,
    state: entity.state,
    durationSeconds: entity.durationSeconds,
    tapCount: entity.tapCount,
    scrollEvents: entity.scrollEvents,
    idleSeconds: entity.idleSeconds,
    startedAt: entity.startedAt,
  );
}

UserProgressEntity toUserProgressEntity(UserProgressData row) {
  return UserProgressEntity(
    id: row.id,
    userId: row.userId,
    contentId: row.contentId,
    completionPct: row.completionPct,
    lastAccessedAt: row.lastAccessedAt,
    difficultyRating: row.difficultyRating,
    timeSpentSeconds: row.timeSpentSeconds,
  );
}

UserProgressData toUserProgressRow(UserProgressEntity entity) {
  return UserProgressData(
    id: entity.id,
    userId: entity.userId,
    contentId: entity.contentId,
    completionPct: entity.completionPct,
    lastAccessedAt: entity.lastAccessedAt,
    difficultyRating: entity.difficultyRating,
    timeSpentSeconds: entity.timeSpentSeconds,
  );
}

EmbeddingEntity toEmbeddingEntity(Embedding row) {
  return EmbeddingEntity(
    id: row.id,
    contentId: row.contentId,
    chunkIndex: row.chunkIndex,
    chunkText: row.chunkText,
    embeddingBytes: row.embedding.toList(growable: false),
    model: row.model,
  );
}

Embedding toEmbeddingRow(EmbeddingEntity entity) {
  return Embedding(
    id: entity.id,
    contentId: entity.contentId,
    chunkIndex: entity.chunkIndex,
    chunkText: entity.chunkText,
    embedding: Uint8List.fromList(entity.embeddingBytes),
    model: entity.model,
  );
}

AIResponseCacheEntity toAIResponseCacheEntity(AIResponseCacheData row) {
  return AIResponseCacheEntity(
    id: row.id,
    cacheKey: row.cacheKey,
    responseJson: row.responseJson,
    source: row.source,
    model: row.model,
    createdAt: row.createdAt,
    expiresAt: row.expiresAt,
  );
}

AIResponseCacheData toAIResponseCacheRow(AIResponseCacheEntity entity) {
  return AIResponseCacheData(
    id: entity.id,
    cacheKey: entity.cacheKey,
    responseJson: entity.responseJson,
    source: entity.source,
    model: entity.model,
    createdAt: entity.createdAt,
    expiresAt: entity.expiresAt,
  );
}

LeaderboardEntryEntity toLeaderboardEntryEntity(LeaderboardEntry row) {
  return LeaderboardEntryEntity(
    id: row.id,
    userId: row.userId,
    displayName: row.displayName,
    streakDays: row.streakDays,
    totalPoints: row.totalPoints,
    weeklyPoints: row.weeklyPoints,
    updatedAt: row.updatedAt,
  );
}

LeaderboardEntry toLeaderboardEntryRow(LeaderboardEntryEntity entity) {
  return LeaderboardEntry(
    id: entity.id,
    userId: entity.userId,
    displayName: entity.displayName,
    streakDays: entity.streakDays,
    totalPoints: entity.totalPoints,
    weeklyPoints: entity.weeklyPoints,
    updatedAt: entity.updatedAt,
  );
}

ChatSessionEntity toChatSessionEntity(ChatSession row) {
  return ChatSessionEntity(
    id: row.id,
    name: row.name,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    linkedFileIds: row.linkedFileIds,
  );
}

ChatSession toChatSessionRow(ChatSessionEntity entity) {
  return ChatSession(
    id: entity.id,
    name: entity.name,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
    linkedFileIds: entity.linkedFileIds,
  );
}

ChatMessageEntity toChatMessageEntity(ChatMessage row) {
  return ChatMessageEntity(
    id: row.id,
    sessionId: row.sessionId,
    role: row.role,
    content: row.content,
    timestamp: row.timestamp,
    sourceChunkId: row.sourceChunkId,
  );
}

ChatMessage toChatMessageRow(ChatMessageEntity entity) {
  return ChatMessage(
    id: entity.id,
    sessionId: entity.sessionId,
    role: entity.role,
    content: entity.content,
    timestamp: entity.timestamp,
    sourceChunkId: entity.sourceChunkId,
  );
}

ManagedFileEntity toManagedFileEntity(ManagedFile row) {
  return ManagedFileEntity(
    id: row.id,
    name: row.name,
    fileType: row.fileType,
    localPath: row.localPath,
    sizeBytes: row.sizeBytes,
    uploadedAt: row.uploadedAt,
    extractedTextPreview: row.extractedTextPreview,
    thumbnailPath: row.thumbnailPath,
    embeddingCount: row.embeddingCount,
  );
}

ManagedFile toManagedFileRow(ManagedFileEntity entity) {
  return ManagedFile(
    id: entity.id,
    name: entity.name,
    fileType: entity.fileType,
    localPath: entity.localPath,
    sizeBytes: entity.sizeBytes,
    uploadedAt: entity.uploadedAt,
    extractedTextPreview: entity.extractedTextPreview,
    thumbnailPath: entity.thumbnailPath,
    embeddingCount: entity.embeddingCount,
  );
}

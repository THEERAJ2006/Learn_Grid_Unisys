import 'package:drift/drift.dart';

// ============================================================================
// TABLE DEFINITIONS
// ============================================================================

class Users extends Table {
  TextColumn get id => text()();
  TextColumn get deviceId => text()();
  IntColumn get createdAt => integer()();
  TextColumn get prefs => text().nullable()(); // JSON blob
  BoolColumn get consentOnline => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

class ContentItems extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get type => text()(); // 'text' | 'video' | 'image' | 'pdf' | 'docx'
  TextColumn get filePath => text()();
  IntColumn get difficultyLevel => integer().withDefault(const Constant(1))();
  TextColumn get topicTags => text().nullable()(); // JSON array
  TextColumn get subject => text().nullable()();
  TextColumn get language => text().withDefault(const Constant('en'))();
  IntColumn get fileSize => integer().nullable()();
  IntColumn get addedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Transcripts extends Table {
  TextColumn get id => text()();
  TextColumn get videoId => text()();
  TextColumn get textChunk => text()();
  RealColumn get startTime => real()();
  RealColumn get endTime => real()();
  TextColumn get language => text().withDefault(const Constant('en'))();

  @override
  Set<Column> get primaryKey => {id};
}

class ImageInsights extends Table {
  TextColumn get id => text()();
  TextColumn get contentId => text()();
  TextColumn get imageType => text().nullable()(); // 'diagram' | 'organ' | 'flowchart' | 'plain' | 'labeled'
  TextColumn get caption => text().nullable()();
  TextColumn get extractedConcepts => text().nullable()(); // JSON array
  TextColumn get ocrText => text().nullable()();
  IntColumn get processedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class Embeddings extends Table {
  TextColumn get id => text()();
  TextColumn get contentId => text()();
  IntColumn get chunkIndex => integer()();
  TextColumn get chunkText => text()();
  BlobColumn get embedding => blob()(); // Float32List as bytes
  TextColumn get model => text().withDefault(const Constant('minilm-l6-v2'))();

  @override
  Set<Column> get primaryKey => {id};
}

class EngagementSessions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get contentId => text()();
  TextColumn get state => text()(); // 'focused' | 'passive' | 'fatigued' | 'absent'
  IntColumn get durationSeconds => integer()();
  IntColumn get tapCount => integer().withDefault(const Constant(0))();
  IntColumn get scrollEvents => integer().withDefault(const Constant(0))();
  IntColumn get idleSeconds => integer().withDefault(const Constant(0))();
  IntColumn get startedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class UserProgress extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get contentId => text()();
  RealColumn get completionPct => real().withDefault(const Constant(0.0))();
  IntColumn get lastAccessedAt => integer()();
  IntColumn get difficultyRating => integer().nullable()(); // 1-5
  IntColumn get timeSpentSeconds => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class AIResponseCache extends Table {
  TextColumn get id => text()();
  TextColumn get cacheKey => text().unique()();
  TextColumn get responseJson => text()();
  TextColumn get source => text()(); // 'offline' | 'cloud'
  TextColumn get model => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get expiresAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class LeaderboardEntries extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get displayName => text()();
  IntColumn get streakDays => integer().withDefault(const Constant(0))();
  IntColumn get totalPoints => integer().withDefault(const Constant(0))();
  IntColumn get weeklyPoints => integer().withDefault(const Constant(0))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class PeerDevices extends Table {
  TextColumn get id => text()();
  TextColumn get deviceName => text()();
  TextColumn get endpointId => text().nullable()();
  IntColumn get lastSeenAt => integer()();
  TextColumn get contentSynced => text().nullable()(); // JSON array

  @override
  Set<Column> get primaryKey => {id};
}

class ChatSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get linkedFileIds => text().withDefault(const Constant('[]'))();
}

class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer()();
  TextColumn get role => text()();
  TextColumn get content => text()();
  IntColumn get timestamp => integer()();
  TextColumn get sourceChunkId => text().nullable()();
}

class ManagedFiles extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get fileType => text()();
  TextColumn get localPath => text()();
  IntColumn get sizeBytes => integer()();
  IntColumn get uploadedAt => integer()();
  TextColumn get extractedTextPreview => text().nullable()();
  TextColumn get thumbnailPath => text().nullable()();
  IntColumn get embeddingCount => integer().withDefault(const Constant(0))();
}

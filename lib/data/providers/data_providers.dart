import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../repositories/drift/drift_repositories.dart';
import '../repositories/repository_interfaces.dart';

import '../../services/connectivity/connectivity_service.dart';
import '../../ai/nlp/embedding_index.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return DriftContentRepository(ref.watch(appDatabaseProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return DriftUserRepository(ref.watch(appDatabaseProvider));
});

final engagementRepositoryProvider = Provider<EngagementRepository>((ref) {
  return DriftEngagementRepository(ref.watch(appDatabaseProvider));
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return DriftProgressRepository(ref.watch(appDatabaseProvider));
});

final transcriptRepositoryProvider = Provider<TranscriptRepository>((ref) {
  return DriftTranscriptRepository(ref.watch(appDatabaseProvider));
});

final imageInsightsRepositoryProvider = Provider<ImageInsightsRepository>((ref) {
  return DriftImageInsightsRepository(ref.watch(appDatabaseProvider));
});

final embeddingRepositoryProvider = Provider<EmbeddingRepository>((ref) {
  return DriftEmbeddingRepository(ref.watch(appDatabaseProvider));
});

final embeddingIndexProvider = FutureProvider<EmbeddingIndex>((ref) async {
  final index = EmbeddingIndex();
  final repo = ref.watch(embeddingRepositoryProvider);
  await index.load(repo);
  return index;
});

final cacheRepositoryProvider = Provider<CacheRepository>((ref) {
  return DriftCacheRepository(ref.watch(appDatabaseProvider));
});

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return DriftLeaderboardRepository(ref.watch(appDatabaseProvider));
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return DriftChatRepository(ref.watch(appDatabaseProvider));
});

final fileRepositoryProvider = Provider<FileManagementRepository>((ref) {
  return DriftFileManagementRepository(ref.watch(appDatabaseProvider));
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

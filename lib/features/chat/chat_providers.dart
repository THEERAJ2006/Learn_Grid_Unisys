import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/entities.dart';
import '../../data/providers/data_providers.dart';
import '../../data/repositories/repository_interfaces.dart';

final activeChatSessionProvider = StateProvider<ChatSessionEntity?>((ref) => null);

final chatMessagesProvider =
    StreamProvider.family<List<ChatMessageEntity>, int>((ref, sessionId) {
  return ref.watch(chatRepositoryProvider).watchMessages(sessionId);
});

final chatInputProvider = StateProvider<String>((ref) => '');

final isAIRespondingProvider = StateProvider<bool>((ref) => false);

final chatSessionsProvider = FutureProvider<List<ChatSessionEntity>>((ref) {
  return ref.watch(chatRepositoryProvider).getAllSessions();
});

final chatSessionStreamProvider =
    StreamProvider<List<ChatSessionEntity>>((ref) {
  return ref.watch(chatRepositoryProvider).watchAllSessions();
});

final chatSessionByIdProvider =
    FutureProvider.family<ChatSessionEntity?, int>((ref, sessionId) {
  return ref.watch(chatRepositoryProvider).getSessionById(sessionId);
});

final chatRepositoryStreamProvider = Provider<ChatRepository>((ref) {
  return ref.watch(chatRepositoryProvider);
});

import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/entities.dart';
import '../../data/providers/data_providers.dart';
import '../../data/repositories/repository_interfaces.dart';
import '../nlp/embedding_service.dart';
import '../nlp/embedding_providers.dart';
import '../router/ai_router.dart';
import '../../features/settings/settings_prefs.dart';

class ChatService {
  ChatService({
    required this.chatRepository,
    required this.fileRepository,
    required this.embeddingService,
    required this.aiRouter,
  });

  final ChatRepository chatRepository;
  final FileManagementRepository fileRepository;
  final EmbeddingService embeddingService;
  final AIRouter aiRouter;

  Future<ChatSessionEntity> createSession(List<int> fileIds, String seedQuestion) async {
    final name = _autoName(seedQuestion);
    return chatRepository.createSession(name, fileIds);
  }

  Future<ChatSessionEntity?> getSession(int id) {
    return chatRepository.getSessionById(id);
  }

  Future<void> renameSession(int id, String newName) => chatRepository.renameSession(id, newName);

  Future<void> deleteSession(int id) => chatRepository.deleteSession(id);

  Future<void> appendFiles(int sessionId, List<int> fileIds) async {
    final session = await chatRepository.getSessionById(sessionId);
    if (session == null) return;
    final existing = _decodeIds(session.linkedFileIds);
    final merged = {...existing, ...fileIds}.toList(growable: false);
    await chatRepository.updateSessionFiles(sessionId, merged);
  }

  Future<ChatMessageEntity> addMessage(ChatMessageEntity message) {
    return chatRepository.insertMessage(message);
  }

  Future<List<ChatMessageEntity>> getRecentHistory(int sessionId, {int limit = 6}) async {
    final messages = await chatRepository.getMessages(sessionId);
    return messages.length <= limit ? messages : messages.sublist(messages.length - limit);
  }

  Stream<String> streamReply({
    required BuildContext context,
    required int sessionId,
    required String question,
    required List<ChatMessageEntity> history,
    required List<int> linkedFileIds,
  }) async* {
    final contextChunks = await _gatherContext(question, linkedFileIds);
    final prompt = _buildPrompt(question, history, contextChunks);
    final useCloud = await _shouldUseCloud();
    final response = useCloud
        ? await _generateCloudReply(context, prompt)
        : _generateOfflineReply(question, history, contextChunks);

    final tokens = response.split(' ');
    for (int i = 0; i < tokens.length; i++) {
      yield tokens[i] + (i < tokens.length - 1 ? ' ' : '');
      await Future<void>.delayed(const Duration(milliseconds: 18));
    }
  }

  Future<List<ContentChunk>> _gatherContext(String question, List<int> fileIds) async {
    final chunks = <ContentChunk>[];
    for (final fileId in fileIds) {
      final file = await fileRepository.getFileById(fileId);
      if (file == null) continue;
      chunks.addAll(
        await embeddingService.semanticSearchForContentId(
          question,
          'managed_file:${file.id}',
          topK: 3,
        ),
      );
    }
    chunks.sort((a, b) => b.score.compareTo(a.score));
    return chunks.take(5).toList(growable: false);
  }

  String _buildPrompt(
    String question,
    List<ChatMessageEntity> history,
    List<ContentChunk> contextChunks,
  ) {
    final ctx = contextChunks.isEmpty
        ? 'No relevant chunk found.'
        : contextChunks
            .map((c) => '[${c.contentId}#${c.chunkIndex}] ${c.text}')
            .join('\n\n');
    final historyLines = history
        .map((m) => '${m.role}: ${m.content}')
        .join('\n');
    return '''
System: You are LearnGrid, an intelligent learning assistant. Answer only based on the provided document context. If the answer is not in the context, say so clearly.

Context:
$ctx

Conversation history:
$historyLines

User: $question
''';
  }

  String _generateOfflineReply(
    String question,
    List<ChatMessageEntity> history,
    List<ContentChunk> contextChunks,
  ) {
    final contextText = contextChunks.isEmpty
        ? 'I could not find a strong match in the uploaded files.'
        : contextChunks
            .map((c) => '• ${c.text.trim()} [source: ${c.contentId}#${c.chunkIndex}]')
            .take(3)
            .join('\n');
    final historyHint = history.isEmpty
        ? ''
        : '\n\nWe have already discussed ${history.where((m) => m.role == 'user').length} user turns in this session.';
    return 'Here is a grounded answer based on your uploaded material:\n\n'
        '$contextText'
        '$historyHint\n\n'
        'Question: $question';
  }

  Future<bool> _shouldUseCloud() async {
    final mode = await SettingsPrefs.getAiMode();
    return mode != AiModePreference.offlineOnly;
  }

  Future<String> _generateCloudReply(BuildContext context, String prompt) async {
    try {
      return await aiRouter.getExplanationWithConsent(context, prompt);
    } catch (_) {
      return _generateOfflineReply(prompt, const [], const []);
    }
  }

  String _autoName(String question) {
    final words = question
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .take(6)
        .toList(growable: false);
    if (words.isEmpty) return 'New Chat';
    return words.join(' ');
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

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService(
    chatRepository: ref.watch(chatRepositoryProvider),
    fileRepository: ref.watch(fileRepositoryProvider),
    embeddingService: ref.watch(embeddingServiceProvider),
    aiRouter: ref.watch(aiRouterProvider),
  );
});

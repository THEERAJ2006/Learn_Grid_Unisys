import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../ai/chat/chat_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/entities.dart';
import 'package:flutter/foundation.dart'; // Added for kIsWeb
import '../../files/file_service.dart';
import '../../files/file_providers.dart';
import '../chat_providers.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.sessionId});

  final int sessionId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _showScrollFab = false;
  bool _isStreaming = false;
  String _draftAssistant = '';
  StreamSubscription<String>? _streamSub;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _streamSub?.cancel();
    _controller.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final shouldShow = pos.pixels < pos.maxScrollExtent - 140;
    if (shouldShow != _showScrollFab) {
      setState(() => _showScrollFab = shouldShow);
    }
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  Future<void> _sendMessage(ChatSessionEntity session, List<ChatMessageEntity> history) async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isStreaming) return;
    _controller.clear();
    final now = DateTime.now().millisecondsSinceEpoch;
    final user = await ref.read(chatServiceProvider).addMessage(
          ChatMessageEntity(
            id: 0,
            sessionId: session.id,
            role: 'user',
            content: text,
            timestamp: now,
          ),
        );

    if (session.name == 'New Chat' || session.name.toLowerCase().startsWith('ask about')) {
      await ref.read(chatServiceProvider).renameSession(session.id, _autoName(text));
    }

    final linkedFileIds = _decodeIds(session.linkedFileIds);
    setState(() {
      _isStreaming = true;
      _draftAssistant = '';
    });
    _scrollToBottom();

    _streamSub?.cancel();
    final stream = ref.read(chatServiceProvider).streamReply(
          context: context,
          sessionId: session.id,
          question: text,
          history: [...history, user],
          linkedFileIds: linkedFileIds,
        );

    _streamSub = stream.listen(
      (chunk) {
        if (!mounted) return;
        setState(() {
          _draftAssistant += chunk;
        });
        _scrollToBottom();
      },
      onError: (e) async {
        if (!mounted) return;
        setState(() {
          _isStreaming = false;
          _draftAssistant = 'Sorry, something went wrong: $e';
        });
        await ref.read(chatServiceProvider).addMessage(
              ChatMessageEntity(
                id: 0,
                sessionId: session.id,
                role: 'assistant',
                content: _draftAssistant,
                timestamp: DateTime.now().millisecondsSinceEpoch,
              ),
            );
      },
      onDone: () async {
        if (!mounted) return;
        final answer = _draftAssistant.trim().isEmpty
            ? 'I could not produce a grounded answer from the available context.'
            : _draftAssistant.trim();
        await ref.read(chatServiceProvider).addMessage(
              ChatMessageEntity(
                id: 0,
                sessionId: session.id,
                role: 'assistant',
                content: answer,
                timestamp: DateTime.now().millisecondsSinceEpoch,
              ),
            );
        if (!mounted) return;
        setState(() {
          _isStreaming = false;
          _draftAssistant = '';
        });
        _scrollToBottom();
      },
      cancelOnError: true,
    );
  }

  Future<void> _attachFile(ChatSessionEntity session) async {
    if (_isStreaming) return;
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'txt', 'md', 'png', 'jpg', 'jpeg', 'webp'],
      withData: kIsWeb, // Important: set to true on web to get bytes
    );
    if (picked == null || picked.files.isEmpty) return;

    final platformFile = picked.files.single;

    await ref.read(chatServiceProvider).addMessage(
          ChatMessageEntity(
            id: 0,
            sessionId: session.id,
            role: 'system',
            content: 'Processing your file...',
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );

    late final ManagedFileEntity stored;

    if (kIsWeb) {
      final bytes = platformFile.bytes;
      if (bytes == null) return;
      
      stored = await ref.read(fileServiceProvider).processAndStoreBytes(platformFile.name, bytes);
      
    } else {
      final path = platformFile.path;
      if (path == null) return;
      stored = await ref.read(fileServiceProvider).processAndStore(File(path));
    }

    await ref.read(chatServiceProvider).appendFiles(session.id, [stored.id]);

    await ref.read(chatServiceProvider).addMessage(
          ChatMessageEntity(
            id: 0,
            sessionId: session.id,
            role: 'system',
            content: 'Ready! Ask me anything about ${stored.name}.',
            timestamp: DateTime.now().millisecondsSinceEpoch,
          ),
        );

    if (mounted) {
      ref.invalidate(chatMessagesProvider(widget.sessionId));
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionAsync = ref.watch(chatSessionByIdProvider(widget.sessionId));
    final messagesAsync = ref.watch(chatMessagesProvider(widget.sessionId));

    final messages = messagesAsync.valueOrNull ?? const <ChatMessageEntity>[];
    final session = sessionAsync.valueOrNull;
    final linkedIds = session == null ? const <int>[] : _decodeIds(session.linkedFileIds);

    final renderedMessages = [
      ...messages,
      if (_isStreaming)
        ChatMessageEntity(
          id: -1,
          sessionId: widget.sessionId,
          role: 'assistant',
          content: _draftAssistant.isEmpty ? '...' : _draftAssistant,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
    ];

    ref.listen(chatMessagesProvider(widget.sessionId), (_, _) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(
        title: Text(session?.name ?? 'Chat'),
        actions: [
          IconButton(
            onPressed: session == null ? null : () => _attachFile(session),
            icon: const Icon(Icons.attach_file),
            tooltip: 'Attach file',
          ),
        ],
      ),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not open chat: $e')),
        data: (session) {
          if (session == null) {
            return const Center(child: Text('Chat session not found.'));
          }
          return Column(
            children: [
              if (linkedIds.isNotEmpty)
                _LinkedFilesBar(
                  fileIds: linkedIds,
                  onTapFile: (id) => context.go('/files/$id'),
                ),
              Expanded(
                child: renderedMessages.isEmpty
                    ? _EmptyChatView(
                        onSuggestedQuestion: (q) {
                          _controller.text = q;
                          _sendMessage(session, messages);
                        },
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                        itemCount: renderedMessages.length,
                        itemBuilder: (context, index) {
                          final message = renderedMessages[index];
                          return _ChatBubble(message: message);
                        },
                      ),
              ),
              _InputBar(
                controller: _controller,
                isBusy: _isStreaming,
                onSend: () => _sendMessage(session, messages),
                onAttach: () => _attachFile(session),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _showScrollFab
          ? FloatingActionButton(
              onPressed: () => _scrollToBottom(),
              child: const Icon(Icons.arrow_downward),
            )
          : null,
    );
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

  String _autoName(String text) {
    final words = text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).take(6);
    final name = words.join(' ');
    return name.isEmpty ? 'New Chat' : name;
  }
}

class _LinkedFilesBar extends ConsumerWidget {
  const _LinkedFilesBar({required this.fileIds, required this.onTapFile});

  final List<int> fileIds;
  final void Function(int id) onTapFile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: fileIds.map((id) {
          final fileAsync = ref.watch(fileByIdProvider(id));
          final file = fileAsync.valueOrNull;
          return ActionChip(
            avatar: const Icon(Icons.insert_drive_file_outlined, size: 18),
            label: Text(file?.name ?? 'File $id'),
            onPressed: () => onTapFile(id),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _EmptyChatView extends StatelessWidget {
  const _EmptyChatView({required this.onSuggestedQuestion});

  final void Function(String question) onSuggestedQuestion;

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      'What is the main idea?',
      'Summarize this file in simple terms.',
      'List the key concepts I should remember.',
      'What should I study first?',
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: AppTheme.accent,
              child: Icon(Icons.auto_awesome, color: Colors.white, size: 34),
            ),
            const SizedBox(height: 16),
            Text(
              'Ask your files anything',
              style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'I’ll keep the conversation grounded in your uploaded material.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: suggestions
                  .map(
                    (q) => ActionChip(
                      label: Text(q),
                      onPressed: () => onSuggestedQuestion(q),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isBusy,
    required this.onSend,
    required this.onAttach,
  });

  final TextEditingController controller;
  final bool isBusy;
  final VoidCallback onSend;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(top: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.2))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: isBusy ? null : onAttach,
              icon: const Icon(Icons.attach_file),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Ask a follow-up question...',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: isBusy ? null : onSend,
              style: FilledButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(14),
              ),
              child: isBusy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessageEntity message;

  @override
  Widget build(BuildContext context) {
    if (message.role == 'system') {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              message.content,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ),
        ),
      );
    }

    final isUser = message.role == 'user';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.accent,
              child: Icon(Icons.auto_awesome, size: 14, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isUser
                    ? AppTheme.accent.withValues(alpha: 0.95)
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 6),
                  bottomRight: Radius.circular(isUser ? 6 : 18),
                ),
                border: isUser ? null : Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: const TextStyle(height: 1.45),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatTime(DateTime.fromMillisecondsSinceEpoch(message.timestamp)),
                    style: const TextStyle(fontSize: 10, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

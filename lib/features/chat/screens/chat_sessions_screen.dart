import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/entities.dart';
import '../../../ai/chat/chat_service.dart';
import '../../files/file_service.dart';
import '../chat_providers.dart';

class ChatSessionsScreen extends ConsumerWidget {
  const ChatSessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(chatSessionStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            onPressed: () => context.go('/files'),
            icon: const Icon(Icons.folder_outlined),
            tooltip: 'Open files',
          ),
        ],
      ),
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load chats: $e')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return _EmptySessionsView(onCreate: () => _startNewChat(context, ref));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _SessionRow(
                session: session,
                onOpen: () => context.go('/chat/session/${session.id}'),
                onDelete: () async {
                  await ref.read(chatServiceProvider).deleteSession(session.id);
                },
                onRename: () async {
                  final value = await _promptRename(context, session.name);
                  if (value == null || value.trim().isEmpty) return;
                  await ref.read(chatServiceProvider).renameSession(session.id, value.trim());
                },
                onNewChatAboutFiles: () => _startNewChat(context, ref),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _startNewChat(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New chat'),
      ),
    );
  }

  Future<void> _startNewChat(BuildContext context, WidgetRef ref) async {
    final choice = await showModalBottomSheet<_StartChoice>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.upload_file),
              title: const Text('Upload file'),
              subtitle: const Text('Create a chat from a PDF or text file'),
              onTap: () => Navigator.of(context).pop(_StartChoice.upload),
            ),
            ListTile(
              leading: const Icon(Icons.notes),
              title: const Text('Start empty'),
              subtitle: const Text('Open a blank session and ask anything'),
              onTap: () => Navigator.of(context).pop(_StartChoice.empty),
            ),
          ],
        ),
      ),
    );

    if (choice == null) return;
    if (choice == _StartChoice.empty) {
      final session = await ref.read(chatServiceProvider).createSession(const [], 'New Chat');
      if (!context.mounted) return;
      context.go('/chat/session/${session.id}');
      return;
    }

    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'txt', 'md', 'png', 'jpg', 'jpeg', 'webp'],
      withData: kIsWeb,
    );
    if (picked == null || picked.files.isEmpty) return;
    
    final platformFile = picked.files.single;
    final service = ref.read(fileServiceProvider);
    
    late final ManagedFileEntity stored;
    if (kIsWeb) {
      final bytes = platformFile.bytes;
      if (bytes == null) return;
      stored = await service.processAndStoreBytes(platformFile.name, bytes);
    } else {
      final path = platformFile.path;
      if (path == null) return;
      stored = await service.processAndStore(File(path));
    }
    final session = await ref.read(chatServiceProvider).createSession([stored.id], 'Ask about ${stored.name}');
    if (!context.mounted) return;
    context.go('/chat/session/${session.id}');
  }

  Future<String?> _promptRename(BuildContext context, String current) async {
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename session'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Session name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    return result;
  }
}

enum _StartChoice { upload, empty }

class _EmptySessionsView extends StatelessWidget {
  const _EmptySessionsView({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.chat_bubble_outline, size: 72, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              'No chat sessions yet',
              style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload a file or start a blank conversation to begin.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Start a chat'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionRow extends ConsumerWidget {
  const _SessionRow({
    required this.session,
    required this.onOpen,
    required this.onDelete,
    required this.onRename,
    required this.onNewChatAboutFiles,
  });

  final ChatSessionEntity session;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback onRename;
  final VoidCallback onNewChatAboutFiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(chatMessagesProvider(session.id));
    final messages = messagesAsync.valueOrNull ?? const <ChatMessageEntity>[];
    final preview = messages.isEmpty ? 'No messages yet' : messages.last.content;
    final files = _decodeIds(session.linkedFileIds);
    final time = DateTime.fromMillisecondsSinceEpoch(session.updatedAt);

    return Dismissible(
      key: ValueKey('chat_${session.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onOpen,
        onLongPress: () async {
          final action = await showModalBottomSheet<_SessionAction>(
            context: context,
            showDragHandle: true,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Rename'),
                    onTap: () => Navigator.of(context).pop(_SessionAction.rename),
                  ),
                  ListTile(
                    leading: const Icon(Icons.open_in_new),
                    title: const Text('Open'),
                    onTap: () => Navigator.of(context).pop(_SessionAction.open),
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete_outline),
                    title: const Text('Delete'),
                    onTap: () => Navigator.of(context).pop(_SessionAction.delete),
                  ),
                  ListTile(
                    leading: const Icon(Icons.upload_file),
                    title: const Text('Start another chat about files'),
                    onTap: () => Navigator.of(context).pop(_SessionAction.newChat),
                  ),
                ],
              ),
            ),
          );
          if (action == _SessionAction.rename) onRename();
          if (action == _SessionAction.delete) onDelete();
          if (action == _SessionAction.open) onOpen();
          if (action == _SessionAction.newChat) onNewChatAboutFiles();
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.chat_bubble_outline),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      preview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _MetaChip(icon: Icons.schedule, label: _formatTime(time)),
                        _MetaChip(icon: Icons.insert_drive_file_outlined, label: '${files.length} files'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

enum _SessionAction { rename, open, delete, newChat }

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }
}

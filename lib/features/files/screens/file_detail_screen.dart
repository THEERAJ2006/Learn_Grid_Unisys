import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../ai/chat/chat_service.dart';
import '../../../data/models/entities.dart';
import '../../chat/chat_providers.dart';
import '../file_providers.dart';

class FileDetailScreen extends ConsumerWidget {
  const FileDetailScreen({super.key, required this.fileId});

  final int fileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileAsync = ref.watch(fileByIdProvider(fileId));
    final sessionsAsync = ref.watch(chatSessionStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('File detail')),
      body: fileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load file: $e')),
        data: (file) {
          if (file == null) {
            return const Center(child: Text('File not found.'));
          }

          final sessions = sessionsAsync.valueOrNull ?? const <ChatSessionEntity>[];
          final linked = sessions
              .where((session) => _decodeIds(session.linkedFileIds).contains(file.id))
              .toList(growable: false)
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _HeaderCard(file: file),
              const SizedBox(height: 16),
              _PreviewCard(file: file),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => _openChat(context, ref, file),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Chat about this file'),
              ),
              const SizedBox(height: 20),
              Text('View all chats', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              if (linked.isEmpty)
                const Text('No chat sessions yet for this file.')
              else
                ...linked.map(
                  (session) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: Text(session.name),
                      subtitle: Text(_relativeTime(session.updatedAt)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.go('/chat/session/${session.id}'),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openChat(BuildContext context, WidgetRef ref, ManagedFileEntity file) async {
    final sessions = await ref.read(chatSessionStreamProvider.future);
    final linked = sessions.where((session) => _decodeIds(session.linkedFileIds).contains(file.id)).toList(growable: false);
    if (linked.isNotEmpty) {
      linked.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      if (!context.mounted) return;
      context.go('/chat/session/${linked.first.id}');
      return;
    }
    final session = await ref.read(chatServiceProvider).createSession([file.id], 'Ask about ${file.name}');
    if (!context.mounted) return;
    context.go('/chat/session/${session.id}');
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

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({required this.file});

  final ManagedFileEntity file;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: _colorForType(file.fileType).withValues(alpha: 0.12),
              child: Icon(_iconForType(file.fileType), color: _colorForType(file.fileType), size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text('${file.fileType.toUpperCase()} · ${_fmtBytes(file.sizeBytes)}'),
                  Text('Uploaded ${_fmtDate(file.uploadedAt)}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.file});

  final ManagedFileEntity file;

  @override
  Widget build(BuildContext context) {
    final thumb = file.thumbnailPath;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preview', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            if (file.fileType == 'image')
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(File(file.localPath), fit: BoxFit.cover),
              )
            else if (thumb != null && File(thumb).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(File(thumb), fit: BoxFit.cover),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_iconForType(file.fileType), size: 80, color: _colorForType(file.fileType)),
              ),
            const SizedBox(height: 12),
            Text(
              file.extractedTextPreview?.isNotEmpty == true
                  ? file.extractedTextPreview!
                  : 'No extracted text preview available.',
              style: const TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

Color _colorForType(String type) {
  switch (type) {
    case 'pdf':
      return Colors.redAccent;
    case 'txt':
      return Colors.blueAccent;
    case 'image':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

IconData _iconForType(String type) {
  switch (type) {
    case 'pdf':
      return Icons.picture_as_pdf;
    case 'txt':
      return Icons.description_outlined;
    case 'image':
      return Icons.image_outlined;
    default:
      return Icons.insert_drive_file_outlined;
  }
}

String _fmtBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

String _fmtDate(int millis) {
  final dt = DateTime.fromMillisecondsSinceEpoch(millis);
  return '${dt.month}/${dt.day}/${dt.year}';
}

String _relativeTime(int millis) {
  final dt = DateTime.fromMillisecondsSinceEpoch(millis);
  final diff = DateTime.now().difference(dt);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

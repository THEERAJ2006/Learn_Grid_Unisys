import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../ai/chat/chat_service.dart';
import '../../../data/models/entities.dart';
import '../../../data/providers/data_providers.dart';
import '../../chat/chat_providers.dart';
import '../file_providers.dart';
import '../file_service.dart';

class FileManagerScreen extends ConsumerStatefulWidget {
  const FileManagerScreen({super.key});

  @override
  ConsumerState<FileManagerScreen> createState() => _FileManagerScreenState();
}

class _FileManagerScreenState extends ConsumerState<FileManagerScreen> {
  bool _searchMode = false;

  @override
  Widget build(BuildContext context) {
    final filesAsync = ref.watch(managedFilesProvider);
    final sessionsAsync = ref.watch(chatSessionStreamProvider);
    final viewMode = ref.watch(fileViewModeProvider);
    final filter = ref.watch(fileFilterProvider);
    final sort = ref.watch(fileSortProvider);
    final query = ref.watch(fileSearchQueryProvider).trim().toLowerCase();

    return Scaffold(
      appBar: AppBar(
        title: _searchMode
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search files...',
                  border: InputBorder.none,
                ),
                onChanged: (value) => ref.read(fileSearchQueryProvider.notifier).state = value,
              )
            : const Text('My Files'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => setState(() => _searchMode = !_searchMode),
          ),
          IconButton(
            icon: Icon(viewMode == FileViewMode.grid ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              ref.read(fileViewModeProvider.notifier).state =
                  viewMode == FileViewMode.grid ? FileViewMode.list : FileViewMode.grid;
            },
          ),
        ],
      ),
      body: filesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load files: $e')),
        data: (files) {
          final sessions = sessionsAsync.valueOrNull ?? const <ChatSessionEntity>[];
          final sessionCounts = <int, int>{};
          for (final session in sessions) {
            for (final id in _decodeIds(session.linkedFileIds)) {
              sessionCounts[id] = (sessionCounts[id] ?? 0) + 1;
            }
          }

          final filtered = files.where((file) {
            final qOk = query.isEmpty ||
                file.name.toLowerCase().contains(query) ||
                (file.extractedTextPreview ?? '').toLowerCase().contains(query);
            return qOk;
          }).toList(growable: false);

          if (filtered.isEmpty) {
            return _EmptyFilesView(
              filter: filter,
              sort: sort,
              onUpload: () => _uploadFile(context),
            );
          }

          return Column(
            children: [
              _FilterRow(
                filter: filter,
                sort: sort,
                onFilterChanged: (value) => ref.read(fileFilterProvider.notifier).state = value,
                onSortChanged: (value) => ref.read(fileSortProvider.notifier).state = value,
              ),
              Expanded(
                child: viewMode == FileViewMode.grid
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.9,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final file = filtered[index];
                          return _FileCard(
                            file: file,
                            sessionCount: sessionCounts[file.id] ?? 0,
                            onTap: () => context.go('/files/${file.id}'),
                            onLongPress: () => _showFileMenu(context, file),
                          );
                        },
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final file = filtered[index];
                          return _FileRow(
                            file: file,
                            sessionCount: sessionCounts[file.id] ?? 0,
                            onTap: () => context.go('/files/${file.id}'),
                            onLongPress: () => _showFileMenu(context, file),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _uploadFile(context),
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  Future<void> _uploadFile(BuildContext context) async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'txt', 'md', 'png', 'jpg', 'jpeg', 'webp'],
      withData: kIsWeb,
    );
    if (picked == null || picked.files.isEmpty) return;
    
    final platformFile = picked.files.single;
    
    if (kIsWeb) {
      final bytes = platformFile.bytes;
      if (bytes == null) return;
      await ref.read(fileServiceProvider).processAndStoreBytes(platformFile.name, bytes);
    } else {
      final path = platformFile.path;
      if (path == null) return;
      await ref.read(fileServiceProvider).processAndStore(File(path));
    }
  }

  Future<void> _showFileMenu(BuildContext context, ManagedFileEntity file) async {
    final choice = await showModalBottomSheet<_FileAction>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () => Navigator.of(context).pop(_FileAction.rename),
            ),
            ListTile(
              leading: const Icon(Icons.chat_bubble_outline),
              title: const Text('Open in Chat'),
              onTap: () => Navigator.of(context).pop(_FileAction.chat),
            ),
            ListTile(
              leading: const Icon(Icons.share_outlined),
              title: const Text('Share'),
              onTap: () => Navigator.of(context).pop(_FileAction.share),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
              title: const Text('Delete'),
              onTap: () => Navigator.of(context).pop(_FileAction.delete),
            ),
          ],
        ),
      ),
    );
    if (choice == null) return;

    if (choice == _FileAction.rename) {
      final next = await _renamePrompt(context, file.name);
      if (next != null && next.trim().isNotEmpty) {
        await ref.read(fileRepositoryProvider).renameFile(file.id, next.trim());
      }
      return;
    }
    if (choice == _FileAction.share) {
      await Clipboard.setData(ClipboardData(text: file.localPath));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File path copied to clipboard')));
      return;
    }
    if (choice == _FileAction.delete) {
      await ref.read(fileServiceProvider).deleteFile(file.id);
      return;
    }
    if (choice == _FileAction.chat) {
      await _openChatAboutFile(context, file);
    }
  }

  Future<String?> _renamePrompt(BuildContext context, String current) async {
    final controller = TextEditingController(text: current);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename file'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    return value;
  }

  Future<void> _openChatAboutFile(BuildContext context, ManagedFileEntity file) async {
    final sessions = await ref.read(chatSessionStreamProvider.future);
    final existing = sessions.where((session) => _decodeIds(session.linkedFileIds).contains(file.id)).toList(growable: false);
    if (existing.isNotEmpty) {
      existing.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      if (!context.mounted) return;
      context.go('/chat/session/${existing.first.id}');
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

enum _FileAction { rename, chat, share, delete }

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filter,
    required this.sort,
    required this.onFilterChanged,
    required this.onSortChanged,
  });

  final String filter;
  final String sort;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final chips = const [
      ('all', 'All'),
      ('pdf', 'PDFs'),
      ('txt', 'Text'),
      ('image', 'Images'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips.map((entry) {
              final value = entry.$1;
              final label = entry.$2;
              return FilterChip(
                label: Text(label),
                selected: filter == value,
                onSelected: (_) => onFilterChanged(value),
              );
            }).toList(growable: false),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sort by',
                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
              ),
              DropdownButton<String>(
                value: sort,
                items: const [
                  DropdownMenuItem(value: 'recent', child: Text('Recent')),
                  DropdownMenuItem(value: 'name', child: Text('Name')),
                  DropdownMenuItem(value: 'size', child: Text('Size')),
                ],
                onChanged: (value) {
                  if (value != null) onSortChanged(value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyFilesView extends StatelessWidget {
  const _EmptyFilesView({
    required this.filter,
    required this.sort,
    required this.onUpload,
  });

  final String filter;
  final String sort;
  final VoidCallback onUpload;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.folder_open_outlined, size: 72, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              'No files found',
              style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload PDFs, text files, or images to start building your study library.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload file'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileCard extends StatelessWidget {
  const _FileCard({
    required this.file,
    required this.sessionCount,
    required this.onTap,
    required this.onLongPress,
  });

  final ManagedFileEntity file;
  final int sessionCount;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  color: _colorForType(file.fileType).withValues(alpha: 0.12),
                ),
                width: double.infinity,
                child: Center(
                  child: Icon(_iconForType(file.fileType), size: 44, color: _colorForType(file.fileType)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_fmtBytes(file.sizeBytes)} · ${_fmtDate(file.uploadedAt)}',
                    style: const TextStyle(fontSize: 11, color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$sessionCount chat session${sessionCount == 1 ? '' : 's'}',
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({
    required this.file,
    required this.sessionCount,
    required this.onTap,
    required this.onLongPress,
  });

  final ManagedFileEntity file;
  final int sessionCount;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(file.fileType);
    return ListTile(
      onTap: onTap,
      onLongPress: onLongPress,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(_iconForType(file.fileType), color: color),
      ),
      title: Text(
        file.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text('${_fmtBytes(file.sizeBytes)} · ${_fmtDate(file.uploadedAt)}'),
      trailing: Chip(label: Text('$sessionCount')),
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

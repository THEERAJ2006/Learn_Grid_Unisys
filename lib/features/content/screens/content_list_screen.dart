import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/entities.dart';
import '../state/content_notifier.dart';

enum SortBy { title, difficulty, recent, typeAsc }

class ContentListScreen extends ConsumerStatefulWidget {
  const ContentListScreen({super.key});

  @override
  ConsumerState<ContentListScreen> createState() => _ContentListScreenState();
}

class _ContentListScreenState extends ConsumerState<ContentListScreen> {
  String? _type;
  String? _subject;
  int? _difficulty;
  bool _isGridView = false;
  SortBy _sortBy = SortBy.title;

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentNotifierProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(
          'All Content',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => setState(() => _isGridView = !_isGridView),
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view_rounded),
            tooltip: _isGridView ? 'List View' : 'Grid View',
          ),
          IconButton(
            onPressed: () async {
              final notifier = ref.read(contentNotifierProvider.notifier);
              await notifier.seedSample();
            },
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Seed Sample Content',
          ),
          IconButton(
            onPressed: () => ref.read(contentNotifierProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: content.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text('Failed to load content: $e', textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.read(contentNotifierProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (items) {
          final filtered = items.where((e) {
            final typeOk = _type == null || e.type == _type;
            final subjectOk = _subject == null || (e.subject ?? '') == _subject;
            final diffOk = _difficulty == null || e.difficultyLevel == _difficulty;
            return typeOk && subjectOk && diffOk;
          }).toList(growable: true);

          // Sort
          switch (_sortBy) {
            case SortBy.title:
              filtered.sort((a, b) => a.title.compareTo(b.title));
            case SortBy.difficulty:
              filtered.sort((a, b) => a.difficultyLevel.compareTo(b.difficultyLevel));
            case SortBy.recent:
              filtered.sort((a, b) => b.addedAt.compareTo(a.addedAt));
            case SortBy.typeAsc:
              filtered.sort((a, b) => a.type.compareTo(b.type));
          }

          final types = items.map((e) => e.type).toSet().toList()..sort();
          final subjects = items.map((e) => e.subject).whereType<String>().toSet().toList()..sort();
          final difficulties = items.map((e) => e.difficultyLevel).toSet().toList()..sort();

          return Column(
            children: [
              // Filter bar
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          label: Text(_subject ?? 'Subject'),
                          avatar: _subject == null ? null : const Icon(Icons.close),
                          onSelected: (_) {
                            _showSimpleDialog<String?>(
                              'Subject',
                              [null, ...subjects],
                              _subject,
                              (v) => setState(() => _subject = v),
                            );
                          },
                        ),
                        FilterChip(
                          label: Text(_type ?? 'Type'),
                          avatar: _type == null ? null : const Icon(Icons.close),
                          onSelected: (_) {
                            _showSimpleDialog<String?>(
                              'Type',
                              [null, ...types],
                              _type,
                              (v) => setState(() => _type = v),
                            );
                          },
                        ),
                        FilterChip(
                          label: Text(_difficulty == null ? 'Level' : 'Level $_difficulty'),
                          avatar: _difficulty == null ? null : const Icon(Icons.close),
                          onSelected: (_) {
                            _showSimpleDialog<int?>(
                              'Difficulty',
                              [null, ...difficulties],
                              _difficulty,
                              (v) => setState(() => _difficulty = v),
                            );
                          },
                        ),
                        if (_subject != null || _type != null || _difficulty != null)
                          ActionChip(
                            label: const Text('Clear'),
                            onPressed: () => setState(() {
                              _subject = null;
                              _type = null;
                              _difficulty = null;
                            }),
                            avatar: const Icon(Icons.refresh),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${filtered.length} item${filtered.length == 1 ? '' : 's'}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        PopupMenuButton<SortBy>(
                          onSelected: (v) => setState(() => _sortBy = v),
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: SortBy.title, child: Text('Title (A-Z)')),
                            const PopupMenuItem(value: SortBy.difficulty, child: Text('Difficulty')),
                            const PopupMenuItem(value: SortBy.recent, child: Text('Recently Added')),
                            const PopupMenuItem(value: SortBy.typeAsc, child: Text('Type')),
                          ],
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.sort, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                'Sort',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            Text(
                              'No content',
                              style: GoogleFonts.nunito(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (_subject != null || _type != null || _difficulty != null)
                              TextButton(
                                onPressed: () => setState(() {
                                  _subject = null;
                                  _type = null;
                                  _difficulty = null;
                                }),
                                child: const Text('Clear Filters'),
                              ),
                          ],
                        ),
                      )
                    : _isGridView
                        ? GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return ContentCardGrid(
                                item: item,
                                onTap: () => context.go('/content/${item.id}'),
                              )
                                  .animate()
                                  .fadeIn(
                                    duration: 400.ms,
                                    delay: (50 * index).ms,
                                  )
                                  .slideY(
                                    begin: 0.2,
                                    end: 0,
                                    duration: 400.ms,
                                    delay: (50 * index).ms,
                                  );
                            },
                          )
                        : ListView.separated(
                            itemCount: filtered.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return ContentCardList(
                                item: item,
                                onTap: () => context.go('/content/${item.id}'),
                              )
                                  .animate()
                                  .fadeIn(
                                    duration: 300.ms,
                                    delay: (30 * index).ms,
                                  );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSimpleDialog<T>(
    String title,
    List<T> options,
    T? selected,
    Function(T?) onChanged,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(title),
        children: [
          for (final opt in options)
            SimpleDialogOption(
              onPressed: () {
                onChanged(opt);
                Navigator.pop(ctx);
              },
              child: Row(
                children: [
                  if (opt == selected) const Icon(Icons.check_circle, color: Colors.blue),
                  if (opt != selected) const Icon(Icons.radio_button_unchecked),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      opt == null ? 'All' : opt.toString(),
                      style: opt == selected ? GoogleFonts.inter(fontWeight: FontWeight.w600) : null,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Grid card ──────────────────────────────────────────────────────────

class ContentCardGrid extends StatelessWidget {
  final ContentItemEntity item;
  final VoidCallback onTap;

  const ContentCardGrid({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _getTypeIcon();
    final color = _getTypeColor();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 0.5),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with type icon
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(icon, size: 40, color: color),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.nunito(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.category, size: 10, color: Colors.grey.shade500),
                      const SizedBox(width: 3),
                      Text(
                        item.subject ?? 'Unknown',
                        style: GoogleFonts.inter(fontSize: 9, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Difficulty dots
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            Icons.star_rounded,
                            size: 8,
                            color: i < item.difficultyLevel
                                ? Colors.orange
                                : Colors.grey.shade300,
                          ),
                        ),
                      ),
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          item.type,
                          style: GoogleFonts.inter(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (item.type.toLowerCase()) {
      case 'video':
        return Icons.video_library;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'image':
        return Icons.image;
      case 'text':
        return Icons.text_fields;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.description;
    }
  }

  Color _getTypeColor() {
    switch (item.type.toLowerCase()) {
      case 'video':
        return Colors.red;
      case 'pdf':
        return Colors.orange;
      case 'image':
        return Colors.purple;
      case 'text':
        return Colors.blue;
      case 'audio':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

// ── List card ──────────────────────────────────────────────────────────

class ContentCardList extends StatelessWidget {
  final ContentItemEntity item;
  final VoidCallback onTap;

  const ContentCardList({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icon = _getTypeIcon();
    final color = _getTypeColor();

    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(icon, size: 24, color: color),
        ),
      ),
      title: Text(
        item.title,
        style: GoogleFonts.nunito(fontWeight: FontWeight.w600, fontSize: 14),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          children: [
            if (item.subject != null)
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.category, size: 11, color: Colors.grey.shade500),
                    const SizedBox(width: 3),
                    Text(
                      item.subject!,
                      style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.videocam, size: 11, color: Colors.grey.shade500),
                  const SizedBox(width: 3),
                  Text(
                    item.type,
                    style: GoogleFonts.inter(fontSize: 11, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (i) => Icon(
                  Icons.star_rounded,
                  size: 10,
                  color: i < item.difficultyLevel ? Colors.orange : Colors.grey.shade300,
                ),
              ),
            ),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  IconData _getTypeIcon() {
    switch (item.type.toLowerCase()) {
      case 'video':
        return Icons.video_library;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'image':
        return Icons.image;
      case 'text':
        return Icons.text_fields;
      case 'audio':
        return Icons.audiotrack;
      default:
        return Icons.description;
    }
  }

  Color _getTypeColor() {
    switch (item.type.toLowerCase()) {
      case 'video':
        return Colors.red;
      case 'pdf':
        return Colors.orange;
      case 'image':
        return Colors.purple;
      case 'text':
        return Colors.blue;
      case 'audio':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}

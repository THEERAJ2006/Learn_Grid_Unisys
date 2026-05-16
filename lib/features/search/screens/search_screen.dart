import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../ai/nlp/embedding_providers.dart';
import '../../../ai/nlp/embedding_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/data_providers.dart';
import '../../../data/models/entities.dart';
import '../../content/state/content_notifier.dart';

enum SearchMode { keyword, semantic }

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  SearchMode _mode = SearchMode.keyword;
  String? _subject;
  String? _type;
  int? _difficulty;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentNotifierProvider);
    final embeddingService = ref.watch(embeddingServiceProvider);
    final embeddingRepo = ref.watch(embeddingRepositoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Search Content',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w800, color: Colors.white),
        ),
        elevation: 0,
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
          final subjects = items.map((e) => e.subject).whereType<String>().toSet().toList()..sort();
          final types = items.map((e) => e.type).toSet().toList()..sort();
          final diffs = items.map((e) => e.difficultyLevel).toSet().toList()..sort();

          final filtered = items.where((e) {
            final subjectOk = _subject == null || e.subject == _subject;
            final typeOk = _type == null || e.type == _type;
            final diffOk = _difficulty == null || e.difficultyLevel == _difficulty;
            return subjectOk && typeOk && diffOk;
          }).toList(growable: false);

          final q = _controller.text.trim().toLowerCase();
          Future<List<(ContentItemEntity item, double score)>> runSearch() async {
            if (q.isEmpty) {
              return filtered.map((e) => (e, 0.0)).toList(growable: false);
            }
            if (_mode == SearchMode.keyword) {
              final scored = <(ContentItemEntity, double)>[];
              for (final item in filtered) {
                final hay = '${item.title} ${item.subject ?? ''} ${item.topicTags ?? ''}'.toLowerCase();
                final score = hay.contains(q) ? 1.0 : 0.0;
                if (score > 0) scored.add((item, score));
              }
              scored.sort((a, b) => b.$2.compareTo(a.$2));
              return scored.map((e) => (e.$1, e.$2 * 100)).toList(growable: false);
            }

            // Semantic: requires embeddings (built lazily from available text). In MVP we
            // only embed title+tags to keep it fast.
            final allEmbeddings = <EmbeddingEntity>[];
            for (final item in filtered) {
              await embeddingService.ensureContentEmbeddings(
                content: item,
                plainText: '${item.title}\n${item.subject ?? ''}\n${item.topicTags ?? ''}',
              );
              final emb = await embeddingRepo.getByContent(item.id);
              allEmbeddings.addAll(emb);
            }
            final chunks = await embeddingService.semanticSearch(q, allEmbeddings, topK: 25);
            final bestByContent = <String, ContentChunk>{};
            for (final c in chunks) {
              final prev = bestByContent[c.contentId];
              if (prev == null || c.similarity > prev.similarity) bestByContent[c.contentId] = c;
            }
            final scored = <(ContentItemEntity, double)>[];
            for (final item in filtered) {
              final c = bestByContent[item.id];
              if (c == null) continue;
              scored.add((item, c.score));
            }
            scored.sort((a, b) => b.$2.compareTo(a.$2));
            return scored.map((e) => (e.$1, e.$2)).toList(growable: false);
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search input field
                TextField(
                  controller: _controller,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Search by title or tags',
                    labelStyle: GoogleFonts.inter(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _controller.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                    filled: true,
                    fillColor: isDark ? Colors.grey.shade900 : Colors.grey.shade50,
                  ),
                  onSubmitted: (_) => setState(() {}),
                ),
                const SizedBox(height: 16),
                // Filter pills
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    // Search mode toggle
                    SegmentedButton<SearchMode>(
                      segments: const [
                        ButtonSegment(
                          value: SearchMode.keyword,
                          label: Text('Keyword'),
                          icon: Icon(Icons.text_fields),
                        ),
                        ButtonSegment(
                          value: SearchMode.semantic,
                          label: Text('Semantic'),
                          icon: Icon(Icons.lightbulb_outline),
                        ),
                      ],
                      selected: {_mode},
                      onSelectionChanged: (s) => setState(() => _mode = s.first),
                    ),
                    // Subject filter
                    FilterChip(
                      label: Text(_subject ?? 'Subject'),
                      avatar: _subject == null ? null : const Icon(Icons.close),
                      onSelected: (_) {
                        _showFilterDialog(
                          'Subject',
                          [null, ...subjects],
                          _subject,
                          (v) => setState(() => _subject = v),
                        );
                      },
                    ),
                    // Type filter
                    FilterChip(
                      label: Text(_type ?? 'Type'),
                      avatar: _type == null ? null : const Icon(Icons.close),
                      onSelected: (_) {
                        _showFilterDialog(
                          'Type',
                          [null, ...types],
                          _type,
                          (v) => setState(() => _type = v),
                        );
                      },
                    ),
                    // Difficulty filter
                    FilterChip(
                      label: Text(_difficulty == null ? 'Level' : 'Level $_difficulty'),
                      avatar: _difficulty == null ? null : const Icon(Icons.close),
                      onSelected: (_) {
                        _showFilterDialog(
                          'Difficulty',
                          [null, ...diffs],
                          _difficulty,
                          (v) => setState(() => _difficulty = v),
                        );
                      },
                    ),
                    // Clear all button
                    if (_subject != null || _type != null || _difficulty != null)
                      ActionChip(
                        label: const Text('Clear All'),
                        onPressed: () => setState(() {
                          _subject = null;
                          _type = null;
                          _difficulty = null;
                          _controller.clear();
                        }),
                        avatar: const Icon(Icons.refresh),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // Results
                Expanded(
                  child: FutureBuilder<List<(ContentItemEntity item, double score)>>(
                    future: runSearch(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.orange.shade300),
                              const SizedBox(height: 16),
                              Text('Search failed: ${snapshot.error}', textAlign: TextAlign.center),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () => setState(() {}),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }
                      final results = snapshot.data ?? const [];
                      if (results.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              const Text(
                                'No results found',
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                              if (q.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    'Try different keywords or filters',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${results.length} result${results.length == 1 ? '' : 's'} found',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                if (_mode == SearchMode.semantic)
                                  Text(
                                    'Relevance: ${_mode == SearchMode.keyword ? 'Keyword' : 'Semantic'}',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: Colors.blue.shade400,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.builder(
                              itemCount: results.length,
                              itemBuilder: (context, index) {
                                final r = results[index];
                              return SearchResultTile(
                                item: r.$1,
                                score: r.$2,
                                searchMode: _mode,
                                onTap: () => context.go('/content/${r.$1.id}'),
                              )
                                  .animate()
                                  .slideX(
                                    duration: 300.ms,
                                    delay: (50 * index).ms,
                                    begin: 0.2,
                                  );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFilterDialog<T>(
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
                      style: opt == selected
                          ? GoogleFonts.inter(fontWeight: FontWeight.w600)
                          : null,
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

// ── Result tile ────────────────────────────────────────────────────────

class SearchResultTile extends StatelessWidget {
  final ContentItemEntity item;
  final double score;
  final SearchMode searchMode;
  final VoidCallback onTap;

  const SearchResultTile({
    super.key,
    required this.item,
    required this.score,
    required this.searchMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scorePercent = score.clamp(0, 100).toStringAsFixed(0);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.title,
                      style: GoogleFonts.nunito(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Score badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getScoreColor(score),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$scorePercent%',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (item.subject != null)
                    _metaChip(item.subject!, Icons.category),
                  _metaChip(item.type, Icons.video_library),
                  _metaChip(
                    'L${item.difficultyLevel}',
                    item.difficultyLevel > 3 ? Icons.trending_up : Icons.trending_down,
                  ),
                ],
              ),
              if ((item.topicTags ?? '').isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Tags: ${item.topicTags}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaChip(String label, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green.shade500;
    if (score >= 60) return Colors.blue.shade500;
    if (score >= 40) return Colors.orange.shade500;
    return Colors.red.shade500;
  }
}

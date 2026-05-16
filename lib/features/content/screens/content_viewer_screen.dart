import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import '../../../ai/router/ai_router.dart';
import '../../../ai/vision/image_processing_queue_provider.dart';
import '../../../data/providers/current_user_provider.dart';
import '../../settings/settings_prefs.dart';
import '../../gamification/state/user_progress_notifier.dart';
import '../state/content_notifier.dart';
import '../../../ai/engagement/engagement_service.dart';
import 'package:shimmer/shimmer.dart';

class ContentViewerScreen extends ConsumerStatefulWidget {
  final String contentId;

  const ContentViewerScreen({
    super.key,
    required this.contentId,
  });

  @override
  ConsumerState<ContentViewerScreen> createState() => _ContentViewerScreenState();
}

class _ContentViewerScreenState extends ConsumerState<ContentViewerScreen> {
  final _scrollController = ScrollController();
  Timer? _tick;

  String _selectedText = '';
  String? _loadedPlainText;
  VideoPlayerController? _video;

  double _maxScrollExtentSeen = 0;
  double _lastPixels = 0;
  DateTime _lastTickAt = DateTime.now();
  int _lastWriteMs = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _tick = Timer.periodic(const Duration(seconds: 1), (_) => _writeProgress());
  }

  @override
  void dispose() {
    _tick?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _video?.dispose();
    super.dispose();
  }

  Future<String> _loadPlainText(String path) async {
    if (path.startsWith('assets/')) {
      return rootBundle.loadString(path);
    }
    return File(path).readAsString();
  }

  Future<List<int>> _loadBytes(String path) async {
    if (path.startsWith('assets/')) {
      final bd = await rootBundle.load(path);
      return bd.buffer.asUint8List();
    }
    return File(path).readAsBytes();
  }

  Future<void> _ensureVideoController(String path) async {
    final existing = _video;
    if (existing != null) return;
    final ctrl = path.startsWith('assets/')
        ? VideoPlayerController.asset(path)
        : VideoPlayerController.file(File(path));
    _video = ctrl;
    await ctrl.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _showExplainSheet(BuildContext context, String seedText) async {
    final router = ref.read(aiRouterProvider);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final controller = TextEditingController(text: seedText);
        final modeFuture = SettingsPrefs.getAiMode();
        Future<String>? future;
        String? result;
        Object? error;

        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> run() async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              setModalState(() {
                future = null;
                result = null;
                error = null;
              });
              final f = router.getExplanationWithConsent(
                context,
                text,
                contentId: widget.contentId,
              );
              setModalState(() {
                future = f;
              });
              try {
                final r = await f;
                if (!context.mounted) return;
                setModalState(() {
                  result = r;
                });
              } catch (e) {
                if (!context.mounted) return;
                setModalState(() {
                  error = e;
                });
              }
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: 16 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                   Row(
                     children: [
                       Expanded(
                         child: Text(
                           'Explain',
                           style: Theme.of(context).textTheme.titleLarge,
                         ),
                       ),
                       FutureBuilder<AiModePreference>(
                         future: modeFuture,
                         builder: (context, snap) {
                           final mode = snap.data;
                           return Text(
                             'Mode: ${mode?.name ?? '...'}',
                             style: Theme.of(context).textTheme.bodySmall,
                           );
                         },
                       ),
                     ],
                   ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Text to explain',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: run,
                    child: const Text('Explain'),
                  ),
                  const SizedBox(height: 12),
                  if (future != null && result == null && error == null)
                    const Center(child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(),
                    )),
                  if (error != null)
                    Text(
                      'Failed: $error',
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  if (result != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SelectionArea(child: Text(result!)),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final pixels = pos.pixels;
    if (_maxScrollExtentSeen < pixels) _maxScrollExtentSeen = pixels;

    final delta = pixels - _lastPixels;
    _lastPixels = pixels;

    final userId = ref.read(currentUserIdProvider);
    // We only need a coarse delta signal for the simulated classifier.
    ref
        .read(engagementServiceProvider((userId: userId, contentId: widget.contentId)))
        .recordScroll(velocityPx: delta);

    _writeProgress();
  }

  void _writeProgress() {
    final now = DateTime.now();
    final nowMs = now.millisecondsSinceEpoch;
    if (nowMs - _lastWriteMs < 1000) return;
    _lastWriteMs = nowMs;

    final userId = ref.read(currentUserIdProvider);

    final maxExtent = _scrollController.hasClients
        ? _scrollController.position.maxScrollExtent
        : 0.0;
    final completion = maxExtent <= 0
        ? 0.0
        : (_maxScrollExtentSeen / maxExtent).clamp(0.0, 1.0);

    final deltaSeconds = now.difference(_lastTickAt).inSeconds;
    _lastTickAt = now;

    ref.read(userProgressNotifierProvider(userId).notifier).touchContent(
          contentId: widget.contentId,
          completionPct: completion,
          deltaTimeSpentSeconds: deltaSeconds < 0 ? 0 : deltaSeconds,
        );
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserIdProvider);
    final item = ref.watch(contentByIdProvider(widget.contentId));
    final engagementAsync = ref.watch(
      engagementStateStreamProvider((userId: userId, contentId: widget.contentId)),
    );
    final currentEngagement = engagementAsync.valueOrNull ?? EngagementState.passive;

    ref.listen(
      adaptationEventStreamProvider((userId: userId, contentId: widget.contentId)),
      (prev, next) {
        final event = next.valueOrNull;
        if (event != null && prev?.valueOrNull != event) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(event.suggestion),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
    final progress = ref.watch(
      progressForContentProvider((userId: userId, contentId: widget.contentId)),
    );

    final seedText = () {
      final selected = _selectedText.trim();
      if (selected.isNotEmpty) return selected;
      final plain = _loadedPlainText?.trim();
      if (plain != null && plain.isNotEmpty) {
        return plain.substring(0, min(plain.length, 800));
      }
      if (item == null) return 'Explain this.';
      return 'Explain this content simply:\n\nTitle: ${item.title}\nSubject: ${item.subject ?? 'Unknown'}\nType: ${item.type}\nTags: ${item.topicTags ?? ''}';
    }();

    return Scaffold(
      appBar: AppBar(
        title: Text(item?.title ?? 'Content Viewer'),
        actions: [
          IconButton(
            tooltip: 'Explain',
            onPressed: item == null ? null : () => _showExplainSheet(context, seedText),
            icon: const Icon(Icons.lightbulb_outline),
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => ref
            .read(engagementServiceProvider((userId: userId, contentId: widget.contentId)))
            .recordTap(),
        child: Column(
          children: [
            Material(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Engagement: ${currentEngagement.name}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Progress: ${(((progress?.completionPct ?? 0) * 100)).toStringAsFixed(0)}%',
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: item == null
                  ? const Center(child: CircularProgressIndicator())
                  : _ContentBody(
                      item: item,
                      scrollController: _scrollController,
                      loadPlainText: _loadPlainText,
                      loadBytes: _loadBytes,
                      ensureVideoController: _ensureVideoController,
                      videoController: _video,
                      onPlainTextLoaded: (text) {
                        _loadedPlainText = text;
                      },
                      onSelectionChanged: (selected) {
                        setState(() => _selectedText = selected);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContentBody extends StatelessWidget {
  final dynamic item;
  final ScrollController scrollController;
  final Future<String> Function(String path) loadPlainText;
  final Future<List<int>> Function(String path) loadBytes;
  final Future<void> Function(String path) ensureVideoController;
  final VideoPlayerController? videoController;
  final void Function(String text) onPlainTextLoaded;
  final void Function(String selected) onSelectionChanged;

  const _ContentBody({
    required this.item,
    required this.scrollController,
    required this.loadPlainText,
    required this.loadBytes,
    required this.ensureVideoController,
    required this.videoController,
    required this.onPlainTextLoaded,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final type = (item.type as String).toLowerCase();
    final path = item.filePath as String;

    if (type == 'text') {
      return FutureBuilder<String>(
        future: loadPlainText(path),
        builder: (context, snapshot) {
          final text = snapshot.data;
          if (text != null) onPlainTextLoaded(text);
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load text: ${snapshot.error}'));
          }
          final t = text ?? '';
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              SelectableText(
                t,
                onSelectionChanged: (selection, cause) {
                  final start = selection.start;
                  final end = selection.end;
                  if (start < 0 || end < 0 || start == end) {
                    onSelectionChanged('');
                    return;
                  }
                  final s = start < end ? start : end;
                  final e = start < end ? end : start;
                  if (s >= 0 && e <= t.length) {
                    onSelectionChanged(t.substring(s, e));
                  }
                },
              ),
            ],
          );
        },
      );
    }

    if (type == 'docx') {
      return FutureBuilder<String>(
        future: () async {
          final bytes = await loadBytes(path);
          final text = docxToText(Uint8List.fromList(bytes));
          return text;
        }(),
        builder: (context, snapshot) {
          final text = snapshot.data;
          if (text != null) onPlainTextLoaded(text);
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load docx: ${snapshot.error}'));
          }
          final t = text ?? '';
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              SelectableText(
                t,
                onSelectionChanged: (selection, cause) {
                  final start = selection.start;
                  final end = selection.end;
                  if (start < 0 || end < 0 || start == end) {
                    onSelectionChanged('');
                    return;
                  }
                  final s = start < end ? start : end;
                  final e = start < end ? end : start;
                  if (s >= 0 && e <= t.length) {
                    onSelectionChanged(t.substring(s, e));
                  }
                },
              ),
            ],
          );
        },
      );
    }

    if (type == 'pdf') {
      if (path.startsWith('assets/')) {
        return SfPdfViewer.asset(path);
      }
      final f = File(path);
      if (!f.existsSync()) {
        return Center(child: Text('PDF not found: $path'));
      }
      return SfPdfViewer.file(f);
    }

    if (type == 'image') {
      return Consumer(builder: (context, ref, child) {
        final queue = ref.watch(imageQueueProvider);
        return StreamBuilder<bool>(
          stream: queue.isProcessingStream,
          initialData: false,
          builder: (ctx, snapshot) {
            if (snapshot.data == true) {
              return Center(
                child: SizedBox(
                  height: 200,
                  child:Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white),
                  ),
                ),
              );
            }
            final w = path.startsWith('assets/')
                ? Image.asset(path, fit: BoxFit.contain)
                : Image.file(File(path), fit: BoxFit.contain);
            return Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 5,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: w,
                ),
              ),
            );
          },
        );
      });
    }

    if (type == 'video') {
      return FutureBuilder<void>(
        future: ensureVideoController(path),
        builder: (context, snapshot) {
          final vc = videoController;
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load video: ${snapshot.error}'));
          }
          if (vc == null || !vc.value.isInitialized) {
            return const Center(child: Text('Video not available.'));
          }
          return Column(
            children: [
              AspectRatio(
                aspectRatio: vc.value.aspectRatio,
                child: VideoPlayer(vc),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      if (vc.value.isPlaying) {
                        await vc.pause();
                      } else {
                        await vc.play();
                      }
                    },
                    icon: Icon(vc.value.isPlaying ? Icons.pause : Icons.play_arrow),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }

    return Center(
      child: Text('Unsupported content type: $type'),
    );
  }
}

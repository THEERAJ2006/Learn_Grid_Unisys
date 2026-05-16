// ignore_for_file: deprecated_member_use
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/entities.dart';
import '../../../data/providers/current_user_provider.dart';
import '../../../data/providers/data_providers.dart';
import '../../content/state/content_notifier.dart';
import '../state/user_progress_notifier.dart';

// ── Computed stats ────────────────────────────────────────────────────────────

class _ProgressStats {
  final Map<String, double> completionBySubject; // subject → avg 0-1
  final Map<String, int> timeByType;             // type → seconds
  final int totalTimeSeconds;
  final int streakDays;
  final List<int> last30DayMinutes;
  final List<UserProgressEntity> allProgress;

  const _ProgressStats({
    required this.completionBySubject,
    required this.timeByType,
    required this.totalTimeSeconds,
    required this.streakDays,
    required this.last30DayMinutes,
    required this.allProgress,
  });
}

// ── Leaderboard streak provider ───────────────────────────────────────────────

final _myStreakProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(leaderboardRepositoryProvider);
  final entry = await repo.getByUser(userId);
  return entry?.streakDays ?? 0;
});

// ── Screen ────────────────────────────────────────────────────────────────────

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final progressAsync =
        ref.watch(userProgressNotifierProvider(userId));
    final contentAsync = ref.watch(contentNotifierProvider);
    final streakAsync = ref.watch(_myStreakProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(
          'My Progress',
          style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white70),
            onPressed: () {
              ref
                  .read(userProgressNotifierProvider(userId).notifier)
                  .reload();
              ref.invalidate(_myStreakProvider);
            },
          ),
        ],
      ),
      body: progressAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => _RetryView(
          message: 'Failed to load progress: $e',
          onRetry: () => ref
              .read(userProgressNotifierProvider(userId).notifier)
              .reload(),
        ),
        data: (progressMap) {
          final items = contentAsync.valueOrNull ?? [];
          final stats = _buildStats(progressMap, items);
          // Prefer leaderboard streak; fall back to computed.
          final streak =
              streakAsync.valueOrNull ?? stats.streakDays;

          return SingleChildScrollView(
            padding:
                const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Streak banner ──
                _StreakBanner(streakDays: streak)
                    .animate()
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 20),

                // ── Subject completion donuts ──
                _sectionHeader(context, '📊 Subject Completion'),
                const SizedBox(height: 12),
                stats.completionBySubject.isEmpty
                    ? _EmptyCard(
                        message:
                            'Start learning to see your subject progress!')
                    : _SubjectDonutRow(
                        completionBySubject:
                            stats.completionBySubject),
                const SizedBox(height: 24),

                // ── Time by content type ──
                _sectionHeader(
                    context, '⏱ Time Per Content Type'),
                const SizedBox(height: 12),
                stats.timeByType.isEmpty
                    ? _EmptyCard(
                        message: 'No time tracked yet.')
                    : _TimeBarChart(
                        timeByType: stats.timeByType),
                const SizedBox(height: 24),

                // ── 30-day heatmap ──
                _sectionHeader(
                    context, '📅 Activity (Last 30 Days)'),
                const SizedBox(height: 12),
                _ActivityHeatmap(
                    minutesByDay: stats.last30DayMinutes),
                const SizedBox(height: 24),

                // ── Per-content progress rows ──
                _sectionHeader(
                    context, '📖 Content Progress'),
                const SizedBox(height: 12),
                if (stats.allProgress.isEmpty)
                  _EmptyCard(
                      message:
                          'Open content to track your progress.')
                else
                  ...stats.allProgress
                      .asMap()
                      .entries
                      .map((e) {
                    final p = e.value;
                    String title = p.contentId;
                    for (final c in items) {
                      if (c.id == p.contentId) {
                        title = c.title;
                        break;
                      }
                    }
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: 8),
                      child: _ProgressTile(
                        title: title,
                        progress: p,
                        delay: Duration(
                            milliseconds:
                                40 * e.key.clamp(0, 10)),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }

  _ProgressStats _buildStats(
    Map<String, UserProgressEntity> progressMap,
    List<ContentItemEntity> items,
  ) {
    final all = progressMap.values.toList()
      ..sort(
          (a, b) => b.lastAccessedAt.compareTo(a.lastAccessedAt));

    final Map<String, List<double>> bySubject = {};
    final Map<String, int> timeByType = {};

    for (final p in all) {
      ContentItemEntity? item;
      for (final c in items) {
        if (c.id == p.contentId) {
          item = c;
          break;
        }
      }
      if (item != null) {
        final subj = item.subject ?? 'General';
        bySubject.putIfAbsent(subj, () => []).add(p.completionPct);
        timeByType[item.type] =
            (timeByType[item.type] ?? 0) + p.timeSpentSeconds;
      }
    }

    final completionBySubject = bySubject.map(
      (k, v) => MapEntry(
          k, v.reduce((a, b) => a + b) / v.length),
    );

    // 30-day heatmap.
    final now = DateTime.now();
    final buckets = List.filled(30, 0);
    for (final p in all) {
      final date =
          DateTime.fromMillisecondsSinceEpoch(p.lastAccessedAt);
      final diff = now.difference(date).inDays;
      if (diff >= 0 && diff < 30) {
        buckets[29 - diff] += (p.timeSpentSeconds ~/ 60);
      }
    }

    final totalTime =
        all.fold<int>(0, (sum, p) => sum + p.timeSpentSeconds);

    // Streak: consecutive days from today.
    final daysSet = all
        .map((p) =>
            DateTime.fromMillisecondsSinceEpoch(p.lastAccessedAt))
        .map((d) => DateFormat('yyyy-MM-dd').format(d))
        .toSet();
    int streak = 0;
    for (int i = 0; i < 30; i++) {
      final day = DateFormat('yyyy-MM-dd')
          .format(now.subtract(Duration(days: i)));
      if (daysSet.contains(day)) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    return _ProgressStats(
      completionBySubject: completionBySubject,
      timeByType: timeByType,
      totalTimeSeconds: totalTime,
      streakDays: streak,
      last30DayMinutes: buckets,
      allProgress: all,
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: Colors.white,
      ),
    );
  }
}

// ── Streak Banner ─────────────────────────────────────────────────────────────

class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.streakDays});
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C1E00), Color(0xFFE85D04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE85D04).withValues(alpha: 0.3),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          // Animated flame emoji.
          const Text('🔥', style: TextStyle(fontSize: 48))
              .animate(
                  onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(end: 1.12, duration: 1.2.seconds),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streakDays',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w900,
                    fontSize: 40,
                    color: Colors.white,
                    height: 1,
                  ),
                ),
                Text(
                  'Day${streakDays == 1 ? '' : 's'} Streak',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  streakDays == 0
                      ? 'Start learning today to build your streak!'
                      : 'Keep it up! You\'re on fire 🎉',
                  style: GoogleFonts.inter(
                      color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subject Donut Row ─────────────────────────────────────────────────────────

class _SubjectDonutRow extends StatelessWidget {
  const _SubjectDonutRow(
      {required this.completionBySubject});
  final Map<String, double> completionBySubject;

  static const _colors = [
    Color(0xFF06A77D),
    Color(0xFF0D9AE0),
    Color(0xFF7C3AED),
    Color(0xFFE85D04),
    Color(0xFFFFB800),
    Color(0xFF6C63FF),
  ];

  @override
  Widget build(BuildContext context) {
    final entries = completionBySubject.entries.toList();

    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        separatorBuilder: (ctx, r) =>
            const SizedBox(width: 12),
        itemCount: entries.length,
        itemBuilder: (ctx, i) {
          final entry = entries[i];
          final color = _colors[i % _colors.length];
          final value = entry.value.clamp(0.0, 1.0);
          final pct = (value * 100).round();

          return Container(
            width: 120,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: color.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      PieChart(
                        PieChartData(
                          startDegreeOffset: -90,
                          sectionsSpace: 0,
                          centerSpaceRadius: 28,
                          sections: [
                            PieChartSectionData(
                              value: value,
                              color: color,
                              radius: 10,
                              showTitle: false,
                            ),
                            PieChartSectionData(
                              value: 1 - value,
                              color: color.withValues(
                                  alpha: 0.12),
                              radius: 10,
                              showTitle: false,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '$pct%',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  entry.key,
                  style: GoogleFonts.inter(
                      color: Colors.white70,
                      fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ).animate(delay: Duration(milliseconds: 80 * i))
              .fadeIn(duration: 350.ms);
        },
      ),
    );
  }
}

// ── Time Bar Chart ────────────────────────────────────────────────────────────

class _TimeBarChart extends StatelessWidget {
  const _TimeBarChart({required this.timeByType});
  final Map<String, int> timeByType;

  static const _allTypes = ['text', 'video', 'pdf', 'image', 'docx'];

  static const _colors = <String, Color>{
    'text': Color(0xFF06A77D),
    'video': Color(0xFFE85D04),
    'pdf': Color(0xFFFF4B4B),
    'image': Color(0xFF7C3AED),
    'docx': Color(0xFF0D9AE0),
  };

  @override
  Widget build(BuildContext context) {
    // Ensure all 4 required types appear on the axis.
    final displayTypes = _allTypes
        .where((t) => timeByType.containsKey(t))
        .toList();

    if (displayTypes.isEmpty) {
      return _EmptyCard(message: 'No time tracked yet.');
    }

    final entries =
        displayTypes.map((t) => MapEntry(t, timeByType[t]!)).toList();
    final maxVal = entries
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();
    final safeMax = maxVal <= 0 ? 60.0 : maxVal;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF1E2E4A), width: 0.8),
      ),
      child: BarChart(
        BarChartData(
          maxY: safeMax * 1.2,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => const FlLine(
                color: Color(0xFF1E2E4A), strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= entries.length) {
                    return const SizedBox();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      entries[i].key,
                      style: GoogleFonts.inter(
                          color: Colors.white54,
                          fontSize: 10),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: safeMax / 4,
                reservedSize: 40,
                getTitlesWidget: (v, _) => Text(
                  '${(v / 60).round()}m',
                  style: GoogleFonts.inter(
                      color: Colors.white30, fontSize: 9),
                ),
              ),
            ),
          ),
          barGroups: entries.asMap().entries.map((e) {
            final color =
                _colors[e.value.key] ?? AppTheme.accent;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.value.toDouble(),
                  color: color,
                  width: 22,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(6)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: safeMax * 1.2,
                    color: color.withValues(alpha: 0.06),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ── Activity Heatmap ──────────────────────────────────────────────────────────

class _ActivityHeatmap extends StatelessWidget {
  const _ActivityHeatmap({required this.minutesByDay});
  final List<int> minutesByDay; // length 30, oldest first

  Color _cellColor(int minutes) {
    if (minutes == 0) return const Color(0xFF1E2E4A);
    if (minutes < 10) {
      return Color.lerp(
          const Color(0xFF1E2E4A),
          AppTheme.accent.withValues(alpha: 0.4),
          minutes / 10)!;
    }
    if (minutes < 60) {
      return Color.lerp(AppTheme.accent.withValues(alpha: 0.4),
          AppTheme.accent, (minutes - 10) / 50)!;
    }
    return AppTheme.accent;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF1E2E4A), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: minutesByDay.asMap().entries.map((e) {
              final daysAgo = 29 - e.key;
              final date =
                  now.subtract(Duration(days: daysAgo));
              final color = _cellColor(e.value);

              return Tooltip(
                message:
                    '${DateFormat('MMM d').format(date)}: ${e.value}min',
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          // Legend.
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Less',
                  style: GoogleFonts.inter(
                      color: Colors.white30, fontSize: 10)),
              const SizedBox(width: 6),
              ...List.generate(
                5,
                (i) => Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(right: 3),
                  decoration: BoxDecoration(
                    color: _cellColor(i == 0
                        ? 0
                        : i == 1
                            ? 5
                            : i == 2
                                ? 20
                                : i == 3
                                    ? 45
                                    : 60),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text('60+ min',
                  style: GoogleFonts.inter(
                      color: Colors.white30, fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Progress Tile ─────────────────────────────────────────────────────────────

class _ProgressTile extends StatelessWidget {
  const _ProgressTile({
    required this.title,
    required this.progress,
    required this.delay,
  });

  final String title;
  final UserProgressEntity progress;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final pct = (progress.completionPct * 100).round();
    final minutes = (progress.timeSpentSeconds ~/ 60);
    final color = pct >= 80
        ? const Color(0xFF06A77D)
        : pct >= 40
            ? AppTheme.accent
            : const Color(0xFFE85D04);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF1E2E4A), width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '$pct%',
                style: GoogleFonts.nunito(
                    color: color,
                    fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.completionPct.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$minutes min spent',
            style: GoogleFonts.inter(
                color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.08, end: 0);
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: const Color(0xFF1E2E4A), width: 0.8),
      ),
      child: Center(
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
              color: Colors.white54, fontSize: 13),
        ),
      ),
    );
  }
}

class _RetryView extends StatelessWidget {
  const _RetryView(
      {required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline,
              color: Color(0xFFE85D04), size: 48),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

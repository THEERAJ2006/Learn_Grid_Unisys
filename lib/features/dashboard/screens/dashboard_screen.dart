// ignore_for_file: deprecated_member_use
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../ai/recommendation/recommendation_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/entities.dart';
import '../../../data/providers/current_user_provider.dart';
import '../../../data/providers/data_providers.dart';
import '../../content/state/content_notifier.dart';
import '../../content/state/engagement_notifier.dart';
import '../../gamification/state/user_progress_notifier.dart';
import '../../settings/settings_prefs.dart';

// ── Subjects meta ─────────────────────────────────────────────────────────────

const _subjects = [
  _SubjectMeta('Science', Icons.science_outlined,
      Color(0xFF06A77D), Color(0xFF04E8AD)),
  _SubjectMeta('Maths', Icons.calculate_outlined,
      Color(0xFF0D9AE0), Color(0xFF5CC8FF)),
  _SubjectMeta('English', Icons.menu_book_outlined,
      Color(0xFF7C3AED), Color(0xFFBB8BFF)),
  _SubjectMeta('History', Icons.history_edu_outlined,
      Color(0xFFE85D04), Color(0xFFFF9B4B)),
  _SubjectMeta('Geography', Icons.public_outlined,
      Color(0xFF1A3A5C), Color(0xFF5585B5)),
  _SubjectMeta('Technology', Icons.laptop_outlined,
      Color(0xFF6C63FF), Color(0xFF9E98FF)),
];

class _SubjectMeta {
  final String name;
  final IconData icon;
  final Color color;
  final Color lightColor;
  const _SubjectMeta(this.name, this.icon, this.color, this.lightColor);
}

// ── Providers ─────────────────────────────────────────────────────────────────

final _myLeaderboardEntryProvider =
    FutureProvider.autoDispose<LeaderboardEntryEntity?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(leaderboardRepositoryProvider);
  return repo.getByUser(userId);
});

// ── Screen ────────────────────────────────────────────────────────────────────

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() =>
      _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  AiModePreference _aiMode = AiModePreference.offlineOnly;

  @override
  void initState() {
    super.initState();
    _loadAiMode();
    _ensureUserInLeaderboard();
  }

  Future<void> _ensureUserInLeaderboard() async {
    final userId = ref.read(currentUserIdProvider);
    final repo = ref.read(leaderboardRepositoryProvider);
    final existing = await repo.getByUser(userId);
    if (existing == null) {
      await repo.update(LeaderboardEntryEntity(
        id: userId,
        userId: userId,
        displayName: 'My Device (${userId.substring(0, 4)})',
        totalPoints: 0,
        weeklyPoints: 0,
        streakDays: 0,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ));
      ref.invalidate(_myLeaderboardEntryProvider);
      // Note: leaderboardProvider is in leaderboard_screen.dart, 
      // but invalidating it here is safe if it's already used.
    }
  }

  Future<void> _loadAiMode() async {
    final mode = await SettingsPrefs.getAiMode();
    if (mounted) setState(() => _aiMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentNotifierProvider);
    final userId = ref.watch(currentUserIdProvider);
    final progress = ref.watch(userProgressNotifierProvider(userId));
    final recommender = ref.watch(recommendationServiceProvider);
    final leaderEntry = ref.watch(_myLeaderboardEntryProvider);
    final recentSessions = ref.watch(recentSessionsProvider(userId));

    // Greeting: device-like ID from userId first 6 chars.
    final shortId = userId.length >= 6
        ? userId.substring(0, 6)
        : userId;
    final greeting = _greeting();
    final today = DateFormat('EEEE, d MMM').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: content.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorView(
          error: '$e',
          onRetry: () =>
              ref.read(contentNotifierProvider.notifier).refresh(),
        ),
        data: (items) {
          final progressMap =
              progress.valueOrNull ??
              const <String, UserProgressEntity>{};

          final recs = items.isEmpty
              ? <ContentItemEntity>[]
              : recommender
                  .recommend(
                    all: items,
                    currentContentId: null,
                    engagementState: 'passive',
                    progressByContent: progressMap,
                  )
                  .take(3)
                  .toList();

          final sessions = recentSessions.valueOrNull ?? [];

          return RefreshIndicator(
            onRefresh: () async {
              ref
                  .read(contentNotifierProvider.notifier)
                  .refresh();
              ref.invalidate(_myLeaderboardEntryProvider);
            },
            child: CustomScrollView(
              slivers: [
                // ── Greeting header ──
                SliverAppBar(
                  expandedHeight: 190,
                  backgroundColor: AppTheme.surface,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _HeaderBanner(
                      greeting: greeting,
                      shortId: shortId,
                      today: today,
                      streakDays:
                          leaderEntry.valueOrNull?.streakDays ?? 0,
                      totalPoints:
                          leaderEntry.valueOrNull?.totalPoints ?? 0,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined,
                          color: Colors.white70),
                      onPressed: () => context.go('/settings'),
                    ),
                  ],
                ),

                // ── AI status chip ──
                SliverToBoxAdapter(
                  child: _AiStatusChip(
                    mode: _aiMode,
                    onTap: () async {
                      await context.push('/settings');
                      // Reload mode after returning from settings.
                      final mode =
                          await SettingsPrefs.getAiMode();
                      if (mounted) {
                        setState(() => _aiMode = mode);
                      }
                    },
                  ),
                ),

                // ── Web Banner ──
                if (kIsWeb)
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Running in web mode — cloud AI only. Download the app for full offline AI.',
                              style: GoogleFonts.inter(color: Colors.blue, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // ── Recommendations ──
                if (recs.isNotEmpty) ...[
                  _sectionHeader(context, '✨ Recommended for You',
                      trailing: TextButton(
                        onPressed: () => context.go('/content'),
                        child: const Text('See all'),
                      )),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16),
                        separatorBuilder: (ctx, r) =>
                            const SizedBox(width: 12),
                        itemCount: recs.length,
                        itemBuilder: (ctx, i) => _ContentCard(
                          item: recs[i],
                          delay: Duration(
                              milliseconds: 80 * i),
                        ),
                      ),
                    ),
                  ),
                ],

                // ── Subjects grid ──
                _sectionHeader(context, '📚 Subjects'),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16),
                  sliver: SliverGrid.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.1,
                    children: _subjects
                        .asMap()
                        .entries
                        .map(
                          (e) => _SubjectCard(
                            meta: e.value,
                            delay: Duration(
                                milliseconds: 50 * e.key),
                            onTap: () =>
                                context.go('/search'),
                          ),
                        )
                        .toList(),
                  ),
                ),

                // ── Recent activity timeline ──
                _sectionHeader(context, '🕐 Recent Activity'),
                sessions.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                                  16, 0, 16, 8),
                          child: _EmptyCard(
                              message:
                                  'Start studying to see your activity here.'),
                        ),
                      )
                    : SliverPadding(
                        padding: const EdgeInsets.fromLTRB(
                            16, 0, 16, 8),
                        sliver: SliverList.separated(
                          separatorBuilder: (ctx, r) =>
                              const SizedBox(height: 6),
                          itemCount: sessions.length,
                          itemBuilder: (ctx, i) =>
                              _ActivityTimelineTile(
                            session: sessions[i],
                            contentItems: items,
                            isLast: i == sessions.length - 1,
                          ),
                        ),
                      ),

                const SliverToBoxAdapter(
                    child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/content'),
        backgroundColor: AppTheme.accent,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Add Content',
          style: GoogleFonts.inter(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _sectionHeader(BuildContext context, String title,
      {Widget? trailing}) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 8, 8),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.nunito(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            trailing ?? const SizedBox(),
          ],
        ),
      ),
    );
  }
}

// ── Header Banner ─────────────────────────────────────────────────────────────

class _HeaderBanner extends StatelessWidget {
  const _HeaderBanner({
    required this.greeting,
    required this.shortId,
    required this.today,
    required this.streakDays,
    required this.totalPoints,
  });

  final String greeting;
  final String shortId;
  final String today;
  final int streakDays;
  final int totalPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D1B2A), AppTheme.surface],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 56,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  today,
                  style: GoogleFonts.inter(
                      color: Colors.white38, fontSize: 11),
                ),
                const SizedBox(height: 2),
                Text(
                  '$greeting, $shortId 👋',
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w800,
                    fontSize: 21,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _StatPill(
                icon: Icons.local_fire_department,
                value: '$streakDays',
                label: 'day streak',
                color: const Color(0xFFE85D04),
              ),
              const SizedBox(height: 6),
              _StatPill(
                icon: Icons.star_rounded,
                value: '$totalPoints',
                label: 'points',
                color: const Color(0xFFFFD700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 5),
          Text(
            '$value $label',
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── AI Status Chip ────────────────────────────────────────────────────────────

class _AiStatusChip extends StatelessWidget {
  const _AiStatusChip({
    required this.mode,
    required this.onTap,
  });

  final AiModePreference mode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isCloud = mode == AiModePreference.alwaysCloud;
    final label = isCloud ? 'Cloud AI (Gemini)' : 'Offline AI';
    final color = isCloud
        ? const Color(0xFF4285F4)
        : const Color(0xFF06A77D);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
                color: color.withValues(alpha: 0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              )
                  .animate(
                      onPlay: (c) => c.repeat(reverse: true))
                  .scaleXY(end: 1.3, duration: 1.seconds),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right,
                  color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Content card (horizontal scroll) ─────────────────────────────────────────

class _ContentCard extends StatelessWidget {
  const _ContentCard({required this.item, required this.delay});
  final ContentItemEntity item;
  final Duration delay;

  Color get _typeColor => switch (item.type) {
        'video' => const Color(0xFFE85D04),
        'pdf' => const Color(0xFFFF4B4B),
        'image' => const Color(0xFF7C3AED),
        'docx' => const Color(0xFF0D9AE0),
        _ => const Color(0xFF06A77D),
      };

  IconData get _typeIcon => switch (item.type) {
        'video' => Icons.play_circle_outline,
        'pdf' => Icons.picture_as_pdf_outlined,
        'image' => Icons.image_outlined,
        'docx' => Icons.description_outlined,
        _ => Icons.article_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/content/${item.id}'),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _typeColor.withValues(alpha: 0.25),
              AppTheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _typeColor.withValues(alpha: 0.35),
              width: 1),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_typeIcon, color: _typeColor, size: 28),
            const Spacer(),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                _DifficultyDots(level: item.difficultyLevel),
                const Spacer(),
                if (item.subject != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: _typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.subject!,
                      style: GoogleFonts.inter(
                          color: _typeColor, fontSize: 8),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.15, end: 0, curve: Curves.easeOut);
  }
}

class _DifficultyDots extends StatelessWidget {
  const _DifficultyDots({required this.level});
  final int level;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(right: 2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < level ? AppTheme.accent : Colors.white12,
          ),
        ),
      ),
    );
  }
}

// ── Subject card ──────────────────────────────────────────────────────────────

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.meta,
    required this.onTap,
    required this.delay,
  });

  final _SubjectMeta meta;
  final VoidCallback onTap;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              meta.color.withValues(alpha: 0.3),
              meta.color.withValues(alpha: 0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: meta.color.withValues(alpha: 0.35),
              width: 0.8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(meta.icon, color: meta.lightColor, size: 28),
            const SizedBox(height: 6),
            Text(
              meta.name,
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 300.ms)
        .scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1, 1));
  }
}

// ── Activity timeline tile ────────────────────────────────────────────────────

class _ActivityTimelineTile extends StatelessWidget {
  const _ActivityTimelineTile({
    required this.session,
    required this.contentItems,
    required this.isLast,
  });

  final EngagementSessionEntity session;
  final List<ContentItemEntity> contentItems;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    // Resolve content title.
    String title = 'Unknown content';
    for (final item in contentItems) {
      if (item.id == session.contentId) {
        title = item.title;
        break;
      }
    }

    final stateColor = switch (session.state) {
      'focused' => const Color(0xFF06A77D),
      'passive' => AppTheme.accent,
      'fatigued' => const Color(0xFFE85D04),
      _ => Colors.white38,
    };

    final stateIcon = switch (session.state) {
      'focused' => Icons.bolt,
      'passive' => Icons.remove_red_eye_outlined,
      'fatigued' => Icons.bedtime_outlined,
      _ => Icons.hourglass_empty_outlined,
    };

    final timeAgo = _formatTimeAgo(
        DateTime.fromMillisecondsSinceEpoch(session.startedAt));
    final minutes = session.durationSeconds ~/ 60;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline dot + line.
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: stateColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                    color: stateColor.withValues(alpha: 0.4)),
              ),
              child: Icon(stateIcon, color: stateColor, size: 16),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: Colors.white12,
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Content.
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      timeAgo,
                      style: GoogleFonts.inter(
                          color: Colors.white38, fontSize: 11),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: stateColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color:
                                stateColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        session.state,
                        style: GoogleFonts.inter(
                            color: stateColor, fontSize: 9),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${minutes}m',
                      style: GoogleFonts.inter(
                          color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ── Empty card ────────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFF1E2E4A), width: 0.8),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style:
            GoogleFonts.inter(color: Colors.white54, fontSize: 13),
      ),
    );
  }
}

// ── Error view ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});
  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                color: Color(0xFFE85D04), size: 56),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

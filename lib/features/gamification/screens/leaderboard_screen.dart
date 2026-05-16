// ignore_for_file: deprecated_member_use
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/entities.dart';
import '../../../data/providers/current_user_provider.dart';
import '../../../data/providers/data_providers.dart';
import '../../../services/p2p/p2p_service.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final leaderboardProvider =
    FutureProvider<List<LeaderboardEntryEntity>>((ref) async {
  final repo = ref.watch(leaderboardRepositoryProvider);
  // Fetch all entries, sorted by weeklyPoints DESC (done in UI).
  return repo.getTop(limit: 50);
});

// ── Screen ────────────────────────────────────────────────────────────────────

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() =>
      _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  StreamSubscription<P2PEvent>? _p2pSub;

  Future<void> _startP2PSync() async {
    if (_syncing) return;
    setState(() => _syncing = true);
    
    final p2p = ref.read(p2pServiceProvider);
    
    _p2pSub?.cancel();
    _p2pSub = p2p.events.listen((event) {
      if (!mounted) return;
      if (event.type == P2PEventType.peerDiscovered) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Discovered peer: ${event.peerName}')),
        );
      } else if (event.type == P2PEventType.transferComplete && event.receivedContent != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Received content: ${event.receivedContent!.title}')),
        );
      }
    });

    p2p.startDiscovery();
    p2p.startAdvertising();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Searching for nearby peers...')),
    );

    // Stop after 15 seconds for this MVP
    await Future.delayed(const Duration(seconds: 15));
    
    p2p.stopDiscovery();
    p2p.stopAdvertising();
    _p2pSub?.cancel();
    
    if (mounted) setState(() => _syncing = false);
  }

  @override
  Widget build(BuildContext context) {
    final allEntries = ref.watch(leaderboardProvider);
    final userId = ref.watch(currentUserIdProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Text(
          'Leaderboard',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        actions: [
          // P2P sync button.
          _syncing
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white70),
                    ),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.sync, color: Colors.white70),
                  tooltip: 'P2P Sync',
                  onPressed: _startP2PSync,
                ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white54),
            onPressed: () => ref.invalidate(leaderboardProvider),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accent,
          labelColor: AppTheme.accent,
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Weekly'),
            Tab(text: 'All Time'),
          ],
        ),
      ),
      body: allEntries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: Colors.redAccent, size: 48),
              const SizedBox(height: 12),
              Text('Failed to load leaderboard',
                  style: GoogleFonts.inter(color: Colors.white70)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(leaderboardProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (entries) {
          final weekly = [...entries]
            ..sort((a, b) =>
                b.weeklyPoints.compareTo(a.weeklyPoints));
          final allTime = [...entries]
            ..sort((a, b) =>
                b.totalPoints.compareTo(a.totalPoints));

          return TabBarView(
            controller: _tabController,
            children: [
              _LeaderboardList(
                  entries: weekly,
                  currentUserId: userId,
                  isWeekly: true),
              _LeaderboardList(
                  entries: allTime,
                  currentUserId: userId,
                  isWeekly: false),
            ],
          );
        },
      ),
    );
  }
}

// ── Leaderboard list ──────────────────────────────────────────────────────────

class _LeaderboardList extends StatelessWidget {
  const _LeaderboardList({
    required this.entries,
    required this.currentUserId,
    required this.isWeekly,
  });

  final List<LeaderboardEntryEntity> entries;
  final String currentUserId;
  final bool isWeekly;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emoji_events_outlined,
                color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            Text(
              'No entries yet.\nStart learning to appear here!',
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.inter(color: Colors.white54, fontSize: 15),
            ),
          ],
        ),
      );
    }

    final myRank =
        entries.indexWhere((e) => e.userId == currentUserId);

    // Split podium (top 3) and rest (4–10+).
    final podiumEntries = entries.take(3).toList();
    final listEntries = entries.length > 3
        ? entries.skip(3).take(7).toList()
        : <LeaderboardEntryEntity>[];

    return CustomScrollView(
      slivers: [
        // Weekly reset countdown banner.
        if (isWeekly)
          SliverToBoxAdapter(child: _WeeklyCountdown()),

        // Top 3 podium.
        if (podiumEntries.length >= 3)
          SliverToBoxAdapter(
            child: _Podium(entries: podiumEntries),
          ),

        // Ranks 4–10 compact tiles.
        if (listEntries.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverList.separated(
              itemCount: listEntries.length,
              separatorBuilder: (ctx, r) =>
                  const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final entry = listEntries[i];
                final rank = i + 4; // offset by 3 podium positions
                final isMe = entry.userId == currentUserId;
                final points = isWeekly
                    ? entry.weeklyPoints
                    : entry.totalPoints;

                return _LeaderboardTile(
                  rank: rank,
                  entry: entry,
                  points: points,
                  isMe: isMe,
                  isWeekly: isWeekly,
                  delay: Duration(milliseconds: 40 * i.clamp(0, 10)),
                );
              },
            ),
          ),

        // Current user's row pinned to bottom if not in top 10.
        if (myRank == -1 || myRank >= 10)
          SliverToBoxAdapter(
            child: _MyRankBanner(currentUserId: currentUserId),
          ),

        // Bottom padding.
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}

// ── Podium ────────────────────────────────────────────────────────────────────

class _Podium extends StatelessWidget {
  const _Podium({required this.entries});
  final List<LeaderboardEntryEntity> entries;

  @override
  Widget build(BuildContext context) {
    final podiumColors = [
      const Color(0xFFFFD700), // Gold – 1st
      const Color(0xFFC0C0C0), // Silver – 2nd
      const Color(0xFFCD7F32), // Bronze – 3rd
    ];

    // Display order: 2nd | 1st | 3rd
    final displayOrder = [1, 0, 2];
    final heights = [90.0, 130.0, 70.0];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1E35), Color(0xFF1A2A4A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: const Color(0xFF253255), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: displayOrder.asMap().entries.map((e) {
          final idx = e.value;
          final entry = entries[idx];
          final color = podiumColors[idx];
          final rank = idx + 1;
          return _PodiumColumn(
            entry: entry,
            rank: rank,
            color: color,
            height: heights[e.key],
          );
        }).toList(),
      ),
    )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({
    required this.entry,
    required this.rank,
    required this.color,
    required this.height,
  });

  final LeaderboardEntryEntity entry;
  final int rank;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Avatar circle.
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.8), color],
            ),
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              entry.displayName.isNotEmpty
                  ? entry.displayName[0].toUpperCase()
                  : '?',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          entry.displayName.length > 10
              ? '${entry.displayName.substring(0, 9)}…'
              : entry.displayName,
          style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          '${entry.weeklyPoints} pts',
          style: GoogleFonts.inter(
              color: Colors.white54, fontSize: 10),
        ),
        const SizedBox(height: 8),
        // Podium block.
        Container(
          width: 70,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.35),
                color.withValues(alpha: 0.15)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  color: color),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.rank,
    required this.entry,
    required this.points,
    required this.isMe,
    required this.isWeekly,
    required this.delay,
  });

  final int rank;
  final LeaderboardEntryEntity entry;
  final int points;
  final bool isMe;
  final bool isWeekly;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final rankColor = rank == 1
        ? const Color(0xFFFFD700)
        : rank == 2
            ? const Color(0xFFC0C0C0)
            : rank == 3
                ? const Color(0xFFCD7F32)
                : Colors.white38;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: isMe
            ? const LinearGradient(
                colors: [Color(0xFF0D3560), Color(0xFF1843A0)],
              )
            : null,
        color: isMe ? null : const Color(0xFF151F35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isMe ? AppTheme.accent : const Color(0xFF1E2E4A),
          width: isMe ? 1.5 : 0.8,
        ),
      ),
      child: Row(
        children: [
          // Rank badge.
          SizedBox(
            width: 36,
            child: Text(
              '#$rank',
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: rankColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Avatar.
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isMe
                  ? AppTheme.accent.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                entry.displayName.isNotEmpty
                    ? entry.displayName[0].toUpperCase()
                    : '?',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: isMe ? AppTheme.accent : Colors.white70,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + streak.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.displayName,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppTheme.accent
                              .withValues(alpha: 0.2),
                          borderRadius:
                              BorderRadius.circular(4),
                          border: Border.all(
                              color: AppTheme.accent
                                  .withValues(alpha: 0.5)),
                        ),
                        child: Text('You',
                            style: GoogleFonts.inter(
                                color: AppTheme.accent,
                                fontSize: 9,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: Color(0xFFE85D04), size: 14),
                    const SizedBox(width: 2),
                    Text(
                      '${entry.streakDays}d streak',
                      style: GoogleFonts.inter(
                          color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Points.
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$points',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: isMe ? AppTheme.accent : Colors.white,
                ),
              ),
              Text(
                'pts',
                style: GoogleFonts.inter(
                    color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    )
        .animate(delay: delay)
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }
}

// ── My Rank Banner ────────────────────────────────────────────────────────────

class _MyRankBanner extends StatelessWidget {
  const _MyRankBanner({required this.currentUserId});
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D3560),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: AppTheme.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.person_pin,
              color: AppTheme.accent, size: 20),
          const SizedBox(width: 10),
          Text(
            'Keep learning to join the leaderboard!',
            style:
                GoogleFonts.inter(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

// ── Weekly Countdown ──────────────────────────────────────────────────────────

class _WeeklyCountdown extends StatefulWidget {
  @override
  State<_WeeklyCountdown> createState() => _WeeklyCountdownState();
}

class _WeeklyCountdownState extends State<_WeeklyCountdown> {
  late Timer _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = _timeUntilMonday();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _remaining = _timeUntilMonday());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Duration _timeUntilMonday() {
    final now = DateTime.now();
    final daysUntilMonday = (DateTime.monday - now.weekday + 7) % 7;
    final nextMonday = DateTime(
      now.year,
      now.month,
      now.day + (daysUntilMonday == 0 ? 7 : daysUntilMonday),
    );
    return nextMonday.difference(now);
  }

  @override
  Widget build(BuildContext context) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFF2E1065).withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timer_outlined,
              color: Color(0xFF6C63FF), size: 18),
          const SizedBox(width: 8),
          Text(
            'Weekly reset in  ',
            style:
                GoogleFonts.inter(color: Colors.white54, fontSize: 12),
          ),
          Text(
            '${days}d ${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m',
            style: GoogleFonts.nunito(
              color: const Color(0xFF6C63FF),
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

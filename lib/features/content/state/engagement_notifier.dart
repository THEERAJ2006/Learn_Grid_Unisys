import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/entities.dart';
import '../../../data/providers/data_providers.dart';

/// Fetches the last 5 engagement sessions for [userId], sorted newest-first.
/// Used by DashboardScreen's Recent Activity timeline.
final recentSessionsProvider =
    FutureProvider.autoDispose
        .family<List<EngagementSessionEntity>, String>((ref, userId) async {
  final repo = ref.watch(engagementRepositoryProvider);
  final sessions = await repo.getUserSessions(userId);
  sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
  return sessions.take(5).toList();
});

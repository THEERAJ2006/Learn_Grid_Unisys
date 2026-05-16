import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../data/models/entities.dart';
import '../../../data/providers/data_providers.dart';
import '../../../data/repositories/repository_interfaces.dart';

typedef UserProgressState = AsyncValue<Map<String, UserProgressEntity>>;

final userProgressNotifierProvider = AsyncNotifierProvider.family<
    UserProgressNotifier, Map<String, UserProgressEntity>, String>(
  UserProgressNotifier.new,
);

final progressForContentProvider =
    Provider.family<UserProgressEntity?, ({String userId, String contentId})>(
        (ref, args) {
  final map = ref
          .watch(userProgressNotifierProvider(args.userId))
          .valueOrNull ??
      const <String, UserProgressEntity>{};
  return map[args.contentId];
});

class UserProgressNotifier
    extends FamilyAsyncNotifier<Map<String, UserProgressEntity>, String> {
  late final ProgressRepository _repo;
  late final String _userId;
  final _uuid = const Uuid();

  @override
  Future<Map<String, UserProgressEntity>> build(String arg) async {
    _userId = arg;
    _repo = ref.watch(progressRepositoryProvider);
    final rows = await _repo.getAllByUser(_userId);
    return {
      for (final r in rows) r.contentId: r,
    };
  }

  Future<void> _refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final rows = await _repo.getAllByUser(_userId);
      return {
        for (final r in rows) r.contentId: r,
      };
    });
  }

  Future<void> touchContent({
    required String contentId,
    required double completionPct,
    required int deltaTimeSpentSeconds,
    int? difficultyRating,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final current = state.valueOrNull?[contentId];
    final next = UserProgressEntity(
      id: current?.id ?? _uuid.v4(),
      userId: _userId,
      contentId: contentId,
      completionPct: completionPct.clamp(0.0, 1.0),
      lastAccessedAt: now,
      difficultyRating: difficultyRating ?? current?.difficultyRating,
      timeSpentSeconds:
          (current?.timeSpentSeconds ?? 0) + deltaTimeSpentSeconds,
    );

    await _repo.upsert(next);
    debugPrint('[PROGRESS] Content $contentId: ${(next.completionPct * 100).toStringAsFixed(1)}% complete, total ${next.timeSpentSeconds}s');

    // Optimistic local update.
    state = AsyncData({
      ...?state.valueOrNull,
      contentId: next,
    });
  }

  Future<void> setCompletion({
    required String contentId,
    required double completionPct,
  }) async {
    await touchContent(
      contentId: contentId,
      completionPct: completionPct,
      deltaTimeSpentSeconds: 0,
    );
  }

  Future<void> reload() => _refresh();
}

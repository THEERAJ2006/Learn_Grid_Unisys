import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/entities.dart';
import '../../data/providers/data_providers.dart';
import '../../data/repositories/repository_interfaces.dart';

// ── Enums & Events ────────────────────────────────────────────────────────────

enum EngagementState {
  focused,
  passive,
  fatigued,
  absent,
}

class ContentAdaptationEvent {
  final String contentId;
  final String suggestion;

  ContentAdaptationEvent({
    required this.contentId,
    required this.suggestion,
  });
}

// ── Signal window ─────────────────────────────────────────────────────────────

class EngagementSignalWindow {
  final int tapCount;
  final double scrollVelocity; // logical pixels / second
  final double idleSeconds;
  final Duration window;

  const EngagementSignalWindow({
    required this.tapCount,
    required this.scrollVelocity,
    required this.idleSeconds,
    this.window = const Duration(seconds: 5),
  });

  Map<String, dynamic> toMap() {
    return {
      'tapCount': tapCount,
      'scrollVelocity': scrollVelocity,
      'idleSeconds': idleSeconds,
      'windowSeconds': window.inSeconds,
    };
  }

  static EngagementSignalWindow fromMap(Map<String, dynamic> map) {
    return EngagementSignalWindow(
      tapCount: map['tapCount'],
      scrollVelocity: map['scrollVelocity'],
      idleSeconds: map['idleSeconds'],
      window: Duration(seconds: map['windowSeconds']),
    );
  }
}

// ── Compute Function ──────────────────────────────────────────────────────────

EngagementState _classifyCompute(Map<String, dynamic> windowMap) {
  final w = EngagementSignalWindow.fromMap(windowMap);

  if (w.idleSeconds >= max(3.5, w.window.inSeconds * 0.7)) {
    return EngagementState.absent;
  }

  final activityScore =
      (w.tapCount * 0.8) + (w.scrollVelocity.abs() / 500.0) - w.idleSeconds;

  if (activityScore >= 2.5) return EngagementState.focused;
  if (activityScore >= 1.0) return EngagementState.passive;
  return EngagementState.fatigued;
}

// ── Real-time tracker ─────────────────────────────────────────────────────────

class EngagementService {
  final String contentId;
  final String userId;
  final EngagementRepository repo;

  static const _windowSeconds = 5;

  int _windowTaps = 0;
  double _windowScrollTotal = 0;
  int _windowIdleSeconds = 0;
  int _windowScrollEvents = 0;
  int _sessionSeq = 0;

  int _secondsSinceLastInteraction = 0;
  int _consecutiveFatigueWindows = 0;

  Timer? _windowTimer;
  Timer? _secondTicker;

  final _stateCtrl = StreamController<EngagementState>.broadcast();
  final _adaptationCtrl = StreamController<ContentAdaptationEvent>.broadcast();

  EngagementState _currentState = EngagementState.passive;

  EngagementService({
    required this.contentId,
    required this.userId,
    required this.repo,
  });

  Stream<EngagementState> get engagementStateStream => _stateCtrl.stream;
  Stream<ContentAdaptationEvent> get adaptationStream => _adaptationCtrl.stream;
  EngagementState get currentState => _currentState;

  void start() {
    _secondTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      _secondsSinceLastInteraction++;
      if (_secondsSinceLastInteraction >= 5) {
        _windowIdleSeconds++;
      }
    });

    _windowTimer = Timer.periodic(
        const Duration(seconds: _windowSeconds), (_) => processWindow());
  }

  void stop() {
    _windowTimer?.cancel();
    _secondTicker?.cancel();
    _windowTimer = null;
    _secondTicker = null;
    _stateCtrl.close();
    _adaptationCtrl.close();
  }

  void recordTap() {
    _windowTaps++;
    _secondsSinceLastInteraction = 0;
  }

  void recordScroll({required double velocityPx}) {
    _windowScrollTotal += velocityPx.abs();
    _windowScrollEvents++;
    _secondsSinceLastInteraction = 0;
  }

  @visibleForTesting
  Future<void> processWindow() async {
    final avgScrollVelocity = _windowScrollEvents > 0
        ? _windowScrollTotal / _windowScrollEvents
        : 0.0;

    final window = EngagementSignalWindow(
      tapCount: _windowTaps,
      scrollVelocity: avgScrollVelocity,
      idleSeconds: _windowIdleSeconds.toDouble(),
      window: const Duration(seconds: _windowSeconds),
    );

    // Run classification in isolate
    final newState = await compute(_classifyCompute, window.toMap());
    _currentState = newState;

    if (!_stateCtrl.isClosed) {
      _stateCtrl.add(newState);
    }

    // Fatigue tracking
    if (newState == EngagementState.fatigued) {
      _consecutiveFatigueWindows++;
      if (_consecutiveFatigueWindows >= 3) {
        if (!_adaptationCtrl.isClosed) {
          _adaptationCtrl.add(
            ContentAdaptationEvent(
              contentId: contentId,
              suggestion: 'You seem tired. Want a summary or a quiz instead?',
            ),
          );
        }
        _consecutiveFatigueWindows = 0; // reset after emitting
      }
    } else {
      _consecutiveFatigueWindows = 0;
    }

    // Persist session
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    _sessionSeq++;
    final session = EngagementSessionEntity(
      // Avoid collisions if multiple windows persist within same millisecond.
      id: '${nowMs}_$_sessionSeq',
      userId: userId,
      contentId: contentId,
      state: newState.name,
      durationSeconds: _windowSeconds,
      tapCount: _windowTaps,
      scrollEvents: _windowScrollEvents,
      idleSeconds: _windowIdleSeconds,
      startedAt: nowMs,
    );
    await repo.recordSession(session);

    // Reset window
    _windowTaps = 0;
    _windowScrollTotal = 0;
    _windowScrollEvents = 0;
    _windowIdleSeconds = 0;
  }
}

final engagementServiceProvider = Provider.family
    .autoDispose<EngagementService, ({String userId, String contentId})>(
        (ref, args) {
  final repo = ref.watch(engagementRepositoryProvider);
  final service = EngagementService(
    contentId: args.contentId,
    userId: args.userId,
    repo: repo,
  );
  service.start();
  ref.onDispose(service.stop);
  return service;
});

final engagementStateStreamProvider = StreamProvider.family
    .autoDispose<EngagementState, ({String userId, String contentId})>((ref, args) {
  final service = ref.watch(engagementServiceProvider(args));
  return service.engagementStateStream;
});

final adaptationEventStreamProvider = StreamProvider.family
    .autoDispose<ContentAdaptationEvent, ({String userId, String contentId})>((ref, args) {
  final service = ref.watch(engagementServiceProvider(args));
  return service.adaptationStream;
});

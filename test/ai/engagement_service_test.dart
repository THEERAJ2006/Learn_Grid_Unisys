import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learngrid/ai/engagement/engagement_service.dart';
import 'package:learngrid/data/database/app_database.dart';
import 'package:learngrid/data/repositories/drift/drift_repositories.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DriftEngagementRepository repo;
  late EngagementService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = DriftEngagementRepository(db);
    service = EngagementService(
      contentId: 'c1',
      userId: 'u1',
      repo: repo,
    );
    // Do NOT call service.start() here — the periodic timers would interfere
    // with the tests. We drive processWindow() manually instead.
  });

  tearDown(() async {
    service.stop();
    await db.close();
  });

  group('EngagementService', () {
    test('initial state is EngagementState.passive', () {
      // EngagementService initialises _currentState to passive.
      expect(service.currentState, EngagementState.passive);
    });

    test('recordTap() does not throw', () {
      expect(() => service.recordTap(), returnsNormally);
    });

    test('recordScroll() does not throw', () {
      expect(
        () => service.recordScroll(velocityPx: 300.0),
        returnsNormally,
      );
    });

    test('dispose() closes streams without error', () {
      // stop() cancels timers and closes broadcast stream controllers.
      expect(() => service.stop(), returnsNormally);
      // Calling stop() a second time must also not throw.
      expect(() => service.stop(), returnsNormally);
    });

    test('engagementStateStream emits at least one value after processWindow()', () async {
      final emitted = <EngagementState>[];
      final sub = service.engagementStateStream.listen(emitted.add);

      // Give 4 taps so activityScore = 3.2 → focused.
      service.recordTap();
      service.recordTap();
      service.recordTap();
      service.recordTap();
      await service.processWindow();

      await sub.cancel();
      expect(emitted.length, greaterThanOrEqualTo(1));
    });

    test('state remains valid enum value after processWindow() with zero interaction', () async {
      // No taps, no scrolls — should classify to fatigued or absent, not throw.
      await service.processWindow();
      final validStates = EngagementState.values;
      expect(validStates, contains(service.currentState));
    });

    test('three focused windows keep state as focused', () async {
      for (var i = 0; i < 3; i++) {
        // 4 taps = score 3.2 → focused
        service.recordTap();
        service.recordTap();
        service.recordTap();
        service.recordTap();
        await service.processWindow();
      }
      expect(service.currentState, EngagementState.focused);
    });

    test('three consecutive fatigued windows emit ContentAdaptationEvent', () async {
      final adaptationEvents = <ContentAdaptationEvent>[];
      final sub = service.adaptationStream.listen(adaptationEvents.add);

      for (var i = 0; i < 3; i++) {
        // 1 tap = score 0.8 → fatigued
        service.recordTap();
        await service.processWindow();
      }

      expect(service.currentState, EngagementState.fatigued);
      expect(adaptationEvents.length, 1);
      expect(
        adaptationEvents.first.suggestion,
        'You seem tired. Want a summary or a quiz instead?',
      );

      await sub.cancel();
    });
  });
}

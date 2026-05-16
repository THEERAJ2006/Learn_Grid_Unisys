import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';

import 'package:learngrid/ai/router/ai_router.dart';
import 'package:learngrid/data/database/app_database.dart';
import 'package:learngrid/data/repositories/drift/drift_repositories.dart';
import 'package:learngrid/features/settings/settings_prefs.dart';

// ── Mock HTTP infrastructure ──────────────────────────────────────────────────

class _TrackingHttpOverrides extends HttpOverrides {
  final List<String> requestedHosts;
  final int statusCode;

  _TrackingHttpOverrides({
    required this.requestedHosts,
  });

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient(requestedHosts, statusCode);
  }
}

class _MockHttpClient implements HttpClient {
  final List<String> requestedHosts;
  final int statusCode;

  _MockHttpClient(this.requestedHosts, this.statusCode);

  @override
  Future<HttpClientRequest> postUrl(Uri url) async {
    requestedHosts.add(url.host);
    return _MockHttpClientRequest(url, statusCode);
  }

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    requestedHosts.add(url.host);
    return _MockHttpClientRequest(url, statusCode);
  }

  @override
  void close({bool force = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientRequest implements HttpClientRequest {
  final Uri url;
  final int statusCode;

  _MockHttpClientRequest(this.url, this.statusCode);

  @override
  HttpHeaders get headers => _MockHttpHeaders();

  @override
  void add(List<int> data) {}

  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse(statusCode);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpHeaders implements HttpHeaders {
  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _MockHttpClientResponse implements HttpClientResponse {
  final int _statusCode;

  _MockHttpClientResponse(this._statusCode);

  @override
  int get statusCode => _statusCode;

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> transformer) {
    return Stream<List<int>>.value(utf8.encode('{}'))
        .transform(transformer);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late DriftCacheRepository cacheRepo;
  late AIRouter router;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    SharedPreferences.setMockInitialValues({});
    cacheRepo = DriftCacheRepository(db);
    router = AIRouter(
      cache: cacheRepo,
      hasInternet: () async => true,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('AIRouter', () {
    test('offline mode returns non-empty string without HTTP call', () async {
      await SettingsPrefs.setAiMode(AiModePreference.offlineOnly);

      final requestedHosts = <String>[];
      final result = await HttpOverrides.runZoned(
        () => router.getExplanation('Explain photosynthesis.'),
        createHttpClient: (ctx) => _MockHttpClient(requestedHosts, 500),
      );

      expect(result, isNotEmpty);
      expect(result, contains('Offline explanation'));
      expect(requestedHosts, isEmpty);
    });

    test('cloud mode with empty API keys falls back to offline', () async {
      await SettingsPrefs.setAiMode(AiModePreference.alwaysCloud);
      await SettingsPrefs.setGeminiApiKey('');
      await SettingsPrefs.setGroqApiKey('');

      final requestedHosts = <String>[];
      final result = await HttpOverrides.runZoned(
        () => router.getExplanation('Explain mitochondria.'),
        createHttpClient: (ctx) => _MockHttpClient(requestedHosts, 500),
      );

      // With empty Gemini and Groq keys the router skips to HuggingFace, which
      // also fails (500) → final fallback is offline.
      expect(result, isNotEmpty);
      expect(result, contains('Offline explanation'));
    });

    test('fallback chain: Gemini 500 → tries Groq next', () async {
      await SettingsPrefs.setAiMode(AiModePreference.alwaysCloud);
      // AIza-prefix is required by _tryGemini; gsk_-prefix by _tryGroq.
      await SettingsPrefs.setGeminiApiKey('AIzaFakeKeyForTest1234567890AB');
      await SettingsPrefs.setGroqApiKey('gsk_FakeGroqKeyForTest');

      final requestedHosts = <String>[];
      final result = await HttpOverrides.runZoned(
        () => router.getExplanation('Explain cell division.'),
        createHttpClient: (ctx) => _MockHttpClient(requestedHosts, 500),
      );

      // All three providers should have been attempted.
      expect(requestedHosts, contains('generativelanguage.googleapis.com'));
      expect(requestedHosts, contains('api.groq.com'));
      expect(requestedHosts, contains('api-inference.huggingface.co'));
      // After all fail → offline fallback.
      expect(result, isNotEmpty);
    });

    test('all APIs return 500 → still returns a string, no exception', () async {
      await SettingsPrefs.setAiMode(AiModePreference.alwaysCloud);
      await SettingsPrefs.setGeminiApiKey('AIzaFakeKeyForTest1234567890AB');
      await SettingsPrefs.setGroqApiKey('gsk_FakeGroqKeyForTest');

      final result = await HttpOverrides.runZoned(
        () => router.getExplanation('Any text here.'),
        createHttpClient: (ctx) => _MockHttpClient([], 500),
      );

      // Must return a non-empty string, not throw.
      expect(result, isNotEmpty);
    });

    test('response is cached after first offline call', () async {
      await SettingsPrefs.setAiMode(AiModePreference.offlineOnly);

      const query = 'Unique caching test query 9876';
      await router.getExplanation(query);

      // The cache should now contain at least 1 entry.
      final count = await cacheRepo.count();
      expect(count, greaterThanOrEqualTo(1));
    });
  });
}

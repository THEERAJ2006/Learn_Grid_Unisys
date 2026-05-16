import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/navigation.dart';
import '../../data/models/entities.dart';
import '../../data/providers/data_providers.dart';
import '../../data/repositories/repository_interfaces.dart';
import '../../features/settings/settings_prefs.dart';

class AIRouter {
  final CacheRepository _cache;
  final Future<bool> Function() _hasInternet;


  AIRouter({required CacheRepository cache, required Future<bool> Function() hasInternet})
      : _cache = cache,
        _hasInternet = hasInternet;

  Future<String> getExplanation(String text) async {
    if (kIsWeb) {
      return _getCloudOrFallback(text);
    }
    
    final mode = await SettingsPrefs.getAiMode();

    if (mode == AiModePreference.offlineOnly) {
      final result = _offlineExplain(text);
      await _cacheResult(text, result, source: 'offline', model: 'offline-rule');
      return result;
    }

    final cached = await _checkCache(text);
    if (cached != null) return cached;

    final hasInternet = await _hasInternet();
    if (!hasInternet) {
      final result = _offlineExplain(text);
      await _cacheResult(text, result, source: 'offline', model: 'offline-rule');
      return result;
    }

    if (mode == AiModePreference.askEachTime) {
      final context = rootNavigatorKey.currentContext;
      if (context != null && context.mounted) {
        final ok = await _showConsentBottomSheet(context);
        if (ok) return _getCloudOrFallback(text);
      }

      // Fail safe: no context available or user declined.
      final result = _offlineExplain(text);
      await _cacheResult(text, result, source: 'offline', model: 'offline-rule');
      return '$result\n\n(Online AI is set to Ask Each Time; consent is required.)';
    }

    return _getCloudOrFallback(text);
  }

  Future<String> getExplanationWithConsent(
    BuildContext context,
    String text, {
    String? contentId,
  }) async {
    if (kIsWeb) return _getCloudOrFallback(text);
    
    final mode = await SettingsPrefs.getAiMode();
    if (mode == AiModePreference.offlineOnly) return getExplanation(text);

    final hasInternet = await _hasInternet();
    if (!hasInternet) return getExplanation(text);

    if (mode == AiModePreference.askEachTime) {
      if (!context.mounted) return getExplanation(text);
      final ok = await _showConsentBottomSheet(context);
      if (!ok) return getExplanation(text);
    }
    return _getCloudOrFallback(text);
  }

  Future<String> _getCloudOrFallback(String text) async {
    final cached = await _checkCache(text);
    if (cached != null) return cached;
    try {
      final result = await _callCloudAPI(text);
      await _cacheResult(text, result, source: 'cloud', model: 'cloud');
      return result;
    } catch (_) {
      final result = _offlineExplain(text);
      await _cacheResult(text, result, source: 'offline', model: 'offline-rule');
      return result;
    }
  }

  String _offlineExplain(String text) {
    // Small rule-based summarizer: first sentence + key term hints.
    final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.isEmpty) return 'Select some text to explain.';
    final firstSentence = cleaned.split(RegExp(r'(?<=[.!?])\s+')).first;
    final words = cleaned
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 6)
        .toList(growable: false);
    final key = <String>{};
    for (final w in words) {
      key.add(w);
      if (key.length >= 5) break;
    }
    final keyLine = key.isEmpty ? '' : '\n\nKey terms: ${key.join(', ')}';
    return 'Offline explanation (summary):\n$firstSentence$keyLine';
  }

  Future<String?> _checkCache(String text) async {
    final key = _cacheKey(text);
    final entry = await _cache.get(key);
    if (entry == null) return null;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (entry.expiresAt <= now) return null;
    // Store as plain text in MVP.
    return entry.responseJson;
  }

  Future<void> _cacheResult(
    String text,
    String result, {
    required String source,
    String? model,
  }) async {
    final key = _cacheKey(text);
    final now = DateTime.now().millisecondsSinceEpoch;
    final entry = AIResponseCacheEntity(
      id: _uuid(),
      cacheKey: key,
      responseJson: result,
      source: source,
      model: model,
      createdAt: now,
      expiresAt: now + const Duration(days: 7).inMilliseconds,
    );
    await _cache.set(entry);
  }

  String _cacheKey(String text) {
    final bytes = utf8.encode(text.trim());
    return sha256.convert(bytes).toString();
  }

  Future<String> _callCloudAPI(String text) async {
    // Priority order: Gemini -> Groq -> HuggingFace
    final geminiKey = ((await SettingsPrefs.getGeminiApiKey()) ?? dotenv.env['GEMINI_API_KEY'])?.trim();
    final groqKey = ((await SettingsPrefs.getGroqApiKey()) ?? dotenv.env['GROQ_API_KEY'])?.trim();
    String? hfKey;
    try {
      hfKey = dotenv.env['HUGGINGFACE_API_KEY'];
    } catch (_) {
      hfKey = null;
    }

    if (geminiKey != null && geminiKey.isNotEmpty) {
      final r = await _tryGemini(text, geminiKey);
      if (r != null) return r;
    }
    if (groqKey != null && groqKey.isNotEmpty) {
      final r = await _tryGroq(text, groqKey);
      if (r != null) return r;
    }
    final r = await _tryHuggingFace(text, hfKey);
    if (r != null) return r;
    throw Exception('All cloud AI providers failed');
  }

  Future<String?> _tryGemini(String text, String apiKey) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey',
    );
    final body = jsonEncode({
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': 'Explain simply:\n\n$text'}
          ]
        }
      ]
    });
    return _postJson(uri, body, parse: (json) {
      final candidates = (json['candidates'] as List?) ?? const [];
      final first = candidates.isEmpty ? null : candidates.first;
      final content = first is Map ? first['content'] : null;
      final parts = content is Map ? (content['parts'] as List?) : null;
      final p0 = (parts == null || parts.isEmpty) ? null : parts.first;
      final t = p0 is Map ? p0['text'] : null;
      return t is String && t.trim().isNotEmpty ? t.trim() : null;
    });
  }

  Future<String?> _tryGroq(String text, String apiKey) async {
    final uri = Uri.parse('https://api.groq.com/openai/v1/chat/completions');
    final body = jsonEncode({
      'model': 'llama-3.1-8b-instant',
      'messages': [
        {'role': 'system', 'content': 'You are a helpful tutor. Explain clearly and briefly.'},
        {'role': 'user', 'content': text},
      ],
      'temperature': 0.3,
      'max_tokens': 256,
    });
    return _postJson(
      uri,
      body,
      headers: {'Authorization': 'Bearer $apiKey'},
      parse: (json) {
        final choices = (json['choices'] as List?) ?? const [];
        final first = choices.isEmpty ? null : choices.first;
        final msg = first is Map ? first['message'] : null;
        final content = msg is Map ? msg['content'] : null;
        return content is String && content.trim().isNotEmpty ? content.trim() : null;
      },
    );
  }

  Future<String?> _tryHuggingFace(String text, String? apiKey) async {
    final uri = Uri.parse('https://api-inference.huggingface.co/models/google/flan-t5-base');
    final body = jsonEncode({'inputs': 'Explain simply: $text'});
    return _postJson(
      uri,
      body,
      headers: apiKey == null || apiKey.isEmpty
          ? const {}
          : {'Authorization': 'Bearer $apiKey'},
      parse: (json) {
        // HF returns either {generated_text:..} or a list of that.
        if (json is List && json.isNotEmpty) {
          final first = json.first;
          if (first is Map && first['generated_text'] is String) {
            return (first['generated_text'] as String).trim();
          }
        }
        if (json is Map && json['generated_text'] is String) {
          return (json['generated_text'] as String).trim();
        }
        return null;
      },
    );
  }

  Future<String?> _postJson(
    Uri uri,
    String body, {
    Map<String, String> headers = const {},
    required String? Function(dynamic json) parse,
  }) async {
    try {
      final reqHeaders = {'Content-Type': 'application/json', ...headers};
      final resp = await http.post(uri, headers: reqHeaders, body: body);
      if (resp.statusCode < 200 || resp.statusCode >= 300) return null;
      final json = jsonDecode(resp.body);
      return parse(json);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _showConsentBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Use Cloud AI?', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              const Text(
                'Your text will be sent to a cloud provider to generate an explanation. You can keep using Offline Only at any time.',
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('I Consent'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Not now'),
              ),
            ],
          ),
        );
      },
    );
    return result ?? false;
  }

  static String _uuid() {
    // Deterministic-ish unique id without adding extra deps.
    final now = DateTime.now().microsecondsSinceEpoch;
    return 'cache_${now}_${now.hashCode}';
  }
}

// Riverpod wiring.
// Exposed via provider so screens/notifiers don't construct AIRouter directly.

final aiRouterProvider = Provider<AIRouter>((ref) {
  final cache = ref.watch(cacheRepositoryProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  return AIRouter(
    cache: cache,
    hasInternet: connectivity.hasInternet,
  );
});

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AiModePreference {
  offlineOnly,
  askEachTime,
  alwaysCloud,
}

class SettingsPrefs {
  static const String _aiModeKey = 'settings.ai_mode';

  static const String _geminiKey = 'settings.gemini_api_key';
  static const String _groqKey = 'settings.groq_api_key';
  static const String _hasShownOnboardingKey = 'settings.has_shown_onboarding';

  static Future<SharedPreferences> _sp() => SharedPreferences.getInstance();

  static const FlutterSecureStorage _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> _secureRead(String key) async {
    try {
      return await _secure.read(key: key);
    } catch (_) {
      // Unit tests run without platform plugins; fall back to SharedPreferences.
      final sp = await _sp();
      return sp.getString(key);
    }
  }

  static Future<void> _secureWrite(String key, String value) async {
    try {
      await _secure.write(key: key, value: value);
    } catch (_) {
      final sp = await _sp();
      await sp.setString(key, value);
    }
  }

  static Future<void> _secureDelete(String key) async {
    try {
      await _secure.delete(key: key);
    } catch (_) {
      final sp = await _sp();
      await sp.remove(key);
    }
  }

  static Future<AiModePreference> getAiMode() async {
    final sp = await _sp();
    final raw = sp.getString(_aiModeKey);
    return AiModePreference.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => AiModePreference.offlineOnly,
    );
  }

  static Future<void> setAiMode(AiModePreference mode) async {
    final sp = await _sp();
    await sp.setString(_aiModeKey, mode.name);
  }

  static Future<String?> getGeminiApiKey() => _secureRead(_geminiKey);
  static Future<void> setGeminiApiKey(String? key) async {
    final v = key?.trim();
    if (v == null || v.isEmpty) {
      await _secureDelete(_geminiKey);
      return;
    }
    await _secureWrite(_geminiKey, v);
  }

  static Future<String?> getGroqApiKey() => _secureRead(_groqKey);
  static Future<void> setGroqApiKey(String? key) async {
    final v = key?.trim();
    if (v == null || v.isEmpty) {
      await _secureDelete(_groqKey);
      return;
    }
    await _secureWrite(_groqKey, v);
  }

  static Future<bool> getHasShownOnboarding() async {
    final sp = await _sp();
    return sp.getBool(_hasShownOnboardingKey) ?? false;
  }

  static Future<void> setHasShownOnboarding(bool shown) async {
    final sp = await _sp();
    await sp.setBool(_hasShownOnboardingKey, shown);
  }
}

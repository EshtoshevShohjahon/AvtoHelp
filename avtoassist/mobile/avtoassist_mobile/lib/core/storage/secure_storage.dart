import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> write(String key, String value) => _storage.write(key: key, value: value);
  static Future<String?> read(String key) => _storage.read(key: key);
  static Future<void> delete(String key) => _storage.delete(key: key);
  static Future<void> deleteAll() => _storage.deleteAll();
}

class AppPrefs {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String get appLang => _prefs.getString('app_lang') ?? 'uz';
  static Future<void> setAppLang(String lang) => _prefs.setString('app_lang', lang);
  static bool get onboardingDone => _prefs.getBool('onboarding_done') ?? false;
  static Future<void> setOnboardingDone() => _prefs.setBool('onboarding_done', true);
}

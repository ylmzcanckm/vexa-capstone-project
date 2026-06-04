import 'package:shared_preferences/shared_preferences.dart';

final class PrivacyPreferences {
  const PrivacyPreferences._();

  static const _keyDiscoverable = 'vexa_privacy_discoverable';
  static const _keyShowEmail = 'vexa_privacy_show_email';
  static const _keyKvkkAcceptedAt = 'vexa_kvkk_accepted_at';

  static Future<bool> discoverable() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDiscoverable) ?? true;
  }

  static Future<bool> showEmailOnProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyShowEmail) ?? false;
  }

  static Future<String?> kvkkAcceptedAtIso() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyKvkkAcceptedAt);
  }

  static Future<void> setDiscoverable(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDiscoverable, value);
  }

  static Future<void> setShowEmailOnProfile(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowEmail, value);
  }

  static Future<void> setKvkkAcceptedNow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyKvkkAcceptedAt,
      DateTime.now().toUtc().toIso8601String(),
    );
  }
}

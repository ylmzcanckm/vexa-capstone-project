import 'package:shared_preferences/shared_preferences.dart';

final class NotificationPreferences {
  const NotificationPreferences._();

  static const _keyPush = 'vexa_notify_push';
  static const _keyInApp = 'vexa_notify_in_app';
  static const _keyMatch = 'vexa_notify_match';

  static Future<bool> pushEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPush) ?? true;
  }

  static Future<bool> inAppEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyInApp) ?? true;
  }

  static Future<bool> matchAlertsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyMatch) ?? true;
  }

  static Future<void> setPush(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPush, value);
  }

  static Future<void> setInApp(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyInApp, value);
  }

  static Future<void> setMatchAlerts(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMatch, value);
  }
}

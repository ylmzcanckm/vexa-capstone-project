import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama geneli karanlık mod tercihi.
final class ThemePreferences {
  const ThemePreferences._();

  static const _keyDark = 'vexa_dark_mode';

  static Future<bool> isDark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDark) ?? false;
  }

  static Future<void> setDark(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDark, value);
  }
}

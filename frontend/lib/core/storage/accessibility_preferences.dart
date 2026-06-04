import 'package:shared_preferences/shared_preferences.dart';

final class AccessibilityPreferences {
  const AccessibilityPreferences._();

  static const _keyTextScale = 'vexa_a11y_text_scale';
  static const _keyBold = 'vexa_a11y_bold';
  static const _keyReduceMotion = 'vexa_a11y_reduce_motion';

  static Future<double> textScale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyTextScale) ?? 1.0;
  }

  static Future<bool> boldText() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBold) ?? false;
  }

  static Future<bool> reduceMotion() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyReduceMotion) ?? false;
  }

  static Future<void> setTextScale(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTextScale, value);
  }

  static Future<void> setBoldText(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBold, value);
  }

  static Future<void> setReduceMotion(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyReduceMotion, value);
  }
}

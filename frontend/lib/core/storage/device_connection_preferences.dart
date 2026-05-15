import 'package:shared_preferences/shared_preferences.dart';

/// İleride gerçek BLE eşlemesi için bayrak (şimdilik simülasyon düğmesi set eder).
final class DeviceConnectionPreferences {
  const DeviceConnectionPreferences._();

  static const _keyLinked = 'vexa_device_linked';

  static Future<bool> isLinked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLinked) ?? false;
  }

  static Future<void> setLinked(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLinked, value);
  }
}

import 'package:shared_preferences/shared_preferences.dart';

/// Cihaz onboarding adımı (giriş sonrası BLE / simülasyon ekranı).
final class DeviceConnectionPreferences {
  const DeviceConnectionPreferences._();

  static const _keyDeviceStepDone = 'vexa_device_onboarding_done';

  /// Kullanıcı “Cihaz bağlantısı” ekranını tamamladı mı?
  static Future<bool> isDeviceStepComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDeviceStepDone) ?? false;
  }

  static Future<void> setDeviceStepComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDeviceStepDone, value);
  }

  /// Eski kod uyumu — artık sadece onboarding adımı bayrağı.
  static Future<bool> isLinked() => isDeviceStepComplete();

  static Future<void> setLinked(bool value) => setDeviceStepComplete(value);
}

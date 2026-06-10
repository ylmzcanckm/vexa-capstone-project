import 'package:shared_preferences/shared_preferences.dart';

/// LilyGO donanım ayarları — yerel saklama + BLE `def3` senkronu.
final class DeviceSettingsValues {
  const DeviceSettingsValues({
    this.vibrationIndex = 1,
    this.brightness = 0.5,
    this.autoBrightness = false,
    this.screenTimeoutIndex = 1,
  });

  final int vibrationIndex;
  final double brightness;
  final bool autoBrightness;
  final int screenTimeoutIndex;

  /// Firmware: 20–100 %
  int get brightnessPercent =>
      (20 + brightness * 80).round().clamp(20, 100);

  /// Firmware: 10, 30 veya 255 (always on).
  int get screenTimeoutSeconds => switch (screenTimeoutIndex) {
        0 => 10,
        1 => 30,
        _ => 0xFF,
      };

  DeviceSettingsValues copyWith({
    int? vibrationIndex,
    double? brightness,
    bool? autoBrightness,
    int? screenTimeoutIndex,
  }) {
    return DeviceSettingsValues(
      vibrationIndex: vibrationIndex ?? this.vibrationIndex,
      brightness: brightness ?? this.brightness,
      autoBrightness: autoBrightness ?? this.autoBrightness,
      screenTimeoutIndex: screenTimeoutIndex ?? this.screenTimeoutIndex,
    );
  }
}

final class DeviceSettingsPreferences {
  const DeviceSettingsPreferences._();

  static const _keyVibration = 'vexa_device_vibration';
  static const _keyBrightness = 'vexa_device_brightness';
  static const _keyAutoBrightness = 'vexa_device_auto_brightness';
  static const _keyScreenTimeout = 'vexa_device_screen_timeout';

  static Future<DeviceSettingsValues> load() async {
    final prefs = await SharedPreferences.getInstance();
    return DeviceSettingsValues(
      vibrationIndex: prefs.getInt(_keyVibration) ?? 1,
      brightness: prefs.getDouble(_keyBrightness) ?? 0.5,
      autoBrightness: prefs.getBool(_keyAutoBrightness) ?? false,
      screenTimeoutIndex: prefs.getInt(_keyScreenTimeout) ?? 1,
    );
  }

  static Future<void> save(DeviceSettingsValues values) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyVibration, values.vibrationIndex);
    await prefs.setDouble(_keyBrightness, values.brightness);
    await prefs.setBool(_keyAutoBrightness, values.autoBrightness);
    await prefs.setInt(_keyScreenTimeout, values.screenTimeoutIndex);
  }
}

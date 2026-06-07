import 'package:vexa/core/api/api_client.dart';
import 'package:vexa/core/api/api_exception.dart';

/// Cihaz eşleme API — `POST /devices/pair`, `GET /devices/my-device`.
final class DeviceRepository {
  const DeviceRepository._();

  static Future<void> pairDevice({
    required String deviceCode,
    String? deviceName,
    String model = 'LILYGO T-Display S3',
    String chipset = 'ESP32-S3R8',
  }) async {
    try {
      await ApiClient.post(
        '/devices/pair',
        auth: true,
        body: {
          'deviceCode': deviceCode,
          'deviceName': deviceName ?? 'VEXA Device',
          'model': model,
          'chipset': chipset,
          'connectivity': ['WiFi', 'BLE'],
        },
      );
    } on ApiException catch (e) {
      // Zaten eşli kullanıcı — MVP demo için devam.
      if (e.statusCode == 409) return;
      rethrow;
    }
  }

  static Future<void> unpairDevice() async {
    try {
      await ApiClient.delete('/devices/unpair', auth: true);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return;
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> fetchMyDevice() async {
    try {
      final json = await ApiClient.get('/devices/my-device', auth: true);
      return json['data'] as Map<String, dynamic>?;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }
}

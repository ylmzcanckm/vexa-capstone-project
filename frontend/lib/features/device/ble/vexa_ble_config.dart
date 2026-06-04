import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BLE UUID ve tarama filtreleri — firmware ile eşleşmeli.
abstract final class VexaBleConfig {
  static final Guid serviceUuid = Guid('12345678-1234-5678-1234-56789abcdef0');
  static final Guid avatarCharacteristicUuid =
      Guid('12345678-1234-5678-1234-56789abcdef1');

  /// Tarama sırasında isimde bunlardan biri geçerse öne alınır.
  static const nameHints = ['VEXA', 'LILYGO', 'T-Display', 'T_Display', 'ESP32'];

  static const avatarPixelSize = 128;
  static const maxChunkPayload = 240;
}

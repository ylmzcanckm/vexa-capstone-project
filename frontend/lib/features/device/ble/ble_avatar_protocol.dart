import 'dart:typed_data';

import 'package:vexa/features/device/ble/vexa_ble_config.dart';

/// VX paketleri — [DEVICE_BLE_AVATAR_PROTOCOL.md]
final class BleAvatarProtocol {
  const BleAvatarProtocol._();

  static const magic1 = 0x56; // V
  static const magic2 = 0x58; // X
  static const opStart = 0x01;
  static const opData = 0x02;
  static const opEnd = 0x03;
  static const opSettings = 0x20;

  static const settingVibration = 0x01;
  static const settingBrightness = 0x02;
  static const settingAutoBrightness = 0x03;
  static const settingScreenTimeout = 0x04;

  /// `def3`: `[V][X][0x20][setting][value][flags]`
  static Uint8List buildDeviceSetting({
    required int setting,
    required int value,
    int flags = 0,
  }) {
    return Uint8List.fromList([
      magic1,
      magic2,
      opSettings,
      setting & 0xFF,
      value & 0xFF,
      flags & 0xFF,
    ]);
  }

  static Uint8List buildStart({
    required int width,
    required int height,
    required int byteLength,
  }) {
    final b = BytesBuilder();
    b.add([magic1, magic2, opStart]);
    b.add(_u16(width));
    b.add(_u16(height));
    b.add(_u32(byteLength));
    return b.toBytes();
  }

  static Uint8List buildData({
    required int seq,
    required Uint8List chunk,
  }) {
    final b = BytesBuilder();
    b.add([magic1, magic2, opData]);
    b.add(_u16(seq));
    b.add(chunk);
    return b.toBytes();
  }

  static Uint8List buildEnd() => Uint8List.fromList([magic1, magic2, opEnd]);

  /// `def2` saat paketi: `[hour][minute][second][unix u32 LE]` (7 byte).
  static Uint8List buildRawClock(DateTime local) {
    final unix = local.millisecondsSinceEpoch ~/ 1000;
    final b = BytesBuilder();
    b.add([
      local.hour & 0xFF,
      local.minute & 0xFF,
      local.second & 0xFF,
    ]);
    b.add(_u32(unix));
    return b.toBytes();
  }

  static List<Uint8List> splitDataChunks(Uint8List rgb565) {
    final max = VexaBleConfig.maxChunkPayload;
    final chunks = <Uint8List>[];
    for (var offset = 0; offset < rgb565.length; offset += max) {
      final end = (offset + max > rgb565.length) ? rgb565.length : offset + max;
      chunks.add(Uint8List.sublistView(rgb565, offset, end));
    }
    return chunks;
  }

  static List<int> _u16(int v) => [v & 0xFF, (v >> 8) & 0xFF];

  static List<int> _u32(int v) => [
        v & 0xFF,
        (v >> 8) & 0xFF,
        (v >> 16) & 0xFF,
        (v >> 24) & 0xFF,
      ];
}

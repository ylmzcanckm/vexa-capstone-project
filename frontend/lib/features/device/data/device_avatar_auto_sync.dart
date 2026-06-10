import 'package:vexa/features/device/data/ble_avatar_transfer_service.dart';

/// Avatar kaydı sonrası LilyGO'ya otomatik BLE gönderimi.
final class DeviceAvatarAutoSync {
  const DeviceAvatarAutoSync._();

  /// LilyGO'ya avatar gönderir. Başarıda cihaz adı, hatada mesaj döner.
  static Future<({String? deviceName, String? error})> pushToDevice(
    String avatarSeed,
  ) async {
    if (!BleAvatarTransferService.isSupported) {
      return (deviceName: null, error: null);
    }
    if (avatarSeed.trim().isEmpty) {
      return (deviceName: null, error: 'Avatar kaydı boş.');
    }

    final ble = BleAvatarTransferService();
    try {
      final name = await ble.scanConnectAndTransfer(avatarSeed);
      return (deviceName: name, error: null);
    } catch (e) {
      return (deviceName: null, error: e.toString());
    } finally {
      await ble.disconnect();
    }
  }
}

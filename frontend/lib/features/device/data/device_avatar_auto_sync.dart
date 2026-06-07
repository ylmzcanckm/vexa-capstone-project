import 'package:vexa/features/device/data/ble_avatar_transfer_service.dart';
import 'package:vexa/features/device/data/device_link_state.dart';
import 'package:vexa/features/device/data/device_repository.dart';

/// Avatar kaydı sonrası LilyGO'ya otomatik BLE gönderimi.
final class DeviceAvatarAutoSync {
  const DeviceAvatarAutoSync._();

  /// Eşli LilyGO varsa avatarı gönderir; yoksa sessizce atlar.
  static Future<String?> syncIfPaired(String avatarSeed) async {
    if (!BleAvatarTransferService.isSupported || avatarSeed.trim().isEmpty) {
      return null;
    }

    final remote = await DeviceRepository.fetchMyDevice();
    final link = DeviceLinkState.fromServer(remote);
    if (!link.isLiveBlePaired) return null;

    final ble = BleAvatarTransferService();
    try {
      return await ble.scanConnectAndTransfer(avatarSeed);
    } finally {
      await ble.disconnect();
    }
  }
}

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vexa/features/device/ble/ble_avatar_protocol.dart';
import 'package:vexa/features/device/ble/vexa_ble_config.dart';
import 'package:vexa/core/storage/device_settings_preferences.dart';
import 'package:vexa/features/device/data/avatar_bitmap_service.dart';
import 'package:vexa/features/device/data/ble_permissions.dart';

typedef AvatarTransferProgress = void Function(int sentChunks, int totalChunks);

/// BLE tarama, bağlantı ve avatar aktarımı.
final class BleAvatarTransferService {
  BleAvatarTransferService();

  BluetoothDevice? _device;
  Timer? _clockSyncTimer;

  static bool get isSupported => !kIsWeb;

  /// LilyGO / VEXA cihazlarını tara (önce servis UUID, sonra genel tarama).
  Future<List<ScanResult>> scan({Duration timeout = const Duration(seconds: 12)}) async {
    if (!isSupported) {
      throw UnsupportedError('BLE yalnızca mobil/masaüstü uygulamada desteklenir.');
    }

    final ok = await BlePermissions.ensureForScan();
    if (!ok) {
      throw Exception('Bluetooth izni verilmedi.');
    }

    if (await FlutterBluePlus.isSupported == false) {
      throw Exception('Bu cihaz Bluetooth LE desteklemiyor.');
    }

    final merged = <String, ScanResult>{};

    await _runScan(
      timeout: timeout,
      withServices: [VexaBleConfig.serviceUuid],
      into: merged,
    );

    if (merged.isEmpty) {
      await _runScan(timeout: timeout, into: merged);
    }

    return _sortResults(merged.values.toList());
  }

  Future<void> _runScan({
    required Duration timeout,
    required Map<String, ScanResult> into,
    List<Guid>? withServices,
  }) async {
    final sub = FlutterBluePlus.scanResults.listen((list) {
      for (final r in list) {
        into[r.device.remoteId.str] = r;
      }
    });

    try {
      await FlutterBluePlus.startScan(
        timeout: timeout,
        withServices: withServices ?? [],
      );
      await Future<void>.delayed(timeout);
    } finally {
      await FlutterBluePlus.stopScan();
      await sub.cancel();
    }
  }

  static List<ScanResult> _sortResults(List<ScanResult> list) {
    return list
      ..sort((a, b) {
        final ah = _nameHintRank(a.device.platformName);
        final bh = _nameHintRank(b.device.platformName);
        if (ah != bh) return bh.compareTo(ah);
        return b.rssi.compareTo(a.rssi);
      });
  }

  static int _nameHintRank(String name) {
    final upper = name.toUpperCase();
    for (var i = 0; i < VexaBleConfig.nameHints.length; i++) {
      if (upper.contains(VexaBleConfig.nameHints[i].toUpperCase())) {
        return VexaBleConfig.nameHints.length - i;
      }
    }
    return 0;
  }

  /// En uygun VEXA cihazını seç (öncelik: `VEXA-B4DC`).
  static ScanResult? pickBestVexaDevice(List<ScanResult> results) {
    if (results.isEmpty) return null;

    final preferred = VexaBleConfig.preferredDeviceName.toUpperCase();
    for (final r in results) {
      if (r.device.platformName.toUpperCase().contains(preferred)) {
        return r;
      }
    }

    for (final r in results) {
      if (_nameHintRank(r.device.platformName) > 0) {
        return r;
      }
    }

    return results.first;
  }

  static String displayName(BluetoothDevice device) {
    return device.platformName.isNotEmpty
        ? device.platformName
        : device.remoteId.str;
  }

  static String pairCodeFor(BluetoothDevice device) {
    final name = device.platformName.trim();
    if (name.isNotEmpty) return name;
    return 'BLE-${device.remoteId.str}';
  }

  Future<void> connect(BluetoothDevice device) async {
    _device = device;
    await device.connect(
      timeout: const Duration(seconds: 20),
      autoConnect: false,
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
    await device.discoverServices();
    try {
      await device.requestMtu(512);
    } catch (_) {}
    await syncDeviceClock();
    _startClockSyncTimer();
  }

  /// Donanım ayarlarını `def3` üzerinden yazar (bağlı cihaz gerekir).
  Future<String?> syncDeviceSettings(DeviceSettingsValues settings) async {
    final device = _device;
    if (device == null) return 'BLE bağlantısı yok';

    try {
      final characteristic = await _findSettingsCharacteristic(device);
      await _write(
        characteristic,
        BleAvatarProtocol.buildDeviceSetting(
          setting: BleAvatarProtocol.settingVibration,
          value: settings.vibrationIndex.clamp(0, 2),
        ),
      );
      await _write(
        characteristic,
        BleAvatarProtocol.buildDeviceSetting(
          setting: BleAvatarProtocol.settingBrightness,
          value: settings.brightnessPercent,
        ),
      );
      await _write(
        characteristic,
        BleAvatarProtocol.buildDeviceSetting(
          setting: BleAvatarProtocol.settingAutoBrightness,
          value: settings.autoBrightness ? 1 : 0,
        ),
      );
      await _write(
        characteristic,
        BleAvatarProtocol.buildDeviceSetting(
          setting: BleAvatarProtocol.settingScreenTimeout,
          value: settings.screenTimeoutSeconds,
        ),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Finder / eşleşme pulse (`0x05`) — bağlı cihaza gönderir.
  /// Firmware QUIZ TIME (`0x06`) komutunu alınca [setting] değiştirilebilir.
  Future<String?> sendFinderPulse({
    int setting = BleAvatarProtocol.settingFinderPulse,
  }) async {
    final device = _device;
    if (device == null) return 'BLE bağlantısı yok';

    try {
      final characteristic = await _findSettingsCharacteristic(device);
      await _write(
        characteristic,
        BleAvatarProtocol.buildDeviceSetting(setting: setting, value: 1),
      );
      // Firmware'in paketi işlemesi için kısa bekleme.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Tara → bağlan → Finder pulse gönder → kes.
  Future<String?> scanConnectAndPulse({
    Duration scanTimeout = const Duration(seconds: 8),
  }) async {
    final results = await scan(timeout: scanTimeout);
    final pick = pickBestVexaDevice(results);
    if (pick == null) {
      return 'VEXA cihazı bulunamadı.';
    }

    await connect(pick.device);
    try {
      return await sendFinderPulse();
    } finally {
      await disconnect();
    }
  }

  /// Tara → bağlan → ayarları gönder → kes.
  Future<String?> scanConnectAndSyncSettings(
    DeviceSettingsValues settings, {
    Duration scanTimeout = const Duration(seconds: 12),
  }) async {
    final results = await scan(timeout: scanTimeout);
    final pick = pickBestVexaDevice(results);
    if (pick == null) {
      return 'VEXA cihazı bulunamadı.';
    }

    await connect(pick.device);
    try {
      return await syncDeviceSettings(settings);
    } finally {
      await disconnect();
    }
  }

  Future<void> disconnect() async {
    _stopClockSyncTimer();
    final d = _device;
    _device = null;
    if (d != null) {
      try {
        await d.disconnect();
      } catch (_) {}
    }
  }

  Future<void> transferAvatarFromSeed(
    String avatarSeed, {
    AvatarTransferProgress? onProgress,
  }) async {
    final device = _device;
    if (device == null) {
      throw Exception('Önce BLE cihazına bağlan.');
    }

    final bitmap = await AvatarBitmapService.loadRgb565FromSeed(avatarSeed);
    final characteristic = await _findAvatarCharacteristic(device);
    final chunks = BleAvatarProtocol.splitDataChunks(bitmap.rgb565);

    await _write(characteristic, BleAvatarProtocol.buildStart(
      width: bitmap.width,
      height: bitmap.height,
      byteLength: bitmap.rgb565.length,
    ));

    for (var i = 0; i < chunks.length; i++) {
      await _write(
        characteristic,
        BleAvatarProtocol.buildData(seq: i, chunk: chunks[i]),
      );
      onProgress?.call(i + 1, chunks.length);
    }

    await _write(characteristic, BleAvatarProtocol.buildEnd());
    await syncDeviceClock();
  }

  /// Telefon saatini cihaza gönderir (`...def2`, ham 7-byte paket).
  Future<String?> syncDeviceClock({DateTime? localTime}) async {
    final device = _device;
    if (device == null) return 'BLE bağlantısı yok';

    try {
      final characteristic = await _findClockCharacteristic(device);
      await _write(
        characteristic,
        BleAvatarProtocol.buildRawClock(localTime ?? DateTime.now()),
      );
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void _startClockSyncTimer() {
    _stopClockSyncTimer();
    _clockSyncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      unawaited(syncDeviceClock());
    });
  }

  void _stopClockSyncTimer() {
    _clockSyncTimer?.cancel();
    _clockSyncTimer = null;
  }

  /// Tara → en iyi VEXA → bağlan → avatar gönder.
  Future<String> scanConnectAndTransfer(
    String avatarSeed, {
    AvatarTransferProgress? onProgress,
    Duration scanTimeout = const Duration(seconds: 12),
  }) async {
    final results = await scan(timeout: scanTimeout);
    final pick = pickBestVexaDevice(results);
    if (pick == null) {
      throw Exception(
        'VEXA cihazı bulunamadı. LilyGO açık mı? nRF Connect kapalı mı?',
      );
    }

    await connect(pick.device);
    try {
      await transferAvatarFromSeed(avatarSeed, onProgress: onProgress);
      final clockErr = await syncDeviceClock();
      if (clockErr != null) {
        throw Exception('Saat gönderilemedi: $clockErr');
      }
      // Firmware'in paketi işlemesi için bağlantıyı kısa süre açık tut.
      await Future<void>.delayed(const Duration(seconds: 3));
      return displayName(pick.device);
    } finally {
      await disconnect();
    }
  }

  Future<BluetoothCharacteristic> _findSettingsCharacteristic(
    BluetoothDevice device,
  ) async {
    for (final service in device.servicesList) {
      if (!_uuidMatches(service.uuid, VexaBleConfig.serviceUuid)) continue;
      for (final c in service.characteristics) {
        if (_uuidMatches(c.uuid, VexaBleConfig.settingsCharacteristicUuid)) {
          return c;
        }
      }
    }

    throw Exception(
      'Ayar characteristic bulunamadı (${VexaBleConfig.settingsCharacteristicUuid}).',
    );
  }

  Future<BluetoothCharacteristic> _findClockCharacteristic(
    BluetoothDevice device,
  ) async {
    for (final service in device.servicesList) {
      if (!_uuidMatches(service.uuid, VexaBleConfig.serviceUuid)) continue;
      for (final c in service.characteristics) {
        if (_uuidMatches(c.uuid, VexaBleConfig.clockCharacteristicUuid)) {
          return c;
        }
      }
    }

    final chars = <String>[];
    for (final service in device.servicesList) {
      for (final c in service.characteristics) {
        chars.add(c.uuid.str);
      }
    }
    throw Exception(
      'Saat characteristic bulunamadı (${VexaBleConfig.clockCharacteristicUuid}). '
      'Bulunan: ${chars.isEmpty ? "yok" : chars.join(", ")}',
    );
  }

  static bool _uuidMatches(Guid actual, Guid expected) {
    final a = actual.str.toLowerCase();
    final e = expected.str.toLowerCase();
    if (a == e) return true;
    final suffix = e.split('-').last;
    return a.endsWith(suffix);
  }

  Future<BluetoothCharacteristic> _findAvatarCharacteristic(
    BluetoothDevice device,
  ) async {
    for (final service in device.servicesList) {
      if (!_uuidMatches(service.uuid, VexaBleConfig.serviceUuid)) continue;
      for (final c in service.characteristics) {
        if (_uuidMatches(c.uuid, VexaBleConfig.avatarCharacteristicUuid)) {
          return c;
        }
      }
    }

    final found = device.servicesList
        .map((s) => s.uuid.str)
        .join(', ');
    throw Exception(
      'Avatar characteristic bulunamadı (${VexaBleConfig.avatarCharacteristicUuid}). '
      'Bulunan servisler: ${found.isEmpty ? "yok" : found}',
    );
  }

  Future<void> _write(
    BluetoothCharacteristic characteristic,
    Uint8List data,
  ) async {
    if (characteristic.properties.writeWithoutResponse) {
      await characteristic.write(data, withoutResponse: true);
    } else {
      await characteristic.write(data, withoutResponse: false);
    }
    // ESP32 BLE buffer için kısa bekleme
    await Future<void>.delayed(const Duration(milliseconds: 22));
  }
}

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:vexa/features/device/ble/ble_avatar_protocol.dart';
import 'package:vexa/features/device/ble/vexa_ble_config.dart';
import 'package:vexa/features/device/data/avatar_bitmap_service.dart';
import 'package:vexa/features/device/data/ble_permissions.dart';

typedef AvatarTransferProgress = void Function(int sentChunks, int totalChunks);

/// BLE tarama, bağlantı ve avatar aktarımı.
final class BleAvatarTransferService {
  BleAvatarTransferService();

  BluetoothDevice? _device;

  static bool get isSupported => !kIsWeb;

  Future<List<ScanResult>> scan({Duration timeout = const Duration(seconds: 10)}) async {
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

    final results = <String, ScanResult>{};
    final sub = FlutterBluePlus.scanResults.listen((list) {
      for (final r in list) {
        results[r.device.remoteId.str] = r;
      }
    });

    await FlutterBluePlus.startScan(timeout: timeout);
    await Future<void>.delayed(timeout);
    await FlutterBluePlus.stopScan();
    await sub.cancel();

    final sorted = results.values.toList()
      ..sort((a, b) {
        final ah = _nameHintRank(a.device.platformName);
        final bh = _nameHintRank(b.device.platformName);
        if (ah != bh) return bh.compareTo(ah);
        return b.rssi.compareTo(a.rssi);
      });
    return sorted;
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

  Future<void> connect(BluetoothDevice device) async {
    _device = device;
    await device.connect(timeout: const Duration(seconds: 15));
    await device.discoverServices();
    try {
      await device.requestMtu(512);
    } catch (_) {}
  }

  Future<void> disconnect() async {
    final d = _device;
    _device = null;
    if (d != null) {
      await d.disconnect();
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
  }

  Future<BluetoothCharacteristic> _findAvatarCharacteristic(
    BluetoothDevice device,
  ) async {
    for (final service in device.servicesList) {
      if (service.uuid != VexaBleConfig.serviceUuid) continue;
      for (final c in service.characteristics) {
        if (c.uuid == VexaBleConfig.avatarCharacteristicUuid) {
          return c;
        }
      }
    }

    // Fallback: herhangi bir yazılabilir karakteristik (geliştirme)
    for (final service in device.servicesList) {
      for (final c in service.characteristics) {
        if (c.properties.write || c.properties.writeWithoutResponse) {
          return c;
        }
      }
    }

    throw Exception(
      'Avatar characteristic bulunamadı. Firmware UUID’leri kontrol et.',
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
    await Future<void>.delayed(const Duration(milliseconds: 15));
  }
}

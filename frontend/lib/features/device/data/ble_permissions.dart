import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

final class BlePermissions {
  const BlePermissions._();

  static Future<bool> ensureForScan() async {
    if (kIsWeb) return false;
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    if (Platform.isAndroid) {
      final scan = await Permission.bluetoothScan.request();
      final connect = await Permission.bluetoothConnect.request();
      if (!scan.isGranted || !connect.isGranted) return false;
      return true;
    }

    // iOS: Bluetooth permission dialog on first BLE use; location not required iOS 13+
    return true;
  }
}

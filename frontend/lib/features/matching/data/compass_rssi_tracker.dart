import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vexa/features/device/data/ble_avatar_transfer_service.dart';

/// BLE RSSI + pusula başlığı ile partner yönünü tahmin eder (v1 sıcak-soğuk).
enum CompassWarmth { cold, neutral, hot }

final class CompassRssiSnapshot {
  const CompassRssiSnapshot({
    required this.isSearching,
    required this.needleAngleRad,
    required this.rssi,
    required this.warmth,
    required this.proximityLabel,
    required this.sampleCount,
  });

  final bool isSearching;
  final double needleAngleRad;
  final int? rssi;
  final CompassWarmth warmth;
  final String proximityLabel;
  final int sampleCount;
}

/// Telefonu yavaşça çevirerek en güçlü BLE sinyalinin geldiği yönü bulur.
final class CompassRssiTracker {
  CompassRssiTracker();

  static const _bucketDegrees = 15;
  static const _bucketCount = 360 ~/ _bucketDegrees;
  static const _minSamplesToLock = 12;
  static const _minBucketsWithData = 3;

  final _controller = StreamController<CompassRssiSnapshot>.broadcast();
  Stream<CompassRssiSnapshot> get snapshots => _controller.stream;

  StreamSubscription<CompassEvent>? _compassSub;
  StreamSubscription<List<ScanResult>>? _scanSub;
  Timer? _emitTimer;

  double? _headingDeg;
  int? _latestRssi;
  final List<List<int>> _rssiByBucket =
      List.generate(_bucketCount, (_) => <int>[]);
  final List<(DateTime, int)> _rssiTimeline = [];

  bool _running = false;

  Future<void> start() async {
    if (_running || !BleAvatarTransferService.isSupported) return;
    _running = true;

    await Permission.locationWhenInUse.request();

    _compassSub = FlutterCompass.events?.listen((event) {
      final h = event.heading;
      if (h != null) _headingDeg = h;
    });

    _scanSub = FlutterBluePlus.scanResults.listen(_onScanResults);

    await FlutterBluePlus.startScan(
      withServices: const [],
      androidScanMode: AndroidScanMode.lowLatency,
    );

    _emitTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      _emit();
    });
    _emit();
  }

  void _onScanResults(List<ScanResult> results) {
    final pick = BleAvatarTransferService.pickBestVexaDevice(results);
    if (pick == null) return;

    final rssi = pick.rssi;
    _latestRssi = rssi;
    final heading = _headingDeg;
    if (heading == null) return;

    final bucket = ((heading % 360) / _bucketDegrees).floor() % _bucketCount;
    final list = _rssiByBucket[bucket];
    list.add(rssi);
    if (list.length > 8) list.removeAt(0);

    final now = DateTime.now();
    _rssiTimeline.add((now, rssi));
    _rssiTimeline.removeWhere(
      (e) => now.difference(e.$1).inSeconds > 12,
    );
  }

  void _emit() {
    final sampleCount =
        _rssiByBucket.fold<int>(0, (sum, b) => sum + b.length);
    final bucketsWithData =
        _rssiByBucket.where((b) => b.isNotEmpty).length;

    final bestBearing = _bestSignalBearing();
    final heading = _headingDeg;
    final isSearching = sampleCount < _minSamplesToLock ||
        bucketsWithData < _minBucketsWithData ||
        bestBearing == null ||
        heading == null;

    double needle;
    if (isSearching) {
      final t = DateTime.now().millisecondsSinceEpoch / 1000.0;
      needle = (t * 2.4) % (math.pi * 2);
    } else {
      var relative = (bestBearing - heading) * math.pi / 180;
      while (relative > math.pi) {
        relative -= 2 * math.pi;
      }
      while (relative < -math.pi) {
        relative += 2 * math.pi;
      }
      needle = relative;
    }

    _controller.add(
      CompassRssiSnapshot(
        isSearching: isSearching,
        needleAngleRad: needle,
        rssi: _latestRssi,
        warmth: _warmth(),
        proximityLabel: _proximityLabel(_latestRssi),
        sampleCount: sampleCount,
      ),
    );
  }

  double? _bestSignalBearing() {
    var bestAvg = -999.0;
    double? bestBearing;

    for (var i = 0; i < _bucketCount; i++) {
      final samples = _rssiByBucket[i];
      if (samples.isEmpty) continue;
      final avg = samples.reduce((a, b) => a + b) / samples.length;
      if (avg > bestAvg) {
        bestAvg = avg;
        bestBearing = i * _bucketDegrees + _bucketDegrees / 2;
      }
    }
    return bestBearing;
  }

  CompassWarmth _warmth() {
    if (_rssiTimeline.length < 4) return CompassWarmth.neutral;
    final now = DateTime.now();
    final recent = _rssiTimeline
        .where((e) => now.difference(e.$1).inSeconds <= 2)
        .map((e) => e.$2)
        .toList();
    final older = _rssiTimeline
        .where((e) {
          final d = now.difference(e.$1).inSeconds;
          return d > 2 && d <= 6;
        })
        .map((e) => e.$2)
        .toList();
    if (recent.isEmpty || older.isEmpty) return CompassWarmth.neutral;

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;
    final delta = recentAvg - olderAvg;
    if (delta >= 4) return CompassWarmth.hot;
    if (delta <= -4) return CompassWarmth.cold;
    return CompassWarmth.neutral;
  }

  static String _proximityLabel(int? rssi) {
    if (rssi == null) return 'Sinyal aranıyor…';
    if (rssi >= -55) return 'Çok yakın';
    if (rssi >= -68) return 'Yakın';
    if (rssi >= -80) return 'Orta mesafe';
    return 'Uzak — yönü takip et';
  }

  Future<void> stop() async {
    if (!_running) return;
    _running = false;
    _emitTimer?.cancel();
    _emitTimer = null;
    await _compassSub?.cancel();
    _compassSub = null;
    await _scanSub?.cancel();
    _scanSub = null;
    try {
      await FlutterBluePlus.stopScan();
    } catch (_) {}
  }

  void dispose() {
    unawaited(stop());
    _controller.close();
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vexa/core/storage/bound_lilygo_store.dart';
import 'package:vexa/features/device/data/ble_avatar_transfer_service.dart';
import 'package:vexa/features/matching/data/live_match_watcher.dart';
import 'package:vexa/features/matching/data/match_cooldown_store.dart';

/// Eşleşme davetinin neden engellendiği — ürün mantığı kapıları.
enum MatchProximityBlockReason {
  unsupportedPlatform('BLE bu platformda desteklenmiyor.'),
  noActiveMode('Aktif mod seçili değil.'),
  cooldown('Eşleşme molası aktif.'),
  noLilyGo('LilyGO eşlemesi yok.'),
  finderOff('VEXA Finder / yakınlık taraması kapalı.'),
  ownDeviceNotVisible('Kendi LilyGO yakında görünmüyor.'),
  noNearbyVexa('Yakında başka VEXA cihazı yok.'),
  staleProximitySignal('Yakınlık sinyali süresi doldu.');

  const MatchProximityBlockReason(this.message);
  final String message;
}

/// VEXA eşleşme daveti — kalıcı ürün mantığı.
///
/// Pop-up yalnızca şu koşulların tamamı sağlandığında açılır:
/// 1. LilyGO eşlemesi + BLE taramasında kendi cihaz görünür
/// 2. VEXA Finder / yakınlık taraması açık
/// 3. Yakında başka VEXA algılandı
/// 4. Backend match kontrolü başarılı (çağıran taraf)
/// 5. Cooldown aktif değil
final class MatchProximityGate {
  const MatchProximityGate._();

  static const _scanTimeout = Duration(seconds: 4);
  static const _signalTtl = Duration(seconds: 45);
  static const _finderEnabledKey = 'vexa_proximity_scan_enabled_v1';

  /// SharedPreferences anahtarı — [ProximityScanner] ile paylaşılır.
  static const finderEnabledPrefsKey = _finderEnabledKey;

  static DateTime? _lastProximitySignalAt;

  static Future<bool> isFinderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_finderEnabledKey) ?? false;
  }

  /// LilyGO eşlemesi, Finder açık, cooldown yok, aktif mod.
  static Future<MatchProximityBlockReason?> staticBlockReason() async {
    if (!BleAvatarTransferService.isSupported) {
      return MatchProximityBlockReason.unsupportedPlatform;
    }
    if (LiveMatchWatcher.activeBackendMode == null) {
      return MatchProximityBlockReason.noActiveMode;
    }
    if (await MatchCooldownStore.isActive()) {
      return MatchProximityBlockReason.cooldown;
    }
    if (!await BoundLilyGoStore.hasBinding()) {
      return MatchProximityBlockReason.noLilyGo;
    }
    if (!await isFinderEnabled()) {
      return MatchProximityBlockReason.finderOff;
    }
    return null;
  }

  /// Arka plan BLE taraması çalışmalı mı?
  static Future<bool> shouldRunBackgroundScan() async {
    final block = await staticBlockReason();
    return block == null;
  }

  static bool hasFreshProximitySignal() {
    final at = _lastProximitySignalAt;
    if (at == null) return false;
    return DateTime.now().difference(at) < _signalTtl;
  }

  /// Backend eşleşmesi onaylandıktan hemen önce çağrılır.
  static void recordProximitySignal() {
    _lastProximitySignalAt = DateTime.now();
  }

  @visibleForTesting
  static void clearProximitySignalForTest() {
    _lastProximitySignalAt = null;
  }

  /// Eşleşme pop-up'ı gösterilebilir mi?
  static Future<MatchProximityBlockReason?> inviteBlockReason() async {
    final staticBlock = await staticBlockReason();
    if (staticBlock != null) return staticBlock;
    if (!hasFreshProximitySignal()) {
      return MatchProximityBlockReason.staleProximitySignal;
    }
    return null;
  }

  /// BLE taraması: kendi LilyGO + yakında başka VEXA.
  static Future<MatchProximityBlockReason?> runProximityScan() async {
    final staticBlock = await staticBlockReason();
    if (staticBlock != null) return staticBlock;

    final bound = await BoundLilyGoStore.load();
    if (bound == null || bound.isEmpty) {
      return MatchProximityBlockReason.noLilyGo;
    }

    try {
      final ble = BleAvatarTransferService();
      final results = await ble.scan(timeout: _scanTimeout);

      if (BleAvatarTransferService.pickBoundDevice(results, bound) == null) {
        return MatchProximityBlockReason.ownDeviceNotVisible;
      }

      if (BleAvatarTransferService.pickOtherVexaDevice(results, bound) ==
          null) {
        return MatchProximityBlockReason.noNearbyVexa;
      }

      return null;
    } catch (_) {
      return MatchProximityBlockReason.ownDeviceNotVisible;
    }
  }
}

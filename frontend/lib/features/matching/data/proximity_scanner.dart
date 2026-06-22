import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vexa/core/api/profile_bio_codec.dart';
import 'package:vexa/features/device/data/ble_avatar_transfer_service.dart';
import 'package:vexa/features/matching/data/discovery_filters_store.dart';
import 'package:vexa/features/matching/data/live_match_watcher.dart';
import 'package:vexa/features/matching/data/match_proximity_gate.dart';
import 'package:vexa/features/matching/data/match_repository.dart';
import 'package:vexa/features/matching/presentation/providers/discovery_filters_provider.dart';

/// VEXA Finder — arka plan yakınlık taraması.
///
/// Zamanlayıcı yalnızca [MatchProximityGate.shouldRunBackgroundScan] true
/// iken çalışır (LilyGO eşlemesi + Finder açık + cooldown yok).
final class ProximityScanner {
  const ProximityScanner._();

  static const _enabledKey = MatchProximityGate.finderEnabledPrefsKey;
  static const interval = Duration(seconds: 20);

  static Timer? _timer;
  static bool _busy = false;
  static Future<void> Function(LiveMatchInvite invite)? _onInvite;

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
    await sync();
  }

  /// Ana ekranda davet geri çağrısını kaydet; kapı koşullarına göre taramayı aç/kapat.
  static void start({
    required Future<void> Function(LiveMatchInvite invite) onInvite,
  }) {
    _onInvite = onInvite;
    unawaited(sync());
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
    _onInvite = null;
  }

  /// LilyGO / Finder / cooldown durumuna göre arka plan taramasını güncelle.
  static Future<void> sync() async {
    final callback = _onInvite;
    if (callback == null) return;

    final shouldRun = await MatchProximityGate.shouldRunBackgroundScan();
    if (!shouldRun) {
      _timer?.cancel();
      _timer = null;
      return;
    }

    if (_timer != null) return;

    _timer = Timer.periodic(interval, (_) => unawaited(_tick(callback)));
    unawaited(_tick(callback));
  }

  static Future<void> _tick(
    Future<void> Function(LiveMatchInvite invite) onInvite,
  ) async {
    if (_busy || LiveMatchWatcher.suspended) return;
    if (!BleAvatarTransferService.isSupported) return;
    _busy = true;
    try {
      if (!await MatchProximityGate.shouldRunBackgroundScan()) {
        await sync();
        return;
      }

      final scanBlock = await MatchProximityGate.runProximityScan();
      if (scanBlock != null) return;

      final filters =
          await DiscoveryFiltersStore.load() ?? const DiscoveryFiltersState();
      final candidates = await MatchRepository.fetchCandidates();

      for (final c in candidates) {
        final profile = ProfileBioCodec.tryDecodeProfileOnly(c.profileBio);
        if (profile != null &&
            !DiscoveryFilterMatcher.matches(filters, profile)) {
          continue;
        }

        final result = await MatchRepository.checkMatch(targetUserId: c.id);
        if (!result.isMatch) continue;
        if (LiveMatchWatcher.isMuted(result.id)) continue;

        MatchProximityGate.recordProximitySignal();
        LiveMatchWatcher.markHandled(result.id);
        await onInvite(
          LiveMatchInvite(
            matchId: result.id,
            partnerId: c.id,
            partnerName: c.displayName,
            matchScore: result.matchScore,
            commonInterests: result.commonInterests,
            mode: LiveMatchWatcher.activeBackendMode ?? 'social',
          ),
        );
        break;
      }
    } catch (_) {
      // BLE / ağ: sonraki turda tekrar dene.
    } finally {
      _busy = false;
    }
  }
}

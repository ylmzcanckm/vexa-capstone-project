import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vexa/core/api/profile_bio_codec.dart';
import 'package:vexa/features/device/data/ble_avatar_transfer_service.dart';
import 'package:vexa/features/matching/data/discovery_filters_store.dart';
import 'package:vexa/features/matching/data/live_match_watcher.dart';
import 'package:vexa/features/matching/data/match_cooldown_store.dart';
import 'package:vexa/features/matching/data/match_repository.dart';
import 'package:vexa/features/matching/presentation/providers/discovery_filters_provider.dart';

/// VEXA cihazı yakınlık taraması — senaryonun "cihaz 20 sn'de bir yayın
/// yapar" ayağının telefon tarafı.
///
/// 20 sn'de bir kısa BLE taraması yapar; yakında bir VEXA/LilyGO cihazı
/// görülürse tanışma filtrelerinden geçen adaylarla sunucuda eşleşme
/// kontrolü yapılır ve eşleşme çıkarsa quiz daveti tetiklenir.
///
/// Not: Firmware, yayına kullanıcı kimliği ekleyince (Can'ın görevi) tarama
/// "hangi kullanıcının cihazı" bilgisini de verecek; şimdilik herhangi bir
/// VEXA cihazı "yakında biri var" sinyali sayılır. Bu yüzden anahtar
/// (ayarlardan açılıp kapanır) varsayılan olarak kapalıdır.
final class ProximityScanner {
  const ProximityScanner._();

  static const _enabledKey = 'vexa_proximity_scan_enabled_v1';
  static const interval = Duration(seconds: 20);
  static const _scanTimeout = Duration(seconds: 4);

  static Timer? _timer;
  static bool _busy = false;

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_enabledKey) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, value);
  }

  static void start({
    required Future<void> Function(LiveMatchInvite invite) onInvite,
  }) {
    stop();
    _timer = Timer.periodic(interval, (_) => _tick(onInvite));
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static Future<void> _tick(
    Future<void> Function(LiveMatchInvite invite) onInvite,
  ) async {
    if (_busy || LiveMatchWatcher.suspended) return;
    if (!BleAvatarTransferService.isSupported) return;
    _busy = true;
    try {
      if (!await isEnabled()) return;
      if (LiveMatchWatcher.activeBackendMode == null) return;
      if (await MatchCooldownStore.isActive()) return;

      final ble = BleAvatarTransferService();
      final results = await ble.scan(timeout: _scanTimeout);
      final nearby = BleAvatarTransferService.pickBestVexaDevice(results);
      if (nearby == null) return;

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

        // Pop-up'ı buradan açıyoruz; watcher aynı eşleşmeyi tekrarlamasın.
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
      // BLE kapalı / izin yok / ağ hatası: sonraki turda tekrar dene.
    } finally {
      _busy = false;
    }
  }
}

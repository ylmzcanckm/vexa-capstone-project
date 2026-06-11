import 'dart:async';

import 'package:vexa/core/api/profile_bio_codec.dart';
import 'package:vexa/features/matching/data/discovery_filters_store.dart';
import 'package:vexa/features/matching/data/match_cooldown_store.dart';
import 'package:vexa/features/matching/data/match_repository.dart';

/// Canlı eşleşme daveti — pop-up ve quiz için gereken bilgiler.
final class LiveMatchInvite {
  const LiveMatchInvite({
    required this.matchId,
    required this.partnerId,
    required this.partnerName,
    required this.matchScore,
    required this.commonInterests,
  });

  final String matchId;
  final String partnerId;
  final String partnerName;
  final int matchScore;
  final List<String> commonInterests;
}

/// Sunucuyu yoklayıp yeni eşleşmede iki telefonda da pop-up tetikler.
///
/// Gerçek BLE yakınlık gelene kadar "iki cihaz birbirini gördü" sinyali:
/// taraflardan biri Kontrol yapınca match `detected` olur; diğer telefon
/// bunu birkaç saniye içinde görüp aynı daveti gösterir.
final class LiveMatchWatcher {
  const LiveMatchWatcher._();

  static Timer? _timer;
  static bool _checking = false;

  /// Davet/quiz ekranı açıkken yeni pop-up çıkmasın.
  static bool suspended = false;

  /// matchId → işlenen updatedAt (aynı güncelleme tekrar pop-up açmaz).
  static final Map<String, String?> _handledUpdatedAt = {};

  /// Kontrol'ü başlatan telefonda pop-up'ı sustur.
  static final Map<String, DateTime> _muteUntil = {};

  static const _freshWindow = Duration(minutes: 5);

  static void start({
    required Future<void> Function(LiveMatchInvite invite) onInvite,
    Duration interval = const Duration(seconds: 12),
  }) {
    stop();
    _timer = Timer.periodic(interval, (_) => _tick(onInvite));
    unawaited(_tick(onInvite));
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Eşleşmeyi bu cihazda manuel başlatan taraf çağırır.
  static void markHandled(String matchId) {
    _muteUntil[matchId] = DateTime.now().add(const Duration(minutes: 15));
  }

  static Future<void> _tick(
    Future<void> Function(LiveMatchInvite invite) onInvite,
  ) async {
    if (suspended || _checking) return;
    _checking = true;
    try {
      if (await MatchCooldownStore.isActive()) return;

      final history = await MatchRepository.fetchHistory();
      final now = DateTime.now().toUtc();

      for (final item in history) {
        if (item.status != 'detected') continue;

        final updatedAt = DateTime.tryParse(item.updatedAt ?? '');
        if (updatedAt == null) continue;
        if (now.difference(updatedAt.toUtc()) > _freshWindow) continue;

        final mute = _muteUntil[item.id];
        if (mute != null && DateTime.now().isBefore(mute)) {
          _handledUpdatedAt[item.id] = item.updatedAt;
          continue;
        }

        if (_handledUpdatedAt[item.id] == item.updatedAt) continue;
        _handledUpdatedAt[item.id] = item.updatedAt;

        // Tanışma filtresi kapısı: karşı taraf filtrelerime uymuyorsa
        // bu telefonda davet çıkmaz (karşılıklı uyum şartı).
        if (!await _passesMyFilters(item.otherUser.id)) continue;

        await onInvite(
          LiveMatchInvite(
            matchId: item.id,
            partnerId: item.otherUser.id,
            partnerName: item.otherUser.displayName,
            matchScore: item.matchScore,
            commonInterests: item.commonInterests,
          ),
        );
        break;
      }
    } catch (_) {
      // Offline / API hatası: sonraki turda tekrar dene.
    } finally {
      _checking = false;
    }
  }

  static Future<bool> _passesMyFilters(String partnerId) async {
    try {
      final filters = await DiscoveryFiltersStore.load();
      if (filters == null) return true;

      final candidates = await MatchRepository.fetchCandidates();
      final partner = candidates.where((c) => c.id == partnerId).toList();
      if (partner.isEmpty) return true;

      final profile =
          ProfileBioCodec.tryDecodeProfileOnly(partner.first.profileBio);
      if (profile == null) return true;

      return DiscoveryFilterMatcher.matches(filters, profile);
    } catch (_) {
      return true;
    }
  }
}

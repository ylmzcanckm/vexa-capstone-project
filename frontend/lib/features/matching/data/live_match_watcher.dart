/// Canlı eşleşme daveti — pop-up ve quiz için gereken bilgiler.
final class LiveMatchInvite {
  const LiveMatchInvite({
    required this.matchId,
    required this.partnerId,
    required this.partnerName,
    required this.matchScore,
    required this.commonInterests,
    required this.mode,
  });

  final String matchId;
  final String partnerId;
  final String partnerName;
  final int matchScore;
  final List<String> commonInterests;

  /// Backend `selected_mode`: `social` | `networking`.
  final String mode;

  bool get isNetworking => mode == 'networking';
  bool get isSocial => mode == 'social';
}

/// Otomatik eşleşme daveti oturumu — paylaşılan durum.
///
/// Davet yalnızca [MatchProximityGate] + [ProximityScanner] üzerinden açılır.
final class LiveMatchWatcher {
  const LiveMatchWatcher._();

  /// Davet/quiz ekranı açıkken yeni pop-up çıkmasın.
  static bool suspended = false;

  /// Ana ekrandaki aktif mod (`social` | `networking`). Ghost modda null.
  static String? activeBackendMode;

  static final Map<String, DateTime> _muteUntil = {};

  static void markHandled(String matchId) {
    _muteUntil[matchId] = DateTime.now().add(const Duration(minutes: 15));
  }

  static bool isMuted(String matchId) {
    final mute = _muteUntil[matchId];
    return mute != null && DateTime.now().isBefore(mute);
  }
}

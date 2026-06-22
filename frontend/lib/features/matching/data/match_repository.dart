import 'package:vexa/core/api/api_client.dart';
import 'package:vexa/core/api/models/match_models.dart';

final class MatchRepository {
  const MatchRepository._();

  static Future<List<RemoteMatchCandidate>> fetchCandidates() async {
    final json = await ApiClient.get('/matches/candidates', auth: true);
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(RemoteMatchCandidate.fromJson)
        .toList();
  }

  static Future<RemoteMatchCheckResult> checkMatch({
    String? targetUserId,
    String? targetEmail,
  }) async {
    final json = await ApiClient.post(
      '/matches/check',
      auth: true,
      body: {
        if (targetUserId != null && targetUserId.isNotEmpty)
          'targetUserId': targetUserId,
        if (targetEmail != null && targetEmail.isNotEmpty)
          'targetEmail': targetEmail,
      },
    );
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return RemoteMatchCheckResult.fromJson(data);
  }

  static Future<List<RemoteMatchHistoryItem>> fetchHistory({
    String? mode,
  }) async {
    final path = mode != null && mode.isNotEmpty
        ? '/matches/history?mode=$mode'
        : '/matches/history';
    final json = await ApiClient.get(path, auth: true);
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(RemoteMatchHistoryItem.fromJson)
        .toList();
  }

  /// Canlı quiz cevaplarını sunucuya gönderir.
  /// İki taraf da gönderdiyse sonuç (`bothSubmitted`, `percent`, `passed`,
  /// `cooldownUntil`) döner.
  static Future<Map<String, dynamic>> submitQuizAnswers({
    required String matchId,
    required Map<String, String> answers,
  }) async {
    final json = await ApiClient.post(
      '/matches/$matchId/quiz/answers',
      auth: true,
      body: {'answers': answers},
    );
    return json['data'] as Map<String, dynamic>? ?? {};
  }

  /// Canlı quiz durumu — karşı taraf bitirdi mi, sonuç ne?
  static Future<Map<String, dynamic>> fetchQuizSession(String matchId) async {
    final json = await ApiClient.get('/matches/$matchId/quiz', auth: true);
    return json['data'] as Map<String, dynamic>? ?? {};
  }

  /// Oturumu başlatır: sunucu eski cevapları siler, kanonik 5 soruyu döndürür.
  static Future<Map<String, dynamic>> beginQuizSession(String matchId) async {
    final json = await ApiClient.post(
      '/matches/$matchId/quiz/begin',
      auth: true,
      body: const {},
    );
    return json['data'] as Map<String, dynamic>? ?? {};
  }
}

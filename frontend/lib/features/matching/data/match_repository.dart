import 'package:vexa/core/api/api_client.dart';
import 'package:vexa/core/api/models/match_models.dart';

final class MatchRepository {
  const MatchRepository._();

  static Future<List<RemoteMatchHistoryItem>> fetchHistory() async {
    final json = await ApiClient.get('/matches/history', auth: true);
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(RemoteMatchHistoryItem.fromJson)
        .toList();
  }
}

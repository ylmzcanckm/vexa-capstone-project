import 'dart:math';

import 'package:vexa/core/api/profile_bio_codec.dart';
import 'package:vexa/core/storage/user_profile_store.dart';
import 'package:vexa/features/auth/data/user_repository.dart';
import 'package:vexa/features/quiz/data/quiz_catalog.dart';
import 'package:vexa/features/quiz/domain/quiz_models.dart';

/// Canlı quiz oturumundaki tek soru (ilgi alanı + soru).
final class LiveQuizQuestionRef {
  const LiveQuizQuestionRef({
    required this.interestId,
    required this.question,
  });

  final String interestId;
  final QuizQuestion question;

  /// Cevap haritasında kullanılan benzersiz anahtar.
  String get key => '$interestId:${question.id}';
}

/// İki cihazın eş zamanlı çözdüğü 5 soruluk quiz oturumu.
///
/// Sorular `matchId`'den deterministik seçilir — iki telefonda da aynı 5 soru.
/// Cevaplar profil `bio` içindeki `quizAnswers['live:<matchId>']` ile sunucuya
/// gider; karşı taraf aday listesinden okur.
final class LiveQuizSession {
  const LiveQuizSession._();

  static const questionCount = 5;

  /// %80 = 5 sorudan en az 4 aynı cevap.
  static const passCount = 4;

  static String answersKeyFor(String matchId) => 'live:$matchId';

  /// FNV-1a — `String.hashCode`'a güvenmeden iki cihazda aynı tohum.
  static int _stableHash(String input) {
    var hash = 0x811C9DC5;
    for (final code in input.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash;
  }

  /// Sunucunun döndürdüğü kanonik soru listesini yerel modele çevirir.
  static List<LiveQuizQuestionRef> questionsFromServer(
    List<dynamic> raw,
  ) {
    return raw.whereType<Map<String, dynamic>>().map((item) {
      final options = (item['options'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(
                (o) => QuizOption(
                  id: o['id'] as String? ?? '',
                  text: o['text'] as String? ?? '',
                ),
              )
              .toList() ??
          const [];
      final interestId = item['interestId'] as String? ?? '';
      final questionId = item['questionId'] as String? ?? '';
      return LiveQuizQuestionRef(
        interestId: interestId,
        question: QuizQuestion(
          id: questionId,
          text: item['text'] as String? ?? '',
          options: options,
        ),
      );
    }).toList();
  }

  /// Ortak ilgi alanlarındaki sorulardan matchId'ye göre 5 soru seçer.
  static Future<List<LiveQuizQuestionRef>> questionsFor({
    required String matchId,
    required List<String> commonInterestIds,
  }) async {
    final catalog = await QuizCatalog.load();
    final interests = commonInterestIds.where(catalog.containsKey).toList()
      ..sort();
    final source = interests.isNotEmpty ? interests : (catalog.keys.toList()..sort());

    final pool = <LiveQuizQuestionRef>[
      for (final interestId in source)
        for (final q in catalog[interestId]!)
          LiveQuizQuestionRef(interestId: interestId, question: q),
    ];
    if (pool.length <= questionCount) return pool;

    final rng = Random(_stableHash(matchId));
    final indices = <int>{};
    while (indices.length < questionCount) {
      indices.add(rng.nextInt(pool.length));
    }
    final sorted = indices.toList()..sort();
    return [for (final i in sorted) pool[i]];
  }

  /// Yeni oturumda eski cevapları yerel profilden siler.
  static Future<void> clearAnswersForMatch(String matchId) async {
    final existing = await UserProfileStore.load();
    if (existing == null) return;
    final merged = Map<String, Map<String, String>>.from(existing.quizAnswers);
    if (!merged.remove(answersKeyFor(matchId))) return;
    await UserProfileStore.save(existing.copyWith(quizAnswers: merged));
    await UserRepository.syncLocalProfileToServer();
  }

  /// Cevapları yerel profile yazar ve sunucuya gönderir.
  static Future<void> saveMyAnswers(
    String matchId,
    Map<String, String> answers,
  ) async {
    final existing = await UserProfileStore.load();
    if (existing == null) {
      throw StateError('Profil bulunamadı.');
    }
    final merged = Map<String, Map<String, String>>.from(existing.quizAnswers);
    merged[answersKeyFor(matchId)] = Map<String, String>.from(answers);
    await UserProfileStore.save(existing.copyWith(quizAnswers: merged));
    await UserRepository.syncLocalProfileToServer();
  }

  /// Karşı tarafın bio JSON'undan bu oturumun cevaplarını çıkarır.
  static Map<String, String>? partnerAnswersFromBio(
    String? bio,
    String matchId,
  ) {
    final answers =
        ProfileBioCodec.tryDecodeProfileOnly(bio)?.quizAnswers[answersKeyFor(matchId)];
    if (answers == null) return null;
    return Map<String, String>.from(answers);
  }

  /// Verilen soru anahtarlarında aynı cevap sayısı.
  static int matchingCount({
    required Map<String, String> mine,
    required Map<String, String> partner,
    required List<String> keys,
  }) {
    var count = 0;
    for (final key in keys) {
      final a = mine[key];
      final b = partner[key];
      if (a != null && b != null && a == b) count++;
    }
    return count;
  }
}

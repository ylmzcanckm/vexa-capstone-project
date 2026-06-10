import 'package:vexa/core/api/profile_bio_codec.dart';
import 'package:vexa/core/storage/user_profile_store.dart';
import 'package:vexa/features/auth/data/user_repository.dart';
import 'package:vexa/features/quiz/data/quiz_catalog.dart';
import 'package:vexa/features/quiz/domain/quiz_models.dart';

/// Quiz cevapları profil `bio` JSON içinde taşınır; karşılaştırma istemci tarafında.
final class QuizService {
  const QuizService._();

  static const passThresholdPercent = 80;

  static Map<String, Map<String, String>> answersFromBio(String? bio) {
    return ProfileBioCodec.tryDecodeProfileOnly(bio)?.quizAnswers ?? {};
  }

  static bool isCompleteForInterests(
    Map<String, Map<String, String>> answers,
    List<String> interestIds,
  ) {
    for (final id in interestIds) {
      final perInterest = answers[id];
      if (perInterest == null || perInterest.length < 5) return false;
      for (var q = 1; q <= 5; q++) {
        final pick = perInterest['$q'];
        if (pick != 'a' && pick != 'b') return false;
      }
    }
    return interestIds.isNotEmpty;
  }

  static Future<bool> localQuizCompleteFor(List<String> interestIds) async {
    final profile = await UserProfileStore.load();
    return isCompleteForInterests(profile?.quizAnswers ?? {}, interestIds);
  }

  static Future<void> saveAnswers(
    Map<String, Map<String, String>> answers,
  ) async {
    final existing = await UserProfileStore.load();
    if (existing == null) return;
    final merged = Map<String, Map<String, String>>.from(existing.quizAnswers);
    merged.addAll(answers);
    await UserProfileStore.save(existing.copyWith(quizAnswers: merged));
    await UserRepository.syncLocalProfileToServer();
  }

  static Future<QuizCompareResult> compareWithRemoteBio({
    required Map<String, Map<String, String>> localAnswers,
    required String? remoteBio,
    required List<String> commonInterestIds,
  }) async {
    final remoteAnswers = answersFromBio(remoteBio);
    return _compare(
      local: localAnswers,
      remote: remoteAnswers,
      interestIds: commonInterestIds,
    );
  }

  static Future<QuizCompareResult> compareLocalWithRemote({
    required String? remoteBio,
    required List<String> commonInterestIds,
  }) async {
    final profile = await UserProfileStore.load();
    return compareWithRemoteBio(
      localAnswers: profile?.quizAnswers ?? {},
      remoteBio: remoteBio,
      commonInterestIds: commonInterestIds,
    );
  }

  static Future<QuizCompareResult> _compare({
    required Map<String, Map<String, String>> local,
    required Map<String, Map<String, String>> remote,
    required List<String> interestIds,
  }) async {
    final catalog = await QuizCatalog.load();
    final missingLocal = <String>[];
    final missingRemote = <String>[];
    var total = 0;
    var matches = 0;
    final byInterest = <String, int>{};

    for (final interestId in interestIds) {
      final questions = catalog[interestId];
      if (questions == null || questions.isEmpty) continue;

      final localSet = local[interestId] ?? {};
      final remoteSet = remote[interestId] ?? {};

      if (!isCompleteForInterests({interestId: localSet}, [interestId])) {
        missingLocal.add(interestId);
      }
      if (!isCompleteForInterests({interestId: remoteSet}, [interestId])) {
        missingRemote.add(interestId);
      }

      var interestMatches = 0;
      for (final q in questions) {
        total++;
        final l = localSet[q.id];
        final r = remoteSet[q.id];
        if (l != null && r != null && l == r) {
          matches++;
          interestMatches++;
        }
      }
      if (questions.isNotEmpty) {
        byInterest[interestId] =
            ((interestMatches / questions.length) * 100).round();
      }
    }

    final percent = total == 0 ? 0 : ((matches / total) * 100).round();
    return QuizCompareResult(
      totalQuestions: total,
      matchingAnswers: matches,
      compatibilityPercent: percent,
      byInterest: byInterest,
      missingLocal: missingLocal,
      missingRemote: missingRemote,
    );
  }
}

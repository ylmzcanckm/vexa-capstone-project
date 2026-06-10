import 'package:flutter/foundation.dart';

@immutable
final class QuizOption {
  const QuizOption({required this.id, required this.text});

  final String id;
  final String text;

  factory QuizOption.fromJson(Map<String, dynamic> j) {
    return QuizOption(
      id: j['id'] as String? ?? '',
      text: j['text'] as String? ?? '',
    );
  }
}

@immutable
final class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
  });

  final String id;
  final String text;
  final List<QuizOption> options;

  factory QuizQuestion.fromJson(Map<String, dynamic> j) {
    return QuizQuestion(
      id: j['id'] as String? ?? '',
      text: j['text'] as String? ?? '',
      options: (j['options'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(QuizOption.fromJson)
              .toList() ??
          const [],
    );
  }
}

/// İlgi alanı başına 5 soru — docx kataloğu ile hizalı.
@immutable
final class QuizCategory {
  const QuizCategory({
    required this.interestId,
    required this.questions,
  });

  final String interestId;
  final List<QuizQuestion> questions;
}

@immutable
final class QuizCompareResult {
  const QuizCompareResult({
    required this.totalQuestions,
    required this.matchingAnswers,
    required this.compatibilityPercent,
    required this.byInterest,
    required this.missingLocal,
    required this.missingRemote,
  });

  final int totalQuestions;
  final int matchingAnswers;
  final int compatibilityPercent;
  final Map<String, int> byInterest;
  final List<String> missingLocal;
  final List<String> missingRemote;

  bool get isPass => compatibilityPercent >= 80;
  bool get canCompare =>
      missingLocal.isEmpty && missingRemote.isEmpty && totalQuestions > 0;
}

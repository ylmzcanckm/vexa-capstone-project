import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:vexa/features/quiz/domain/quiz_models.dart';

/// `assets/quiz/quiz_catalog.json` — WhatsApp docx kaynağından üretildi.
final class QuizCatalog {
  const QuizCatalog._();

  static const _assetPath = 'assets/quiz/quiz_catalog.json';

  static Map<String, List<QuizQuestion>>? _cache;

  static Future<Map<String, List<QuizQuestion>>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final categories = json['categories'] as Map<String, dynamic>? ?? {};
    final out = <String, List<QuizQuestion>>{};
    for (final entry in categories.entries) {
      final list = entry.value as List<dynamic>? ?? [];
      out[entry.key] = list
          .whereType<Map<String, dynamic>>()
          .map(QuizQuestion.fromJson)
          .toList();
    }
    _cache = out;
    return out;
  }

  static Future<List<QuizCategory>> categoriesForInterests(
    List<String> interestIds,
  ) async {
    final all = await load();
    return interestIds
        .where((id) => all.containsKey(id))
        .map(
          (id) => QuizCategory(interestId: id, questions: all[id]!),
        )
        .toList();
  }

  static Future<int> questionCountForInterests(List<String> interestIds) async {
    final cats = await categoriesForInterests(interestIds);
    return cats.fold<int>(0, (sum, c) => sum + c.questions.length);
  }
}

import 'package:flutter/material.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_palette.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/features/profile/domain/match_interest.dart';
import 'package:vexa/features/quiz/data/quiz_catalog.dart';
import 'package:vexa/features/quiz/data/quiz_service.dart';
import 'package:vexa/features/quiz/domain/quiz_models.dart';

/// Seçili ilgi alanları için A/B quiz — cevaplar profile kaydedilir.
class QuizPlayScreen extends StatefulWidget {
  const QuizPlayScreen({
    super.key,
    required this.interestIds,
    this.title = 'İlgi alanı quizi',
  });

  final List<String> interestIds;
  final String title;

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  List<({QuizCategory category, QuizQuestion question})> _flow = [];
  int _index = 0;
  bool _loading = true;
  bool _saving = false;
  String? _error;
  final Map<String, Map<String, String>> _draft = {};

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final cats = await QuizCatalog.categoriesForInterests(widget.interestIds);
      final flow = <({QuizCategory category, QuizQuestion question})>[];
      for (final cat in cats) {
        for (final q in cat.questions) {
          flow.add((category: cat, question: q));
        }
      }
      if (!mounted) return;
      setState(() {
        _flow = flow;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Quiz yüklenemedi.';
        _loading = false;
      });
    }
  }

  Future<void> _pick(String optionId) async {
    if (_saving || _flow.isEmpty) return;
    final item = _flow[_index];
    _draft.putIfAbsent(item.category.interestId, () => {});
    _draft[item.category.interestId]![item.question.id] = optionId;

    if (_index + 1 < _flow.length) {
      setState(() => _index++);
      return;
    }

    setState(() => _saving = true);
    try {
      await QuizService.saveAnswers(_draft);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quiz kaydedilemedi. Tekrar dene.')),
      );
    }
  }

  String _categoryLabel(String id) =>
      MatchInterest.byId(id)?.displayLabel ?? id;

  @override
  Widget build(BuildContext context) {
    final vexa = context.vexa;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _flow.isEmpty
                  ? Center(
                      child: Text(
                        'Bu ilgi alanları için soru bulunamadı.',
                        style: TextStyle(color: vexa.textSecondary),
                      ),
                    )
                  : _saving
                      ? const Center(child: CircularProgressIndicator())
                      : _buildQuestion(vexa, textTheme),
    );
  }

  Widget _buildQuestion(VexaPalette vexa, TextTheme textTheme) {
    final item = _flow[_index];
    final progress = (_index + 1) / _flow.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _categoryLabel(item.category.interestId),
            style: textTheme.labelLarge?.copyWith(color: vexa.textSecondary),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
            backgroundColor: vexa.border,
            color: AppColors.primary,
          ),
          const SizedBox(height: 6),
          Text(
            'Soru ${_index + 1} / ${_flow.length}',
            style: textTheme.bodySmall?.copyWith(color: vexa.textSecondary),
          ),
          const SizedBox(height: 28),
          Text(
            item.question.text,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
          const Spacer(),
          for (final opt in item.question.options) ...[
            _OptionCard(
              label: opt.text,
              onTap: () => _pick(opt.id),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final vexa = context.vexa;
    return Material(
      color: vexa.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: vexa.border),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

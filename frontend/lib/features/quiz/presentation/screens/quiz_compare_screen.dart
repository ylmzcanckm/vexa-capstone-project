import 'package:flutter/material.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_palette.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/features/profile/domain/match_interest.dart';
import 'package:vexa/features/quiz/data/quiz_service.dart';
import 'package:vexa/features/quiz/domain/quiz_models.dart';
import 'package:vexa/features/quiz/presentation/screens/quiz_play_screen.dart';

/// Ortak ilgi alanlarında iki kullanıcının quiz uyumu (%80 hedef).
class QuizCompareScreen extends StatefulWidget {
  const QuizCompareScreen({
    super.key,
    required this.partnerName,
    required this.commonInterestIds,
    required this.remoteBio,
  });

  final String partnerName;
  final List<String> commonInterestIds;
  final String? remoteBio;

  @override
  State<QuizCompareScreen> createState() => _QuizCompareScreenState();
}

class _QuizCompareScreenState extends State<QuizCompareScreen> {
  QuizCompareResult? _result;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runCompare();
  }

  Future<void> _runCompare() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await QuizService.compareLocalWithRemote(
        remoteBio: widget.remoteBio,
        commonInterestIds: widget.commonInterestIds,
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Karşılaştırma yapılamadı.';
        _loading = false;
      });
    }
  }

  Future<void> _openQuiz(List<String> interestIds) async {
    final done = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => QuizPlayScreen(
          interestIds: interestIds,
          title: 'Quizi tamamla',
        ),
      ),
    );
    if (done == true) await _runCompare();
  }

  String _interestLabel(String id) =>
      MatchInterest.byId(id)?.label ?? id;

  @override
  Widget build(BuildContext context) {
    final vexa = context.vexa;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz · ${widget.partnerName}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildBody(vexa, textTheme, _result!),
    );
  }

  Widget _buildBody(
    VexaPalette vexa,
    TextTheme textTheme,
    QuizCompareResult result,
  ) {
    if (result.missingLocal.isNotEmpty) {
      return _missingPanel(
        vexa,
        textTheme,
        title: 'Önce senin quizini tamamla',
        subtitle:
            'Eksik: ${result.missingLocal.map(_interestLabel).join(', ')}',
        onAction: () => _openQuiz(result.missingLocal),
      );
    }
    if (result.missingRemote.isNotEmpty) {
      return _missingPanel(
        vexa,
        textTheme,
        title: '${widget.partnerName} quizi henüz tamamlamamış',
        subtitle:
            'Karşı tarafın şu ilgi alanlarında quiz yapması gerekiyor: '
            '${result.missingRemote.map(_interestLabel).join(', ')}',
        onAction: null,
      );
    }

    final pass = result.isPass;
    return RefreshIndicator(
      onRefresh: _runCompare,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                colors: pass
                    ? [
                        AppColors.primary.withValues(alpha: 0.15),
                        AppColors.primary.withValues(alpha: 0.05),
                      ]
                    : [
                        vexa.surface,
                        vexa.surface,
                      ],
              ),
              border: Border.all(
                color: pass
                    ? AppColors.primary.withValues(alpha: 0.4)
                    : vexa.border,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  pass
                      ? Icons.favorite_rounded
                      : Icons.psychology_alt_outlined,
                  size: 48,
                  color: pass ? AppColors.primary : vexa.textSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  pass ? 'Quiz uyumu yüksek!' : 'Quiz uyumu düşük',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '%${result.compatibilityPercent}',
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${result.matchingAnswers} / ${result.totalQuestions} aynı cevap'
                  ' · hedef ≥ %${QuizService.passThresholdPercent}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: vexa.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Kategori bazında',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          for (final id in widget.commonInterestIds)
            if (result.byInterest.containsKey(id))
              Card(
                child: ListTile(
                  title: Text(_interestLabel(id)),
                  trailing: Text(
                    '%${result.byInterest[id]}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _missingPanel(
    VexaPalette vexa,
    TextTheme textTheme, {
    required String title,
    required String subtitle,
    required VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.quiz_outlined, size: 56, color: vexa.textSecondary),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: vexa.textSecondary, height: 1.4),
            ),
            if (onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onAction,
                child: const Text('Quize başla'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:vexa/core/api/api_exception.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/features/matching/data/match_cooldown_store.dart';
import 'package:vexa/features/matching/data/match_repository.dart';
import 'package:vexa/features/matching/presentation/screens/match_compass_screen.dart';
import 'package:vexa/features/profile/domain/match_interest.dart';
import 'package:vexa/features/quiz/data/live_quiz_session.dart';

enum _Phase { loading, answering, saving, waiting, failed, error }

/// Eşleşme sonrası iki cihazın eş zamanlı çözdüğü 5 soruluk quiz.
///
/// İki telefonda da aynı sorular gelir; ikisi de bitirince karşılaştırılır.
/// ≥ %80 (4/5) → Minecraft pusulası ekranı.
class LiveQuizScreen extends StatefulWidget {
  const LiveQuizScreen({
    super.key,
    required this.matchId,
    required this.partnerId,
    required this.partnerName,
    required this.commonInterestIds,
  });

  final String matchId;
  final String partnerId;
  final String partnerName;
  final List<String> commonInterestIds;

  @override
  State<LiveQuizScreen> createState() => _LiveQuizScreenState();
}

class _LiveQuizScreenState extends State<LiveQuizScreen> {
  List<LiveQuizQuestionRef> _questions = [];
  final Map<String, String> _answers = {};
  int _index = 0;
  _Phase _phase = _Phase.loading;
  int _matchingCount = 0;
  String? _error;
  Timer? _pollTimer;

  /// Sunucu quiz endpoint'i kullanılabilir mi? 404 → eski bio yolu.
  bool _serverQuiz = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final questions = await LiveQuizSession.questionsFor(
        matchId: widget.matchId,
        commonInterestIds: widget.commonInterestIds,
      );
      if (!mounted) return;
      if (questions.isEmpty) {
        setState(() {
          _error = 'Quiz soruları yüklenemedi.';
          _phase = _Phase.error;
        });
        return;
      }
      setState(() {
        _questions = questions;
        _phase = _Phase.answering;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Quiz soruları yüklenemedi.';
        _phase = _Phase.error;
      });
    }
  }

  Future<void> _pick(String optionId) async {
    final q = _questions[_index];
    _answers[q.key] = optionId;

    if (_index + 1 < _questions.length) {
      setState(() => _index++);
      return;
    }
    await _submit();
  }

  Future<void> _submit() async {
    setState(() => _phase = _Phase.saving);

    // Yerel kayıt + bio sync (eski backend için yedek yol).
    try {
      await LiveQuizSession.saveMyAnswers(widget.matchId, _answers);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Cevaplar sunucuya gönderilemedi. Tekrar dene.';
        _phase = _Phase.error;
      });
      return;
    }

    // Sunucu quiz oturumu (yeni backend).
    Map<String, dynamic>? data;
    try {
      data = await MatchRepository.submitQuizAnswers(
        matchId: widget.matchId,
        answers: _answers,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) _serverQuiz = false;
    } catch (_) {}

    if (!mounted) return;
    if (data != null && data['bothSubmitted'] == true) {
      await _finishFromServer(data);
      return;
    }

    setState(() => _phase = _Phase.waiting);
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkPartner(),
    );
    unawaited(_checkPartner());
  }

  Future<void> _checkPartner() async {
    if (_phase != _Phase.waiting) return;

    if (_serverQuiz) {
      try {
        final data = await MatchRepository.fetchQuizSession(widget.matchId);
        if (data['bothSubmitted'] == true) {
          await _finishFromServer(data);
        }
        return;
      } on ApiException catch (e) {
        if (e.statusCode == 404) {
          _serverQuiz = false; // eski backend → bio yoluna düş
        } else {
          return;
        }
      } catch (_) {
        return;
      }
    }

    // Eski yol: karşı tarafın cevapları profil bio'sundan okunur.
    try {
      final candidates = await MatchRepository.fetchCandidates();
      final partner = candidates.where((c) => c.id == widget.partnerId).toList();
      if (partner.isEmpty) return;

      final partnerAnswers = LiveQuizSession.partnerAnswersFromBio(
        partner.first.profileBio,
        widget.matchId,
      );
      if (partnerAnswers == null) return;

      final keys = _questions.map((q) => q.key).toList();
      final answeredAll = keys.every(
        (k) => partnerAnswers[k] == 'a' || partnerAnswers[k] == 'b',
      );
      if (!answeredAll) return;

      final count = LiveQuizSession.matchingCount(
        mine: _answers,
        partner: partnerAnswers,
        keys: keys,
      );

      _pollTimer?.cancel();
      await MatchCooldownStore.activate();
      if (!mounted) return;
      await _showResult(matchingCount: count, total: _questions.length);
    } catch (_) {
      // Geçici hata: sonraki yoklamada tekrar dene.
    }
  }

  /// Sunucunun hesapladığı sonuçla bitir (cooldown dahil).
  Future<void> _finishFromServer(Map<String, dynamic> data) async {
    _pollTimer?.cancel();

    final matching = (data['matching'] as num?)?.toInt() ?? 0;
    final total = (data['total'] as num?)?.toInt() ?? _questions.length;

    final cooldownRaw = data['cooldownUntil'];
    final cooldownUntil =
        cooldownRaw is String ? DateTime.tryParse(cooldownRaw) : null;
    if (cooldownUntil != null) {
      await MatchCooldownStore.activateUntil(cooldownUntil.toLocal());
    } else {
      await MatchCooldownStore.activate();
    }

    if (!mounted) return;
    await _showResult(matchingCount: matching, total: total);
  }

  Future<void> _showResult({
    required int matchingCount,
    required int total,
  }) async {
    final safeTotal = total > 0 ? total : _questions.length;
    final percent = ((matchingCount / safeTotal) * 100).round();

    if (matchingCount >= LiveQuizSession.passCount) {
      await Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute<void>(
          builder: (_) => MatchCompassScreen(
            matchId: widget.matchId,
            partnerName: widget.partnerName,
            compatibilityPercent: percent,
          ),
        ),
      );
    } else {
      setState(() {
        _matchingCount = matchingCount;
        _phase = _Phase.failed;
      });
    }
  }

  String _interestLabel(String id) =>
      MatchInterest.byId(id)?.displayLabel ?? id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quiz · ${widget.partnerName}')),
      body: switch (_phase) {
        _Phase.loading ||
        _Phase.saving =>
          const Center(child: CircularProgressIndicator()),
        _Phase.error => _buildError(),
        _Phase.answering => _buildQuestion(),
        _Phase.waiting => _buildWaiting(),
        _Phase.failed => _buildFailed(),
      },
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error ?? 'Bir hata oluştu.', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                setState(() => _phase = _Phase.loading);
                if (_questions.isEmpty) {
                  _load();
                } else {
                  _submit();
                }
              },
              child: const Text('Tekrar dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestion() {
    final vexa = context.vexa;
    final textTheme = Theme.of(context).textTheme;
    final item = _questions[_index];
    final progress = (_index + 1) / _questions.length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _interestLabel(item.interestId),
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
            'Soru ${_index + 1} / ${_questions.length}',
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
            Material(
              color: vexa.surface,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => _pick(opt.id),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: vexa.border),
                  ),
                  child: Text(
                    opt.text,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  Widget _buildWaiting() {
    final vexa = context.vexa;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Cevapların gönderildi.',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.partnerName} quizi bitirince sonuç burada açılacak…',
              textAlign: TextAlign.center,
              style: TextStyle(color: vexa.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Arka planda bekle'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFailed() {
    final vexa = context.vexa;
    final percent = ((_matchingCount / _questions.length) * 100).round();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: 96,
              color: vexa.textSecondary,
            ),
            const SizedBox(height: 20),
            Text(
              'Maalesef birbirinize uygun değilsiniz',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.25,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'Uyum %$percent — $_matchingCount / ${_questions.length} aynı '
              'cevap (hedef en az ${LiveQuizSession.passCount}).',
              textAlign: TextAlign.center,
              style: TextStyle(color: vexa.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              '2 saatlik eşleşme molası başladı.',
              style: TextStyle(
                color: vexa.textSecondary,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        ),
      ),
    );
  }
}

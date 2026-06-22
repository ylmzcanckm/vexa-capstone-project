import 'package:flutter/material.dart';
import 'package:vexa/core/api/api_exception.dart';
import 'package:vexa/core/api/models/match_models.dart';
import 'package:vexa/core/api/profile_bio_codec.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/features/matching/data/discovery_filters_store.dart';
import 'package:vexa/features/matching/data/live_match_watcher.dart';
import 'package:vexa/features/matching/data/match_cooldown_store.dart';
import 'package:vexa/features/matching/data/match_proximity_gate.dart';
import 'package:vexa/features/matching/data/match_repository.dart';
import 'package:vexa/features/profile/domain/match_interest.dart';
import 'package:vexa/features/quiz/presentation/screens/live_quiz_screen.dart';

/// Aday listesi — yalnızca geliştirici / tanılama (eşleşme yine yakınlık kapısından geçer).
class MatchCandidatesScreen extends StatefulWidget {
  const MatchCandidatesScreen({super.key});

  @override
  State<MatchCandidatesScreen> createState() => _MatchCandidatesScreenState();
}

class _MatchCandidatesScreenState extends State<MatchCandidatesScreen> {
  List<RemoteMatchCandidate>? _candidates;
  String? _error;
  bool _loading = true;
  String? _checkingId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await MatchRepository.fetchCandidates();
      if (!mounted) return;
      setState(() {
        _candidates = list;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Adaylar yüklenemedi.';
        _loading = false;
      });
    }
  }

  Future<void> _check(RemoteMatchCandidate candidate) async {
    final scanBlock = await MatchProximityGate.runProximityScan();
    if (scanBlock != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(scanBlock.message)),
      );
      return;
    }

    final cooldown = await MatchCooldownStore.remaining();
    if (cooldown != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Eşleşme molası aktif — kalan: '
            '${MatchCooldownStore.formatRemaining(cooldown)}.',
          ),
        ),
      );
      return;
    }

    setState(() => _checkingId = candidate.id);
    try {
      // Tanışma filtreleri tam tutmuyorsa quiz daveti verilmez.
      final filters = await DiscoveryFiltersStore.load();
      final profile = ProfileBioCodec.tryDecodeProfileOnly(candidate.profileBio);
      final filtersOk = filters == null ||
          profile == null ||
          DiscoveryFilterMatcher.matches(filters, profile);

      final result = await MatchRepository.checkMatch(targetUserId: candidate.id);
      final canQuiz =
          result.isMatch && result.commonInterests.isNotEmpty && filtersOk;
      if (canQuiz) {
        MatchProximityGate.recordProximitySignal();
      }
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(result.isMatch ? 'Eşleşme!' : 'Eşleşme yok'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${candidate.displayName} ile uyum: %${result.matchScore}'),
              const SizedBox(height: 8),
              Text(
                result.isMatch
                    ? 'Skor ≥ 50 — geçmişe kaydedildi.'
                    : result.isFiltered
                        ? 'Skor yeterli ama tanışma filtreleri uyuşmuyor.'
                        : 'Skor < 50 — henüz eşleşme sayılmıyor.',
              ),
              if (result.commonInterests.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Ortak ilgi: ${result.commonInterests.map(_interestLabel).join(', ')}',
                ),
              ],
              if (result.sameMode) ...[
                const SizedBox(height: 8),
                const Text('Aynı mod seçili (+puan).'),
              ],
              if (canQuiz) ...[
                const SizedBox(height: 12),
                const Text(
                  'Quiz ile uyumunu ölçmek için devam edebilirsin (hedef ≥ %80).',
                ),
              ],
              if (result.isMatch && !filtersOk) ...[
                const SizedBox(height: 12),
                const Text(
                  'Tanışma filtrelerinle tam uyuşmuyor — quiz daveti çıkmaz.',
                ),
              ],
            ],
          ),
          actions: [
            if (canQuiz)
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  final block = await MatchProximityGate.inviteBlockReason();
                  if (block != null) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(block.message)),
                    );
                    return;
                  }
                  LiveMatchWatcher.markHandled(result.id);
                  if (!context.mounted) return;
                  Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => LiveQuizScreen(
                        matchId: result.id,
                        partnerId: candidate.id,
                        partnerName: candidate.displayName,
                        commonInterestIds: result.commonInterests,
                      ),
                    ),
                  );
                },
                child: const Text('Quize geç'),
              ),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$e')),
      );
    } finally {
      if (mounted) setState(() => _checkingId = null);
    }
  }

  static String _interestLabel(String id) {
    return MatchInterest.byId(id)?.label ?? id;
  }

  @override
  Widget build(BuildContext context) {
    final vexa = context.vexa;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adaylar'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('Tekrar dene'),
                        ),
                      ],
                    ),
                  ),
                )
              : (_candidates == null || _candidates!.isEmpty)
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Henüz başka kullanıcı yok.\nCan da kayıt olunca burada görünür.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: vexa.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _candidates!.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final c = _candidates![index];
                        final checking = _checkingId == c.id;
                        return Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  AppColors.primary.withValues(alpha: 0.15),
                              child: Text(
                                c.displayName.isNotEmpty
                                    ? c.displayName[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            title: Text(
                              c.displayName,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(
                              [
                                if (c.selectedMode != null) 'Mod: ${c.selectedMode}',
                                if (c.interests.isNotEmpty)
                                  'İlgi: ${c.interests.map(_interestLabel).take(2).join(', ')}',
                              ].join(' · '),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: checking
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : FilledButton(
                                    onPressed: () => _check(c),
                                    child: const Text('Kontrol'),
                                  ),
                          ),
                        );
                      },
                    ),
    );
  }
}

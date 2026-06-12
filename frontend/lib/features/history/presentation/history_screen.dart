import 'package:flutter/material.dart';
import 'package:vexa/core/api/api_exception.dart';
import 'package:vexa/core/api/models/match_models.dart';
import 'package:vexa/core/api/profile_bio_codec.dart';
import 'package:vexa/core/storage/user_profile_store.dart';
import 'package:vexa/core/theme/vexa_palette.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/features/history/presentation/matched_person_card_screen.dart';
import 'package:vexa/features/matching/data/match_repository.dart';
import 'package:vexa/features/matching/presentation/screens/match_candidates_screen.dart';
import 'package:vexa/features/mode/domain/vexa_mode.dart';
import 'package:vexa/features/mode/domain/vexa_mode_api.dart';
import 'package:vexa/features/mode/presentation/vexa_mode_style.dart';
import 'package:vexa/features/profile/domain/match_interest.dart';

/// Mod bazlı eşleşme geçmişi — sosyal: quiz geçenler; network: direkt eşleşenler.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.modeContext});

  final VexaMode modeContext;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<RemoteMatchHistoryItem>? _items;
  String? _error;
  bool _loading = true;

  String? get _backendMode => widget.modeContext.backendMode;

  String get _title => switch (widget.modeContext) {
        VexaMode.social => 'Sosyal geçmiş',
        VexaMode.business => 'Network geçmiş',
        VexaMode.ghost => 'Geçmiş',
      };

  String get _emptyHint => switch (widget.modeContext) {
        VexaMode.social =>
          'Henüz quiz geçtiğin bir eşleşme yok.\nEşleşince quizi tamamla, kişi kartı buraya düşer.',
        VexaMode.business =>
          'Henüz network eşleşmen yok.\nNetwork modunda eşleşince kişi kartı direkt buraya düşer.',
        VexaMode.ghost => 'Ghost modda geçmiş görüntülenmez.',
      };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_backendMode == null) {
      setState(() {
        _items = const [];
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      var items = await MatchRepository.fetchHistory(mode: _backendMode);
      items = _applyClientFallbackFilter(items);
      if (!mounted) return;
      setState(() {
        _items = items;
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
        _error = 'Geçmiş yüklenemedi. Bağlantını kontrol et.';
        _loading = false;
      });
    }
  }

  /// Eski backend `?mode=` filtresini tanımıyorsa istemci tarafında süzer.
  List<RemoteMatchHistoryItem> _applyClientFallbackFilter(
    List<RemoteMatchHistoryItem> items,
  ) {
    final mode = _backendMode;
    if (mode == null) return const [];

    return items.where((item) {
      if (item.mode != mode) return false;
      if (mode == 'social') {
        return (item.quizPercent ?? 0) >= 80 ||
            item.status == 'completed';
      }
      if (mode == 'networking') {
        return item.status == 'detected' || item.status == 'completed';
      }
      return false;
    }).toList();
  }

  void _openCard(RemoteMatchHistoryItem item) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MatchedPersonCardScreen(
          profileContext: widget.modeContext,
          displayName: item.otherUser.displayName,
          profileBio: item.otherUser.bio,
          matchScore: item.matchScore,
          quizPercent: item.quizPercent,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vexa = context.vexa;

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _buildBody(vexa),
    );
  }

  Widget _buildBody(VexaPalette vexa) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, size: 48),
              const SizedBox(height: 16),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _load,
                child: const Text('Tekrar dene'),
              ),
            ],
          ),
        ),
      );
    }

    final items = _items ?? const <RemoteMatchHistoryItem>[];
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _emptyHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: vexa.textSecondary, fontSize: 16),
              ),
              if (widget.modeContext != VexaMode.ghost) ...[
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push<void>(
                      MaterialPageRoute<void>(
                        builder: (_) => const MatchCandidatesScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.people_outline_rounded),
                  label: const Text('Adayları gör'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = items[index];
          return _HistoryPersonCard(
            item: item,
            modeContext: widget.modeContext,
            onTap: () => _openCard(item),
          );
        },
      ),
    );
  }
}

class _HistoryPersonCard extends StatelessWidget {
  const _HistoryPersonCard({
    required this.item,
    required this.modeContext,
    required this.onTap,
  });

  final RemoteMatchHistoryItem item;
  final VexaMode modeContext;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final vexa = context.vexa;
    final profile = ProfileBioCodec.tryDecodeProfileOnly(item.otherUser.bio);
    final subtitle = _subtitle(profile);

    return Card(
      elevation: 0,
      color: vexa.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: vexa.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor:
                    modeContext.accentColor.withValues(alpha: 0.15),
                child: Text(
                  item.otherUser.displayName.isNotEmpty
                      ? item.otherUser.displayName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: modeContext.accentColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.otherUser.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: vexa.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    if (item.quizPercent != null) ...[
                      const SizedBox(height: 6),
                      Text(
                        'Quiz: %${item.quizPercent}',
                        style: TextStyle(
                          fontSize: 12,
                          color: modeContext.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.matchScore}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    'skor',
                    style: TextStyle(fontSize: 11, color: vexa.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: vexa.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(StoredUserProfile? profile) {
    if (modeContext == VexaMode.business) {
      final b = profile?.business;
      if (b == null) return 'Network profili';
      final parts = <String>[
        if (b.jobTitle.isNotEmpty) b.jobTitle,
        if (b.companyOrUniversity.isNotEmpty) b.companyOrUniversity,
      ];
      return parts.isEmpty ? 'Network profili' : parts.join(' · ');
    }

    final s = profile?.social;
    if (s == null) {
      final interests = item.commonInterests
          .map((id) => MatchInterest.byId(id)?.label ?? id)
          .take(2)
          .join(', ');
      return interests.isEmpty ? 'Sosyal profil' : 'Ortak: $interests';
    }
    if (s.aboutMe != null && s.aboutMe!.trim().isNotEmpty) {
      return s.aboutMe!.trim();
    }
    if (s.interestIds.isNotEmpty) {
      return s.interestIds
          .map((id) => MatchInterest.byId(id)?.label ?? id)
          .take(3)
          .join(', ');
    }
    return 'Sosyal profil';
  }
}

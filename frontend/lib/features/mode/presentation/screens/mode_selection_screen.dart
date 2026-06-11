import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vexa/core/api/api_exception.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/features/auth/data/user_repository.dart';
import 'package:vexa/features/history/presentation/history_screen.dart';
import 'package:vexa/features/finder/data/vexa_finder_service.dart';
import 'package:vexa/features/matching/data/live_match_watcher.dart';
import 'package:vexa/features/matching/data/proximity_scanner.dart';
import 'package:vexa/features/matching/presentation/screens/match_invite_screen.dart';
import 'package:vexa/features/mode/domain/vexa_mode.dart';
import 'package:vexa/features/mode/domain/vexa_mode_api.dart';
import 'package:vexa/features/mode/presentation/vexa_mode_style.dart';
import 'package:vexa/features/mode/presentation/widgets/mode_profile_gate_tabs.dart';
import 'package:vexa/features/profile/presentation/screens/profile_person_screen.dart';
import 'package:vexa/features/quiz/presentation/screens/live_quiz_screen.dart';
import 'package:vexa/features/settings/presentation/settings_screen.dart';

/// Profil + avatar tamamlandıktan sonra ana ekran (wireframe: üst hap modlar,
/// ortada sürüklenen arka plan, altta Geçmiş / Profil / Ayarlar).
class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;
  String? _lastSyncedBackendMode;
  bool _bootstrapping = true;

  @override
  void initState() {
    super.initState();
    _bootstrapSelectedMode();
    LiveMatchWatcher.start(onInvite: _onLiveMatchInvite);
    ProximityScanner.start(onInvite: _onLiveMatchInvite);
  }

  @override
  void dispose() {
    LiveMatchWatcher.stop();
    ProximityScanner.stop();
    _pageController.dispose();
    super.dispose();
  }

  /// İki cihaz birbirini görünce (yeni eşleşme) tam ekran davet + canlı quiz.
  Future<void> _onLiveMatchInvite(LiveMatchInvite invite) async {
    if (!mounted) return;
    LiveMatchWatcher.suspended = true;
    // LilyGO: titreşim (+ firmware gelince ekranda "QUIZ TIME").
    unawaited(VexaFinderService.pulseDeviceIfPossible());
    try {
      final accepted = await Navigator.of(context).push<bool>(
        PageRouteBuilder<bool>(
          fullscreenDialog: true,
          opaque: true,
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (ctx, animation, secondary) => FadeTransition(
            opacity:
                CurvedAnimation(parent: animation, curve: Curves.easeOut),
            child: MatchInviteScreen(
              partnerName: invite.partnerName,
              matchScore: invite.matchScore,
            ),
          ),
        ),
      );
      if (accepted == true && mounted) {
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => LiveQuizScreen(
              matchId: invite.matchId,
              partnerId: invite.partnerId,
              partnerName: invite.partnerName,
              commonInterestIds: invite.commonInterests,
            ),
          ),
        );
      }
    } finally {
      LiveMatchWatcher.suspended = false;
    }
  }

  Future<void> _bootstrapSelectedMode() async {
    try {
      final user = await UserRepository.fetchMe();
      final fromServer = VexaModeApi.fromBackend(user.settings?.selectedMode);
      if (fromServer != null && mounted) {
        final index = VexaMode.values.indexOf(fromServer);
        if (index >= 0 && index != _pageIndex) {
          _pageIndex = index;
          _lastSyncedBackendMode = fromServer.backendMode;
          if (_pageController.hasClients) {
            _pageController.jumpToPage(index);
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && _pageController.hasClients) {
                _pageController.jumpToPage(index);
              }
            });
          }
        }
      }
    } catch (_) {
      // Offline: varsayılan sosyal modda kal.
    } finally {
      if (mounted) setState(() => _bootstrapping = false);
    }
  }

  Future<void> _syncModeToServer(VexaMode mode) async {
    final backendMode = mode.backendMode;
    if (backendMode == null || backendMode == _lastSyncedBackendMode) {
      return;
    }
    try {
      await UserRepository.setMode(backendMode);
      _lastSyncedBackendMode = backendMode;
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mod kaydedilemedi: ${e.message}')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mod sunucuya yazılamadı.')),
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() => _pageIndex = index);
    final mode = VexaMode.values[index];
    debugPrint('VexaMode: $mode');
    _syncModeToServer(mode);
  }

  Future<void> _goToPage(int index) async {
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  double _contentTopPadding(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return top + 24 + 28 + 10 + 52 + 16;
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final vexa = context.vexa;

    if (_bootstrapping) {
      return Scaffold(
        backgroundColor: vexa.scaffold,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: vexa.scaffold,
      body: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: VexaMode.values.length,
            itemBuilder: (context, index) {
              final mode = VexaMode.values[index];
              final bottomPad =
                  MediaQuery.paddingOf(context).bottom + 112;
              return DecoratedBox(
                decoration: BoxDecoration(
                  gradient: mode.pageBackgroundGradient(context),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    _contentTopPadding(context),
                    24,
                    bottomPad,
                  ),
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  child: _ModeBodyContent(mode: mode),
                ),
              );
            },
          ),
          Positioned(
            top: topInset + 8,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'VEXA',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        color: vexa.textPrimary,
                      ),
                ),
                const SizedBox(height: 10),
                _ModePillBar(
                  currentIndex: _pageIndex,
                  onSelect: (i) => _goToPage(i),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomActionsBar(
              onHistory: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const HistoryScreen(),
                  ),
                );
              },
              onProfile: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => ProfilePersonScreen(
                      profileContext: VexaMode.values[_pageIndex],
                    ),
                  ),
                );
              },
              onSettings: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ModePillBar extends StatelessWidget {
  const _ModePillBar({
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final vexa = context.vexa;
    return Material(
      color: vexa.pillBar,
      borderRadius: BorderRadius.circular(32),
      elevation: context.isDarkMode ? 0 : 2,
      shadowColor: Colors.black26,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: List.generate(VexaMode.values.length, (i) {
            final mode = VexaMode.values[i];
            final selected = i == currentIndex;
            return Expanded(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onSelect(i),
                  borderRadius: BorderRadius.circular(28),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selected ? mode.accentColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      mode.shortLabel,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: selected ? Colors.white : vexa.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ModeBodyContent extends ConsumerWidget {
  const _ModeBodyContent({required this.mode});

  final VexaMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final vexa = context.vexa;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          mode.bodyHeadline,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: vexa.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          mode.bodySubtitle,
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 28),
        Text(
          'Yana kaydırarak mod değiştir.',
          style: TextStyle(
            fontSize: 13,
            color: vexa.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 20),
        switch (mode) {
          VexaMode.social => const SocialModeProfileGate(),
          VexaMode.business => const NetworkModeProfileGate(),
          VexaMode.ghost => const GhostModeVisual(),
        },
      ],
    );
  }
}

class _BottomActionsBar extends StatelessWidget {
  const _BottomActionsBar({
    required this.onHistory,
    required this.onProfile,
    required this.onSettings,
  });

  final VoidCallback onHistory;
  final VoidCallback onProfile;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final vexa = context.vexa;
    return Material(
      color: vexa.bottomBar,
      elevation: context.isDarkMode ? 0 : 8,
      shadowColor: Colors.black12,
      child: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: vexa.border)),
          ),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Expanded(
                child: _BottomTile(
                  icon: Icons.history_rounded,
                  label: 'Geçmiş',
                  onTap: onHistory,
                ),
              ),
              Expanded(
                child: _BottomTile(
                  icon: Icons.person_outline_rounded,
                  label: 'Profil',
                  onTap: onProfile,
                ),
              ),
              Expanded(
                child: _BottomTile(
                  icon: Icons.settings_outlined,
                  label: 'Ayarlar',
                  onTap: onSettings,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomTile extends StatelessWidget {
  const _BottomTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final vexa = context.vexa;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 26, color: vexa.textPrimary),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: vexa.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

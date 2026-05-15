import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vexa/core/profile/profile_gate_helpers.dart';
import 'package:vexa/core/storage/user_profile_store.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/features/matching/presentation/widgets/discovery_filters_section.dart';
import 'package:vexa/features/mode/presentation/widgets/business_profile_completion_section.dart';
import 'package:vexa/features/mode/presentation/widgets/social_profile_completion_section.dart';

/// Sosyal mod: profil tamamlanmadan blur + diyalog; tamamlanınca yalnızca tanışma filtreleri.
class SocialModeProfileGate extends ConsumerStatefulWidget {
  const SocialModeProfileGate({super.key});

  @override
  ConsumerState<SocialModeProfileGate> createState() =>
      _SocialModeProfileGateState();
}

class _SocialModeProfileGateState extends ConsumerState<SocialModeProfileGate> {
  StoredUserProfile? _profile;
  bool _loading = true;
  bool _autoPromptScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _reload();
      if (!mounted || _autoPromptScheduled) return;
      _autoPromptScheduled = true;
      if (!isSocialProfileComplete(_profile?.social)) {
        await _showProfileDialog();
        await _reload();
      }
    });
  }

  Future<void> _reload() async {
    final p = await UserProfileStore.load();
    if (!mounted) return;
    setState(() {
      _profile = p;
      _loading = false;
    });
  }

  Future<void> _showProfileDialog() async {
    if (!mounted) return;
    final editorKey = GlobalKey<SocialProfileEditorState>();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Profilinizi oluşturun'),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.sizeOf(ctx).height * 0.72,
            child: SingleChildScrollView(
              child: SocialProfileEditor(
                key: editorKey,
                showInlineSave: false,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Daha sonra'),
            ),
            FilledButton(
              onPressed: () async {
                final ok =
                    await editorKey.currentState?.persist(ctx) ?? false;
                if (ok && ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final complete = isSocialProfileComplete(_profile?.social);

    if (complete) {
      return const DiscoveryFiltersSection();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Sosyal profil',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            await _showProfileDialog();
            await _reload();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 320,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.88,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: SocialProfileEditor(
                            showInlineSave: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Material(
                  color: context.vexa.surface.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(14),
                  elevation: context.isDarkMode ? 0 : 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_person_outlined,
                            size: 36, color: AppColors.primary),
                        const SizedBox(height: 10),
                        Text(
                          'Devam etmek için sosyal profilini oluştur.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: context.vexa.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dokunarak veya açılan pencereden bilgilerini girebilirsin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.vexa.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Network mod: profil tamamlanmadan blur + diyalog; tamamlanınca özet mesaj.
class NetworkModeProfileGate extends StatefulWidget {
  const NetworkModeProfileGate({super.key});

  @override
  State<NetworkModeProfileGate> createState() => _NetworkModeProfileGateState();
}

class _NetworkModeProfileGateState extends State<NetworkModeProfileGate> {
  StoredUserProfile? _profile;
  bool _loading = true;
  bool _autoPromptScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _reload();
      if (!mounted || _autoPromptScheduled) return;
      _autoPromptScheduled = true;
      if (!isBusinessProfileComplete(_profile?.business)) {
        await _showProfileDialog();
        await _reload();
      }
    });
  }

  Future<void> _reload() async {
    final p = await UserProfileStore.load();
    if (!mounted) return;
    setState(() {
      _profile = p;
      _loading = false;
    });
  }

  Future<void> _showProfileDialog() async {
    if (!mounted) return;
    final editorKey = GlobalKey<BusinessProfileEditorState>();
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Network profilini oluşturun'),
          content: SizedBox(
            width: double.maxFinite,
            height: MediaQuery.sizeOf(ctx).height * 0.78,
            child: SingleChildScrollView(
              child: BusinessProfileEditor(
                key: editorKey,
                showInlineSave: false,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Daha sonra'),
            ),
            FilledButton(
              onPressed: () async {
                final ok = await editorKey.currentState?.persist() ?? false;
                if (ok && ctx.mounted) Navigator.of(ctx).pop();
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final complete = isBusinessProfileComplete(_profile?.business);

    if (complete) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            'Network kartın hazır. Düzenlemek için alttan Profil’e git (Business sekmesindeyken).',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: context.vexa.textSecondary,
                  height: 1.45,
                ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Network profili',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            await _showProfileDialog();
            await _reload();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 360,
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.88,
                        child: SingleChildScrollView(
                          physics: const NeverScrollableScrollPhysics(),
                          child: BusinessProfileEditor(
                            showInlineSave: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Material(
                  color: context.vexa.surface.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(14),
                  elevation: context.isDarkMode ? 0 : 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.business_center_outlined,
                            size: 36, color: AppColors.primary),
                        const SizedBox(height: 10),
                        Text(
                          'Network özelliğini kullanmak için profilini oluştur.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: context.vexa.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dokunarak veya açılan pencereden bilgilerini girebilirsin.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: context.vexa.textSecondary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Ghost mod: yalnızca hayalet görseli.
class GhostModeVisual extends StatelessWidget {
  const GhostModeVisual({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Opacity(
            opacity: 0.45,
            child: Text(
              '👻',
              style: TextStyle(
                fontSize: MediaQuery.sizeOf(context).shortestSide * 0.28,
                height: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

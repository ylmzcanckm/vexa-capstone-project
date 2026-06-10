import 'dart:async' show Timer, unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vexa/core/theme/app_colors.dart';

/// Yakınlık eşleşmesi — tam ekran mavi-mor dikkat uyarısı.
///
/// Donanım titreşim motoru gelince [VexaFinderService] LilyGO'ya da pulse yollar.
class VexaFinderAlertScreen extends StatefulWidget {
  const VexaFinderAlertScreen({
    super.key,
    this.subtitle,
    this.onExplore,
  });

  final String? subtitle;
  final VoidCallback? onExplore;

  @override
  State<VexaFinderAlertScreen> createState() => _VexaFinderAlertScreenState();
}

class _VexaFinderAlertScreenState extends State<VexaFinderAlertScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  Timer? _hapticTimer;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _startHaptics();
  }

  void _startHaptics() {
    unawaited(HapticFeedback.heavyImpact());
    _hapticTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      HapticFeedback.mediumImpact();
    });
  }

  @override
  void dispose() {
    _hapticTimer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _dismiss() => Navigator.of(context).pop(false);

  void _explore() {
    Navigator.of(context).pop(true);
    widget.onExplore?.call();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _dismiss();
      },
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _pulse,
          builder: (context, child) {
            final t = 0.35 + _pulse.value * 0.25;
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(AppColors.primary, Colors.white, 1 - t)!,
                    Color.lerp(AppColors.accent, AppColors.primary, t)!,
                  ],
                ),
              ),
              child: child,
            );
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      onPressed: _dismiss,
                      icon: const Icon(Icons.close_rounded, color: Colors.white),
                      tooltip: 'Kapat',
                    ),
                  ),
                  const Spacer(flex: 2),
                  Icon(
                    Icons.sensors_rounded,
                    size: 88,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Yakında uyumlu biri var',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.subtitle ??
                        'VEXA cihazın titreşince eşleşmeyi inceleyebilirsin.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 16,
                      height: 1.45,
                    ),
                  ),
                  const Spacer(flex: 3),
                  FilledButton(
                    onPressed: _explore,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(54),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    child: const Text('İncele'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _dismiss,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Şimdilik geç'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

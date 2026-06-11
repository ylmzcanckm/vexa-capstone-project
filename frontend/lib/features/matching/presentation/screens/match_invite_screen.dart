import 'dart:async' show Timer, unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vexa/core/theme/app_colors.dart';

/// İki cihaz birbirini görünce çıkan tam ekran mavi-mor eşleşme daveti.
///
/// `true` → quize geç, `false` → şimdilik geç.
class MatchInviteScreen extends StatefulWidget {
  const MatchInviteScreen({
    super.key,
    required this.partnerName,
    required this.matchScore,
  });

  final String partnerName;
  final int matchScore;

  @override
  State<MatchInviteScreen> createState() => _MatchInviteScreenState();
}

class _MatchInviteScreenState extends State<MatchInviteScreen>
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

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.of(context).pop(false);
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
                  const Spacer(flex: 2),
                  Icon(
                    Icons.favorite_rounded,
                    size: 88,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Eşleşme var!',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    '${widget.partnerName} ile uyum %${widget.matchScore}.\n'
                    'Quize geçmek ister misin?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 17,
                      height: 1.45,
                    ),
                  ),
                  const Spacer(flex: 3),
                  FilledButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      minimumSize: const Size.fromHeight(54),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    child: const Text('Quize geç'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
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

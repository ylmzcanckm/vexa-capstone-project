import 'dart:async' show Timer, unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/features/history/presentation/matched_person_card_screen.dart';
import 'package:vexa/features/mode/domain/vexa_mode.dart';

/// Network modunda eşleşme — quiz yok, kişi kartı geçmişe düşer.
class NetworkMatchScreen extends StatefulWidget {
  const NetworkMatchScreen({
    super.key,
    required this.partnerName,
    required this.matchScore,
    required this.partnerBio,
  });

  final String partnerName;
  final int matchScore;
  final String? partnerBio;

  @override
  State<NetworkMatchScreen> createState() => _NetworkMatchScreenState();
}

class _NetworkMatchScreenState extends State<NetworkMatchScreen>
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

  void _openCard() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MatchedPersonCardScreen(
          profileContext: VexaMode.business,
          displayName: widget.partnerName,
          profileBio: widget.partnerBio,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Navigator.of(context).pop();
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
                    Color.lerp(const Color(0xFF1E88E5), Colors.white, 1 - t)!,
                    Color.lerp(const Color(0xFF1565C0), AppColors.primary, t)!,
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
                    Icons.handshake_rounded,
                    size: 88,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Network eşleşmesi!',
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
                    'Kişi kartı network geçmişine eklendi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: 17,
                      height: 1.45,
                    ),
                  ),
                  const Spacer(flex: 3),
                  FilledButton(
                    onPressed: _openCard,
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1565C0),
                      minimumSize: const Size.fromHeight(54),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    child: const Text('Kişi kartını gör'),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(foregroundColor: Colors.white),
                    child: const Text('Tamam'),
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

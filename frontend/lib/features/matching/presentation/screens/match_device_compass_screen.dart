import 'package:flutter/material.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/features/matching/presentation/match_compass_palette.dart';

/// Quiz ≥ %80 — yön LilyGO ekranında; telefonda kısa yönlendirme metni.
class MatchDeviceCompassScreen extends StatelessWidget {
  const MatchDeviceCompassScreen({
    super.key,
    required this.partnerName,
    required this.compatibilityPercent,
    required this.matchId,
    required this.arrowRight,
  });

  final String partnerName;
  final int compatibilityPercent;
  final String matchId;
  final bool arrowRight;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final matchColor = MatchCompassPalette.colorFor(matchId);
    final darker = Color.lerp(matchColor, Colors.black, 0.45)!;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [matchColor, darker],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(28, 16, 28, 32),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    tooltip: 'Kapat',
                  ),
                ),
                const Spacer(),
                Icon(
                  arrowRight
                      ? Icons.arrow_forward_rounded
                      : Icons.arrow_back_rounded,
                  size: 72,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 24),
                Text(
                  'Quiz uyumu %$compatibilityPercent',
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Cihazındaki oku takip et',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$partnerName ile buluşmak için LilyGO ekranındaki ok yönünde ilerle. '
                  'İkinizin cihazı da aynı renkte — kalabalıkta bu renge bak.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 16,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    minimumSize: const Size.fromHeight(52),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  child: const Text('Tamam'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

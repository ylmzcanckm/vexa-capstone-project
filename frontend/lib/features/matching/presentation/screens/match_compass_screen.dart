import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vexa/core/theme/app_colors.dart';

/// Quiz ≥ %80 → iki cihaz birbirini "gösterir" — Minecraft pusulası.
///
/// Arka plan rengi `matchId`'den türetilir: iki telefonda da **aynı renk**
/// çıkar. Kalabalıkta eşler birbirini bu renkten tanır.
///
/// Gerçek yön (BLE/UWB) donanım ile gelecek; şimdilik ibre önce arama
/// animasyonu yapar, sonra sabit bir yöne kilitlenip hafifçe titrer.
class MatchCompassScreen extends StatefulWidget {
  const MatchCompassScreen({
    super.key,
    required this.matchId,
    required this.partnerName,
    required this.compatibilityPercent,
  });

  final String matchId;
  final String partnerName;
  final int compatibilityPercent;

  /// İki telefonda da aynı sonucu veren eşleşme rengi (FNV-1a).
  static Color colorFor(String matchId) {
    var hash = 0x811C9DC5;
    for (final code in matchId.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return _palette[hash % _palette.length];
  }

  /// Kalabalıkta ayırt edilebilir, canlı tonlar.
  static const List<Color> _palette = [
    Color(0xFF119FF2), // mavi
    Color(0xFFE05AFF), // mor-pembe
    Color(0xFF00C48C), // yeşil
    Color(0xFFFF8A00), // turuncu
    Color(0xFFFF3D71), // kırmızı-pembe
    Color(0xFF7C4DFF), // mor
    Color(0xFF00BCD4), // camgöbeği
    Color(0xFFFFC400), // sarı
    Color(0xFF8BC34A), // açık yeşil
    Color(0xFFFF6E40), // mercan
  ];

  @override
  State<MatchCompassScreen> createState() => _MatchCompassScreenState();
}

class _MatchCompassScreenState extends State<MatchCompassScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;
  late final DateTime _startedAt;

  static const _searchSeconds = 2.6;
  static const _lockedBearing = 0.6; // radyan — demo hedef yönü

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double _needleAngle() {
    final t =
        DateTime.now().difference(_startedAt).inMilliseconds / 1000.0;
    if (t < _searchSeconds) {
      // Arama: hızlı dönüş, sona doğru yavaşlar.
      final progress = t / _searchSeconds;
      final eased = Curves.easeOutCubic.transform(progress);
      return (1 - eased) * math.pi * 6 + _lockedBearing;
    }
    // Kilitli: hedef yönde küçük titreşim.
    final wobble = math.sin((t - _searchSeconds) * 5) * 0.06;
    return _lockedBearing + wobble;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final matchColor = MatchCompassScreen.colorFor(widget.matchId);
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
                Text(
                  'Quiz uyumu %${widget.compatibilityPercent}',
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.partnerName} bu yönde',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 36),
                AnimatedBuilder(
                  animation: _ticker,
                  builder: (context, _) {
                    return CustomPaint(
                      size: const Size.square(260),
                      painter: _MinecraftCompassPainter(
                        needleAngle: _needleAngle(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 36),
                Text(
                  'Birbirinize doğru yürüyün!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'İkinizin ekranı da aynı renkte — kalabalıkta bu renge bak. '
                  'Gerçek yön bilgisi cihaz (BLE) ile gelecek.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12.5,
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

/// Minecraft pusulası görünümü: taş gri çerçeve, koyu yüz, kırmızı ibre.
class _MinecraftCompassPainter extends CustomPainter {
  const _MinecraftCompassPainter({required this.needleAngle});

  final double needleAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;

    // Dış taş çerçeve (koyu).
    canvas.drawCircle(center, r, Paint()..color = const Color(0xFF2A2A2A));

    // Alt-sol gümüş parlama (Minecraft dokusundaki açık kenar).
    final highlight = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.16
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFC9D1D6);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r * 0.86),
      math.pi * 0.45,
      math.pi * 0.75,
      false,
      highlight,
    );
    final midTone = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * 0.10
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF565E63);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r * 0.86),
      -math.pi * 0.55,
      math.pi * 0.7,
      false,
      midTone,
    );

    // Koyu yüz.
    canvas.drawCircle(center, r * 0.68, Paint()..color = const Color(0xFF101114));
    canvas.drawCircle(
      center,
      r * 0.68,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.04
        ..color = const Color(0xFF34383D),
    );

    // İbre — pixel hissi için dikdörtgen bloklar.
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(needleAngle);

    final needleLen = r * 0.52;
    final needleW = r * 0.11;

    // Ana kırmızı gövde.
    canvas.drawRect(
      Rect.fromLTWH(-needleW / 2, -needleLen, needleW, needleLen),
      Paint()..color = const Color(0xFFE0382F),
    );
    // Uç (açık kırmızı blok).
    canvas.drawRect(
      Rect.fromLTWH(-needleW / 2, -needleLen, needleW, needleW),
      Paint()..color = const Color(0xFFFF7A5C),
    );
    // Kuyruk (koyu).
    canvas.drawRect(
      Rect.fromLTWH(-needleW / 2, 0, needleW, needleLen * 0.35),
      Paint()..color = const Color(0xFF7E1F1B),
    );
    // Pivot.
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: needleW * 1.3,
        height: needleW * 1.3,
      ),
      Paint()..color = const Color(0xFFB9C0C6),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MinecraftCompassPainter oldDelegate) =>
      oldDelegate.needleAngle != needleAngle;
}

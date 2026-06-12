import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/features/matching/data/compass_rssi_tracker.dart';

/// Quiz ≥ %80 → BLE RSSI + pusula ile partner yönü (Minecraft pusulası).
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

  static Color colorFor(String matchId) {
    var hash = 0x811C9DC5;
    for (final code in matchId.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return _palette[hash % _palette.length];
  }

  static const List<Color> _palette = [
    Color(0xFF119FF2),
    Color(0xFFE05AFF),
    Color(0xFF00C48C),
    Color(0xFFFF8A00),
    Color(0xFFFF3D71),
    Color(0xFF7C4DFF),
    Color(0xFF00BCD4),
    Color(0xFFFFC400),
    Color(0xFF8BC34A),
    Color(0xFFFF6E40),
  ];

  @override
  State<MatchCompassScreen> createState() => _MatchCompassScreenState();
}

class _MatchCompassScreenState extends State<MatchCompassScreen> {
  final _tracker = CompassRssiTracker();
  CompassRssiSnapshot _snap = const CompassRssiSnapshot(
    isSearching: true,
    needleAngleRad: 0,
    rssi: null,
    warmth: CompassWarmth.neutral,
    proximityLabel: 'Sinyal aranıyor…',
    sampleCount: 0,
  );
  StreamSubscription<CompassRssiSnapshot>? _sub;

  @override
  void initState() {
    super.initState();
    _sub = _tracker.snapshots.listen((s) {
      if (mounted) setState(() => _snap = s);
    });
    unawaited(_tracker.start());
  }

  @override
  void dispose() {
    _sub?.cancel();
    _tracker.dispose();
    super.dispose();
  }

  String get _warmthLabel => switch (_snap.warmth) {
        CompassWarmth.hot => 'Sıcak — doğru yöndesin',
        CompassWarmth.cold => 'Soğuk — yön değiştir',
        CompassWarmth.neutral => 'Telefonu yavaşça çevir',
      };

  IconData get _warmthIcon => switch (_snap.warmth) {
        CompassWarmth.hot => Icons.whatshot_rounded,
        CompassWarmth.cold => Icons.ac_unit_rounded,
        CompassWarmth.neutral => Icons.screen_rotation_rounded,
      };

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
                  _snap.isSearching
                      ? '${widget.partnerName} aranıyor…'
                      : '${widget.partnerName} bu yönde',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _snap.proximityLabel,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 28),
                CustomPaint(
                  size: const Size.square(260),
                  painter: _MinecraftCompassPainter(
                    needleAngle: _snap.needleAngleRad,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_warmthIcon, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      _warmthLabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                if (_snap.isSearching) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Telefonu başının üzerinde yavaşça 360° çevir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12.5,
                    ),
                  ),
                ],
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
                  'Yön BLE sinyal gücü + pusula ile hesaplanır.',
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

class _MinecraftCompassPainter extends CustomPainter {
  const _MinecraftCompassPainter({required this.needleAngle});

  final double needleAngle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2;

    canvas.drawCircle(center, r, Paint()..color = const Color(0xFF2A2A2A));

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

    canvas.drawCircle(center, r * 0.68, Paint()..color = const Color(0xFF101114));
    canvas.drawCircle(
      center,
      r * 0.68,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.04
        ..color = const Color(0xFF34383D),
    );

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(needleAngle);

    final needleLen = r * 0.52;
    final needleW = r * 0.11;

    canvas.drawRect(
      Rect.fromLTWH(-needleW / 2, -needleLen, needleW, needleLen),
      Paint()..color = const Color(0xFFE0382F),
    );
    canvas.drawRect(
      Rect.fromLTWH(-needleW / 2, -needleLen, needleW, needleW),
      Paint()..color = const Color(0xFFFF7A5C),
    );
    canvas.drawRect(
      Rect.fromLTWH(-needleW / 2, 0, needleW, needleLen * 0.35),
      Paint()..color = const Color(0xFF7E1F1B),
    );
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

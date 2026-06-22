import 'package:flutter/material.dart';

/// Quiz sonrası eşleşme rengi — telefon ve LilyGO aynı indeksi kullanır.
final class MatchCompassPalette {
  const MatchCompassPalette._();

  static const List<Color> colors = [
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

  static int colorIndexFor(String matchId) {
    var hash = 0x811C9DC5;
    for (final code in matchId.codeUnits) {
      hash ^= code;
      hash = (hash * 0x01000193) & 0x7FFFFFFF;
    }
    return hash % colors.length;
  }

  static Color colorFor(String matchId) => colors[colorIndexFor(matchId)];
}

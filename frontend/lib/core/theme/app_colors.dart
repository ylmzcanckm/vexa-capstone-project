import 'package:flutter/material.dart';

final class AppColors {
  const AppColors._();

  /// Marka mavi
  static const Color primary = Color(0xFF119FF2);

  /// Marka mor
  static const Color accent = Color(0xFFE05AFF);

  /// Ghost mod ana gri (switch / vurgu).
  static const Color modeGhost = Color(0xFF94A3B8);

  static const Color background = Color(0xFFF5FAFF);
  static const Color backgroundAlt = Color(0xFFFBF5FF);
  static const Color surface = Colors.white;

  /// Beyaz saç / açık tonlar için avatar önizleme zemin (saf beyazla kaybolmaz).
  static const Color avatarPreviewBackdrop = Color(0xFFB8C4D4);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color border = Color(0xFFDCE8F5);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, accent],
  );

  static const LinearGradient loginBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFEEF7FE),
      Color(0xFFFDF5FF),
    ],
  );
}

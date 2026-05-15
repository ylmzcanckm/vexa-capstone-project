import 'package:flutter/material.dart';
import 'package:vexa/core/theme/app_colors.dart';

/// Tema-bağımlı renkler ve mod ekranı gradyanları.
@immutable
final class VexaPalette extends ThemeExtension<VexaPalette> {
  const VexaPalette({
    required this.scaffold,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.cardFill,
    required this.pillBar,
    required this.bottomBar,
    required this.loginGradient,
    required this.socialPageGradient,
    required this.ghostPageGradient,
    required this.businessPageGradient,
    required this.avatarPreviewBackdrop,
  });

  final Color scaffold;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;

  /// Kart / chip zeminleri.
  final Color cardFill;

  /// Mod hap çubuğu ve alt bar.
  final Color pillBar;
  final Color bottomBar;

  final LinearGradient loginGradient;
  final LinearGradient socialPageGradient;
  final LinearGradient ghostPageGradient;
  final LinearGradient businessPageGradient;
  final Color avatarPreviewBackdrop;

  static const light = VexaPalette(
    scaffold: AppColors.background,
    surface: AppColors.surface,
    surfaceElevated: Colors.white,
    border: AppColors.border,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    cardFill: Color(0xD9FFFFFF),
    pillBar: Color(0xEBFFFFFF),
    bottomBar: Color(0xF0FFFFFF),
    loginGradient: AppColors.loginBackgroundGradient,
    socialPageGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFF5E8FF),
        Color(0xFFFCEEFF),
        Color(0xFFE8F4FC),
      ],
    ),
    ghostPageGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFE8ECF1),
        Color(0xFFF1F4F8),
        Color(0xFFF8FAFC),
      ],
    ),
    businessPageGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFFD8EEF9),
        Color(0xFFE8F4FD),
        Color(0xFFF0F7FF),
      ],
    ),
    avatarPreviewBackdrop: AppColors.avatarPreviewBackdrop,
  );

  /// Gri-siyah taban; mod sayfalarında mor / gri / mavi tatlı gradyanlar.
  static const dark = VexaPalette(
    scaffold: Color(0xFF111113),
    surface: Color(0xFF1A1A1E),
    surfaceElevated: Color(0xFF242428),
    border: Color(0xFF3A3A42),
    textPrimary: Color(0xFFE8E8EC),
    textSecondary: Color(0xFF9CA3AF),
    cardFill: Color(0xE6252528),
    pillBar: Color(0xF01E1E22),
    bottomBar: Color(0xF0161618),
    loginGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF1A1822),
        Color(0xFF14161C),
        Color(0xFF111318),
      ],
    ),
    socialPageGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF221C2A),
        Color(0xFF1E1A26),
        Color(0xFF1A2230),
      ],
    ),
    ghostPageGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF1C1E24),
        Color(0xFF1A1C22),
        Color(0xFF181A20),
      ],
    ),
    businessPageGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF161C28),
        Color(0xFF182230),
        Color(0xFF1A2638),
      ],
    ),
    avatarPreviewBackdrop: Color(0xFF3A3A44),
  );

  @override
  VexaPalette copyWith({
    Color? scaffold,
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? cardFill,
    Color? pillBar,
    Color? bottomBar,
    LinearGradient? loginGradient,
    LinearGradient? socialPageGradient,
    LinearGradient? ghostPageGradient,
    LinearGradient? businessPageGradient,
    Color? avatarPreviewBackdrop,
  }) {
    return VexaPalette(
      scaffold: scaffold ?? this.scaffold,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      cardFill: cardFill ?? this.cardFill,
      pillBar: pillBar ?? this.pillBar,
      bottomBar: bottomBar ?? this.bottomBar,
      loginGradient: loginGradient ?? this.loginGradient,
      socialPageGradient: socialPageGradient ?? this.socialPageGradient,
      ghostPageGradient: ghostPageGradient ?? this.ghostPageGradient,
      businessPageGradient: businessPageGradient ?? this.businessPageGradient,
      avatarPreviewBackdrop:
          avatarPreviewBackdrop ?? this.avatarPreviewBackdrop,
    );
  }

  @override
  VexaPalette lerp(ThemeExtension<VexaPalette>? other, double t) {
    if (other is! VexaPalette) return this;
    return t < 0.5 ? this : other;
  }
}

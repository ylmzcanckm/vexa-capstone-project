import 'package:flutter/material.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_palette.dart';

final class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme => _build(
        brightness: Brightness.light,
        palette: VexaPalette.light,
      );

  static ThemeData get darkTheme => _build(
        brightness: Brightness.dark,
        palette: VexaPalette.dark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required VexaPalette palette,
  }) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = isDark
        ? ColorScheme.dark(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            secondary: AppColors.accent,
            onSecondary: Colors.white,
            surface: palette.surface,
            onSurface: palette.textPrimary,
            outline: palette.border,
          )
        : ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            secondary: AppColors.accent,
            onSecondary: Colors.white,
            surface: palette.surface,
            onSurface: palette.textPrimary,
            outline: palette.border,
          );

    final textTheme = TextTheme(
      headlineLarge: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: palette.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineSmall: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: palette.textPrimary,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: palette.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: palette.textSecondary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: palette.textPrimary,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: palette.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: palette.textSecondary,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.scaffold,
      colorScheme: colorScheme,
      textTheme: textTheme,
      extensions: [palette],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: palette.textPrimary,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: palette.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: palette.border),
        ),
      ),
      dividerColor: palette.border,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.primary,
        textColor: palette.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? palette.surfaceElevated : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.2),
        ),
        labelStyle: TextStyle(color: palette.textSecondary),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.surfaceElevated,
        side: BorderSide(color: palette.border),
        labelStyle: TextStyle(color: palette.textPrimary),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: palette.border,
        thumbColor: AppColors.primary,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return palette.border;
        }),
      ),
    );
  }
}

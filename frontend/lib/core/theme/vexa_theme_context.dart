import 'package:flutter/material.dart';
import 'package:vexa/core/theme/vexa_palette.dart';
import 'package:vexa/features/mode/domain/vexa_mode.dart';

extension VexaThemeContext on BuildContext {
  VexaPalette get vexa =>
      Theme.of(this).extension<VexaPalette>() ?? VexaPalette.light;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}

extension VexaModePalette on VexaMode {
  LinearGradient pageGradient(BuildContext context) {
    final p = context.vexa;
    return switch (this) {
      VexaMode.social => p.socialPageGradient,
      VexaMode.ghost => p.ghostPageGradient,
      VexaMode.business => p.businessPageGradient,
    };
  }
}

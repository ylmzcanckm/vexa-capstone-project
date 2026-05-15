import 'package:flutter/material.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';
import 'package:vexa/features/mode/domain/vexa_mode.dart';

extension VexaModeStyle on VexaMode {
  String get shortLabel => switch (this) {
        VexaMode.social => 'Social',
        VexaMode.ghost => 'Ghost',
        VexaMode.business => 'Business',
      };

  Color get accentColor => switch (this) {
        VexaMode.social => AppColors.accent,
        VexaMode.ghost => AppColors.modeGhost,
        VexaMode.business => AppColors.primary,
      };

  /// Mod sayfası arka planı — açıkta pastel, karanlıkta mor / gri / mavi tonlar.
  LinearGradient pageBackgroundGradient(BuildContext context) =>
      pageGradient(context);

  String get bodyHeadline => switch (this) {
        VexaMode.social => 'Sosyal moddasın',
        VexaMode.ghost => 'Ghost moddasın',
        VexaMode.business => 'Business moddasın',
      };

  String get bodySubtitle => switch (this) {
        VexaMode.social => 'Keşif ve eşleşme için hazırız.',
        VexaMode.ghost =>
            'Cihaz dinlenmede; tanışma kapalı, daha az enerji.',
        VexaMode.business => 'İş odaklı kullanım.',
      };
}

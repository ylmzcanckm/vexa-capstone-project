import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vexa/app/app_startup_screen.dart';
import 'package:vexa/core/theme/app_theme.dart';
import 'package:vexa/core/theme/theme_mode_provider.dart';
import 'package:vexa/features/settings/providers/settings_providers.dart';

void main() {
  runApp(const ProviderScope(child: VexaApp()));
}

class VexaApp extends ConsumerWidget {
  const VexaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final a11y = ref.watch(accessibilitySettingsProvider);

    return MaterialApp(
      title: 'VEXA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(a11y.textScale),
            boldText: a11y.boldText,
            disableAnimations: a11y.reduceMotion,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AppStartupScreen(),
    );
  }
}

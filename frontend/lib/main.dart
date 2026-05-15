import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vexa/app/app_startup_screen.dart';
import 'package:vexa/core/theme/app_theme.dart';
import 'package:vexa/core/theme/theme_mode_provider.dart';

void main() {
  runApp(const ProviderScope(child: VexaApp()));
}

class VexaApp extends ConsumerWidget {
  const VexaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'VEXA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const AppStartupScreen(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vexa/core/storage/theme_preferences.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    _loadSaved();
    return ThemeMode.light;
  }

  Future<void> _loadSaved() async {
    final dark = await ThemePreferences.isDark();
    state = dark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setDark(bool enabled) async {
    await ThemePreferences.setDark(enabled);
    state = enabled ? ThemeMode.dark : ThemeMode.light;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

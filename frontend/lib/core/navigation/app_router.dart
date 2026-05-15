import 'package:flutter/material.dart';
import 'package:vexa/core/storage/device_connection_preferences.dart';
import 'package:vexa/core/storage/onboarding_preferences.dart';
import 'package:vexa/core/storage/user_profile_store.dart';
import 'package:vexa/features/auth/presentation/screens/login_screen.dart';
import 'package:vexa/features/device/presentation/screens/device_connection_screen.dart';
import 'package:vexa/features/mode/presentation/screens/mode_selection_screen.dart';
import 'package:vexa/features/onboarding/presentation/screens/avatar_selection_screen.dart';
import 'package:vexa/features/profile/presentation/screens/profile_creation_screen.dart';

/// Oturum + onboarding durumuna göre ilk ekran.
final class AppRouter {
  const AppRouter._();

  static Future<Widget> homeForAuthenticatedUser() async {
    final onboarded = await OnboardingPreferences.isComplete();
    if (onboarded) {
      return const ModeSelectionScreen();
    }

    final linked = await DeviceConnectionPreferences.isLinked();
    if (!linked) {
      return DeviceConnectionScreen(
        loginScreenBuilder: () => const LoginScreen(),
      );
    }

    final profile = await UserProfileStore.load();
    final hasCore = profile != null &&
        profile.name.isNotEmpty &&
        profile.surname.isNotEmpty &&
        profile.birthDateIso.isNotEmpty;

    if (!hasCore) {
      return const ProfileCreationScreen();
    }

    if (profile.avatarSeed.isEmpty) {
      return const AvatarSelectionScreen();
    }

    await OnboardingPreferences.setComplete(true);
    return const ModeSelectionScreen();
  }
}

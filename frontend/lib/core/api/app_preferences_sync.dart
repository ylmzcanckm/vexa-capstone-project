import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vexa/core/theme/theme_mode_provider.dart';
import 'package:vexa/features/auth/data/user_repository.dart';
import 'package:vexa/features/settings/providers/settings_providers.dart';

/// Ayar değişince sunucuya yazar (`profiles.bio` içinde `appPrefs`).
final class AppPreferencesSync {
  const AppPreferencesSync._();

  static Future<void> pushToServer() => UserRepository.syncAppPreferencesToServer();

  /// `syncFromServer` sonrası Riverpod state'ini yerel prefs ile hizalar.
  static Future<void> refreshProvidersFromLocalStorage(
    ProviderContainer container,
  ) async {
    await container.read(themeModeProvider.notifier).reloadFromStorage();
    container
      ..invalidate(notificationSettingsProvider)
      ..invalidate(privacySettingsProvider)
      ..invalidate(accessibilitySettingsProvider)
      ..invalidate(blockedUsersProvider);
  }
}

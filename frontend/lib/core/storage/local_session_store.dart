import 'package:vexa/core/storage/auth_token_store.dart';
import 'package:vexa/core/storage/device_connection_preferences.dart';
import 'package:vexa/core/storage/onboarding_preferences.dart';
import 'package:vexa/core/storage/user_profile_store.dart';

/// Çıkış veya hesap silme: oturum + profil verisi.
final class LocalSessionStore {
  const LocalSessionStore._();

  static Future<void> clearSession() async {
    await AuthTokenStore.clear();
  }

  /// Hesap silme / tam sıfırlama (sunucu silme API’si yok).
  static Future<void> clearAllUserData() async {
    await AuthTokenStore.clear();
    await OnboardingPreferences.setComplete(false);
    await DeviceConnectionPreferences.setLinked(false);
    await UserProfileStore.clear();
  }
}

import 'package:shared_preferences/shared_preferences.dart';

/// İlk kayıt (profil + avatar) tamamlandı mı? Sonraki açılışlarda doğrudan ana ekran.
final class OnboardingPreferences {
  const OnboardingPreferences._();

  static const _keyComplete = 'vexa_onboarding_complete';

  static Future<bool> isComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyComplete) ?? false;
  }

  static Future<void> setComplete(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyComplete, value);
  }
}

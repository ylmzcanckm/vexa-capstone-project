import 'package:vexa/core/config/app_config.dart';

/// Google OAuth — iOS URL scheme ve doğrulama yardımcıları.
final class GoogleOAuthConfig {
  const GoogleOAuthConfig._();

  static bool get hasIosClientId => AppConfig.googleIosClientId.isNotEmpty;

  /// `74651460819-xxx.apps.googleusercontent.com` → `com.googleusercontent.apps.74651460819-xxx`
  static String reversedClientScheme(String clientId) {
    final suffix = '.apps.googleusercontent.com';
    if (!clientId.endsWith(suffix)) {
      throw ArgumentError('Geçersiz Google client ID: $clientId');
    }
    final core = clientId.substring(0, clientId.length - suffix.length);
    return 'com.googleusercontent.apps.$core';
  }

  static String? get iosUrlScheme =>
      hasIosClientId ? reversedClientScheme(AppConfig.googleIosClientId) : null;
}

/// Backend ve ortam ayarları.
final class AppConfig {
  const AppConfig._();

  /// Production API (Render). Yerel backend için değiştir:
  /// `http://localhost:3000/api`
  static const String apiBaseUrl =
      'https://vexa-backend-umg2.onrender.com/api';

  /// Render backend ile aynı — Google Cloud Web OAuth Client ID.
  static const String googleWebClientId =
      '74651460819-eolahk2dks1r9odgo5mjehpafgmetbeq.apps.googleusercontent.com';

  static Uri uri(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$apiBaseUrl$normalized');
  }
}

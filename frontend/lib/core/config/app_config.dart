/// Backend ve ortam ayarları.
final class AppConfig {
  const AppConfig._();

  /// Production API (Render). Yerel backend için değiştir:
  /// `http://localhost:3000/api`
  static const String apiBaseUrl =
      'https://vexa-backend-umg2.onrender.com/api';

  /// Backend doğrulama + Flutter Web — **Web** OAuth Client ID.
  static const String googleWebClientId =
      '74651460819-eolahk2dks1r9odgo5mjehpafgmetbeq.apps.googleusercontent.com';

  /// Google Cloud → **iOS** OAuth Client ID (Bundle: `com.selcukbuyukpoyraz.vexa`).
  /// Web client burada kullanılamaz (400: custom scheme / WEB client).
  /// Console'dan oluştur → buraya yapıştır → `tool/sync_google_ios_plist.sh` çalıştır.
  static const String googleIosClientId =
      '74651460819-kgnm2akm01dbn98lm3d8ebrqc56eegie.apps.googleusercontent.com';

  static Uri uri(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$apiBaseUrl$normalized');
  }
}

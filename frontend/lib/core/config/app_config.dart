/// Backend ve ortam ayarları.
final class AppConfig {
  const AppConfig._();

  /// Production API (Render). Yerel backend için değiştir:
  /// `http://localhost:3000/api`
  static const String apiBaseUrl =
      'https://vexa-backend-umg2.onrender.com/api';

  static Uri uri(String path) {
    final normalized = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$apiBaseUrl$normalized');
  }
}

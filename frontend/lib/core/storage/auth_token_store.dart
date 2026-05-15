import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT bearer token (güvenli depolama).
final class AuthTokenStore {
  const AuthTokenStore._();

  static const _key = 'vexa_jwt_token';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> read() => _storage.read(key: _key);

  static Future<void> write(String token) =>
      _storage.write(key: _key, value: token);

  static Future<void> clear() => _storage.delete(key: _key);
}

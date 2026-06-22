import 'package:vexa/core/api/api_client.dart';
import 'package:vexa/core/api/api_exception.dart';
import 'package:vexa/core/api/models/auth_models.dart';
import 'package:vexa/core/storage/auth_token_store.dart';
import 'package:vexa/core/storage/bound_lilygo_store.dart';
import 'package:vexa/features/auth/data/oauth_sign_in_service.dart';

/// Backend JWT oturumu (Google / Apple).
final class AuthRepository {
  const AuthRepository._();

  static Future<void> _persistSession(Map<String, dynamic> data) async {
    final session = AuthSession.fromLoginJson(data);
    if (session.token.isEmpty) {
      throw const ApiException('Sunucu token döndürmedi.');
    }
    await AuthTokenStore.write(session.token);
    if (session.userId.isNotEmpty) {
      await BoundLilyGoStore.setActiveUserId(session.userId);
    }
  }

  /// Google native → POST /auth/google (idToken veya accessToken)
  static Future<void> loginWithGoogle() async {
    await warmUpBackend();
    final google = await OAuthSignInService.googleCredentials();
    final json = await ApiClient.postWithRetry(
      '/auth/google',
      body: google.toJson(),
    );
    await _persistSession(json['data'] as Map<String, dynamic>? ?? {});
  }

  /// Apple native → POST /auth/apple
  static Future<void> loginWithApple() async {
    await warmUpBackend();
    final apple = await OAuthSignInService.appleCredentials();
    final json = await ApiClient.postWithRetry(
      '/auth/apple',
      body: apple.toJson(),
    );
    await _persistSession(json['data'] as Map<String, dynamic>? ?? {});
  }

  static Future<bool> hasSession() async {
    final token = await AuthTokenStore.read();
    return token != null && token.isNotEmpty;
  }

  static Future<void> logout() => AuthTokenStore.clear();

  static Future<bool> checkHealth() async {
    try {
      final json = await ApiClient.getWithRetry('/health');
      return json['success'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Render uyuyorsa uyanması için giriş öncesi ping.
  static Future<void> warmUpBackend() async {
    try {
      await ApiClient.getWithRetry('/health');
    } catch (_) {
      // Giriş isteği yine de denenecek.
    }
  }
}

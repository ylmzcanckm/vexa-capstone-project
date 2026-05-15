import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:vexa/core/api/api_exception.dart';

/// Google / Apple native oturum açma — id token üretir.
final class OAuthSignInService {
  const OAuthSignInService._();

  static final GoogleSignIn _google = GoogleSignIn(
    scopes: const ['email', 'profile'],
  );

  static Future<String> googleIdToken() async {
    final account = await _google.signIn();
    if (account == null) {
      throw const ApiException('Google girişi iptal edildi.');
    }
    final auth = await account.authentication;
    final token = auth.idToken;
    if (token == null || token.isEmpty) {
      throw const ApiException('Google kimlik jetonu alınamadı.');
    }
    return token;
  }

  static Future<AppleOAuthPayload> appleCredentials() async {
    final available = await SignInWithApple.isAvailable();
    if (!available) {
      throw const ApiException('Apple ile giriş bu cihazda kullanılamıyor.');
    }

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final identityToken = credential.identityToken;
    if (identityToken == null || identityToken.isEmpty) {
      throw const ApiException('Apple kimlik jetonu alınamadı.');
    }

    final given = credential.givenName ?? '';
    final family = credential.familyName ?? '';
    final fullName = [given, family].where((s) => s.isNotEmpty).join(' ');

    return AppleOAuthPayload(
      identityToken: identityToken,
      email: credential.email,
      fullName: fullName.isEmpty ? null : fullName,
    );
  }
}

final class AppleOAuthPayload {
  const AppleOAuthPayload({
    required this.identityToken,
    this.email,
    this.fullName,
  });

  final String identityToken;
  final String? email;
  final String? fullName;

  Map<String, dynamic> toJson() => {
        'identityToken': identityToken,
        if (email != null) 'email': email,
        if (fullName != null) 'fullName': fullName,
      };
}

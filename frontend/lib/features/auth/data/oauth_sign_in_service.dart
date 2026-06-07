import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:vexa/core/api/api_exception.dart';
import 'package:vexa/core/config/app_config.dart';
/// Google / Apple native oturum açma.
final class OAuthSignInService {
  const OAuthSignInService._();

  static GoogleSignIn get _google {
    const scopes = ['email', 'openid'];

    if (kIsWeb) {
      return GoogleSignIn(
        clientId: AppConfig.googleWebClientId,
        scopes: scopes,
      );
    }

    if (Platform.isIOS) {
      final iosId = AppConfig.googleIosClientId;
      if (iosId.isEmpty) {
        throw const ApiException(
          'iOS Google Client ID eksik. Google Cloud Console\'da iOS OAuth '
          'oluştur (Bundle: com.selcukbuyukpoyraz.vexa), ID\'yi '
          'app_config.dart → googleIosClientId alanına yaz ve '
          'tool/sync_google_ios_plist.sh çalıştır.',
        );
      }
      return GoogleSignIn(
        clientId: iosId,
        serverClientId: AppConfig.googleWebClientId,
        scopes: scopes,
      );
    }

    // Android: clientId genelde google-services.json; backend için serverClientId.
    return GoogleSignIn(
      serverClientId: AppConfig.googleWebClientId,
      scopes: scopes,
    );
  }

  /// Web'de [idToken] boş gelebilir; o zaman [accessToken] kullanılır.
  static Future<GoogleAuthPayload> googleCredentials() async {
    await _google.signOut();

    final account = await _google.signIn();
    if (account == null) {
      throw const ApiException('Google girişi iptal edildi.');
    }

    final auth = await account.authentication;

    final idToken = auth.idToken;
    if (idToken != null && idToken.isNotEmpty) {
      return GoogleAuthPayload(idToken: idToken);
    }

    final accessToken = auth.accessToken;
    if (accessToken != null && accessToken.isNotEmpty) {
      return GoogleAuthPayload(accessToken: accessToken);
    }

    throw const ApiException('Google kimlik jetonu alınamadı.');
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

final class GoogleAuthPayload {
  GoogleAuthPayload({this.idToken, this.accessToken});

  final String? idToken;
  final String? accessToken;

  Map<String, dynamic> toJson() {
    if (idToken != null && idToken!.isNotEmpty) {
      return {'idToken': idToken};
    }

    return {'accessToken': accessToken};
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

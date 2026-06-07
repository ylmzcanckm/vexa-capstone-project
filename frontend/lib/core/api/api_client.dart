import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:vexa/core/api/api_exception.dart';
import 'package:vexa/core/config/app_config.dart';
import 'package:vexa/core/storage/auth_token_store.dart';

/// HTTP istemcisi — JSON + Bearer token.
final class ApiClient {
  const ApiClient._();

  static const _timeout = Duration(seconds: 45);

  static Future<Map<String, dynamic>> get(
    String path, {
    bool auth = false,
  }) async {
    return _decode(
      await http
          .get(
            AppConfig.uri(path),
            headers: await _headers(auth: auth),
          )
          .timeout(_timeout),
    );
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool auth = false,
  }) async {
    return _decode(
      await http
          .post(
            AppConfig.uri(path),
            headers: await _headers(auth: auth),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(_timeout),
    );
  }

  static Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    return _decode(
      await http
          .put(
            AppConfig.uri(path),
            headers: await _headers(auth: auth),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(_timeout),
    );
  }

  static Future<Map<String, dynamic>> delete(
    String path, {
    bool auth = true,
  }) async {
    return _decode(
      await http
          .delete(
            AppConfig.uri(path),
            headers: await _headers(auth: auth),
          )
          .timeout(_timeout),
    );
  }

  static Future<Map<String, String>> _headers({required bool auth}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (auth) {
      final token = await AuthTokenStore.read();
      if (token == null || token.isEmpty) {
        throw const ApiException('Oturum bulunamadı. Tekrar giriş yap.', statusCode: 401);
      }
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic>? json;
    if (response.body.isNotEmpty) {
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          json = decoded;
        }
      } catch (_) {
        throw ApiException(
          'Sunucu yanıtı okunamadı (${response.statusCode}).',
          statusCode: response.statusCode,
        );
      }
    }

    final ok = response.statusCode >= 200 && response.statusCode < 300;
    if (!ok) {
      final message = json?['message'] as String? ??
          'İstek başarısız (${response.statusCode}).';
      throw ApiException(message, statusCode: response.statusCode);
    }

    if (json != null && json['success'] == false) {
      throw ApiException(
        json['message'] as String? ?? 'İşlem başarısız.',
        statusCode: response.statusCode,
      );
    }

    return json ?? <String, dynamic>{'success': true};
  }
}

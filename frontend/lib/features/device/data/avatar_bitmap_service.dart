import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:vexa/core/avatar/dicebear_dylan_avatar.dart';
import 'package:vexa/core/theme/app_colors.dart';
import 'package:vexa/features/device/ble/vexa_ble_config.dart';

/// DiceBear PNG → LilyGO RGB565 (yuvarlak avatar + marka halkası, dışı siyah).
final class AvatarBitmapService {
  const AvatarBitmapService._();

  /// Cihaz LCD siyah zemini — daire dışı kare görünmesin.
  static const _outside = Color(0xFF000000);

  /// Uygulama gri tonunun 1–2 kademe koyusu (avatar içi).
  static const _backdrop = Color(0xFF95A3B3);
  static const _ringPrimary = AppColors.primary;
  static const _ringAccent = AppColors.accent;

  static Future<({int width, int height, Uint8List rgb565})> loadRgb565FromSeed(
    String avatarSeed, {
    int size = VexaBleConfig.avatarPixelSize,
  }) async {
    final uri = DicebearDylanUri.pngFromStoredKey(avatarSeed, size: size);
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Avatar PNG indirilemedi (${response.statusCode})');
    }

    final decoded = img.decodeImage(response.bodyBytes);
    if (decoded == null) {
      throw Exception('PNG çözümlenemedi');
    }

    final framed = _composeDeviceAvatar(decoded, size);
    return (width: size, height: size, rgb565: _toRgb565(framed));
  }

  /// Yuvarlak gri zemin + mavi→mor halka; daire dışı siyah (kare kutu yok).
  static img.Image _composeDeviceAvatar(img.Image avatar, int size) {
    final out = img.Image(width: size, height: size);
    final cx = size / 2.0;
    final cy = size / 2.0;
    final outerR = size / 2.0 - 0.5;
    final ringWidth = math.max(5.0, size * 5.0 / 112.0);
    final innerR = outerR - ringWidth;
    final avatarInset = innerR * 0.88;
    final avatarSide = (avatarInset * 2).round().clamp(8, size);

    final avatarCore = img.copyResize(
      avatar,
      width: avatarSide,
      height: avatarSide,
      interpolation: img.Interpolation.linear,
    );

    for (var y = 0; y < size; y++) {
      for (var x = 0; x < size; x++) {
        final dx = x + 0.5 - cx;
        final dy = y + 0.5 - cy;
        final dist = math.sqrt(dx * dx + dy * dy);

        if (dist > outerR) {
          out.setPixelRgba(
            x,
            y,
            _outside.red,
            _outside.green,
            _outside.blue,
            255,
          );
          continue;
        }

        if (dist >= innerR) {
          final angle = (math.atan2(dy, dx) + math.pi) / (2 * math.pi);
          final c = Color.lerp(_ringPrimary, _ringAccent, angle)!;
          out.setPixelRgba(x, y, c.red, c.green, c.blue, 255);
          continue;
        }

        final ax = (x - (cx - avatarSide / 2)).round();
        final ay = (y - (cy - avatarSide / 2)).round();
        final inAvatar =
            ax >= 0 && ay >= 0 && ax < avatarSide && ay < avatarSide;
        final adx = ax + 0.5 - avatarSide / 2;
        final ady = ay + 0.5 - avatarSide / 2;
        final avatarDist = math.sqrt(adx * adx + ady * ady);
        final avatarMaskR = avatarSide / 2.0 - 1;

        if (inAvatar && avatarDist <= avatarMaskR) {
          final p = avatarCore.getPixel(ax, ay);
          final a = p.a / 255.0;
          final br = _backdrop.red;
          final bg = _backdrop.green;
          final bb = _backdrop.blue;
          final r = ((p.r * a) + br * (1 - a)).round().clamp(0, 255);
          final g = ((p.g * a) + bg * (1 - a)).round().clamp(0, 255);
          final b = ((p.b * a) + bb * (1 - a)).round().clamp(0, 255);
          out.setPixelRgba(x, y, r, g, b, 255);
        } else {
          out.setPixelRgba(
            x,
            y,
            _backdrop.red,
            _backdrop.green,
            _backdrop.blue,
            255,
          );
        }
      }
    }

    return out;
  }

  static Uint8List _toRgb565(img.Image image) {
    final out = Uint8List(image.width * image.height * 2);
    var i = 0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        final r5 = (p.r * 31 / 255).round();
        final g6 = (p.g * 63 / 255).round();
        final b5 = (p.b * 31 / 255).round();
        final rgb565 = (r5 << 11) | (g6 << 5) | b5;
        out[i++] = rgb565 & 0xFF;
        out[i++] = (rgb565 >> 8) & 0xFF;
      }
    }
    return out;
  }
}

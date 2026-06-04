import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:vexa/core/avatar/dicebear_dylan_avatar.dart';
import 'package:vexa/features/device/ble/vexa_ble_config.dart';

/// DiceBear PNG → kare RGB565 (LilyGO ekran).
final class AvatarBitmapService {
  const AvatarBitmapService._();

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

    final square = img.copyResize(
      decoded,
      width: size,
      height: size,
      interpolation: img.Interpolation.linear,
    );

    return (width: size, height: size, rgb565: _toRgb565(square));
  }

  static Uint8List _toRgb565(img.Image image) {
    final out = Uint8List(image.width * image.height * 2);
    var i = 0;
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        final a = p.a / 255.0;
        final r = ((p.r * a) + 255 * (1 - a)).round().clamp(0, 255);
        final g = ((p.g * a) + 255 * (1 - a)).round().clamp(0, 255);
        final b = ((p.b * a) + 255 * (1 - a)).round().clamp(0, 255);
        final r5 = (r * 31 / 255).round();
        final g6 = (g * 63 / 255).round();
        final b5 = (b * 31 / 255).round();
        final rgb565 = (r5 << 11) | (g6 << 5) | b5;
        out[i++] = rgb565 & 0xFF;
        out[i++] = (rgb565 >> 8) & 0xFF;
      }
    }
    return out;
  }
}

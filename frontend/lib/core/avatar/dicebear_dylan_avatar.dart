import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vexa/core/avatar/dylan_manual_avatar_config.dart';
import 'package:vexa/core/avatar/dylan_params_generator.dart';
import 'package:vexa/core/theme/vexa_theme_context.dart';

/// [DiceBear](https://www.dicebear.com/) HTTP API — **Dylan** (tasarım CC BY 4.0, atıf önerilir).
abstract final class DicebearDylanUri {
  static const storedKeyPrefix = 'vxg1|';

  static const _host = 'api.dicebear.com';
  static const _path = '/9.x/dylan/svg';

  /// Yalnızca [seed] (DiceBear PRNG); eski kayıtlar için.
  static Uri svgLegacy(String seed, {int size = 256}) {
    final s = seed.trim().isEmpty ? 'vexa' : seed.trim();
    return Uri.https(_host, _path, {
      'seed': s,
      'size': '$size',
      'backgroundColor': 'transparent',
      'backgroundType': 'solid',
      'clip': 'true',
      'radius': '50',
      'scale': '92',
    });
  }

  /// [storedKey]: `vxg2:` JSON manuel seçimler, `vxg1|…` otomatik satır, aksi halde legacy seed.
  static Uri svgFromStoredKey(String storedKey, {int size = 256}) {
    final t = storedKey.trim();

    final manual = DylanManualConfig.tryDeserialize(t);
    if (manual != null) {
      return Uri.https(_host, _path, manual.toQueryMap(size: size));
    }

    if (t.startsWith(storedKeyPrefix)) {
      final parts = t.split('|');
      if (parts.length == 3) {
        final basis = parts[1].trim();
        final variant = int.tryParse(parts[2].trim()) ?? 0;
        final safeVariant = variant < 0 ? 0 : variant;
        if (basis.isNotEmpty) {
          final q = DylanParamsGenerator.queryForBasisAndVariant(
            basisHex: basis,
            variant: safeVariant,
            size: size,
          );
          return Uri.https(_host, _path, q);
        }
      }
    }
    return svgLegacy(t, size: size);
  }
}

/// Yuvarlak önizleme; SVG şeffaf zeminde — açık saçlar için [contrastBackdrop].
class DicebearDylanAvatar extends StatelessWidget {
  const DicebearDylanAvatar({
    super.key,
    required this.seed,
    this.size = 104,
    this.contrastBackdrop = true,
  });

  /// Legacy seed, `vxg1|…` veya `vxg2:…` JSON.
  final String seed;
  final double size;

  /// Beyaz / açık tonların kaybolmaması için nötr zemin.
  final bool contrastBackdrop;

  @override
  Widget build(BuildContext context) {
    final uri = DicebearDylanUri.svgFromStoredKey(seed, size: size.round());
    final s = size;
    final backdrop = contrastBackdrop
        ? context.vexa.avatarPreviewBackdrop
        : Colors.transparent;
    return ClipOval(
      child: ColoredBox(
        color: backdrop,
        child: SizedBox(
          width: s,
          height: s,
          child: SvgPicture.network(
            uri.toString(),
            width: s,
            height: s,
            fit: BoxFit.cover,
            alignment: Alignment.center,
            allowDrawingOutsideViewBox: true,
            placeholderBuilder: (_) => SizedBox(
              width: s,
              height: s,
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

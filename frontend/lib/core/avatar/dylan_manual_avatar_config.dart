import 'dart:convert';

import 'package:vexa/core/avatar/dylan_params_generator.dart';

/// DiceBear Dylan — kullanıcı seçimleri ([DiceBear Dylan](https://www.dicebear.com/styles/dylan/)).
final class DylanManualConfig {
  const DylanManualConfig({
    required this.mood,
    required this.hair,
    required this.skinColor,
    required this.hairColor,
    required this.facialHairProbability,
  });

  final String mood;
  final String hair;
  final String skinColor;
  final String hairColor;

  /// 0–100
  final int facialHairProbability;

  static const storedPrefix = 'vxg2:';

  factory DylanManualConfig.defaults() {
    return DylanManualConfig(
      mood: DylanParamsGenerator.moods.first,
      hair: DylanParamsGenerator.hairs.first,
      skinColor: DylanParamsGenerator.skinColors.first,
      hairColor: DylanParamsGenerator.hairColors.first,
      facialHairProbability: 0,
    );
  }

  DylanManualConfig copyWith({
    String? mood,
    String? hair,
    String? skinColor,
    String? hairColor,
    int? facialHairProbability,
  }) {
    return DylanManualConfig(
      mood: mood ?? this.mood,
      hair: hair ?? this.hair,
      skinColor: skinColor ?? this.skinColor,
      hairColor: hairColor ?? this.hairColor,
      facialHairProbability: facialHairProbability ?? this.facialHairProbability,
    );
  }

  Map<String, dynamic> toJson() => {
        'version': 2,
        'mood': mood,
        'hair': hair,
        'skinColor': skinColor,
        'hairColor': hairColor,
        'facialHairProbability': facialHairProbability,
      };

  factory DylanManualConfig.fromJson(Map<String, dynamic> j) {
    int prob(dynamic v) {
      if (v is int) return v.clamp(0, 100);
      if (v is num) return v.toInt().clamp(0, 100);
      return int.tryParse('$v')?.clamp(0, 100) ?? 0;
    }

    return DylanManualConfig(
      mood: _pick(j['mood'] as String?, DylanParamsGenerator.moods),
      hair: _pick(j['hair'] as String?, DylanParamsGenerator.hairs),
      skinColor: _pick(j['skinColor'] as String?, DylanParamsGenerator.skinColors),
      hairColor: _pick(j['hairColor'] as String?, DylanParamsGenerator.hairColors),
      facialHairProbability: prob(j['facialHairProbability']) > 0 ? 100 : 0,
    );
  }

  static String _pick(String? v, List<String> allowed) {
    if (v != null && allowed.contains(v)) return v;
    return allowed.first;
  }

  String serialize() => '$storedPrefix${jsonEncode(toJson())}';

  /// `vxg1|<basis>|<variant>` satırından manuel konfig (aynı yüz parametreleri).
  factory DylanManualConfig.fromVxg1Row(String basisHex, int variant) {
    final q = DylanParamsGenerator.queryForBasisAndVariant(
      basisHex: basisHex,
      variant: variant < 0 ? 0 : variant,
      size: 256,
    );
    return DylanManualConfig(
      mood: q['mood']!,
      hair: q['hair']!,
      skinColor: q['skinColor']!,
      hairColor: q['hairColor']!,
      facialHairProbability:
          (int.tryParse(q['facialHairProbability'] ?? '0') ?? 0) > 0 ? 100 : 0,
    );
  }

  static DylanManualConfig? tryDeserialize(String stored) {
    final t = stored.trim();
    if (!t.startsWith(storedPrefix)) return null;
    try {
      final j = jsonDecode(t.substring(storedPrefix.length)) as Map<String, dynamic>;
      return DylanManualConfig.fromJson(j);
    } on FormatException {
      return null;
    }
  }

  /// API sorgu parametreleri (seed sabitlenir; aynı seçim = aynı SVG).
  Map<String, String> toQueryMap({required int size}) {
    final seed = 'vxg2-${Object.hash(mood, hair, skinColor, hairColor, facialHairProbability)}';
    return {
      'seed': seed,
      'size': '$size',
      'mood': mood,
      'hair': hair,
      'skinColor': skinColor,
      'hairColor': hairColor,
      'facialHairProbability': '$facialHairProbability',
      'backgroundColor': 'transparent',
      'backgroundType': 'solid',
      'clip': 'true',
      'radius': '50',
      'scale': '92',
    };
  }
}

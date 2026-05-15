import 'package:vexa/core/storage/user_profile_store.dart';

/// Dylan HTTP API’de geçerli seçenekler ([DiceBear Dylan](https://www.dicebear.com/styles/dylan/)).
abstract final class DylanParamsGenerator {
  static const moods = <String>[
    'neutral',
    'happy',
    'hopeful',
    'superHappy',
    'confused',
    'sad',
    'angry',
  ];

  static const hairs = <String>[
    'plain',
    'wavy',
    'bangs',
    'parting',
    'fluffy',
    'shaggy',
    'shortCurls',
    'longCurls',
    'roundBob',
    'buns',
    'spiky',
    'flatTop',
  ];

  /// Varsayılan palet + birkaç ek ton (6 hane hex, küçük harf).
  static const skinColors = <String>[
    'ffd6c0',
    'f5c4a8',
    'e8a88c',
    'c26450',
    '9a5b45',
    '7d4a38',
  ];

  static const hairColors = <String>[
    '000000',
    '1d5dff',
    'ff543d',
    'fff500',
    'ffffff',
    '6b4423',
    'c41e3a',
    '2d5016',
  ];

  /// Profilden 8 hanelik sabit kimlik (vxg1 satırı için).
  static String basisHexFromProfile(StoredUserProfile? p) {
    if (p == null) return '00000000';
    final raw =
        '${p.name.trim()}|${p.surname.trim()}|${p.birthDateIso.trim()}';
    if (raw == '||') return '00000000';
    final h = Object.hash(
      p.name,
      p.surname,
      p.birthDateIso,
    );
    return (h & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0');
  }

  static int _mix32(String basisHex, int variant, int salt) {
    return Object.hash(
      basisHex,
      variant,
      salt,
    );
  }

  /// [basisHex] + [variant] ile deterministik parametre (vxg1 geriye dönük).
  static Map<String, String> queryForBasisAndVariant({
    required String basisHex,
    required int variant,
    required int size,
  }) {
    final m0 = _mix32(basisHex, variant, 0xD101);
    final m1 = _mix32(basisHex, variant, 0xEBEA);
    final m2 = _mix32(basisHex, variant, 0xA11);
    final m3 = _mix32(basisHex, variant, 0xFACE);
    final m4 = _mix32(basisHex, variant, 0x600D);

    final mood = moods[m0.abs() % moods.length];
    final hair = hairs[m1.abs() % hairs.length];
    final skinColor = skinColors[m2.abs() % skinColors.length];
    final hairColor = hairColors[m3.abs() % hairColors.length];
    final facialHairProbability = (m4.abs() % 100 < 22) ? '18' : '0';

    final seed = 'vxg1-$basisHex-$variant';

    return {
      'seed': seed,
      'size': '$size',
      'mood': mood,
      'hair': hair,
      'skinColor': skinColor,
      'hairColor': hairColor,
      'facialHairProbability': facialHairProbability,
      'backgroundColor': 'transparent',
      'backgroundType': 'solid',
      'clip': 'true',
      'radius': '50',
      'scale': '92',
    };
  }
}

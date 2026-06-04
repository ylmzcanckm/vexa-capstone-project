import 'dart:convert';

import 'package:vexa/core/api/app_preferences_codec.dart';
import 'package:vexa/core/api/models/user_models.dart';
import 'package:vexa/core/storage/user_profile_store.dart';

/// Geniş profil verisini backend `bio` alanında JSON olarak taşır (geçici köprü).
final class ProfileBioCodec {
  const ProfileBioCodec._();

  static const _prefix = 'VEXA_PROFILE_V1:';

  static Future<String> encode(StoredUserProfile profile) async {
    final json = profile.toJson();
    json[AppPreferencesCodec.prefsKey] = await AppPreferencesCodec.exportJson();
    return '$_prefix${jsonEncode(json)}';
  }

  static StoredUserProfile? tryDecodeProfileOnly(String? bio) {
    if (bio == null || bio.isEmpty || !bio.startsWith(_prefix)) {
      return null;
    }
    try {
      final json = jsonDecode(bio.substring(_prefix.length));
      if (json is Map<String, dynamic>) {
        return StoredUserProfile.fromJson(json);
      }
    } catch (_) {}
    return null;
  }

  static Future<void> applyAppPrefsFromBio(String? bio) async {
    if (bio == null || bio.isEmpty || !bio.startsWith(_prefix)) return;
    try {
      final json = jsonDecode(bio.substring(_prefix.length));
      if (json is Map<String, dynamic>) {
        final prefs = json[AppPreferencesCodec.prefsKey];
        if (prefs is Map<String, dynamic>) {
          await AppPreferencesCodec.importJson(prefs);
        }
      }
    } catch (_) {}
  }

  static Future<Map<String, dynamic>> profilePayload(StoredUserProfile profile) async {
    final interests =
        profile.social?.interestIds ?? <String>[];
    final tags = <String>[
      if (profile.social?.gender.isNotEmpty ?? false)
        'gender:${profile.social!.gender}',
      if (profile.social?.education.isNotEmpty ?? false)
        'education:${profile.social!.education}',
    ];
    return {
      'bio': await encode(profile),
      'interests': interests,
      'personalityTags': tags,
    };
  }

  /// Sunucudan gelen profili yerel depoya yazar + ayarları uygular.
  static Future<void> applyRemoteToLocal(RemoteUser user) async {
    await applyAppPrefsFromBio(user.profile?.bio);

    final fromBio = tryDecodeProfileOnly(user.profile?.bio);
    if (fromBio != null) {
      await UserProfileStore.save(fromBio);
      return;
    }

    final parts = user.fullName.trim().split(RegExp(r'\s+'));
    final name = parts.isNotEmpty ? parts.first : '';
    final surname = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    final existing = await UserProfileStore.load();
    await UserProfileStore.save(
      StoredUserProfile(
        name: name.isNotEmpty ? name : (existing?.name ?? ''),
        surname: surname.isNotEmpty ? surname : (existing?.surname ?? ''),
        birthDateIso: existing?.birthDateIso ?? '',
        avatarSeed: existing?.avatarSeed ?? '',
        social: existing?.social,
        business: existing?.business,
      ),
    );
  }
}

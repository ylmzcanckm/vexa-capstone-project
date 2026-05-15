import 'dart:convert';

import 'package:vexa/core/api/models/user_models.dart';
import 'package:vexa/core/storage/user_profile_store.dart';

/// Geniş profil verisini backend `bio` alanında JSON olarak taşır (geçici köprü).
final class ProfileBioCodec {
  const ProfileBioCodec._();

  static const _prefix = 'VEXA_PROFILE_V1:';

  static String encode(StoredUserProfile profile) {
    return '$_prefix${jsonEncode(profile.toJson())}';
  }

  static StoredUserProfile? tryDecode(String? bio) {
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

  static Map<String, dynamic> profilePayload(StoredUserProfile profile) {
    final interests =
        profile.social?.interestIds ?? <String>[];
    final tags = <String>[
      if (profile.social?.gender.isNotEmpty ?? false)
        'gender:${profile.social!.gender}',
      if (profile.social?.education.isNotEmpty ?? false)
        'education:${profile.social!.education}',
    ];
    return {
      'bio': encode(profile),
      'interests': interests,
      'personalityTags': tags,
    };
  }

  /// Sunucudan gelen profili yerel depoya yazar.
  static Future<void> applyRemoteToLocal(RemoteUser user) async {
    final fromBio = tryDecode(user.profile?.bio);
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

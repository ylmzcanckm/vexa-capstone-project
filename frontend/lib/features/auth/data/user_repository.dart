import 'package:vexa/core/api/api_client.dart';
import 'package:vexa/core/api/models/user_models.dart';
import 'package:vexa/core/api/profile_bio_codec.dart';
import 'package:vexa/core/storage/onboarding_preferences.dart';
import 'package:vexa/core/storage/user_profile_store.dart';

/// Kullanıcı ve profil API senkronu.
final class UserRepository {
  const UserRepository._();

  static Future<RemoteUser> fetchMe() async {
    final json = await ApiClient.get('/users/me', auth: true);
    final data = json['data'] as Map<String, dynamic>? ?? {};
    return RemoteUser.fromJson(data);
  }

  /// Sunucudan çekip yerel profile yazar; onboarding durumunu günceller.
  static Future<RemoteUser> syncFromServer() async {
    final user = await fetchMe();
    await ProfileBioCodec.applyRemoteToLocal(user);

    final local = await UserProfileStore.load();
    final hasCore = local != null &&
        local.name.isNotEmpty &&
        local.surname.isNotEmpty &&
        local.birthDateIso.isNotEmpty;
    final hasAvatar = local != null && local.avatarSeed.isNotEmpty;
    final serverAvatar = user.settings?.selectedAvatarId;

    if (hasCore && (hasAvatar || (serverAvatar?.isNotEmpty ?? false))) {
      await OnboardingPreferences.setComplete(true);
    }

    return user;
  }

  static Future<void> pushProfile(StoredUserProfile profile) async {
    await ApiClient.put(
      '/users/me/profile',
      body: ProfileBioCodec.profilePayload(profile),
    );
  }

  /// Yerel profili sunucuya yazar (sosyal/network düzenleme sonrası).
  static Future<void> syncLocalProfileToServer() async {
    final profile = await UserProfileStore.load();
    if (profile == null) return;
    await pushProfile(profile);
  }

  static Future<List<RemoteAvatar>> fetchAvatars() async {
    final json = await ApiClient.get('/avatars');
    final list = json['data'] as List<dynamic>? ?? [];
    return list
        .whereType<Map<String, dynamic>>()
        .map(RemoteAvatar.fromJson)
        .toList();
  }

  static Future<void> saveAvatarId(String avatarId) async {
    await ApiClient.put(
      '/users/me/avatar',
      body: {'avatarId': avatarId},
    );
  }

  /// İlk backend avatarını seçer (DiceBear yerel kalır).
  static Future<void> syncDefaultAvatarIfNeeded() async {
    final user = await fetchMe();
    if (user.settings?.selectedAvatarId?.isNotEmpty ?? false) {
      return;
    }
    final avatars = await fetchAvatars();
    if (avatars.isEmpty) return;
    await saveAvatarId(avatars.first.id);
  }

  static Future<void> setMode(String mode) async {
    await ApiClient.put('/users/me/mode', body: {'mode': mode});
  }
}

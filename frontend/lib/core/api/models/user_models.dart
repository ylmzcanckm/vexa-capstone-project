/// GET /users/me yanıtı.
final class RemoteUser {
  const RemoteUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.profile,
    this.settings,
  });

  final String id;
  final String email;
  final String fullName;
  final RemoteProfile? profile;
  final RemoteSettings? settings;

  factory RemoteUser.fromJson(Map<String, dynamic> j) {
    return RemoteUser(
      id: j['id'] as String? ?? '',
      email: j['email'] as String? ?? '',
      fullName: j['fullName'] as String? ?? '',
      profile: j['profile'] is Map<String, dynamic>
          ? RemoteProfile.fromJson(j['profile'] as Map<String, dynamic>)
          : null,
      settings: j['settings'] is Map<String, dynamic>
          ? RemoteSettings.fromJson(j['settings'] as Map<String, dynamic>)
          : null,
    );
  }
}

final class RemoteProfile {
  const RemoteProfile({
    required this.bio,
    required this.interests,
    required this.personalityTags,
  });

  final String bio;
  final List<String> interests;
  final List<String> personalityTags;

  factory RemoteProfile.fromJson(Map<String, dynamic> j) {
    return RemoteProfile(
      bio: j['bio'] as String? ?? '',
      interests: (j['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      personalityTags: (j['personalityTags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}

final class RemoteSettings {
  const RemoteSettings({
    this.selectedAvatarId,
    this.selectedMode,
    this.isAvailable = true,
  });

  final String? selectedAvatarId;
  final String? selectedMode;
  final bool isAvailable;

  factory RemoteSettings.fromJson(Map<String, dynamic> j) {
    return RemoteSettings(
      selectedAvatarId: j['selectedAvatarId'] as String?,
      selectedMode: j['selectedMode'] as String?,
      isAvailable: j['isAvailable'] as bool? ?? true,
    );
  }
}

/// GET /avatars list item.
final class RemoteAvatar {
  const RemoteAvatar({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String imageUrl;

  factory RemoteAvatar.fromJson(Map<String, dynamic> j) {
    return RemoteAvatar(
      id: j['id'] as String? ?? '',
      name: j['name'] as String? ?? '',
      imageUrl: j['imageUrl'] as String? ?? '',
    );
  }
}

/// GET /matches/history öğesi.
final class RemoteMatchHistoryItem {
  const RemoteMatchHistoryItem({
    required this.id,
    required this.matchScore,
    required this.commonInterests,
    required this.commonPersonalityTags,
    required this.sameMode,
    required this.mode,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.otherUser,
  });

  final String id;
  final int matchScore;
  final List<String> commonInterests;
  final List<String> commonPersonalityTags;
  final bool sameMode;
  final String mode;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final RemoteMatchOtherUser otherUser;

  factory RemoteMatchHistoryItem.fromJson(Map<String, dynamic> j) {
    return RemoteMatchHistoryItem(
      id: j['id'] as String? ?? '',
      matchScore: (j['matchScore'] as num?)?.toInt() ?? 0,
      commonInterests: (j['commonInterests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      commonPersonalityTags: (j['commonPersonalityTags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sameMode: j['sameMode'] as bool? ?? false,
      mode: j['mode'] as String? ?? '',
      status: j['status'] as String? ?? '',
      createdAt: j['createdAt'] as String?,
      updatedAt: j['updatedAt'] as String?,
      otherUser: j['otherUser'] is Map<String, dynamic>
          ? RemoteMatchOtherUser.fromJson(
              j['otherUser'] as Map<String, dynamic>,
            )
          : const RemoteMatchOtherUser(),
    );
  }
}

final class RemoteMatchOtherUser {
  const RemoteMatchOtherUser({
    this.id = '',
    this.email = '',
    this.fullName = '',
  });

  final String id;
  final String email;
  final String fullName;

  factory RemoteMatchOtherUser.fromJson(Map<String, dynamic> j) {
    return RemoteMatchOtherUser(
      id: j['id'] as String? ?? '',
      email: j['email'] as String? ?? '',
      fullName: j['fullName'] as String? ?? '',
    );
  }

  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    if (email.isNotEmpty) return email.split('@').first;
    return 'Kullanıcı';
  }
}

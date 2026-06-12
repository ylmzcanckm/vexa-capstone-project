/// GET /matches/candidates öğesi.
final class RemoteMatchCandidate {
  const RemoteMatchCandidate({
    required this.id,
    required this.email,
    required this.fullName,
    this.selectedMode,
    this.interests = const [],
    this.profileBio,
  });

  final String id;
  final String email;
  final String fullName;
  final String? selectedMode;
  final List<String> interests;

  /// Quiz cevapları `bio` JSON içinde (`quizAnswers`).
  final String? profileBio;

  factory RemoteMatchCandidate.fromJson(Map<String, dynamic> j) {
    final profile = j['profile'] as Map<String, dynamic>?;
    final settings = j['settings'] as Map<String, dynamic>?;
    return RemoteMatchCandidate(
      id: j['id'] as String? ?? '',
      email: j['email'] as String? ?? '',
      fullName: j['fullName'] as String? ?? '',
      selectedMode: settings?['selectedMode'] as String?,
      interests: (profile?['interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      profileBio: profile?['bio'] as String?,
    );
  }

  String get displayName {
    if (fullName.trim().isNotEmpty) return fullName.trim();
    if (email.isNotEmpty) return email.split('@').first;
    return 'Kullanıcı';
  }
}

/// POST /matches/check yanıtı.
final class RemoteMatchCheckResult {
  const RemoteMatchCheckResult({
    required this.id,
    required this.matchScore,
    required this.status,
    required this.commonInterests,
    required this.sameMode,
  });

  final String id;
  final int matchScore;
  final String status;
  final List<String> commonInterests;
  final bool sameMode;

  /// Yeni backend `filtered` durumunu da bilir: skor yeterli ama tanışma
  /// filtreleri uyuşmuyor → eşleşme sayılmaz. Eski backend status boş
  /// dönerse skora bakılır.
  bool get isMatch =>
      status.isNotEmpty ? status == 'detected' : matchScore >= 50;

  bool get isFiltered => status == 'filtered';

  factory RemoteMatchCheckResult.fromJson(Map<String, dynamic> j) {
    return RemoteMatchCheckResult(
      id: j['id'] as String? ?? '',
      matchScore: (j['matchScore'] as num?)?.toInt() ?? 0,
      status: j['status'] as String? ?? '',
      commonInterests: (j['commonInterests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sameMode: j['sameMode'] as bool? ?? false,
    );
  }
}

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
    this.quizPercent,
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
  final int? quizPercent;
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
      quizPercent: (j['quizPercent'] as num?)?.toInt(),
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
    this.bio,
  });

  final String id;
  final String email;
  final String fullName;
  final String? bio;

  factory RemoteMatchOtherUser.fromJson(Map<String, dynamic> j) {
    return RemoteMatchOtherUser(
      id: j['id'] as String? ?? '',
      email: j['email'] as String? ?? '',
      fullName: j['fullName'] as String? ?? '',
      bio: j['bio'] as String?,
    );
  }

  String get displayName {
    if (fullName.isNotEmpty) return fullName;
    if (email.isNotEmpty) return email.split('@').first;
    return 'Kullanıcı';
  }
}

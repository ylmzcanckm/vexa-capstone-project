/// Giriş yanıtı.
final class AuthSession {
  const AuthSession({
    required this.token,
    required this.userId,
    required this.email,
    required this.fullName,
  });

  final String token;
  final String userId;
  final String email;
  final String fullName;

  factory AuthSession.fromLoginJson(Map<String, dynamic> data) {
    final user = data['user'] as Map<String, dynamic>? ?? {};
    return AuthSession(
      token: data['token'] as String? ?? '',
      userId: user['id'] as String? ?? '',
      email: user['email'] as String? ?? '',
      fullName: user['fullName'] as String? ?? '',
    );
  }
}

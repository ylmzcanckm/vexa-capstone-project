import 'package:shared_preferences/shared_preferences.dart';

/// Quiz bitince (başarılı ya da değil) 2 saatlik eşleşme molası.
///
/// Mola boyunca: yakınlık taraması, canlı eşleşme pop-up'ı ve manuel
/// Kontrol devre dışıdır. Şimdilik cihaz-yerel; sunucu tarafı enforcement
/// backend görevi olarak yol haritasında.
final class MatchCooldownStore {
  const MatchCooldownStore._();

  static const _key = 'vexa_match_cooldown_until_v1';
  static const duration = Duration(hours: 2);

  static Future<void> activate() async {
    await activateUntil(DateTime.now().add(duration));
  }

  /// Sunucudan gelen bitiş zamanıyla molayı başlatır.
  static Future<void> activateUntil(DateTime until) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, until.toLocal().toIso8601String());
  }

  /// Mola aktifse kalan süre, değilse `null`.
  static Future<Duration?> remaining() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    final until = DateTime.tryParse(raw);
    if (until == null) return null;
    final left = until.difference(DateTime.now());
    if (left.isNegative) return null;
    return left;
  }

  static Future<bool> isActive() async => (await remaining()) != null;

  /// Test için: molayı kaldır.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static String formatRemaining(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '$h sa $m dk';
    return '$m dk';
  }
}

import 'package:shared_preferences/shared_preferences.dart';
import 'package:vexa/core/storage/accessibility_preferences.dart';
import 'package:vexa/core/storage/blocked_users_preferences.dart';
import 'package:vexa/core/storage/notification_preferences.dart';
import 'package:vexa/core/storage/privacy_preferences.dart';
import 'package:vexa/core/storage/theme_preferences.dart';

/// Ayarlar — `profiles.bio` içindeki `appPrefs` alanı (sunucu köprüsü).
final class AppPreferencesCodec {
  const AppPreferencesCodec._();

  static const prefsKey = 'appPrefs';

  static Future<Map<String, dynamic>> exportJson() async {
    final blocked = await BlockedUsersPreferences.loadAll();
    return {
      'v': 1,
      'notifications': {
        'push': await NotificationPreferences.pushEnabled(),
        'inApp': await NotificationPreferences.inAppEnabled(),
        'matchAlerts': await NotificationPreferences.matchAlertsEnabled(),
      },
      'privacy': {
        'discoverable': await PrivacyPreferences.discoverable(),
        'showEmail': await PrivacyPreferences.showEmailOnProfile(),
        'kvkkAcceptedAt': await PrivacyPreferences.kvkkAcceptedAtIso(),
      },
      'accessibility': {
        'textScale': await AccessibilityPreferences.textScale(),
        'boldText': await AccessibilityPreferences.boldText(),
        'reduceMotion': await AccessibilityPreferences.reduceMotion(),
      },
      'theme': {
        'dark': await ThemePreferences.isDark(),
      },
      'blockedUsers': blocked.map((e) => e.toJson()).toList(),
    };
  }

  static Future<void> importJson(Map<String, dynamic>? json) async {
    if (json == null) return;

    final n = json['notifications'];
    if (n is Map<String, dynamic>) {
      await NotificationPreferences.setPush(n['push'] as bool? ?? true);
      await NotificationPreferences.setInApp(n['inApp'] as bool? ?? true);
      await NotificationPreferences.setMatchAlerts(
        n['matchAlerts'] as bool? ?? true,
      );
    }

    final p = json['privacy'];
    if (p is Map<String, dynamic>) {
      await PrivacyPreferences.setDiscoverable(p['discoverable'] as bool? ?? true);
      await PrivacyPreferences.setShowEmailOnProfile(p['showEmail'] as bool? ?? false);
      final kvkk = p['kvkkAcceptedAt'] as String?;
      if (kvkk != null && kvkk.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('vexa_kvkk_accepted_at', kvkk);
      }
    }

    final a = json['accessibility'];
    if (a is Map<String, dynamic>) {
      final scale = (a['textScale'] as num?)?.toDouble() ?? 1.0;
      await AccessibilityPreferences.setTextScale(scale);
      await AccessibilityPreferences.setBoldText(a['boldText'] as bool? ?? false);
      await AccessibilityPreferences.setReduceMotion(
        a['reduceMotion'] as bool? ?? false,
      );
    }

    final t = json['theme'];
    if (t is Map<String, dynamic>) {
      await ThemePreferences.setDark(t['dark'] as bool? ?? false);
    }

    final blocked = json['blockedUsers'];
    if (blocked is List<dynamic>) {
      final entries = blocked
          .whereType<Map<String, dynamic>>()
          .map(BlockedUserEntry.fromJson)
          .toList();
      await BlockedUsersPreferences.saveAll(entries);
    }
  }
}

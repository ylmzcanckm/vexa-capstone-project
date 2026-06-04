import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vexa/core/storage/accessibility_preferences.dart';
import 'package:vexa/core/storage/blocked_users_preferences.dart';
import 'package:vexa/core/storage/notification_preferences.dart';
import 'package:vexa/core/storage/privacy_preferences.dart';

final class NotificationSettings {
  const NotificationSettings({
    required this.pushEnabled,
    required this.inAppEnabled,
    required this.matchAlertsEnabled,
  });

  final bool pushEnabled;
  final bool inAppEnabled;
  final bool matchAlertsEnabled;

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? inAppEnabled,
    bool? matchAlertsEnabled,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      inAppEnabled: inAppEnabled ?? this.inAppEnabled,
      matchAlertsEnabled: matchAlertsEnabled ?? this.matchAlertsEnabled,
    );
  }
}

class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    _load();
    return const NotificationSettings(
      pushEnabled: true,
      inAppEnabled: true,
      matchAlertsEnabled: true,
    );
  }

  Future<void> _load() async {
    state = NotificationSettings(
      pushEnabled: await NotificationPreferences.pushEnabled(),
      inAppEnabled: await NotificationPreferences.inAppEnabled(),
      matchAlertsEnabled: await NotificationPreferences.matchAlertsEnabled(),
    );
  }

  Future<void> setPush(bool v) async {
    await NotificationPreferences.setPush(v);
    state = state.copyWith(pushEnabled: v);
  }

  Future<void> setInApp(bool v) async {
    await NotificationPreferences.setInApp(v);
    state = state.copyWith(inAppEnabled: v);
  }

  Future<void> setMatchAlerts(bool v) async {
    await NotificationPreferences.setMatchAlerts(v);
    state = state.copyWith(matchAlertsEnabled: v);
  }
}

final notificationSettingsProvider = NotifierProvider<NotificationSettingsNotifier,
    NotificationSettings>(NotificationSettingsNotifier.new);

final class PrivacySettings {
  const PrivacySettings({
    required this.discoverable,
    required this.showEmailOnProfile,
    this.kvkkAcceptedAtIso,
  });

  final bool discoverable;
  final bool showEmailOnProfile;
  final String? kvkkAcceptedAtIso;

  PrivacySettings copyWith({
    bool? discoverable,
    bool? showEmailOnProfile,
    String? kvkkAcceptedAtIso,
  }) {
    return PrivacySettings(
      discoverable: discoverable ?? this.discoverable,
      showEmailOnProfile: showEmailOnProfile ?? this.showEmailOnProfile,
      kvkkAcceptedAtIso: kvkkAcceptedAtIso ?? this.kvkkAcceptedAtIso,
    );
  }
}

class PrivacySettingsNotifier extends Notifier<PrivacySettings> {
  @override
  PrivacySettings build() {
    _load();
    return const PrivacySettings(discoverable: true, showEmailOnProfile: false);
  }

  Future<void> _load() async {
    state = PrivacySettings(
      discoverable: await PrivacyPreferences.discoverable(),
      showEmailOnProfile: await PrivacyPreferences.showEmailOnProfile(),
      kvkkAcceptedAtIso: await PrivacyPreferences.kvkkAcceptedAtIso(),
    );
  }

  Future<void> setDiscoverable(bool v) async {
    await PrivacyPreferences.setDiscoverable(v);
    state = state.copyWith(discoverable: v);
  }

  Future<void> setShowEmail(bool v) async {
    await PrivacyPreferences.setShowEmailOnProfile(v);
    state = state.copyWith(showEmailOnProfile: v);
  }

  Future<void> acceptKvkk() async {
    await PrivacyPreferences.setKvkkAcceptedNow();
    state = state.copyWith(
      kvkkAcceptedAtIso: DateTime.now().toUtc().toIso8601String(),
    );
  }
}

final privacySettingsProvider =
    NotifierProvider<PrivacySettingsNotifier, PrivacySettings>(
  PrivacySettingsNotifier.new,
);

final class AccessibilitySettings {
  const AccessibilitySettings({
    required this.textScale,
    required this.boldText,
    required this.reduceMotion,
  });

  final double textScale;
  final bool boldText;
  final bool reduceMotion;

  AccessibilitySettings copyWith({
    double? textScale,
    bool? boldText,
    bool? reduceMotion,
  }) {
    return AccessibilitySettings(
      textScale: textScale ?? this.textScale,
      boldText: boldText ?? this.boldText,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }
}

class AccessibilitySettingsNotifier extends Notifier<AccessibilitySettings> {
  @override
  AccessibilitySettings build() {
    _load();
    return const AccessibilitySettings(
      textScale: 1.0,
      boldText: false,
      reduceMotion: false,
    );
  }

  Future<void> _load() async {
    state = AccessibilitySettings(
      textScale: await AccessibilityPreferences.textScale(),
      boldText: await AccessibilityPreferences.boldText(),
      reduceMotion: await AccessibilityPreferences.reduceMotion(),
    );
  }

  Future<void> setTextScale(double v) async {
    await AccessibilityPreferences.setTextScale(v);
    state = state.copyWith(textScale: v);
  }

  Future<void> setBoldText(bool v) async {
    await AccessibilityPreferences.setBoldText(v);
    state = state.copyWith(boldText: v);
  }

  Future<void> setReduceMotion(bool v) async {
    await AccessibilityPreferences.setReduceMotion(v);
    state = state.copyWith(reduceMotion: v);
  }
}

final accessibilitySettingsProvider = NotifierProvider<
    AccessibilitySettingsNotifier, AccessibilitySettings>(
  AccessibilitySettingsNotifier.new,
);

class BlockedUsersNotifier extends Notifier<List<BlockedUserEntry>> {
  @override
  List<BlockedUserEntry> build() {
    _load();
    return const [];
  }

  Future<void> _load() async {
    state = await BlockedUsersPreferences.loadAll();
  }

  Future<void> reload() => _load();

  Future<void> add(String displayName, {String note = ''}) async {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) return;
    final id = '${DateTime.now().millisecondsSinceEpoch}_$trimmed';
    await BlockedUsersPreferences.add(
      BlockedUserEntry(id: id, displayName: trimmed, note: note),
    );
    await _load();
  }

  Future<void> remove(String id) async {
    await BlockedUsersPreferences.remove(id);
    await _load();
  }
}

final blockedUsersProvider =
    NotifierProvider<BlockedUsersNotifier, List<BlockedUserEntry>>(
  BlockedUsersNotifier.new,
);

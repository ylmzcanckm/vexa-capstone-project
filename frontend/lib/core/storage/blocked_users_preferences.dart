import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

final class BlockedUserEntry {
  const BlockedUserEntry({
    required this.id,
    required this.displayName,
    this.note = '',
  });

  final String id;
  final String displayName;
  final String note;

  Map<String, dynamic> toJson() => {
        'id': id,
        'displayName': displayName,
        'note': note,
      };

  factory BlockedUserEntry.fromJson(Map<String, dynamic> j) {
    return BlockedUserEntry(
      id: j['id'] as String? ?? '',
      displayName: j['displayName'] as String? ?? '',
      note: j['note'] as String? ?? '',
    );
  }
}

final class BlockedUsersPreferences {
  const BlockedUsersPreferences._();

  static const _key = 'vexa_blocked_users_v1';

  static Future<List<BlockedUserEntry>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .whereType<Map<String, dynamic>>()
          .map(BlockedUserEntry.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveAll(List<BlockedUserEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  static Future<void> add(BlockedUserEntry entry) async {
    final all = await loadAll();
    if (all.any((e) => e.id == entry.id)) return;
    all.add(entry);
    await saveAll(all);
  }

  static Future<void> remove(String id) async {
    final all = await loadAll();
    all.removeWhere((e) => e.id == id);
    await saveAll(all);
  }
}

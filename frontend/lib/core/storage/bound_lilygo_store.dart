import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Kullanıcıya özel LilyGO BLE adı (`VEXA-80DC18D9B4DC` gibi).
final class BoundLilyGoStore {
  const BoundLilyGoStore._();

  static const _activeUserKey = 'vexa_bound_ble_active_user_id';
  static const _mapKey = 'vexa_bound_ble_names_v1';

  static Future<void> setActiveUserId(String userId) async {
    if (userId.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_activeUserKey, userId);
  }

  static Future<String?> activeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_activeUserKey);
  }

  static Future<Map<String, String>> _loadMap() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_mapKey);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return {};
      return decoded.map(
        (k, v) => MapEntry(k, v.toString()),
      );
    } catch (_) {
      return {};
    }
  }

  static Future<void> _saveMap(Map<String, String> map) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_mapKey, jsonEncode(map));
  }

  /// Kayıtlı LilyGO BLE adını döner (aktif kullanıcı için).
  static Future<String?> load() async {
    final userId = await activeUserId();
    if (userId == null || userId.isEmpty) return null;
    final map = await _loadMap();
    final name = map[userId]?.trim();
    if (name == null || name.isEmpty) return null;
    return name;
  }

  static Future<void> save(String bleName, {String? userId}) async {
    final id = userId ?? await activeUserId();
    if (id == null || id.isEmpty) return;
    final trimmed = bleName.trim();
    if (trimmed.isEmpty) return;

    final map = await _loadMap();
    map[id] = trimmed;
    await _saveMap(map);
    await setActiveUserId(id);
  }

  /// Sunucudaki eşleşme kodundan yerel kayıt oluştur (ilk açılış / senkron).
  static Future<void> syncFromServerDeviceCode(String? deviceCode) async {
    final code = deviceCode?.trim();
    if (code == null || code.isEmpty) return;
    if (!code.toUpperCase().startsWith('VEXA-')) return;

    final existing = await load();
    if (existing != null && existing.isNotEmpty) return;

    await save(code);
  }

  static Future<void> clear({String? userId}) async {
    final id = userId ?? await activeUserId();
    if (id == null || id.isEmpty) return;
    final map = await _loadMap();
    map.remove(id);
    await _saveMap(map);
  }

  static Future<bool> hasBinding() async {
    final name = await load();
    return name != null && name.isNotEmpty;
  }
}

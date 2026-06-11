import 'dart:async' show unawaited;
import 'dart:convert';

import 'package:flutter/material.dart' show RangeValues;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vexa/core/api/api_client.dart';
import 'package:vexa/core/constants/education_options.dart';
import 'package:vexa/core/storage/user_profile_store.dart';
import 'package:vexa/core/utils/user_age.dart';
import 'package:vexa/features/matching/domain/discovery_substance_filter.dart';
import 'package:vexa/features/matching/presentation/providers/discovery_filters_provider.dart';

/// Tanışma filtrelerinin kalıcı kaydı — eşleşme akışı UI dışından da okur.
/// Sunucuya da kopyalanır (`PUT /users/me/filters`); böylece `/matches/check`
/// iki tarafın filtresini de uygular.
final class DiscoveryFiltersStore {
  const DiscoveryFiltersStore._();

  static const _key = 'vexa_discovery_filters_v1';

  static Map<String, dynamic> _toJson(DiscoveryFiltersState s) => {
        'age': [s.ageRange.start, s.ageRange.end],
        'height': [s.heightRange.start, s.heightRange.end],
        'weight': [s.weightRange.start, s.weightRange.end],
        'genders': s.selectedGenders.toList(),
        'educationFloor': s.educationFloor,
        'tobacco': s.tobaccoFilter.name,
        'alcohol': s.alcoholFilter.name,
      };

  static Future<void> save(DiscoveryFiltersState s) async {
    final json = _toJson(s);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(json));
    unawaited(_syncToServer(json));
  }

  static Future<void> _syncToServer(Map<String, dynamic> json) async {
    try {
      await ApiClient.put('/users/me/filters', body: {'filters': json});
    } catch (_) {
      // Offline / eski backend: yerel kayıt yeterli, sonraki kayıtta dener.
    }
  }

  static Future<DiscoveryFiltersState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      RangeValues range(String key, RangeValues fallback) {
        final list = j[key] as List<dynamic>?;
        if (list == null || list.length != 2) return fallback;
        return RangeValues(
          (list[0] as num).toDouble(),
          (list[1] as num).toDouble(),
        );
      }

      DiscoverySubstanceFilter substance(String key) {
        return DiscoverySubstanceFilter.values.firstWhere(
          (v) => v.name == j[key],
          orElse: () => DiscoverySubstanceFilter.any,
        );
      }

      const def = DiscoveryFiltersState();
      return DiscoveryFiltersState(
        ageRange: range('age', def.ageRange),
        heightRange: range('height', def.heightRange),
        weightRange: range('weight', def.weightRange),
        selectedGenders: ((j['genders'] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .toSet(),
        educationFloor: j['educationFloor'] as String?,
        tobaccoFilter: substance('tobacco'),
        alcoholFilter: substance('alcohol'),
      );
    } catch (_) {
      return null;
    }
  }
}

/// Tanışma filtrelerini karşı tarafın profiline uygular.
///
/// Senaryo: filtreler **tam tutuyorsa** quiz daveti çıkar. İki telefon da
/// kendi filtresini karşı tarafa uyguladığı için karşılıklı uyum şartı
/// kendiliğinden sağlanır (ikisi de kabul etmeden quiz başlamaz).
final class DiscoveryFilterMatcher {
  const DiscoveryFilterMatcher._();

  /// Karşı tarafın profili (bio'dan çözülen) filtrelere uyuyor mu?
  ///
  /// Profilde eksik olan alanlar filtreyi geçer (bilinmeyen → eleme yok).
  static bool matches(DiscoveryFiltersState f, StoredUserProfile p) {
    final social = p.social;

    final age = UserAge.completedYears(p.birthDateIso);
    if (age != null &&
        (age < f.ageRange.start.round() || age > f.ageRange.end.round())) {
      return false;
    }

    if (f.selectedGenders.isNotEmpty) {
      final gender = social?.gender.trim() ?? '';
      if (gender.isNotEmpty && !f.selectedGenders.contains(gender)) {
        return false;
      }
    }

    final height = int.tryParse(social?.heightCm.trim() ?? '');
    if (height != null &&
        (height < f.heightRange.start.round() ||
            height > f.heightRange.end.round())) {
      return false;
    }

    final weight = int.tryParse(social?.weightKg.trim() ?? '');
    if (weight != null &&
        (weight < f.weightRange.start.round() ||
            weight > f.weightRange.end.round())) {
      return false;
    }

    final floor = f.educationFloor;
    if (floor != null) {
      final floorRank = EducationOptions.labels.indexOf(floor);
      final profileRank =
          EducationOptions.labels.indexOf(social?.education.trim() ?? '');
      if (floorRank >= 0 && profileRank >= 0 && profileRank < floorRank) {
        return false;
      }
    }

    if (!discoverySubstanceMatches(social?.tobacco, f.tobaccoFilter)) {
      return false;
    }
    if (!discoverySubstanceMatches(social?.alcohol, f.alcoholFilter)) {
      return false;
    }

    return true;
  }
}

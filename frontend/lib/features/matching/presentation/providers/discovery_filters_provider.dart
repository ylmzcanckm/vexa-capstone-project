import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vexa/features/matching/data/discovery_filters_store.dart';
import 'package:vexa/features/matching/domain/discovery_substance_filter.dart';

final class DiscoveryFiltersState {
  const DiscoveryFiltersState({
    this.ageRange = const RangeValues(20, 45),
    this.heightRange = const RangeValues(165, 185),
    this.weightRange = const RangeValues(55, 90),
    this.selectedGenders = const <String>{},
    /// Alt sınır: bu ve **daha yüksek** formal sıra dahildir; `null` = filtre yok.
    this.educationFloor,
    this.tobaccoFilter = DiscoverySubstanceFilter.any,
    this.alcoholFilter = DiscoverySubstanceFilter.any,
  });

  final RangeValues ageRange;
  final RangeValues heightRange;
  final RangeValues weightRange;
  final Set<String> selectedGenders;
  final String? educationFloor;
  final DiscoverySubstanceFilter tobaccoFilter;
  final DiscoverySubstanceFilter alcoholFilter;

  DiscoveryFiltersState copyWith({
    RangeValues? ageRange,
    RangeValues? heightRange,
    RangeValues? weightRange,
    Set<String>? selectedGenders,
    String? educationFloor,
    bool clearEducationFloor = false,
    DiscoverySubstanceFilter? tobaccoFilter,
    DiscoverySubstanceFilter? alcoholFilter,
  }) {
    return DiscoveryFiltersState(
      ageRange: ageRange ?? this.ageRange,
      heightRange: heightRange ?? this.heightRange,
      weightRange: weightRange ?? this.weightRange,
      selectedGenders: selectedGenders ?? this.selectedGenders,
      educationFloor:
          clearEducationFloor ? null : (educationFloor ?? this.educationFloor),
      tobaccoFilter: tobaccoFilter ?? this.tobaccoFilter,
      alcoholFilter: alcoholFilter ?? this.alcoholFilter,
    );
  }
}

class DiscoveryFiltersNotifier extends Notifier<DiscoveryFiltersState> {
  @override
  DiscoveryFiltersState build() {
    unawaited(_restore());
    return const DiscoveryFiltersState();
  }

  Future<void> _restore() async {
    final saved = await DiscoveryFiltersStore.load();
    if (saved != null) state = saved;
  }

  void _set(DiscoveryFiltersState next) {
    state = next;
    unawaited(DiscoveryFiltersStore.save(next));
  }

  void setAgeRange(RangeValues v) {
    _set(state.copyWith(ageRange: v));
  }

  void setHeightRange(RangeValues v) {
    _set(state.copyWith(heightRange: v));
  }

  void setWeightRange(RangeValues v) {
    _set(state.copyWith(weightRange: v));
  }

  void toggleGender(String label) {
    final next = Set<String>.from(state.selectedGenders);
    if (next.contains(label)) {
      next.remove(label);
    } else {
      next.add(label);
    }
    _set(state.copyWith(selectedGenders: next));
  }

  void setEducationFloor(String? label) {
    if (label == null) {
      _set(state.copyWith(clearEducationFloor: true));
    } else {
      _set(state.copyWith(educationFloor: label));
    }
  }

  void setTobaccoFilter(DiscoverySubstanceFilter v) {
    _set(state.copyWith(tobaccoFilter: v));
  }

  void setAlcoholFilter(DiscoverySubstanceFilter v) {
    _set(state.copyWith(alcoholFilter: v));
  }

  void reset() {
    _set(const DiscoveryFiltersState());
  }
}

final discoveryFiltersProvider =
    NotifierProvider<DiscoveryFiltersNotifier, DiscoveryFiltersState>(
  DiscoveryFiltersNotifier.new,
);

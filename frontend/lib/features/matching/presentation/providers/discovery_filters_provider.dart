import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  DiscoveryFiltersState build() => const DiscoveryFiltersState();

  void setAgeRange(RangeValues v) {
    state = state.copyWith(ageRange: v);
  }

  void setHeightRange(RangeValues v) {
    state = state.copyWith(heightRange: v);
  }

  void setWeightRange(RangeValues v) {
    state = state.copyWith(weightRange: v);
  }

  void toggleGender(String label) {
    final next = Set<String>.from(state.selectedGenders);
    if (next.contains(label)) {
      next.remove(label);
    } else {
      next.add(label);
    }
    state = state.copyWith(selectedGenders: next);
  }

  void setEducationFloor(String? label) {
    if (label == null) {
      state = state.copyWith(clearEducationFloor: true);
    } else {
      state = state.copyWith(educationFloor: label);
    }
  }

  void setTobaccoFilter(DiscoverySubstanceFilter v) {
    state = state.copyWith(tobaccoFilter: v);
  }

  void setAlcoholFilter(DiscoverySubstanceFilter v) {
    state = state.copyWith(alcoholFilter: v);
  }

  void reset() {
    state = const DiscoveryFiltersState();
  }
}

final discoveryFiltersProvider =
    NotifierProvider<DiscoveryFiltersNotifier, DiscoveryFiltersState>(
  DiscoveryFiltersNotifier.new,
);

import 'package:vexa/core/constants/substance_use_options.dart';

/// Tanışma filtrelerinde sigara / alkol için üçlü seçim.
enum DiscoverySubstanceFilter {
  /// Filtre uygulanmaz.
  any,

  /// Yalnızca “Kullanmıyor” seçenekli profiller.
  onlyNonUsers,

  /// Düzenli veya sosyal içen profiller (kullanmıyor hariç).
  onlyUsers,
}

bool discoverySubstanceMatches(
  String? profileValue,
  DiscoverySubstanceFilter filter,
) {
  if (filter == DiscoverySubstanceFilter.any) return true;
  if (profileValue == null || profileValue.trim().isEmpty) {
    return true;
  }
  final isNon = profileValue == SubstanceUseOptions.none;
  return switch (filter) {
    DiscoverySubstanceFilter.any => true,
    DiscoverySubstanceFilter.onlyNonUsers => isNon,
    DiscoverySubstanceFilter.onlyUsers => !isNon,
  };
}

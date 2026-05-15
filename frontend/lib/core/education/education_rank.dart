import 'package:vexa/core/constants/education_options.dart';

abstract final class EducationRank {
  /// Düşükten yükseğe indeks. Bilinmeyen etiket için null.
  static int? of(String? label) {
    if (label == null || label.isEmpty) return null;
    final i = EducationOptions.labels.indexOf(label);
    if (i < 0) return null;
    return i;
  }

  /// Tanışma filtresi: [floor] alt sınır seçildiğinde profilin eğitimi bu düzey ve **üzeri** mi?
  /// `floor == null` → filtre yok (hepsi).
  static bool profileMatchesFloor(String? profileEducation, String? floor) {
    if (floor == null) return true;
    if (profileEducation == null || profileEducation.isEmpty) {
      return true;
    }
    if (profileEducation == EducationOptions.privacyLabel) {
      return true;
    }
    final floorRank = of(floor);
    final pRank = of(profileEducation);
    if (floorRank == null || pRank == null) return true;
    return pRank >= floorRank;
  }
}

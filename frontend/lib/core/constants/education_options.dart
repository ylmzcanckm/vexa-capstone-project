/// Profil ve tanışma filtrelerinde ortak eğitim etiketleri.
/// Sıra düşükten yükseğe: tanışma filtresinde **alt sınır** seçildiğinde bu düzey ve
/// **daha yüksek** formal sıra dahildir (örn. Lise → Lise ve üstü).
abstract final class EducationOptions {
  static const String privacyLabel = 'Belirtmek istemiyorum';

  /// Profil / onboarding varsayılan sekmesi.
  static const String profileDefaultSelection = 'Lise';

  static const List<String> labels = [
    'Okuryazar değil',
    'İlkokul',
    'Ortaokul',
    'Lise',
    'Meslek lisesi',
    'Önlisans',
    'Lisans',
    'Yüksek lisans',
    'Doktora',
    'Lise öğrencisi',
    'Üniversite öğrencisi (önlisans)',
    'Üniversite öğrencisi (lisans)',
    'Üniversite öğrencisi (lisansüstü)',
    'Belirtmek istemiyorum',
  ];
}

abstract final class UserAge {
  static DateTime? tryParseIsoDate(String iso) {
    final t = iso.trim();
    if (t.length < 10) return null;
    return DateTime.tryParse(t.substring(0, 10));
  }

  static int? completedYears(String birthDateIso, [DateTime? reference]) {
    final b = tryParseIsoDate(birthDateIso);
    if (b == null) return null;
    final t = reference ?? DateTime.now();
    var age = t.year - b.year;
    if (t.month < b.month || (t.month == b.month && t.day < b.day)) {
      age--;
    }
    return age;
  }

  /// Eski kayıtta sadece yaş metni varsa kabaca ISO üretir (1 Temmuz).
  static String legacyIsoFromAgeString(String age) {
    final y = int.tryParse(age.trim());
    if (y == null || y < 1 || y > 120) return '';
    final approxYear = DateTime.now().year - y;
    return '${approxYear.toString().padLeft(4, '0')}-07-01';
  }

  static String formatTrDayMonthYear(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    return '$dd.$mm.${d.year}';
  }

  /// Örn. `27 yaşında (12.05.1998)` veya `—`
  static String displayAgeAndBirth(String birthDateIso) {
    final years = completedYears(birthDateIso);
    final d = tryParseIsoDate(birthDateIso);
    if (years == null || d == null) return '—';
    return '$years yaşında (${formatTrDayMonthYear(d)})';
  }

  static bool isValidOnboardingBirth(DateTime birth, {DateTime? today}) {
    final t = today ?? DateTime.now();
    final age = completedYears(
      '${birth.year.toString().padLeft(4, '0')}-'
      '${birth.month.toString().padLeft(2, '0')}-'
      '${birth.day.toString().padLeft(2, '0')}',
      t,
    );
    if (age == null) return false;
    return age >= 13 && age <= 120;
  }

  static String toIsoDateOnly(DateTime d) {
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }
}

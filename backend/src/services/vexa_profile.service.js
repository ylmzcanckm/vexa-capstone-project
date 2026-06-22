// Uygulamanın profiles.bio alanında taşıdığı VEXA profil JSON'unu çözer ve
// tanışma filtrelerini / quiz cevaplarını sunucu tarafında değerlendirir.
// Kurallar frontend'deki DiscoveryFilterMatcher ile birebir aynı tutulmalı.

const BIO_PREFIX = "VEXA_PROFILE_V1:";

// frontend/lib/core/constants/education_options.dart ile aynı sıra
const EDUCATION_LABELS = [
  "Okuryazar değil",
  "İlkokul",
  "Ortaokul",
  "Lise",
  "Meslek lisesi",
  "Önlisans",
  "Lisans",
  "Yüksek lisans",
  "Doktora",
  "Lise öğrencisi",
  "Üniversite öğrencisi (önlisans)",
  "Üniversite öğrencisi (lisans)",
  "Üniversite öğrencisi (lisansüstü)",
  "Belirtmek istemiyorum"
];

// frontend/lib/core/constants/substance_use_options.dart
const SUBSTANCE_NONE = "Kullanmıyor";

const decodeBioProfile = (bio) => {
  if (!bio || typeof bio !== "string" || !bio.startsWith(BIO_PREFIX)) {
    return null;
  }

  try {
    const json = JSON.parse(bio.slice(BIO_PREFIX.length));
    return json && typeof json === "object" ? json : null;
  } catch (_) {
    return null;
  }
};

const computeAge = (birthDateIso) => {
  if (!birthDateIso || typeof birthDateIso !== "string") return null;

  const birth = new Date(birthDateIso.slice(0, 10));
  if (Number.isNaN(birth.getTime())) return null;

  const now = new Date();
  let age = now.getFullYear() - birth.getFullYear();
  if (
    now.getMonth() < birth.getMonth() ||
    (now.getMonth() === birth.getMonth() && now.getDate() < birth.getDate())
  ) {
    age -= 1;
  }

  return age;
};

const substanceMatches = (profileValue, filter) => {
  if (!filter || filter === "any") return true;
  if (!profileValue || !String(profileValue).trim()) return true;

  const isNon = profileValue === SUBSTANCE_NONE;
  if (filter === "onlyNonUsers") return isNon;
  if (filter === "onlyUsers") return !isNon;
  return true;
};

// filters: profiles.discovery_filters JSONB
//   { age: [min,max], height: [min,max], weight: [min,max],
//     genders: [..], educationFloor, tobacco, alcohol }
// profileJson: bio'dan çözülen VEXA profil JSON'u
// Bilinmeyen / eksik alanlar filtreyi geçer (frontend ile aynı davranış).
const passesDiscoveryFilters = (filters, profileJson) => {
  if (!filters || typeof filters !== "object") return true;
  if (!profileJson || typeof profileJson !== "object") return true;

  const social = profileJson.social || {};

  const inRange = (value, range) => {
    if (value == null) return true;
    if (!Array.isArray(range) || range.length !== 2) return true;
    return value >= Math.round(range[0]) && value <= Math.round(range[1]);
  };

  const age = computeAge(profileJson.birthDateIso);
  if (!inRange(age, filters.age)) return false;

  const genders = Array.isArray(filters.genders) ? filters.genders : [];
  if (genders.length > 0) {
    const gender = String(social.gender || "").trim();
    if (gender && !genders.includes(gender)) return false;
  }

  const height = parseInt(String(social.heightCm || "").trim(), 10);
  if (!inRange(Number.isNaN(height) ? null : height, filters.height)) {
    return false;
  }

  const weight = parseInt(String(social.weightKg || "").trim(), 10);
  if (!inRange(Number.isNaN(weight) ? null : weight, filters.weight)) {
    return false;
  }

  if (filters.educationFloor) {
    const floorRank = EDUCATION_LABELS.indexOf(filters.educationFloor);
    const profileRank = EDUCATION_LABELS.indexOf(
      String(social.education || "").trim()
    );
    if (floorRank >= 0 && profileRank >= 0 && profileRank < floorRank) {
      return false;
    }
  }

  if (!substanceMatches(social.tobacco, filters.tobacco)) return false;
  if (!substanceMatches(social.alcohol, filters.alcohol)) return false;

  return true;
};

// İki cevap haritasını karşılaştırır (anahtar: "ilgiAlani:soruId" → "a"|"b").
// expectedKeys verilirse tam 5 soru üzerinden hesaplanır; farklı soru seti → fail.
const compareQuizAnswers = (answersA, answersB, expectedKeys = null) => {
  const a = answersA && typeof answersA === "object" ? answersA : {};
  const b = answersB && typeof answersB === "object" ? answersB : {};

  const keys = expectedKeys?.length
    ? [...expectedKeys].sort()
    : [...new Set([...Object.keys(a), ...Object.keys(b)])].sort();

  const keysA = Object.keys(a).sort();
  const keysB = Object.keys(b).sort();
  const keyMismatch =
    expectedKeys?.length > 0
      ? keysA.join("|") !== keys.join("|") || keysB.join("|") !== keys.join("|")
      : keysA.join("|") !== keysB.join("|");

  if (keyMismatch) {
    return {
      matching: 0,
      total: keys.length || 5,
      percent: 0,
      passed: false,
      keyMismatch: true
    };
  }

  const matching = keys.filter((key) => a[key] === b[key]).length;
  const total = keys.length;
  const percent = total > 0 ? Math.round((matching / total) * 100) : 0;

  return {
    matching,
    total,
    percent,
    passed: total > 0 && percent >= 80,
    keyMismatch: false
  };
};

module.exports = {
  decodeBioProfile,
  passesDiscoveryFilters,
  compareQuizAnswers
};

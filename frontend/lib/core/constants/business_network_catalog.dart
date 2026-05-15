// Network / Business mod — çalışma durumu, sektör sekmeli tag’ler, arayış listesi.

const List<String> kNetworkWorkStatusLabels = [
  'Student',
  'Intern',
  'Junior',
  'Founder',
  'Recruiter',
  'Engineer',
];

/// Sektör sekmesi → etiketler (tüm stringler katalog içinde tekil olmalı).
const Map<String, List<String>> kProfessionalTagsByIndustry = {
  'Yazılım & IT': [
    'Backend',
    'Frontend',
    'Full-stack',
    'DevOps',
    'SRE',
    'Cybersecurity',
    'Mobil (iOS/Android)',
    'Gömülü yazılım',
    'Oyun geliştirme',
    'QA / Test otomasyonu',
    'Technical writing',
  ],
  'Veri, AI & Cloud': [
    'AI',
    'Data Science',
    'Machine Learning',
    'MLOps',
    'Data Engineering',
    'BI / Analytics',
    'AI ürün',
    'Cloud mimarisi',
    'FinOps',
    'Ağ mühendisliği',
  ],
  'Ürün, Tasarım & UX': [
    'UI/UX',
    'Ürün yönetimi (PM)',
    'Ürün tasarımı',
    'Design systems',
    'Kullanıcı araştırması',
    'Prototipleme',
    'Erişilebilirlik',
  ],
  'Pazarlama, Büyüme & Satış': [
    'Growth',
    'Performance marketing',
    'SEO / SEM',
    'İçerik pazarlama',
    'Sosyal medya',
    'Marka yönetimi',
    'B2B satış',
    'Partnerlikler',
    'Startup',
    'Marketing',
  ],
  'Finans, Muhasebe & Yatırım': [
    'Finance',
    'Muhasebe',
    'FP&A',
    'Denetim',
    'Risk yönetimi',
    'Ödeme sistemleri',
    'VC / Angel ekosistemi',
    'Kripto / Web3 iş',
  ],
  'İK, Operasyon & Strateji': [
    'İnsan kaynakları',
    'Talent acquisition',
    'People ops',
    'İş analisti',
    'Strateji',
    'Operasyon müdürlüğü',
    'Tedarik zinciri',
    'Proje yönetimi',
    'Office / Workplace',
  ],
  'Sağlık, Ar-Ge & Bilim': [
    'Biyoteknoloji',
    'Klinik araştırma',
    'Sağlık teknolojileri',
    'Regülasyon (GxP)',
    'Kimya / Malzeme Ar-Ge',
    'Elektronik donanım',
    'Laboratuvar otomasyonu',
  ],
  'Hukuk, Uyum & Kamu': [
    'Kurumsal hukuk',
    'KVKK / GDPR',
    'Siber hukuk',
    'Kamu politikası',
    'Lobbying',
    'Patent / Fikri mülkiyet',
  ],
  'Üretim, Enerji & Lojistik': [
    'Endüstri 4.0',
    'Üretim mühendisliği',
    'Enerji sistemleri',
    'Lojistik planlama',
    'Satın alma',
    'Kalite yönetimi',
    'Bakım mühendisliği',
  ],
  'Medya, İletişim & Eğitim': [
    'Video prodüksiyon',
    'Podcast',
    'PR / İletişim',
    'Eğitim teknolojileri',
    'Kurumsal eğitmenlik',
    'Yayıncılık',
    'Çeviri / Lokalleştirme',
  ],
};

final Set<String> kAllProfessionalCatalogTags = {
  for (final list in kProfessionalTagsByIndustry.values) ...list,
};

const List<String> kLookingForLabels = [
  'Internship',
  'Co-founder',
  'Collaboration',
  'Mentor',
  'Hiring',
  'Networking',
  'Investors',
  'Freelance',
  'Team member',
];

const int kElevatorPitchMaxLength = 220;

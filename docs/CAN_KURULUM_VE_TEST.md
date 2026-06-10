# Can — Kurulum ve end-to-end test

Selçuk telefonda build hazır. Senin telefonunda aynı `dev` branch ile test edeceğiz.

---

## A. Kurulum (Mac + iPhone)

### 1. Kodu çek

```bash
cd /path/to/vexa-project   # repo kökü (frontend değil, üst klasör)
git checkout dev
git pull origin dev
```

### 2. iPhone’u hazırla

- USB ile Mac’e bağla
- Telefonda **Bu bilgisayara güven**
- UDID Apple Developer team’de (`3C3C9222D2`) kayıtlı olmalı  
  (Xcode → Window → Devices and Simulators)

### 3. Uygulamayı yükle

```bash
cd frontend
flutter devices              # cihaz ID’ni kopyala
./tool/ios_run_device.sh <SENIN_DEVICE_ID>
```

İlk açılışta: **Ayarlar → Genel → VPN ve Cihaz Yönetimi** → geliştirici sertifikasına güven.

### 4. Giriş

- **Kendi Google hesabın** ile giriş (Selçuk’tan farklı hesap şart)
- Production API: `https://vexa-backend-umg2.onrender.com/api`

---

## B. Profil hazırlığı (Selçuk ile uyumlu)

| Adım | Ne yap |
|------|--------|
| LilyGO | İsteğe bağlı (match için şart değil) |
| Sosyal profil | Boy, kilo, cinsiyet, eğitim |
| İlgi alanları | Selçuk ile **en az 2 ortak** seç (ör. Teknoloji + Müzik) |
| Mod | **Social** |
| Kaydet | Hata çıkmamalı |

### Quiz

1. Sosyal profil → **İlgi alanı quizi** kartı
2. **Quize başla** → tüm soruları bitir
3. Profil sunucuya gitsin (quiz cevapları `bio` içinde)

---

## C. Match + quiz testi

**Selçuk ile aynı anda veya sırayla:**

1. Ana ekran → **Geçmiş**
2. Sağ üst **insan ikonu** → **Adaylar**
3. Karşı taraf listede görünmeli
4. **Kontrol** → skor ≥ 50 → “Eşleşme!”
5. **Quize geç** (veya quiz ikonu) → uyum %’si (hedef ≥ 80)
6. Geçmiş’i yenile → kayıt listede

**İpucu:** Yüksek quiz uyumu için ortak sorularda benzer cevaplar seçin.

---

## D. VEXA Finder (demo)

1. **Ayarlar** → **VEXA Finder**
2. **Uyarıyı dene (demo)** → mavi-mor tam ekran + telefon titreşimi
3. **İncele** → Adaylar ekranına gider

Titreşim motoru firmware’e gelince LilyGO da otomatik titreşecek (`def3` setting `0x05`).

---

## E. Sorun giderme

| Sorun | Çözüm |
|-------|--------|
| Kurulum olmuyor | UDID team’de mi? USB güven? |
| Aday listesi boş | İkiniz de giriş yaptınız mı? `git pull` son build mi? |
| Quiz karşılaştırılamıyor | İkiniz de quizi bitirdiniz mi? |
| Google giriş hata | İnternet + aynı production API |

---

## F. Bug bildirimi

Test sırasında not al:

- Ekran adı + ne yaptın + ne oldu / ne bekliyordun
- Mümkünse ekran görüntüsü

Selçuk ile birlikte bug fix turuna geçilecek.

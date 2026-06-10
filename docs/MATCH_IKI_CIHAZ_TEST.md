# VEXA — İki telefon eşleşme testi (Selçuk + Can)

## Yol haritası

1. **Şimdi:** Can’ın telefonuna uygulama + iki hesap ile match testi
2. **Sonra:** Quiz akışı
3. **Son:** Kalan bug fix’ler

---

## 1. Can’ın telefonuna kurulum (iOS)

### Gerekenler

- Can’ın iPhone’u USB ile Mac’e
- Apple Developer Team: `3C3C9222D2` (Can’ın cihaz UDID’si team’e eklenmeli)
- Xcode → Settings → Accounts → team’de cihaz görünmeli

### Kurulum

```bash
cd frontend
flutter devices                    # Can’ın cihaz ID’sini bul
./tool/ios_run_device.sh           # veya:
flutter build ios --profile
flutter install -d <CAN_DEVICE_ID>
```

**Not:** Her kullanıcı **kendi Google hesabı** ile giriş yapmalı (farklı JWT = farklı kullanıcı).

---

## 2. Her iki telefonda hazırlık

| Adım | Selçuk | Can |
|------|--------|-----|
| Giriş | Google (kendi hesabın) | Google (kendi hesabı) |
| Profil | İsim, doğum, avatar | Aynı |
| LilyGO | İsteğe bağlı (match için şart değil) | İsteğe bağlı |
| Sosyal profil | Boy, kilo, **en az 1 ilgi alanı** | Aynı |
| Mod | **Social** seçili kalsın | **Social** |

### Eşleşme için önemli

Backend skoru şöyle hesaplar:

- Ortak ilgi alanı: **+25** (her biri)
- Ortak kişilik etiketi: **+15**
- Aynı mod (social): **+20**
- **≥ 50** → eşleşme (`detected`)

**Pratik:** İkiniz de **en az 2 ortak ilgi** seçin (ör. Teknoloji + Müzik) → %50+ garanti.

Sosyal profili kaydettikten sonra sunucuya gittiğinden emin ol (kaydet → hata yok).

---

## 3. Quiz hazırlığı (her iki telefon)

1. Sosyal mod → profil sekmesi → **İlgi alanı quizi** kartı
2. Seçtiğin her ilgi alanı için 5 soru (toplam docx kataloğu: 10 kategori × 5 soru)
3. Bitince “Quiz tamam” mesajı; cevaplar sunucuya `bio` JSON ile gider

**Önemli:** Quiz karşılaştırması için ikiniz de **ortak ilgi alanlarında** quizi bitirmiş olmalısınız.

---

## 4. Match + quiz testi (uygulama)

1. Ana ekran → **Geçmiş**
2. Sağ üst **insan ikonu** → **Adaylar**
3. Karşı taraf listede görünmeli (Can / Selçuk)
4. **Kontrol** → skor ve “Eşleşme!” diyaloğu (≥ 50)
5. Diyalogda **Quize geç** veya satırdaki quiz ikonu
6. Ortak ilgilerde cevap uyumu — hedef **≥ %80**
7. Geçmiş’e dön → yenile → match kaydı listede

Her iki telefondan da bir kez **Kontrol** + **Quiz** yapılabilir.

---

## 5. Sorun giderme

| Sorun | Çözüm |
|-------|--------|
| Aday listesi boş | İkinci kullanıcı kayıt oldu mu? Aynı production API mi? |
| Skor düşük | Ortak ilgi ekle; ikisi de Social modda olsun |
| Geçmiş boş | Skor ≥ 50 olmalı; Kontrol sonrası yenile |
| Quiz karşılaştırılamıyor | İkiniz de ortak ilgilerde quizi bitirin; profili kaydet |
| Quiz düşük çıktı | Normal — farklı cevaplar düşük uyum verir; test için benzer seç |
| Can’a kurulum olmuyor | UDID Xcode’a ekle; güven “Bu bilgisayara güven” |

---

## 6. Sonraki adımlar

- [x] Quiz UI (docx kataloğu → `assets/quiz/quiz_catalog.json`)
- [ ] BLE yakınlık (ileride)
- [ ] Bug fix turu

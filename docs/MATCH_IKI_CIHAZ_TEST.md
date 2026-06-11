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

## 3. Canlı eşleşme + quiz akışı (senaryo)

Quiz profilde değil — **eşleşme anında canlı** oynanır:

1. **Tetikleme (iki yol):**
   - **Yakınlık taraması** (Ayarlar → VEXA Finder → anahtar açık): telefon
     **20 sn’de bir** BLE’de VEXA cihazı arar; cihaz görülünce tanışma
     filtrelerinden geçen adaylarla otomatik eşleşme kontrolü yapılır.
   - **Manuel:** Geçmiş → **Adaylar** → **Kontrol** (skor ≥ 50 → eşleşme)
2. **Tanışma filtresi kapısı:** Karşı taraf senin filtrelerine (yaş, boy,
   kilo, cinsiyet, eğitim, sigara/alkol) **tam uymuyorsa** o telefonda davet
   çıkmaz. İki telefon da kendi filtresini uyguladığı için karşılıklı uyum
   şartı sağlanır.
3. **Davet:** LilyGO titrer (firmware ile ekranda **QUIZ TIME**) ve iki
   telefonda da pop-up: *“Eşleşme var! Quize geçmek ister misin?”* —
   **Quize geç / Şimdilik geç** (Hayır → ana ekrana dönülür).
4. **Quiz:** Havuzdan ortak ilgi alanlarına göre **5 soru** (iki telefonda
   birebir aynı). İkisi de bitirince karşılaştırılır:
   - **≥ %80 (5’te 4)** → **Minecraft pusulası**: “X bu yönde, birbirinize
     doğru yürüyün!” Arka plan rengi eşleşmeye özel **random** ama iki
     telefonda **aynı** — kalabalıkta birbirinizi renkten tanıyın.
   - Altında → üzgün surat: “Maalesef birbirinize uygun değilsiniz.”
5. **Eşleşme molası:** Quiz bitince (sonuç ne olursa olsun) iki cihazda da
   **2 saat** yeni eşleşme olmaz. Test için: Ayarlar → VEXA Finder →
   “Sıfırla”.

**Notlar:**

- Pusula ibresi şimdilik demo animasyon; gerçek yön LilyGO BLE ile gelecek.
- Yakınlık taraması şimdilik “herhangi bir VEXA cihazı yakında” sinyali
  kullanır; firmware yayına kullanıcı kimliği ekleyince kişiye özel olacak.
- Aynı eşleşmeyi tekrar test etmek için ikiniz de quizi yeniden bitirin
  (eski cevaplar üzerine yazılır) ve molayı sıfırlayın.

---

## 4. Test senaryosu (önerilen)

1. İki telefon da açık, uygulama **ön planda**, ana ekranda
2. Selçuk: Adaylar → Can → **Kontrol** → Eşleşme diyaloğu → **Quize geç**
3. Can’ın telefonunda ~12 sn içinde pop-up → **Quize geç**
4. İkiniz de 5 soruyu cevaplayın — testte **aynı cevapları** verin (≥ 4/5)
5. İki telefonda da pusula ekranı açılmalı
6. İkinci tur: 2+ farklı cevap verin → “bu sefer olmadı” ekranını doğrulayın

---

## 5. Sorun giderme

| Sorun | Çözüm |
|-------|--------|
| Aday listesi boş | İkinci kullanıcı kayıt oldu mu? Aynı production API mi? |
| Skor düşük | Ortak ilgi ekle; ikisi de Social modda olsun |
| Geçmiş boş | Skor ≥ 50 olmalı; Kontrol sonrası yenile |
| Pop-up gelmedi | Uygulama ön planda mı? Eşleşme son 5 dk içinde mi? ~12 sn bekle |
| Sonuç açılmıyor | Karşı taraf 5 soruyu bitirdi mi? İnternet var mı? |
| Quiz düşük çıktı | Normal — farklı cevaplar düşük uyum verir; test için aynı cevapları verin |
| Can’a kurulum olmuyor | UDID Xcode’a ekle; güven “Bu bilgisayara güven” |

---

## 6. Sonraki adımlar

- [x] Quiz UI (docx kataloğu → `assets/quiz/quiz_catalog.json`)
- [ ] BLE yakınlık (ileride)
- [ ] Bug fix turu

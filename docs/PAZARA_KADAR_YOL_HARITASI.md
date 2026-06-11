# VEXA — Yol haritası

**HEDEF: MVP Cuma (12 Haziran) akşamı bitmiş olacak. Cumartesi tam gün test.**

---

## MVP "bitti" sayılır — kontrol listesi

Aşağıdakilerin hepsi 3 cihazla çalışıyorsa MVP tamamdır:

- [ ] Google ile giriş + profil + avatar → LilyGO'ya aktarım
- [ ] Tanışma filtreleri seçimi (sunucuya gidiyor)
- [ ] Yakınlık taraması açık → iki telefonda **otomatik pop-up** + LilyGO titreşimi
- [ ] Quiz: iki telefonda aynı 5 soru → sonuç sunucudan
- [ ] ≥ %80 → iki telefonda **aynı renkte** pusula
- [ ] < %80 → üzgün surat ekranı
- [ ] Quiz sonrası **2 saat mola** (iki cihazda da; Kontrol + tarama + pop-up kilitli)
- [ ] Filtre uyuşmazsa davet çıkmıyor
- [ ] LilyGO: avatar + saat + ayarlar + `0x05` titreşim hepsi aynı firmware'de

---

## Cuma planı (MVP bitirme günü)

### Sabah — Can (firmware)

| # | İş | Not |
|---|----|-----|
| 1 | `git pull origin dev` | Gece push'lanan pulse entegrasyonu |
| 2 | `0x06` QUIZ TIME komutu | Titreşim + ekranda büyük "QUIZ TIME" (~10 sn) |
| 3 | 3 cihaza güncel firmware | Her cihaz benzersiz BLE adıyla |
| 4 | (Yetişirse) Yayına kullanıcı kimliği | `VEXA-<kısaId>` — yetişmezse MVP'yi bloklamaz |

### Gündüz — Selçuk + Cursor

| # | İş | Not |
|---|----|-----|
| 1 | Network modu revizesi | Selçuk anlatır → Cursor uygular |
| 2 | `0x06` gelirse uygulamaya bağlama | 10 dk — tek satır değişiklik hazır |
| 3 | 2 telefon + 3 cihazla ilk E2E koşusu | Kontrol listesi yukarıda |
| 4 | Çıkan bugları anında fix + yeniden kurulum | Cursor canlı düzeltir |

### Akşam — kapanış

- Kontrol listesi yeşil → **MVP bitti** etiketi (git tag `mvp-v1`)
- Cumartesi test senaryoları yazılı hazır

## Cumartesi — test günü

1. Tam akış × 5+ tekrar (başarılı / başarısız quiz, mola, sıfırlama)
2. Filtre kombinasyonları (yaş/boy/cinsiyet daralt → davet çıkmamalı)
3. Kötü koşullar: BLE kapalı, internet yok, uygulama arka planda, Render cold start
4. 3. cihaz karışıklık testi: yanlış cihaz titremiyor mu?
5. Bug listesi → öncelik sırala → kritik olanlar aynı gün fix

---

## MVP SONRASI — pazara kadar (2-3 hafta)

| Öncelik | Konu | Durum |
|---------|------|--------|
| P0 | Push bildirim (FCM/APNs) — uygulama kapalıyken eşleşme | Yok |
| P0 | Apple Sign-In backend doğrulaması | Buton var, backend eksik |
| P0 | Apple Developer Program ($99/yıl) kararı | TestFlight/Store için şart |
| P1 | Arka plan BLE/yoklama (push ile birlikte) | Yok |
| P1 | Crash raporlama (Sentry/Crashlytics) | Yok |
| P1 | Render paralı plan (cold start çözümü) | Free tier |
| P1 | Ghost mod sunucu sync | UI only |
| P1 | Pusula gerçek yön (RSSI sıcak-soğuk v1) | Demo ibre |
| P2 | Gizlilik politikası + KVKK + store görselleri | Yok |
| P2 | Profil normalize (bio JSON → tablolar) | Köprü çalışıyor |
| P2 | Token yenileme, rate limiting | Temel seviye |
| P3 | Android / Play Store | Test edilmedi |

---

## Durum özeti

- **MVP/demo:** ~%90 → Cuma akşamı %100 hedef
- **Store'da yayınlanabilir v1:** ~%60-65 → 2-3 hafta

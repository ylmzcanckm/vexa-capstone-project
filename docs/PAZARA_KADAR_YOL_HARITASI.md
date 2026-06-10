# VEXA — Pazara kadar yol haritası

**Bugün (Can ile):** Kurulum → match + quiz E2E → bug listesi  
**Pazara kadar:** Aşağıdaki MVP+ maddeler + VEXA Finder donanım entegrasyonu

---

## Bugün bitirilecekler

| # | Görev | Kim |
|---|--------|-----|
| 1 | `git pull origin dev` + iOS kurulum | Can |
| 2 | İki hesap, 2 ortak ilgi, Social mod | İkiniz |
| 3 | Quiz tamamla (her telefon) | İkiniz |
| 4 | Adaylar → Kontrol → Quiz → Geçmiş | İkiniz |
| 5 | Bug notları | İkiniz |

Rehber: `docs/CAN_KURULUM_VE_TEST.md`, `docs/MATCH_IKI_CIHAZ_TEST.md`

---

## Pazara kadar — MVP+ (ürün)

| Öncelik | Konu | Durum | Not |
|---------|------|--------|-----|
| P0 | Match + quiz E2E | Test ediliyor | Bug fix turu |
| P0 | Bug fix turu | Bekliyor | Bugünkü test sonrası |
| P1 | **VEXA Finder** UI | ✅ Demo hazır | Ayarlar → VEXA Finder → Uyarıyı dene |
| P1 | VEXA Finder BLE yakınlık | Bekliyor | ~15 m algı → otomatik uyarı |
| P1 | LilyGO titreşim pulse (`0x05`) | Firmware | Can — `DEVICE_SETTINGS_BLE.md` |
| P1 | Hesap silme canlı API | Kontrol | `DELETE /users/me` Render deploy |
| P2 | Push bildirim (FCM) | Yok | Match / Finder için |
| P2 | Apple Sign-In | Yok | App Store gereksinimi |
| P2 | Ghost mod sunucu sync | Yok | Şu an UI only |
| P2 | Discovery filtreleri backend | Yok | Local Riverpod |
| P3 | Profil normalize tablolar | Yok | `bio` JSON köprüsünden çıkış |

---

## VEXA Finder — nasıl çalışacak

```text
Uyumlu kullanıcı ~15 m yakın (BLE)
        ↓
LilyGO titreşir (motor + firmware 0x05)
        ↓
Telefon: mavi-mor tam ekran uyarı
        ↓
İncele → Adaylar / match akışı
        ↓
Quiz ≥ %80 → tanışma
```

**Şimdi:** Demo butonu + telefon haptics + güçlü titreşim ayarı BLE’ye yazma denemesi  
**Motor gelince:** Can `0x05` pulse implement eder → otomatik tetikleme servisi bağlanır

---

## Demo günü konuşma metni (yatırımcı / pazar)

1. Google ile giriş, profil, LilyGO avatar
2. Social mod, ilgi alanları, quiz
3. İki telefon match + quiz uyumu
4. VEXA Finder demo (yakınlık vizyonu)
5. Bilinen sınırlar: BLE menzil algoritması ve push henüz üretim seviyesinde değil

---

## Sıra özeti

```text
[Bugün]     Can kurulum → E2E test → bug listesi
[Bu hafta]  Bug fix → Finder firmware pulse → hesap silme doğrula
[Pazar öncesi] Push + Apple Sign-In değerlendir → Store build
```

# VEXA MVP — Pazar hazırlık listesi

**Hedef demo akışı:**

```text
Google giriş → Cihaz (BLE veya simülasyon) → Profil → Avatar → Mod → Geçmiş
```

Production API: `https://vexa-backend-umg2.onrender.com/api`  
Branch: `dev`

---

## MVP’de çalışması gerekenler

| # | Özellik | Platform | Backend |
|---|---------|----------|---------|
| 1 | Google OAuth + JWT | Web + Mobil | ✅ |
| 2 | Profil kaydet / oku (`bio` köprüsü) | Web + Mobil | ✅ |
| 3 | Avatar (DiceBear seed + sunucu) | Web + Mobil | ✅ |
| 4 | Mod kaydet (`social` / `networking`) | Web + Mobil | ✅ |
| 5 | Cihaz eşleme `POST /devices/pair` | Mobil + Sim web | ✅ |
| 6 | BLE avatar → LilyGO (VX protokol) | **Mobil only** | Firmware |
| 7 | Geçmiş `GET /matches/history` | Web + Mobil | ✅ |
| 8 | Ayarlar (bildirim, gizlilik, tema…) | Yerel prefs | — |
| 9 | Logout / tekrar giriş profil sync | Web + Mobil | ✅ |

---

## Demo öncesi test (Selçuk)

### Web (Chrome)

```bash
cd frontend && flutter run -d chrome --web-port=7357
```

- [ ] Google Console: `http://localhost:7357` origin
- [ ] Google ile giriş
- [ ] Profil + avatar tamamla
- [ ] Mod değiştir (Social / Business)
- [ ] Geçmiş ekranı açılır (boş liste OK)
- [ ] Logout → tekrar giriş → onboarding tekrar sormamalı

### Mobil (iPhone / Android)

```bash
flutter run -d <device_id>
```

- [ ] Bluetooth izni
- [ ] Cihaz tara → seç → avatar gönder
- [ ] LilyGO ekranda avatar (firmware hazırsa)
- [ ] Simülasyon ile devam (firmware yoksa)

---

## Arkadaş (firmware)

1. `docs/DEVICE_BLE_AVATAR_PROTOCOL.md` — START/DATA/END
2. nRF Connect → gerçek UUID → `vexa_ble_config.dart`
3. 128×128 RGB565 ST7789 çizim

---

## MVP dışı (Pazar sonrası)

- Apple Sign-In (`APPLE_CLIENT_ID`)
- `GET /matches/candidates` + quiz UI
- Ayarların sunucuya yazılması
- Hesap silme API
- Profil şeması (`bio` JSON’dan ayrı tablolar)
- Push bildirim (FCM)

---

## Bilinen sınırlar (demo’da söyle)

- Ghost mod backend’e yazılmaz (sadece UI)
- Ayarlar cihazda kalır, sunucuda değil
- Web’de BLE yok → simülasyon
- Avatar LilyGO’da firmware gerektirir

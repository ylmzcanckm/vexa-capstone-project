# VEXA — Cihaz ayarları BLE protokolü (Can)

Flutter **Cihaz ayarları** ekranından `def3` üzerinden LilyGO'ya yazar.

| Rol | UUID |
|-----|------|
| Cihaz ayarları write | `12345678-1234-5678-1234-56789abcdef3` |

### Paket formatı (öneri)

Magic: `V` `X` — avatar/saat ile tutarlı.

```text
[V][X][0x20][setting u8][value u8][flags u8]
```

| setting | value | Anlam |
|---------|-------|--------|
| `0x01` | `0` Güçlü, `1` Hafif, `2` Kapalı | Titreşim |
| `0x02` | `0–100` | Parlaklık (manuel) |
| `0x03` | `0`/`1` | Otomatik parlaklık açık/kapalı |
| `0x04` | `10`, `30`, `255` | Ekran zaman aşımı (sn; 255 = always on) |
| `0x05` | `1` | **VEXA Finder** tek seferlik titreşim pulse (yakınlık uyarısı) |

**Firmware pseudocode:**

```c
case 0x20:
  switch (data[3]) {
    case 0x01: set_vibration(data[4]); break;
    case 0x02: set_backlight(data[4]); break;
    case 0x03: auto_brightness = data[4]; break;
    case 0x04: screen_timeout_sec = data[4]; break;
  }
  apply_settings();
  break;
```

## Flutter (✅ bağlı)

- `vexa_ble_config.dart` → `settingsCharacteristicUuid` (`...def3`)
- Ayar değişince `BleAvatarTransferService.scanConnectAndSyncSettings()`
- Paket: `BleAvatarProtocol.buildDeviceSetting()` → `[V][X][0x20][setting][value][flags]`
- Parlaklık slider: %20–100 eşlemesi
- Ekran kapanma: 10 / 30 / `0xFF` (sürekli)

## Test

1. Flutter parlaklık kaydır → serial'de `VX 0x20` setting `0x02`
2. LilyGO ekran parlaklığı değişmeli

---

İsteğe bağlı (ileride): pil seviyesi `def3` **notify** veya ayrı `...def4` read.

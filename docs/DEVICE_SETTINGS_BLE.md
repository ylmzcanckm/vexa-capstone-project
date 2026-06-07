# VEXA — Cihaz ayarları BLE protokolü (Can)

Flutter **Cihaz ayarları** ekranında titreşim, parlaklık ve ekran zaman aşımı gösterilir. Şu an tercihler **yalnızca telefonda** saklanır; LilyGO'ya yazılmadığı için parlaklık vb. cihazda değişmez.

## Yapılacak (firmware)

Yeni characteristic önerisi (aynı servis `...def0`):

| Rol | UUID (öneri) |
|-----|----------------|
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

## Flutter (siz firmware hazır olunca)

1. `vexa_ble_config.dart` → `settingsCharacteristicUuid`
2. Ayar değişince `BleDeviceSettingsService.pushSettings()` → `def3` write
3. Bağlantıda mevcut tercihleri bir kez gönder

## Test

1. Flutter parlaklık kaydır → serial'de `VX 0x20` setting `0x02`
2. LilyGO ekran parlaklığı değişmeli

---

İsteğe bağlı (ileride): pil seviyesi `def3` **notify** veya ayrı `...def4` read.

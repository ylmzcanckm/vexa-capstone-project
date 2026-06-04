# VEXA — BLE avatar aktarım protokolü (Yol 2)

**Amaç:** Flutter uygulaması DiceBear PNG’yi indirir → RGB565 bitmap → LilyGO T-Display S3 ekranına BLE ile yazar.

**Firmware sorumlusu:** Donanım ekibi (UUID’ler nRF Connect ile doğrulanınca `vexa_ble_config.dart` güncellenir).

---

## UUID’ler (varsayılan — değiştirilebilir)

| Rol | UUID |
|-----|------|
| Service | `12345678-1234-5678-1234-56789abcdef0` |
| Avatar write | `12345678-1234-5678-1234-56789abcdef1` |

Özellik: **Write** veya **Write Without Response**.

---

## Paket formatı

Tüm paketler: `0x56 0x58` (`V` `X`) magic ile başlar.

### START (0x01)

```text
[V][X][0x01][width u16 LE][height u16 LE][byteLength u32 LE]
```

Örnek: 128×128 RGB565 → `byteLength = 128 * 128 * 2 = 32768`

### DATA (0x02)

```text
[V][X][0x02][seq u16 LE][payload...]
```

- `seq`: 0, 1, 2, …
- `payload`: ham RGB565 parçası (önerilen ≤ 240 byte / paket)

### END (0x03)

```text
[V][X][0x03]
```

Cihaz buffer’ı tamamlayınca LCD’ye çizer.

---

## RGB565

- Piksel sırası: satır satır, soldan sağa
- Little-endian: `low byte, high byte` per pixel
- Format: `(R5 << 11) | (G6 << 5) | B5`
- Şeffaf PNG: beyaz zemin üzerine alpha blend (Flutter tarafı)

---

## Firmware pseudocode

```c
on_ble_write(data, len):
  if data[0]=='V' && data[1]=='X':
    switch data[2]:
      case 0x01: parse width, height, total; allocate buffer
      case 0x02: copy payload to buffer at seq * chunk_size (veya sıralı append)
      case 0x03: draw_rgb565(buffer, width, height); free buffer
```

---

## Test

1. Flutter: Cihaz bağlantısı → tara → LilyGO seç → “Bağlan ve avatar gönder”
2. Serial log’da START / DATA seq / END görülmeli
3. Ekranda 128×128 avatar

---

## Referans (Flutter)

- `lib/features/device/ble/vexa_ble_config.dart`
- `lib/features/device/ble/ble_avatar_protocol.dart`
- `lib/features/device/data/avatar_bitmap_service.dart`
- `lib/features/device/data/ble_avatar_transfer_service.dart`

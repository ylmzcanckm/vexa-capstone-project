#!/usr/bin/env bash
# iPhone'a VEXA — profile build (ikonla açılınca çökmez).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
export COPYFILE_DISABLE=1
chmod +x ios/strip_codesign_xattrs.sh 2>/dev/null || true

DEVICE="${1:-}"

echo "=== 1/4 Bağımlılıklar ==="
flutter pub get
cd ios && pod install && cd ..

echo "=== 2/4 Build klasörü (/tmp — imza sorunu için) ==="
rm -f build
mkdir -p /tmp/vexa_build
ln -sf /tmp/vexa_build build
if [ ! -d /tmp/vexa_build ]; then
  echo "HATA: /tmp/vexa_build oluşturulamadı"
  exit 1
fi

echo "=== 3/4 Derleme (profile) ==="
flutter build ios --profile

echo "=== 4/4 Telefona yükleme ==="
if [ -z "$DEVICE" ]; then
  flutter install
else
  flutter install -d "$DEVICE"
fi

echo ""
echo "Tamam. Telefonda VEXA ikonuna bas."
echo "Güven: Ayarlar → Genel → VPN ve Cihaz Yönetimi"
echo ""
echo "BLE test: Giriş → Cihaz bağlantısı → VEXA-B4DC → Bağlan ve avatarı gönder"

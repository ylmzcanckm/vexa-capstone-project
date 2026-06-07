#!/usr/bin/env bash
# iOS Google OAuth — Info.plist + app_config senkronu.
# Kullanım: ./tool/sync_google_ios_plist.sh 74651460819-XXXX.apps.googleusercontent.com
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IOS_ID="${1:-}"

if [[ -z "$IOS_ID" ]]; then
  echo "Kullanım: $0 <iOS_OAuth_Client_ID>"
  echo "Örnek: $0 74651460819-abc123.apps.googleusercontent.com"
  echo ""
  echo "Google Cloud → APIs & Services → Credentials → Create OAuth client ID → iOS"
  echo "Bundle ID: com.selcukbuyukpoyraz.vexa"
  exit 1
fi

if [[ "$IOS_ID" == *"eolahk2dks1r9odgo5mjehpafgmetbeq"* ]]; then
  echo "HATA: Bu Web client ID. iOS tipinde ayrı bir client oluştur."
  exit 1
fi

SCHEME="com.googleusercontent.apps.${IOS_ID%.apps.googleusercontent.com}"
PLIST="$ROOT/ios/Runner/Info.plist"

if /usr/libexec/PlistBuddy -c "Print :GIDClientID" "$PLIST" &>/dev/null; then
  /usr/libexec/PlistBuddy -c "Set :GIDClientID $IOS_ID" "$PLIST"
else
  /usr/libexec/PlistBuddy -c "Add :GIDClientID string $IOS_ID" "$PLIST"
fi
if /usr/libexec/PlistBuddy -c "Print :CFBundleURLTypes" "$PLIST" &>/dev/null; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleURLTypes:0:CFBundleURLSchemes:0 $SCHEME" "$PLIST"
else
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes array" "$PLIST"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0 dict" "$PLIST"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleTypeRole string Editor" "$PLIST"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes array" "$PLIST"
  /usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:0:CFBundleURLSchemes:0 string $SCHEME" "$PLIST"
fi

CONFIG="$ROOT/lib/core/config/app_config.dart"
if grep -q "googleIosClientId = ''" "$CONFIG"; then
  sed -i '' "s|static const String googleIosClientId = '';|static const String googleIosClientId =\n      '$IOS_ID';|" "$CONFIG"
else
  sed -i '' "s|static const String googleIosClientId =.*|static const String googleIosClientId =\n      '$IOS_ID';|" "$CONFIG"
fi

echo "OK"
echo "  GIDClientID: $IOS_ID"
echo "  URL scheme:  $SCHEME"
echo ""
echo "Sonra: cd frontend && flutter build ios --profile && flutter install"

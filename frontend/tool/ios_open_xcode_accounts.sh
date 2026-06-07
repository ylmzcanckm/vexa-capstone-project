#!/usr/bin/env bash
# Xcode'u açar ve Ayarlar penceresini açar (Accounts sekmesine sen tıklarsın).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
open "$ROOT/ios/Runner.xcworkspace"
osascript <<'EOF'
tell application "Xcode" to activate
delay 1.5
tell application "System Events"
  tell process "Xcode"
    keystroke "," using command down
  end tell
end tell
EOF
echo ""
echo "Xcode açıldı. Pencerede:"
echo "  1) Üstte 'Accounts' sekmesi"
echo "  2) Sol altta '+' → Apple ID ile giriş (yoksa)"
echo "  3) Apple ID satırına tıkla → sağda 'Personal Team' ve 'Team ID: XXXXX'"
echo "  4) Terminal: ./tool/ios_set_team.sh XXXXX"

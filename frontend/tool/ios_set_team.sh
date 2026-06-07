#!/usr/bin/env bash
# Kullanım: ./tool/ios_set_team.sh ABCDE12345
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TEAM_ID="${1:-}"
if [[ -z "$TEAM_ID" ]]; then
  echo "Team ID gerekli (10 karakter, örn. AB12CD34EF)"
  echo "Xcode → Settings (Cmd+,) → Accounts → Apple ID → Team ID"
  exit 1
fi
cat > "$ROOT/ios/Team.xcconfig" <<EOF
DEVELOPMENT_TEAM=$TEAM_ID
EOF
echo "Yazıldı: ios/Team.xcconfig"
echo "Sonra: cd frontend && flutter run"

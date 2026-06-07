#!/bin/bash
# macOS Sequoia+ com.apple.provenance imzayı bozar; ditto --norsrc ile kopyala.
set +e
strip_file() {
  local f="$1"
  [ -f "$f" ] || return 0
  local tmp="${f}.vexa_noxattr"
  ditto --norsrc "$f" "$tmp" 2>/dev/null || return 0
  chmod --reference="$f" "$tmp" 2>/dev/null
  mv -f "$tmp" "$f"
}

strip_tree() {
  local root="$1"
  [ -d "$root" ] || return 0
  find "$root" \( -name "*.framework" -o -name "*.dylib" -o -name "*.a" \) -type f 2>/dev/null | while read -r f; do
    strip_file "$f"
  done
  find "$root" -path "*/Flutter.framework/Flutter" -type f 2>/dev/null | while read -r f; do
    strip_file "$f"
  done
  find "$root" -path "*/native_assets/*" -type f 2>/dev/null | while read -r f; do
    strip_file "$f"
  done
  find "$root" -name "*.app" -type d 2>/dev/null | while read -r app; do
    find "$app" -type f -perm +111 2>/dev/null | while read -r f; do
      strip_file "$f"
    done
  done
}

ROOT="${1:-}"
if [ -n "$ROOT" ]; then
  strip_tree "$ROOT"
fi
strip_tree "${PROJECT_DIR}/../build"
strip_tree "${TARGET_BUILD_DIR}"
strip_tree "${BUILT_PRODUCTS_DIR}"
xattr -cr "${PROJECT_DIR}/../build" 2>/dev/null
exit 0

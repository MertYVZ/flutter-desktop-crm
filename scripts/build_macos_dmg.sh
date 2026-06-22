#!/usr/bin/env bash
#
# Build a release macOS .app and package it as a drag-to-Applications DMG.
#
# Usage:
#   ./scripts/build_macos_dmg.sh              # full build + DMG
#   ./scripts/build_macos_dmg.sh --skip-build # DMG only (requires existing Release .app)
#   ./scripts/build_macos_dmg.sh --ad-hoc-sign
#
# Optional environment variables:
#   CODESIGN_IDENTITY  Developer ID or "-" for ad-hoc (used with --ad-hoc-sign)
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SKIP_BUILD=0
AD_HOC_SIGN=0

usage() {
  cat <<'EOF'
Build Ok Teknik Metal CRM macOS release DMG.

Usage:
  ./scripts/build_macos_dmg.sh [options]

Options:
  --skip-build    Skip "flutter build macos --release" (use existing Release .app)
  --ad-hoc-sign   Ad-hoc codesign the .app before packaging (dev/local distribution)
  -h, --help      Show this help

Output:
  dist/Ok_Teknik_Metal_CRM_<version>_macos.dmg

Optional tools:
  brew install create-dmg   # nicer DMG layout; falls back to hdiutil if missing
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-build)
      SKIP_BUILD=1
      shift
      ;;
    --ad-hoc-sign)
      AD_HOC_SIGN=1
      shift
      ;;
    -h | --help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: macOS DMG packaging must run on macOS." >&2
  exit 1
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "Error: flutter is not on PATH." >&2
  exit 1
fi

read_app_metadata() {
  local app_info="$ROOT_DIR/macos/Runner/Configs/AppInfo.xcconfig"
  local pubspec="$ROOT_DIR/pubspec.yaml"

  if [[ ! -f "$app_info" ]]; then
    echo "Error: missing $app_info" >&2
    exit 1
  fi
  if [[ ! -f "$pubspec" ]]; then
    echo "Error: missing $pubspec" >&2
    exit 1
  fi

  APP_NAME="$(sed -n 's/^PRODUCT_NAME = //p' "$app_info" | head -n1)"
  BUNDLE_ID="$(sed -n 's/^PRODUCT_BUNDLE_IDENTIFIER = //p' "$app_info" | head -n1)"
  VERSION="$(grep -E '^version:' "$pubspec" | head -n1 | sed -E 's/^version:[[:space:]]*//' | cut -d'+' -f1)"

  if [[ -z "$APP_NAME" || -z "$BUNDLE_ID" || -z "$VERSION" ]]; then
    echo "Error: could not read app name, bundle id, or version." >&2
    exit 1
  fi
}

read_app_metadata

APP_BASENAME="${APP_NAME}.app"
BUILD_DIR="$ROOT_DIR/build/macos/Build/Products/Release"
APP_PATH="$BUILD_DIR/$APP_BASENAME"
DIST_DIR="$ROOT_DIR/dist"
DMG_BASENAME="Ok_Teknik_Metal_CRM_${VERSION}_macos.dmg"
DMG_PATH="$DIST_DIR/$DMG_BASENAME"
STAGING_DIR=""

cleanup() {
  if [[ -n "$STAGING_DIR" && -d "$STAGING_DIR" ]]; then
    rm -rf "$STAGING_DIR"
  fi
}

trap cleanup EXIT

echo "==> App:        $APP_NAME"
echo "==> Bundle ID:  $BUNDLE_ID"
echo "==> Version:    $VERSION"
echo "==> App path:   $APP_PATH"
echo "==> DMG output: $DMG_PATH"

if [[ "$SKIP_BUILD" -eq 0 ]]; then
  echo "==> Building macOS release..."
  flutter build macos --release
else
  echo "==> Skipping flutter build (--skip-build)"
fi

if [[ ! -d "$APP_PATH" ]]; then
  echo "Error: Release app not found at:" >&2
  echo "  $APP_PATH" >&2
  echo "Run without --skip-build or build manually: flutter build macos --release" >&2
  exit 1
fi

if [[ "$AD_HOC_SIGN" -eq 1 ]]; then
  sign_identity="${CODESIGN_IDENTITY:--}"
  echo "==> Ad-hoc codesigning with identity: $sign_identity"
  codesign --force --deep --sign "$sign_identity" --options runtime "$APP_PATH"
  codesign --verify --deep --strict "$APP_PATH"
fi

mkdir -p "$DIST_DIR"
rm -f "$DMG_PATH"

create_dmg_with_create_dmg() {
  local volicon_args=()
  local app_icon="$APP_PATH/Contents/Resources/AppIcon.icns"

  if [[ -f "$app_icon" ]]; then
    volicon_args=(--volicon "$app_icon")
  fi

  create-dmg \
    --volname "$APP_NAME" \
    "${volicon_args[@]}" \
    --window-pos 200 120 \
    --window-size 660 400 \
    --icon-size 128 \
    --icon "$APP_BASENAME" 180 170 \
    --hide-extension "$APP_BASENAME" \
    --app-drop-link 480 170 \
    --no-internet-enable \
    "$DMG_PATH" \
    "$APP_PATH"
}

create_dmg_with_hdiutil() {
  STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/okteknikmetal-dmg.XXXXXX")"

  echo "==> Staging DMG contents in $STAGING_DIR"
  ditto "$APP_PATH" "$STAGING_DIR/$APP_BASENAME"
  ln -s /Applications "$STAGING_DIR/Applications"

  local temp_dmg="$DIST_DIR/.${DMG_BASENAME%.dmg}.temp.dmg"
  rm -f "$temp_dmg"

  echo "==> Creating compressed DMG with hdiutil..."
  hdiutil create \
    -volname "$APP_NAME" \
    -srcfolder "$STAGING_DIR" \
    -ov \
    -format UDRW \
    "$temp_dmg"

  hdiutil convert "$temp_dmg" -format UDZO -imagekey zlib-level=9 -o "$DMG_PATH"
  rm -f "$temp_dmg"
}

if command -v create-dmg >/dev/null 2>&1; then
  echo "==> Packaging DMG with create-dmg..."
  create_dmg_with_create_dmg
else
  echo "==> create-dmg not found; using hdiutil fallback"
  echo "    Tip: brew install create-dmg for a polished drag-to-Applications layout"
  create_dmg_with_hdiutil
fi

if [[ ! -f "$DMG_PATH" ]]; then
  echo "Error: DMG was not created at $DMG_PATH" >&2
  exit 1
fi

echo ""
echo "Done."
echo "  DMG: $DMG_PATH"
echo "  Size: $(du -h "$DMG_PATH" | awk '{print $1}')"

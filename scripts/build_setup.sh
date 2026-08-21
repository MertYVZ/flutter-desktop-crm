#!/usr/bin/env bash
#
# App Store olmadan birine atmak için: derle, imzala, setup üret, zip hazırla.
#
# Kullanım:
#   ./scripts/build_setup.sh
#
# Karşı tarafa atacağın dosya:
#   dist/Hurda_CRM_<version>_macos_kurulum.zip
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

STAGING_DIR=""

cleanup() {
  if [[ -n "$STAGING_DIR" && -d "$STAGING_DIR" ]]; then
    rm -rf "$STAGING_DIR"
  fi
}

trap cleanup EXIT

usage() {
  cat <<'EOF'
Hurda CRM'i birine atmak için kurulum paketi üretir (App Store yok).

Kullanım:
  ./scripts/build_setup.sh

Çıktı:
  dist/Hurda_CRM_<version>_macos_kurulum.zip

Zip'in içinde setup (.pkg) ve KURULUM.txt vardır. Karşı taraf zip'i açıp
.pkg'ye Control+tık → Aç desin.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ $# -gt 0 ]]; then
  echo "Unknown option: $1" >&2
  usage >&2
  exit 1
fi

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "Error: this setup must be built on a Mac." >&2
  exit 1
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "Error: flutter is not on PATH." >&2
  exit 1
fi

APP_INFO="$ROOT_DIR/macos/Runner/Configs/AppInfo.xcconfig"
PUBSPEC="$ROOT_DIR/pubspec.yaml"

if [[ ! -f "$APP_INFO" || ! -f "$PUBSPEC" ]]; then
  echo "Error: missing AppInfo.xcconfig or pubspec.yaml." >&2
  exit 1
fi

APP_NAME="$(sed -n 's/^PRODUCT_NAME = //p' "$APP_INFO" | head -n1)"
BUNDLE_ID="$(sed -n 's/^PRODUCT_BUNDLE_IDENTIFIER = //p' "$APP_INFO" | head -n1)"
VERSION="$(grep -E '^version:' "$PUBSPEC" | head -n1 | sed -E 's/^version:[[:space:]]*//' | cut -d'+' -f1)"

if [[ -z "$APP_NAME" || -z "$BUNDLE_ID" || -z "$VERSION" ]]; then
  echo "Error: could not read app name, bundle id, or version." >&2
  exit 1
fi

APP_PATH="$ROOT_DIR/build/macos/Build/Products/Release/${APP_NAME}.app"
DIST_DIR="$ROOT_DIR/dist"
PKG_NAME="Hurda_CRM_${VERSION}_macos_setup.pkg"
ZIP_NAME="Hurda_CRM_${VERSION}_macos_kurulum.zip"
PKG_PATH="$DIST_DIR/$PKG_NAME"
ZIP_PATH="$DIST_DIR/$ZIP_NAME"

echo "==> App:     $APP_NAME"
echo "==> Version: $VERSION"
echo "==> Zip:     $ZIP_PATH"

echo "==> Compiling macOS release..."
flutter build macos --release

if [[ ! -d "$APP_PATH" ]]; then
  echo "Error: Release app not found at $APP_PATH" >&2
  exit 1
fi

echo "==> Signing app for sharing..."
sign_item() {
  codesign --force --sign - --timestamp=none "$1"
}

if [[ -d "$APP_PATH/Contents/Frameworks" ]]; then
  while IFS= read -r -d '' item; do
    sign_item "$item"
  done < <(find "$APP_PATH/Contents/Frameworks" \( -name "*.dylib" -o -name "*.framework" \) -print0)
fi

if [[ -d "$APP_PATH/Contents/PlugIns" ]]; then
  while IFS= read -r -d '' item; do
    sign_item "$item"
  done < <(find "$APP_PATH/Contents/PlugIns" \( -name "*.dylib" -o -name "*.framework" -o -name "*.appex" \) -print0)
fi

codesign --force --sign - "$APP_PATH"
codesign --verify --strict "$APP_PATH"

mkdir -p "$DIST_DIR"
rm -f "$PKG_PATH" "$ZIP_PATH"

echo "==> Creating setup package..."
pkgbuild \
  --component "$APP_PATH" \
  --install-location /Applications \
  --identifier "$BUNDLE_ID" \
  --version "$VERSION" \
  "$PKG_PATH"

STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/hurdacrm-setup.XXXXXX")"
cp "$PKG_PATH" "$STAGING_DIR/$PKG_NAME"

cat > "$STAGING_DIR/KURULUM.txt" <<EOF
Hurda CRM ${VERSION} kurulumu
=============================

1. "${PKG_NAME}" dosyasına Control tuşu basılı tutarak tıklayın.
2. Aç'ı seçin.
3. Kurulum sihirbazını takip edin.
4. Uygulama Programlar (Applications) klasörüne kurulur.
5. Launchpad veya Programlar'dan "Hurda CRM"i açın.

macOS "geliştirici doğrulanamadı" veya "zararlı yazılım" derse:
- Dosyaya normal çift tıklamayın.
- Control + tık → Aç deyin.
- veya Sistem Ayarları → Gizlilik ve Güvenlik → Yine de Aç.

Bu paket App Store'dan gelmez; bu uyarı normaldir.
EOF

echo "==> Creating shareable zip..."
(
  cd "$STAGING_DIR"
  zip -X -q "$ZIP_PATH" "$PKG_NAME" KURULUM.txt
)

if [[ ! -f "$ZIP_PATH" ]]; then
  echo "Error: zip was not created at $ZIP_PATH" >&2
  exit 1
fi

echo ""
echo "Hazır. Karşı tarafa sadece bunu at:"
echo "  $ZIP_PATH"
echo "  Boyut: $(du -h "$ZIP_PATH" | awk '{print $1}')"
echo ""
echo "Karşı taraf zip'i açıp .pkg'ye Control+tık → Aç desin."
echo "App Store olmadığı için macOS bir kez uyarı gösterebilir; bu normal."

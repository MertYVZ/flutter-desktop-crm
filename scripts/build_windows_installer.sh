#!/usr/bin/env bash
#
# Build a release Windows app and package it as an Inno Setup installer (.exe).
#
# IMPORTANT: Full packaging requires Windows. On macOS/Linux this script validates
# paths and prints instructions; run build_windows_installer.ps1 on a Windows machine.
#
# Usage:
#   ./scripts/build_windows_installer.sh              # full build + installer (Windows only)
#   ./scripts/build_windows_installer.sh --skip-build # package existing Release build
#   ./scripts/build_windows_installer.sh --zip-only   # ZIP fallback only
#   ./scripts/build_windows_installer.sh --validate   # check metadata and script paths only
#
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SKIP_BUILD=0
ZIP_ONLY=0
VALIDATE_ONLY=0

usage() {
  cat <<'EOF'
Build Ok Teknik Metal CRM Windows release installer.

Usage:
  ./scripts/build_windows_installer.sh [options]

Options:
  --skip-build   Skip "flutter build windows --release"
  --zip-only     Create ZIP of Release build (no Inno Setup)
  --validate     Verify metadata and script paths (works on any OS)
  -h, --help     Show this help

On Windows, prefer PowerShell:
  .\scripts\build_windows_installer.ps1

Output:
  dist/Ok_Teknik_Metal_CRM_<version>_windows_setup.exe
  dist/Ok_Teknik_Metal_CRM_<version>_windows.zip   (fallback)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-build)
      SKIP_BUILD=1
      shift
      ;;
    --zip-only)
      ZIP_ONLY=1
      shift
      ;;
    --validate)
      VALIDATE_ONLY=1
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

read_app_metadata() {
  local app_info="$ROOT_DIR/macos/Runner/Configs/AppInfo.xcconfig"
  local pubspec="$ROOT_DIR/pubspec.yaml"
  local cmake="$ROOT_DIR/windows/CMakeLists.txt"
  local iss="$ROOT_DIR/scripts/windows_installer.iss"

  for f in "$app_info" "$pubspec" "$cmake" "$iss"; do
    if [[ ! -f "$f" ]]; then
      echo "Error: missing $f" >&2
      exit 1
    fi
  done

  APP_NAME="$(sed -n 's/^PRODUCT_NAME = //p' "$app_info" | head -n1)"
  VERSION="$(grep -E '^version:' "$pubspec" | head -n1 | sed -E 's/^version:[[:space:]]*//' | cut -d'+' -f1)"
  BINARY_NAME="$(sed -n 's/^set(BINARY_NAME "\(.*\)")/\1/p' "$cmake" | head -n1)"

  if [[ -z "$APP_NAME" || -z "$VERSION" || -z "$BINARY_NAME" ]]; then
    echo "Error: could not read app name, version, or binary name." >&2
    exit 1
  fi
}

read_app_metadata

RELEASE_DIR="$ROOT_DIR/build/windows/x64/runner/Release"
EXE_PATH="$RELEASE_DIR/${BINARY_NAME}.exe"
DIST_DIR="$ROOT_DIR/dist"
OUTPUT_BASENAME="Ok_Teknik_Metal_CRM_${VERSION}_windows_setup"
INSTALLER_PATH="$DIST_DIR/${OUTPUT_BASENAME}.exe"
ZIP_PATH="$DIST_DIR/Ok_Teknik_Metal_CRM_${VERSION}_windows.zip"
ISS_PATH="$ROOT_DIR/scripts/windows_installer.iss"

echo "==> App:           $APP_NAME"
echo "==> Version:       $VERSION"
echo "==> Executable:    $EXE_PATH"
echo "==> Installer out: $INSTALLER_PATH"
echo "==> ISS script:    $ISS_PATH"

if [[ "$VALIDATE_ONLY" -eq 1 ]]; then
  echo ""
  echo "Validation OK (metadata and script paths)."
  echo "Build the installer on Windows:"
  echo "  .\\scripts\\build_windows_installer.ps1"
  exit 0
fi

if [[ "$(uname -s)" != MINGW* && "$(uname -s)" != MSYS* && "$OSTYPE" != msys && "$OSTYPE" != cygwin ]]; then
  if [[ "$(uname -s)" == "Darwin" || "$(uname -s)" == "Linux" ]]; then
    echo ""
    echo "Error: Windows installer packaging must run on Windows." >&2
    echo "Use --validate to check script paths from this machine." >&2
    echo "On a Windows PC, run:" >&2
    echo "  .\\scripts\\build_windows_installer.ps1" >&2
    exit 1
  fi
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "Error: flutter is not on PATH." >&2
  exit 1
fi

if [[ "$SKIP_BUILD" -eq 0 ]]; then
  echo "==> Building Windows release..."
  flutter build windows --release
else
  echo "==> Skipping flutter build (--skip-build)"
fi

if [[ ! -f "$EXE_PATH" ]]; then
  echo "Error: Release executable not found at:" >&2
  echo "  $EXE_PATH" >&2
  echo "Run without --skip-build or build manually: flutter build windows --release" >&2
  exit 1
fi

mkdir -p "$DIST_DIR"

create_zip() {
  local dest="$1"
  echo "==> Creating ZIP archive: $dest"
  rm -f "$dest"
  if command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -NoProfile -Command \
      "Compress-Archive -Path '${RELEASE_DIR}\\*' -DestinationPath '${dest}' -Force"
  else
    (cd "$RELEASE_DIR" && zip -r "$dest" .)
  fi
}

find_iscc() {
  local candidates=(
    "/c/Program Files (x86)/Inno Setup 6/ISCC.exe"
    "/c/Program Files/Inno Setup 6/ISCC.exe"
  )
  for c in "${candidates[@]}"; do
    if [[ -f "$c" ]]; then
      echo "$c"
      return 0
    fi
  done
  if command -v ISCC.exe >/dev/null 2>&1; then
    command -v ISCC.exe
    return 0
  fi
  return 1
}

if [[ "$ZIP_ONLY" -eq 1 ]]; then
  create_zip "$ZIP_PATH"
  echo ""
  echo "Done."
  echo "  ZIP: $ZIP_PATH"
  exit 0
fi

if ! ISCC="$(find_iscc)"; then
  echo "==> Inno Setup (ISCC.exe) not found; creating ZIP fallback."
  echo "    Install Inno Setup 6: https://jrsoftware.org/isdl.php"
  create_zip "$ZIP_PATH"
  echo ""
  echo "Done (ZIP fallback)."
  echo "  ZIP: $ZIP_PATH"
  exit 0
fi

rm -f "$INSTALLER_PATH"

echo "==> Compiling installer with Inno Setup..."
echo "    ISCC: $ISCC"

"$ISCC" \
  "/DMyAppVersion=${VERSION}" \
  "/DSourceDir=${RELEASE_DIR}" \
  "/DOutputDir=${DIST_DIR}" \
  "/DOutputBaseFilename=${OUTPUT_BASENAME}" \
  "$ISS_PATH"

if [[ ! -f "$INSTALLER_PATH" ]]; then
  echo "Error: installer was not created at $INSTALLER_PATH" >&2
  exit 1
fi

echo ""
echo "Done."
echo "  Installer: $INSTALLER_PATH"
if command -v stat >/dev/null 2>&1; then
  echo "  Size: $(du -h "$INSTALLER_PATH" | awk '{print $1}')"
fi

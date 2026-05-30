#!/bin/bash
# ============================================================
#  Filza26Maker v2.1 — WSL / Linux / macOS ready
#  Converts Filza .deb → IPA  OR  uses a pre-built IPA directly
#  Compatible with iOS 17 / iOS 18 / iOS 26 (jailed sideload)
# ============================================================

set -eo pipefail

# ---- Detect environment ----------------------------------------
IS_WSL=false
if grep -qi microsoft /proc/version 2>/dev/null || \
   [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; then
  IS_WSL=true
fi

# ---- Output directory ------------------------------------------
if $IS_WSL; then
  WIN_USER="$(cmd.exe /c 'echo %USERNAME%' 2>/dev/null | tr -d '\r')"
  OUTPUT_DIR="/mnt/c/Users/${WIN_USER}/Desktop"
else
  OUTPUT_DIR="$(pwd)"
fi

IPA_NAME="Filza-Jailed-iOS26-Premium.ipa"
ARG1="${1:-}"

echo "================================================"
echo "  Filza26Maker v2.1"
echo "  Environment : $(if $IS_WSL; then echo WSL; else uname -s; fi)"
echo "  Output dir  : $OUTPUT_DIR"
echo "================================================"
echo

# ---- MODE A: pre-built IPA provided directly -------------------
if [[ -n "$ARG1" && "$ARG1" == *.ipa && -f "$ARG1" ]]; then
  echo "[ + ] Pre-built IPA detected: $ARG1"
  echo "[ i ] Skipping .deb conversion — copying IPA directly..."
  mkdir -p "$OUTPUT_DIR"
  cp -f "$ARG1" "$OUTPUT_DIR/$IPA_NAME"
  echo
  echo "[ + ] Done! IPA saved to: $OUTPUT_DIR/$IPA_NAME"
  echo "[ ! ] Unsigned. Use Sideloadly / AltStore / ESign to sign & install."
  exit 0
fi

# ---- MODE B: download .deb and convert -------------------------
DEB_URL="${ARG1:-https://tigisoftware.com/cydia/com.tigisoftware.filza_4.0.1-2_iphoneos-arm.deb}"
WORKDIR="$(mktemp -d)"
DEB_LOCAL="$WORKDIR/filza.deb"

echo "[ i ] DEB URL : $DEB_URL"
echo "[ i ] Workdir : $WORKDIR"
echo

# Check required tools
for TOOL in curl ar tar zip; do
  if ! command -v "$TOOL" >/dev/null 2>&1; then
    echo "[!] '$TOOL' not found."
    case "$TOOL" in
      ar|tar)  echo "    Install: sudo apt install binutils tar" ;;
      zip)     echo "    Install: sudo apt install zip" ;;
      curl)    echo "    Install: sudo apt install curl" ;;
    esac
    exit 1
  fi
done

# Download DEB
if [[ -f "$ARG1" && "$ARG1" != "$DEB_URL" ]]; then
  echo "[ i ] Using local file: $ARG1"
  cp "$ARG1" "$DEB_LOCAL"
else
  echo "[ i ] Downloading DEB..."
  curl -L --fail --progress-bar -o "$DEB_LOCAL" "$DEB_URL"
fi

cd "$WORKDIR"

echo "[ i ] Extracting .deb..."
ar -x "$DEB_LOCAL"

DATA_TAR="$(ls data.tar.* 2>/dev/null | head -n1 || true)"
if [[ -z "$DATA_TAR" ]]; then
  echo "[-] data.tar.* not found. Contents:"
  ar -t "$DEB_LOCAL"
  exit 1
fi

echo "[ i ] Found $DATA_TAR — extracting..."
mkdir data_extracted
tar -xf "$DATA_TAR" -C data_extracted

echo "[ i ] Searching for Filza.app..."
FILZA_APP_PATH="$(find data_extracted -type d -iname 'Filza.app' | head -n1 || true)"
if [[ -z "$FILZA_APP_PATH" ]]; then
  echo "[-] Filza.app not found. Top dirs:"
  find data_extracted -maxdepth 3 -type d | head -30
  exit 1
fi

echo "[ + ] Found: $FILZA_APP_PATH"
echo "[ i ] Building Payload..."
mkdir -p Payload
cp -R "$FILZA_APP_PATH" Payload/
rm -rf Payload/Filza.app/_CodeSignature 2>/dev/null || true
rm -f  Payload/Filza.app/embedded.mobileprovision 2>/dev/null || true

echo "[ i ] Creating IPA..."
zip -r "$IPA_NAME" Payload > /dev/null

mkdir -p "$OUTPUT_DIR"
cp -f "$IPA_NAME" "$OUTPUT_DIR/$IPA_NAME"
rm -rf "$WORKDIR"

echo
echo "[ + ] Done! IPA saved to: $OUTPUT_DIR/$IPA_NAME"
echo "[ ! ] Unsigned. Use Sideloadly / AltStore / ESign to sign & install."

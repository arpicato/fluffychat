#!/usr/bin/env bash

set -euo pipefail

APP_NAME="${APP_NAME:-FluffyChat}"
APP_ID="${APP_ID:-chat.fluffy.fluffychat}"
ARCH="${ARCH:-x86_64}"
ARTIFACT_DIR="${ARTIFACT_DIR:-build/appimage}"
APPDIR="${APPDIR:-build/appimage/AppDir}"
LINUX_BUNDLE_DIR="${LINUX_BUNDLE_DIR:-build/linux/x64/release/bundle}"
DESKTOP_FILE="${DESKTOP_FILE:-linux/fluffychat.desktop}"
ICON_FILE="${ICON_FILE:-assets/logo/img/logo_appimage_512.png}"
VERSION="${VERSION:-$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)}"
OUTPUT_NAME="${OUTPUT_NAME:-${APP_NAME}-${VERSION}-linux-${ARCH}.AppImage}"
LOG_DIR="${LOG_DIR:-/tmp/opencode}"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/fluffy_appimage_build.log}"
LINUXDEPLOY_BIN="${LINUXDEPLOY_BIN:-linuxdeploy}"

mkdir -p "$LOG_DIR" "$ARTIFACT_DIR"
rm -rf "$APPDIR"

if [[ ! -d "$LINUX_BUNDLE_DIR" ]]; then
  echo "Linux bundle not found at $LINUX_BUNDLE_DIR" | tee "$LOG_FILE"
  echo "Build it first with: bash scripts/build_linux_docker.sh" | tee -a "$LOG_FILE"
  exit 1
fi

mkdir -p "$APPDIR/usr"
cp -a "$LINUX_BUNDLE_DIR"/* "$APPDIR/usr/"
cp "$DESKTOP_FILE" "$APPDIR/$APP_ID.desktop"
cp "$ICON_FILE" "$APPDIR/fluffychat.png"

cat > "$APPDIR/AppRun" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
HERE="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="$HERE/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
export PATH="$HERE/usr/bin${PATH:+:$PATH}"
export GSETTINGS_SCHEMA_DIR="$HERE/usr/share/glib-2.0/schemas"
export XDG_DATA_DIRS="$HERE/usr/share${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
exec "$HERE/usr/fluffychat" "$@"
EOF
chmod +x "$APPDIR/AppRun"

ARCH="$ARCH" VERSION="$VERSION" "$LINUXDEPLOY_BIN" --appdir "$APPDIR" --desktop-file "$APPDIR/$APP_ID.desktop" --icon-file "$APPDIR/fluffychat.png" --output appimage

mv "${APP_NAME}-${VERSION}-${ARCH}.AppImage" "$ARTIFACT_DIR/$OUTPUT_NAME"
printf '%s\n' "$ARTIFACT_DIR/$OUTPUT_NAME"

#!/usr/bin/env bash

set -euo pipefail

APP_NAME="${APP_NAME:-FluffyChat}"
APP_ID="${APP_ID:-chat.fluffy.fluffychat}"
ARCH="${ARCH:-x86_64}"
ARTIFACT_DIR="${ARTIFACT_DIR:-build/appimage}"
APPDIR="${APPDIR:-build/appimage/AppDir}"
LINUX_BUNDLE_DIR="${LINUX_BUNDLE_DIR:-build/linux/x64/release/bundle}"
DESKTOP_FILE="${DESKTOP_FILE:-linux/fluffychat.desktop}"
ICON_FILE="${ICON_FILE:-assets/logo/img/logo.png}"
VERSION="${VERSION:-$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d+ -f1)}"
OUTPUT_NAME="${OUTPUT_NAME:-${APP_NAME}-${VERSION}-linux-${ARCH}.AppImage}"
LOG_DIR="${LOG_DIR:-/tmp/opencode}"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/fluffy_appimage_build.log}"

mkdir -p "$LOG_DIR" "$ARTIFACT_DIR"
rm -rf "$APPDIR"

flutter build linux --release 2>&1 | tee "$LOG_FILE"

mkdir -p "$APPDIR/usr"
cp -a "$LINUX_BUNDLE_DIR"/* "$APPDIR/usr/"
cp "$DESKTOP_FILE" "$APPDIR/$APP_ID.desktop"
cp "$ICON_FILE" "$APPDIR/fluffychat.png"

cat > "$APPDIR/AppRun" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
HERE="$(dirname "$(readlink -f "$0")")"
exec "$HERE/usr/fluffychat" "$@"
EOF
chmod +x "$APPDIR/AppRun"

ARCH="$ARCH" VERSION="$VERSION" linuxdeploy --appdir "$APPDIR" --desktop-file "$APPDIR/$APP_ID.desktop" --icon-file "$APPDIR/fluffychat.png" --output appimage

mv "${APP_NAME}-${VERSION}-${ARCH}.AppImage" "$ARTIFACT_DIR/$OUTPUT_NAME"
printf '%s\n' "$ARTIFACT_DIR/$OUTPUT_NAME"

#!/usr/bin/env bash

set -euo pipefail

APPIMAGE_PATH="${1:-}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/Applications}"
DESKTOP_DIR="${DESKTOP_DIR:-$HOME/.local/share/applications}"
ICON_DIR="${ICON_DIR:-$HOME/.local/share/icons/hicolor/512x512/apps}"
TARGET_APPIMAGE="$INSTALL_DIR/FluffyChat.AppImage"
TARGET_DESKTOP="$DESKTOP_DIR/fluffychat-appimage.desktop"
TARGET_ICON="$ICON_DIR/fluffychat.png"
TARGET_LAUNCHER="$INSTALL_DIR/FluffyChat.sh"

if [[ -z "$APPIMAGE_PATH" ]]; then
  APPIMAGE_PATH="$(ls -1t build/appimage/*.AppImage 2>/dev/null | head -n 1 || true)"
fi

if [[ -z "$APPIMAGE_PATH" || ! -f "$APPIMAGE_PATH" ]]; then
  echo "No AppImage found. Build one with: bash scripts/build_linux_appimage_docker.sh"
  exit 1
fi

mkdir -p "$INSTALL_DIR" "$DESKTOP_DIR" "$ICON_DIR"
cp "$APPIMAGE_PATH" "$TARGET_APPIMAGE"
chmod +x "$TARGET_APPIMAGE"
cp assets/logo/img/logo_appimage_512.png "$TARGET_ICON"
cp scripts/launch_appimage_local.sh "$TARGET_LAUNCHER"
chmod +x "$TARGET_LAUNCHER"

cat > "$TARGET_DESKTOP" <<EOF
[Desktop Entry]
Name=FluffyChat
GenericName=Matrix Client
Comment=Chat with your friends
Exec=$TARGET_LAUNCHER
Icon=$TARGET_ICON
Terminal=false
Type=Application
Categories=Network;Chat;InstantMessaging;
StartupWMClass=chat.fluffy.fluffychat
EOF

chmod 644 "$TARGET_DESKTOP"

if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database "$DESKTOP_DIR" >/dev/null 2>&1 || true
fi

printf '%s\n' "$TARGET_APPIMAGE"

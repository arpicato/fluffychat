#!/usr/bin/env bash

set -euo pipefail

APPIMAGE_PATH="${1:-$HOME/Applications/FluffyChat.AppImage}"

if [[ ! -f "$APPIMAGE_PATH" ]]; then
  echo "AppImage not found at $APPIMAGE_PATH"
  exit 1
fi

# Avoid loading host GVFS GIO modules into the bundled GTK stack on NixOS.
exec env GIO_EXTRA_MODULES= appimage-run "$APPIMAGE_PATH"

#!/usr/bin/env bash

set -euo pipefail

APPIMAGE_PATH="${1:-}"

if [[ -z "$APPIMAGE_PATH" ]]; then
  APPIMAGE_PATH="$(ls -1t build/appimage/*.AppImage 2>/dev/null | head -n 1 || true)"
fi

if [[ -z "$APPIMAGE_PATH" || ! -f "$APPIMAGE_PATH" ]]; then
  echo "No AppImage found. Build one with: bash scripts/build_linux_appimage_docker.sh"
  exit 1
fi

exec appimage-run "$APPIMAGE_PATH"

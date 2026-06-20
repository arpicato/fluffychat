#!/usr/bin/env bash

set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-fluffychat-appimage:latest}"
BASE_IMAGE="${FLUFFYCHAT_BUILDER_IMAGE:-fluffychat-builder-base:3.41.6}"
LOG_DIR="${LOG_DIR:-/tmp/opencode}"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/fluffy_appimage_docker_build.log}"
HOST_UID="${HOST_UID:-$(id -u)}"
HOST_GID="${HOST_GID:-$(id -g)}"
TOOLS_DIR="${TOOLS_DIR:-/tmp/opencode/appimage-tools}"
LINUXDEPLOY_APPIMAGE="${LINUXDEPLOY_APPIMAGE:-${TOOLS_DIR}/linuxdeploy-x86_64.AppImage}"
APPIMAGETOOL_APPIMAGE="${APPIMAGETOOL_APPIMAGE:-${TOOLS_DIR}/appimagetool-x86_64.AppImage}"
LINUXDEPLOY_DIR="${LINUXDEPLOY_DIR:-${TOOLS_DIR}/linuxdeploy-root}"
APPIMAGETOOL_DIR="${APPIMAGETOOL_DIR:-${TOOLS_DIR}/appimagetool-root}"

mkdir -p "$LOG_DIR" "$TOOLS_DIR" build/appimage build/linux

docker run --rm -v "$PWD/build/appimage:/fix" alpine sh -lc "chown -R $HOST_UID:$HOST_GID /fix 2>/dev/null || true"
docker run --rm -v "$PWD/build/linux:/fix" alpine sh -lc "chown -R $HOST_UID:$HOST_GID /fix 2>/dev/null || true"

if [[ ! -f "$LINUXDEPLOY_APPIMAGE" ]]; then
  curl -L -o "$LINUXDEPLOY_APPIMAGE" "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
  chmod +x "$LINUXDEPLOY_APPIMAGE"
fi

if [[ ! -f "$APPIMAGETOOL_APPIMAGE" ]]; then
  curl -L -o "$APPIMAGETOOL_APPIMAGE" "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-x86_64.AppImage"
  chmod +x "$APPIMAGETOOL_APPIMAGE"
fi

rm -rf "$LINUXDEPLOY_DIR" "$APPIMAGETOOL_DIR"
mkdir -p "$LINUXDEPLOY_DIR" "$APPIMAGETOOL_DIR"

appimage-run "$LINUXDEPLOY_APPIMAGE" --version >/dev/null
appimage-run "$APPIMAGETOOL_APPIMAGE" --version >/dev/null || true

LINUXDEPLOY_CACHE_DIR="$(bash -lc 'printf %s "$HOME/.cache/appimage-run/$(sha256sum "$1" | awk '\''{print $1}'\'')"' _ "$LINUXDEPLOY_APPIMAGE")"
APPIMAGETOOL_CACHE_DIR="$(bash -lc 'printf %s "$HOME/.cache/appimage-run/$(sha256sum "$1" | awk '\''{print $1}'\'')"' _ "$APPIMAGETOOL_APPIMAGE")"

cp -a "$LINUXDEPLOY_CACHE_DIR"/. "$LINUXDEPLOY_DIR"/
cp -a "$APPIMAGETOOL_CACHE_DIR"/. "$APPIMAGETOOL_DIR"/

bash scripts/build_builder_base.sh >/tmp/opencode/fluffy_builder_base.log 2>&1

docker build -f Dockerfile.appimage --build-arg "FLUFFYCHAT_BUILDER_IMAGE=$BASE_IMAGE" -t "$IMAGE_NAME" . 2>&1 | tee "$LOG_FILE"

docker run --rm \
  -e HOST_UID="$HOST_UID" \
  -e HOST_GID="$HOST_GID" \
  -e LINUXDEPLOY_BIN="/tools/linuxdeploy/AppRun" \
  -e APPIMAGETOOL="/tools/appimagetool/AppRun" \
  -v "$PWD:/app" \
  -v "$LINUXDEPLOY_DIR:/tools/linuxdeploy:ro" \
  -v "$APPIMAGETOOL_DIR:/tools/appimagetool:ro" \
  -w /app \
  "$IMAGE_NAME"

#!/usr/bin/env bash

set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-fluffychat-appimage:latest}"
LOG_DIR="${LOG_DIR:-/tmp/opencode}"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/fluffy_appimage_docker_build.log}"

mkdir -p "$LOG_DIR" build/appimage

docker build -f Dockerfile.appimage -t "$IMAGE_NAME" . 2>&1 | tee "$LOG_FILE"

docker run --rm \
  -v "$PWD:/app" \
  -w /app \
  "$IMAGE_NAME"

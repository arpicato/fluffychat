#!/usr/bin/env bash

set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-fluffychat-web:prod}"
LOG_DIR="${LOG_DIR:-/tmp/opencode}"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/fluffy_web_build.log}"

mkdir -p "$LOG_DIR"

docker build -f Dockerfile.web -t "$IMAGE_NAME" . 2>&1 | tee "$LOG_FILE"

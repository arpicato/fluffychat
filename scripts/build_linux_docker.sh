#!/usr/bin/env bash

set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-fluffychat-linux:latest}"
LOG_DIR="${LOG_DIR:-/tmp/opencode}"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/fluffy_linux_build.log}"

mkdir -p "$LOG_DIR"

docker build -f Dockerfile.linux -t "$IMAGE_NAME" . 2>&1 | tee "$LOG_FILE"

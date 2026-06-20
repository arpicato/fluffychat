#!/usr/bin/env bash

set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-fluffychat-builder-base:3.41.6}"
LOG_DIR="${LOG_DIR:-/tmp/opencode}"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/fluffy_builder_base.log}"

mkdir -p "$LOG_DIR"

docker build -f Dockerfile.builder-base -t "$IMAGE_NAME" . 2>&1 | tee "$LOG_FILE"

#!/usr/bin/env bash

set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-fluffychat-web:prod}"
BASE_IMAGE="${FLUFFYCHAT_BUILDER_IMAGE:-fluffychat-builder-base:3.41.6}"
LOG_DIR="${LOG_DIR:-/tmp/opencode}"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/fluffy_web_build.log}"

mkdir -p "$LOG_DIR"

bash scripts/build_builder_base.sh >/tmp/opencode/fluffy_builder_base.log 2>&1

docker build -f Dockerfile.web --build-arg "FLUFFYCHAT_BUILDER_IMAGE=$BASE_IMAGE" -t "$IMAGE_NAME" . 2>&1 | tee "$LOG_FILE"

#!/usr/bin/env bash

set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-fluffychat-linux:latest}"
LOG_DIR="${LOG_DIR:-/tmp/opencode}"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/fluffy_linux_build.log}"
HOST_UID="${HOST_UID:-$(id -u)}"
HOST_GID="${HOST_GID:-$(id -g)}"

mkdir -p "$LOG_DIR"

docker build -f Dockerfile.linux -t "$IMAGE_NAME" . 2>&1 | tee "$LOG_FILE"

mkdir -p build/linux
docker run --rm \
  -e HOST_UID="$HOST_UID" \
  -e HOST_GID="$HOST_GID" \
  -v "$PWD/build/linux:/out" \
  "$IMAGE_NAME" \
  bash -lc 'rm -rf /out/x64/release && mkdir -p /out/x64/release && cp -a /opt/fluffychat-bundle /out/x64/release/bundle && chown -R "$HOST_UID:$HOST_GID" /out/x64/release'

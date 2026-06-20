#!/usr/bin/env bash

set -euo pipefail

IMAGE_NAME="${IMAGE_NAME:-fluffychat-linux:latest}"
BASE_IMAGE="${FLUFFYCHAT_BUILDER_IMAGE:-fluffychat-builder-base:3.41.6}"
LOG_DIR="${LOG_DIR:-/tmp/opencode}"
LOG_FILE="${LOG_FILE:-${LOG_DIR}/fluffy_linux_build.log}"
HOST_UID="${HOST_UID:-$(id -u)}"
HOST_GID="${HOST_GID:-$(id -g)}"

mkdir -p "$LOG_DIR"

bash scripts/build_builder_base.sh >/tmp/opencode/fluffy_builder_base.log 2>&1

docker build -f Dockerfile.linux --build-arg "FLUFFYCHAT_BUILDER_IMAGE=$BASE_IMAGE" -t "$IMAGE_NAME" . 2>&1 | tee "$LOG_FILE"

mkdir -p build/linux
container_name="fluffychat-linux-export-$$"
docker create --name "$container_name" "$IMAGE_NAME" >/dev/null
trap 'docker rm -f "$container_name" >/dev/null 2>&1 || true' EXIT
rm -rf build/linux/x64/release
mkdir -p build/linux/x64/release
docker cp "$container_name:/out/fluffychat-bundle" "$PWD/build/linux/x64/release/bundle"
chown -R "$HOST_UID:$HOST_GID" "$PWD/build/linux/x64/release"

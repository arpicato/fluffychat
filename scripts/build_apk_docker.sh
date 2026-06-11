#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
output_dir="${APK_OUTPUT_DIR:-$repo_root/build/android}"
image_tag="${APK_IMAGE_TAG:-fluffychat-apk:latest}"
signing_mode="${APK_SIGNING_MODE:-release}"

mkdir -p "$output_dir"

if [[ "$signing_mode" == "release" && ! -f "$repo_root/android/key.properties" ]]; then
  printf 'ERROR: %s\n' "android/key.properties not found for release signing." >&2
  printf 'Either provide real signing material or set APK_SIGNING_MODE=dev for a disposable test APK.\n' >&2
  exit 1
fi

build_log="/tmp/opencode/build_apk_docker.log"

DOCKER_BUILDKIT=1 docker build \
  -f "$repo_root/Dockerfile.apk" \
  --build-arg "APK_SIGNING_MODE=$signing_mode" \
  -t "$image_tag" \
  "$repo_root" >"$build_log" 2>&1

container_name="fluffychat-apk-export-$$"
cleanup() {
  docker rm -f "$container_name" >/dev/null 2>&1 || true
}
trap cleanup EXIT

docker create --name "$container_name" "$image_tag" >/dev/null
docker cp \
  "$container_name:/app/build/app/outputs/flutter-apk/app-release.apk" \
  "$output_dir/app-release.apk"

printf 'APK exported to %s\n' "$output_dir/app-release.apk"
printf 'Build log: %s\n' "$build_log"

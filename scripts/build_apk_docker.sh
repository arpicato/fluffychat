#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
output_dir="${APK_OUTPUT_DIR:-$repo_root/build/android}"
image_tag="${APK_IMAGE_TAG:-fluffychat-apk:latest}"
signing_mode="${APK_SIGNING_MODE:-release}"
temp_signing_files=()
container_name=""

mkdir -p "$output_dir"

cleanup_files() {
  for path in "${temp_signing_files[@]:-}"; do
    rm -f "$path"
  done
}
cleanup() {
  if [[ -n "$container_name" ]]; then
    docker rm -f "$container_name" >/dev/null 2>&1 || true
  fi
  cleanup_files
}
trap cleanup EXIT

if [[ "$signing_mode" == "release" && ! -f "$repo_root/android/key.properties" ]]; then
  if [[ -n "${FDROID_KEY:-}" && -n "${FDROID_KEY_PASS:-}" ]]; then
    printf '%s' "$FDROID_KEY" | base64 --decode --ignore-garbage > "$repo_root/key.jks"
    cat >"$repo_root/android/key.properties" <<EOF
storePassword=${FDROID_KEY_PASS}
keyPassword=${FDROID_KEY_PASS}
keyAlias=key
storeFile=../key.jks
EOF
    temp_signing_files+=("$repo_root/key.jks" "$repo_root/android/key.properties")
  fi
fi

if [[ "$signing_mode" == "release" && ! -f "$repo_root/android/key.properties" ]]; then
  printf 'ERROR: %s\n' "android/key.properties not found for release signing." >&2
  printf 'Provide android/key.properties plus keystore, or set FDROID_KEY and FDROID_KEY_PASS, or use APK_SIGNING_MODE=dev for a disposable test APK.\n' >&2
  exit 1
fi

build_log="/tmp/opencode/build_apk_docker.log"

DOCKER_BUILDKIT=1 docker build \
  -f "$repo_root/Dockerfile.apk" \
  --build-arg "APK_SIGNING_MODE=$signing_mode" \
  -t "$image_tag" \
  "$repo_root" >"$build_log" 2>&1

container_name="fluffychat-apk-export-$$"

docker create --name "$container_name" "$image_tag" >/dev/null
docker cp \
  "$container_name:/app/build/app/outputs/flutter-apk/app-release.apk" \
  "$output_dir/app-release.apk"

printf 'APK exported to %s\n' "$output_dir/app-release.apk"
printf 'Build log: %s\n' "$build_log"

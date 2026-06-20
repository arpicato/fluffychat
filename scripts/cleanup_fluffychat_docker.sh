#!/usr/bin/env bash

set -euo pipefail

KEEP_LINUX_TAGS=(latest)
KEEP_WEB_TAGS=(prod)
KEEP_APK_TAGS=(latest)

delete_old_tags() {
  local repo="$1"
  shift
  local keep=("$@")
  docker images --format '{{.Repository}}:{{.Tag}} {{.ID}}' "$repo" | while read -r ref _; do
    [[ -z "$ref" ]] && continue
    local tag="${ref#${repo}:}"
    local keep_it=0
    for k in "${keep[@]}"; do
      if [[ "$tag" == "$k" ]]; then
        keep_it=1
        break
      fi
    done
    if [[ "$keep_it" -eq 0 ]]; then
      docker image rm "$ref" >/dev/null 2>&1 || true
    fi
  done
}

delete_old_tags fluffychat-linux "${KEEP_LINUX_TAGS[@]}"
delete_old_tags fluffychat-web "${KEEP_WEB_TAGS[@]}"
delete_old_tags fluffychat-apk "${KEEP_APK_TAGS[@]}"

docker image prune -f >/dev/null
docker builder prune -f --filter 'until=168h' >/dev/null

echo 'Remaining FluffyChat images:'
docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}' | grep -E '^fluffychat-' || true

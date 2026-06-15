#!/usr/bin/env bash

set -euo pipefail

REMOTE_HOST="${REMOTE_HOST:-arpin-hp.local}"
IMAGE_NAME="${IMAGE_NAME:-fluffychat-web:prod}"
CONTAINER_NAME="${CONTAINER_NAME:-fluffychat-web}"
REMOTE_NETWORK="${REMOTE_NETWORK:-messie-messenger_default}"
REMOTE_PORT="${REMOTE_PORT:-3000}"

docker save "$IMAGE_NAME" | gzip | ssh "$REMOTE_HOST" "docker load"

ssh "$REMOTE_HOST" \
  "docker stop $CONTAINER_NAME && docker rm $CONTAINER_NAME && docker run -d --name $CONTAINER_NAME --network $REMOTE_NETWORK -p $REMOTE_PORT:80 $IMAGE_NAME"

ssh "$REMOTE_HOST" "docker port $CONTAINER_NAME"
ssh "$REMOTE_HOST" "docker container ls --filter name=$CONTAINER_NAME"
ssh "$REMOTE_HOST" "curl -I http://localhost:$REMOTE_PORT"

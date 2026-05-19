#!/usr/bin/env bash
# Launch FluffyChat Linux desktop from Docker container with X11 forwarding
# Usage: ./run-linux.sh

IMAGE="${FLUFFYCHAT_LINUX_IMAGE:-fluffychat-linux:latest}"

xhost +local:docker 2>/dev/null

exec docker run --rm \
  -e DISPLAY="$DISPLAY" \
  -e XAUTHORITY=/tmp/.xauth \
  -v "$XAUTHORITY:/tmp/.xauth:ro" \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v "$HOME/.local/share/fluffychat-docker:/root/.local/share" \
  --network host \
  "$IMAGE" \
  /app/build/linux/x64/release/bundle/fluffychat

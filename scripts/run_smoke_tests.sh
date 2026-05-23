#!/usr/bin/env bash

set -euo pipefail

MODE="${1:-widget}"
VISIBLE="${VISIBLE:-0}"
IMAGE="fluffychat-test-linux:latest"
WEB_IMAGE="fluffychat-test-web:latest"
SYNAPSE_IMAGE="matrixdotorg/synapse:latest"
HOST_CACHE_ROOT="${HOST_CACHE_ROOT:-/tmp/opencode/fluffychat-docker-cache}"
HOST_HOME_CACHE="${HOST_HOME_CACHE:-${HOST_CACHE_ROOT}/home}"
HOST_PUB_CACHE="${HOST_PUB_CACHE:-${HOST_CACHE_ROOT}/pub-cache}"
HOST_DART_TOOL_CACHE="${HOST_DART_TOOL_CACHE:-${HOST_CACHE_ROOT}/dart_tool}"
HOST_BUILD_CACHE="${HOST_BUILD_CACHE:-${HOST_CACHE_ROOT}/build}"
SYNAPSE_PORT="${SYNAPSE_PORT:-40180}"
SYNAPSE_HOST="localhost:${SYNAPSE_PORT}"
INTEGRATION_TIMEOUT_SECONDS="${INTEGRATION_TIMEOUT_SECONDS:-180}"
INTEGRATION_TARGET="${INTEGRATION_TARGET:-web}"
WEB_CHROME_EXECUTABLE="${WEB_CHROME_EXECUTABLE:-/usr/local/bin/google-chrome-no-sandbox}"

ensure_cache_dirs() {
  mkdir -p \
    "$HOST_HOME_CACHE" \
    "$HOST_PUB_CACHE" \
    "$HOST_DART_TOOL_CACHE" \
    "$HOST_BUILD_CACHE"
}

run_in_test_container() {
  local command="$1"
  ensure_cache_dirs
  docker run --rm \
    -e HOME=/tmp/fluffychat-home \
    -e PUB_CACHE=/tmp/fluffychat-pub-cache \
    -e GIT_CONFIG_COUNT=1 \
    -e GIT_CONFIG_KEY_0=safe.directory \
    -e GIT_CONFIG_VALUE_0=/sdks/flutter \
    -v "$HOST_HOME_CACHE:/tmp/fluffychat-home" \
    -v "$HOST_PUB_CACHE:/tmp/fluffychat-pub-cache" \
    -v "$HOST_DART_TOOL_CACHE:/app/.dart_tool" \
    -v "$HOST_BUILD_CACHE:/app/build" \
    -v "$PWD:/app" \
    -w /app \
    "$IMAGE" \
    bash -lc "$command"
}

maybe_pub_get_cmd() {
  cat <<'EOF'
set -euo pipefail
mkdir -p build
chmod -R u+w build .dart_tool || true
if [[ ! -f .dart_tool/package_config.json || pubspec.lock -nt .dart_tool/package_config.json || pubspec.yaml -nt .dart_tool/package_config.json || packages/messie_api/pubspec.yaml -nt .dart_tool/package_config.json ]]; then
  flutter pub get
fi
EOF
}

start_synapse() {
  docker rm -f fluffychat-smoke-synapse >/dev/null 2>&1 || true
  docker run -d --name fluffychat-smoke-synapse \
    --tmpfs /data \
    -v "$PWD/integration_test/synapse/data/homeserver.yaml:/data/homeserver.yaml:rw" \
    -v "$PWD/integration_test/synapse/data/localhost.log.config:/data/localhost.log.config:rw" \
    -p "${SYNAPSE_PORT}:80" \
    "$SYNAPSE_IMAGE" >/dev/null
}

stop_synapse() {
  docker rm -f fluffychat-smoke-synapse >/dev/null 2>&1 || true
}

build_image() {
  docker build -f Dockerfile.test-linux -t "$IMAGE" .
}

build_web_image() {
  docker build -f Dockerfile.test-web -t "$WEB_IMAGE" .
}

run_full_test_suite() {
  run_in_test_container "$(maybe_pub_get_cmd); rm -rf build/unit_test_assets || true; flutter test --reporter compact"
}

run_widget_tests() {
  run_in_test_container "$(maybe_pub_get_cmd); rm -rf build/unit_test_assets || true; flutter test test/shortcut_resolver_test.dart test/shortcut_help_model_test.dart test/shortcut_context_conditions_test.dart test/keyboard_navigation_state_test.dart test/message_focus_wrapper_test.dart"
}

run_integration_tests_headless() {
  start_synapse
  trap stop_synapse RETURN
  if [[ "$INTEGRATION_TARGET" == "web" ]]; then
    build_web_image
    docker run --rm \
      -e HOME=/tmp/fluffychat-home \
      -e PUB_CACHE=/tmp/fluffychat-pub-cache \
      -e HOMESERVER="$SYNAPSE_HOST" \
      -e INTEGRATION_TIMEOUT_SECONDS="$INTEGRATION_TIMEOUT_SECONDS" \
      -e CHROME_EXECUTABLE="$WEB_CHROME_EXECUTABLE" \
      -e GIT_CONFIG_COUNT=1 \
      -e GIT_CONFIG_KEY_0=safe.directory \
      -e GIT_CONFIG_VALUE_0=/sdks/flutter \
      -v "$PWD:/app" \
      -w /app \
      --network host \
      "$WEB_IMAGE" \
      bash -lc 'set -euo pipefail; echo "[smoke] phase=pubget"; flutter pub get; echo "[smoke] phase=prepare"; bash scripts/prepare_integration_test.sh; echo "[smoke] phase=chromedriver"; /usr/local/bin/chromedriver --port=4444 --allowed-ips="" >/tmp/chromedriver.log 2>&1 & chromedriver_pid=$!; trap "kill $chromedriver_pid 2>/dev/null || true" EXIT; sleep 2; echo "[smoke] phase=integration-web-drive timeout=${INTEGRATION_TIMEOUT_SECONDS}s"; timeout "${INTEGRATION_TIMEOUT_SECONDS}s" flutter drive --driver=test_driver/integration_driver.dart --target=integration_test/mobile_test.dart -d chrome --dart-define=HOMESERVER="$HOMESERVER"'
      return
    fi

  docker run --rm \
    -e HOME=/tmp/fluffychat-home \
    -e PUB_CACHE=/tmp/fluffychat-pub-cache \
    -e HOMESERVER="$SYNAPSE_HOST" \
    -e INTEGRATION_TIMEOUT_SECONDS="$INTEGRATION_TIMEOUT_SECONDS" \
    -e GIT_CONFIG_COUNT=1 \
    -e GIT_CONFIG_KEY_0=safe.directory \
    -e GIT_CONFIG_VALUE_0=/sdks/flutter \
    -v "$PWD:/app" \
    -w /app \
    --network host \
    "$IMAGE" \
    bash -lc 'set -euo pipefail; echo "[smoke] phase=pubget"; flutter pub get; echo "[smoke] phase=prepare"; bash scripts/prepare_integration_test.sh; echo "[smoke] phase=integration timeout=${INTEGRATION_TIMEOUT_SECONDS}s"; timeout "${INTEGRATION_TIMEOUT_SECONDS}s" xvfb-run -a --server-args="-screen 0 1280x720x24" dbus-run-session -- flutter test integration_test/mobile_test.dart -d linux --dart-define=HOMESERVER="$HOMESERVER"'
}

run_integration_tests_visible() {
  if [[ "$INTEGRATION_TARGET" == "web" ]]; then
    echo "Visible mode is not supported for web integration target"
    return 1
  fi

  start_synapse
  trap stop_synapse RETURN
  docker run --rm \
    -e HOME=/tmp/fluffychat-home \
    -e PUB_CACHE=/tmp/fluffychat-pub-cache \
    -e DISPLAY="$DISPLAY" \
    -e HOMESERVER="$SYNAPSE_HOST" \
    -e INTEGRATION_TIMEOUT_SECONDS="$INTEGRATION_TIMEOUT_SECONDS" \
    -e XAUTHORITY=/tmp/.xauth \
    -e GIT_CONFIG_COUNT=1 \
    -e GIT_CONFIG_KEY_0=safe.directory \
    -e GIT_CONFIG_VALUE_0=/sdks/flutter \
    -v "$XAUTHORITY:/tmp/.xauth:ro" \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v "$PWD:/app" \
    -w /app \
    --network host \
    "$IMAGE" \
    bash -lc 'set -euo pipefail; echo "[smoke] phase=pubget"; flutter pub get; echo "[smoke] phase=prepare"; bash scripts/prepare_integration_test.sh; echo "[smoke] phase=keyring-preflight"; timeout 30s dbus-run-session -- bash -lc "set -euo pipefail; eval \"\$(gnome-keyring-daemon --start --components=secrets)\"; export SSH_AUTH_SOCK GNOME_KEYRING_CONTROL GNOME_KEYRING_PID; printf smoke-secret | secret-tool store --label=fluffychat-smoke test-suite visible-smoke secret smoke >/dev/null; test \"\$(secret-tool lookup test-suite visible-smoke secret smoke)\" = smoke-secret"; echo "[smoke] phase=integration timeout=${INTEGRATION_TIMEOUT_SECONDS}s"; timeout "${INTEGRATION_TIMEOUT_SECONDS}s" dbus-run-session -- bash -lc "set -euo pipefail; eval \"\$(gnome-keyring-daemon --start --components=secrets)\"; export SSH_AUTH_SOCK GNOME_KEYRING_CONTROL GNOME_KEYRING_PID; flutter test integration_test/mobile_test.dart -d linux --dart-define=HOMESERVER=\"$HOMESERVER\""'
}

case "$MODE" in
  widget)
    build_image
    run_widget_tests
    ;;
  full)
    build_image
    run_full_test_suite
    ;;
  integration)
    if [[ "$VISIBLE" == "1" ]]; then
      build_image
      run_integration_tests_visible
    else
      if [[ "$INTEGRATION_TARGET" != "web" ]]; then build_image; fi
      run_integration_tests_headless
    fi
    ;;
  all)
    build_image
    run_widget_tests
    run_full_test_suite
    ;;
  *)
    echo "Usage: $0 [widget|full|integration|all]"
    exit 1
    ;;
esac

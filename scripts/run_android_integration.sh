#!/usr/bin/env bash

set -euo pipefail

MODE="${1:-all}"
DEVICE_ID="${DEVICE_ID:-emulator-5554}"
PACKAGE_ID="${PACKAGE_ID:-chat.fluffy.fluffychat}"
PUB_CACHE_DIR="${PUB_CACHE:-/home/arpin/.pub-cache}"
FLUTTER_ROOT_DIR="${FLUTTER_ROOT:-}"
SYNAPSE_PORT="${SYNAPSE_PORT:-40280}"
HOMESERVER_HOST="${HOMESERVER_HOST:-10.0.2.2}"
HOMESERVER="${HOMESERVER:-${HOMESERVER_HOST}:${SYNAPSE_PORT}}"
APK_PATH="${APK_PATH:-build/app/outputs/flutter-apk/app-debug.apk}"
TEST_TIMEOUT_SECONDS="${TEST_TIMEOUT_SECONDS:-180}"
TEST_NAME="${TEST_NAME:-}"
RESET_APP_STATE="${RESET_APP_STATE:-1}"
PREPARE_HOMESERVER="${PREPARE_HOMESERVER:-0}"
USER1_NAME="${USER1_NAME:-alice}"
USER1_PW="${USER1_PW:-AliceInWonderland}"
USER2_NAME="${USER2_NAME:-bob}"
USER2_PW="${USER2_PW:-JoWirSchaffenDas}"
HOST_PATH="${PATH}"
PHASE_START_SECONDS=""

usage() {
  cat <<'EOF'
Usage: scripts/run_android_integration.sh [build|install|run|all]

Environment overrides:
  DEVICE_ID=emulator-5554
  PACKAGE_ID=chat.fluffy.fluffychat
  PUB_CACHE=/home/arpin/.pub-cache
  FLUTTER_ROOT=/path/to/flutter
  SYNAPSE_PORT=40280
  HOMESERVER_HOST=10.0.2.2
  HOMESERVER=10.0.2.2:40280
  APK_PATH=build/app/outputs/flutter-apk/app-debug.apk
  TEST_TIMEOUT_SECONDS=180
  TEST_NAME="Login and logout flow"
  RESET_APP_STATE=1
  PREPARE_HOMESERVER=0
EOF
}

log() {
  printf '[android-integration] %s phase=%s\n' "$(date --iso-8601=seconds)" "$1"
}

phase_begin() {
  PHASE_START_SECONDS="$(date +%s)"
  log "$1"
}

phase_end() {
  local name="$1"
  local end_seconds elapsed
  end_seconds="$(date +%s)"
  elapsed="$((end_seconds - PHASE_START_SECONDS))"
  printf '[android-integration] %s phase=%s-complete elapsed=%ss\n' "$(date --iso-8601=seconds)" "$name" "$elapsed"
}

prepare_test_users() {
  if [[ "$PREPARE_HOMESERVER" != "1" ]]; then
    return
  fi

  local suffix
  suffix="$(date +%s)"
  USER1_NAME="alice_${suffix}"
  USER2_NAME="bob_${suffix}"
}

cleanup_generated_state() {
  phase_begin cleanup-generated-state
  local uid gid
  uid="$(id -u)"
  gid="$(id -g)"
  docker run --rm -v "$PWD:/work" -w /work alpine rm -rf \
    windows/flutter/ephemeral/.plugin_symlinks \
    linux/flutter/ephemeral/.plugin_symlinks \
    build/unit_test_assets \
    .dart_tool/flutter_build \
    .dart_tool/hooks_runner >/dev/null 2>&1 || true
  docker run --rm -v "$PWD:/work" -w /work alpine mkdir -p \
    .dart_tool \
    build \
    linux \
    windows >/dev/null 2>&1 || true
  docker run --rm -v "$PWD:/work" -w /work alpine chown -R "$uid:$gid" \
    .dart_tool \
    build \
    linux \
    windows >/dev/null 2>&1 || true
  rm -rf \
    windows/flutter/ephemeral/.plugin_symlinks \
    linux/flutter/ephemeral/.plugin_symlinks \
    build/unit_test_assets \
    .dart_tool/flutter_build \
    .dart_tool/hooks_runner \
    2>/dev/null || true
  phase_end cleanup-generated-state
}

flutter_metadata_is_fresh() {
  if [[ ! -f .dart_tool/package_config.json || ! -f .flutter-plugins-dependencies ]]; then
    return 1
  fi

  if ! grep -Fq "$PUB_CACHE_DIR" .flutter-plugins-dependencies; then
    return 1
  fi

  return 0
}

ensure_device() {
  phase_begin ensure-device
  adb -s "$DEVICE_ID" get-state >/dev/null
  phase_end ensure-device
}

resolve_flutter_root() {
  if [[ -n "$FLUTTER_ROOT_DIR" ]]; then
    return
  fi

  FLUTTER_ROOT_DIR="$({ sed -n 's/^flutter\.sdk=//p' android/local.properties || true; } | tail -n 1)"

  # Host runs may use a wrapped Flutter outside android/local.properties.
  # Skip exporting a stale SDK path so the active flutter binary can resolve
  # its own toolchain correctly.
  if [[ -n "$FLUTTER_ROOT_DIR" && ! -d "$FLUTTER_ROOT_DIR" ]]; then
    FLUTTER_ROOT_DIR=""
  fi
}

run_flutter() {
  resolve_flutter_root
  local escaped_path escaped_cache escaped_root command_string
  printf -v escaped_path '%q' "$HOST_PATH"
  printf -v escaped_cache '%q' "$PUB_CACHE_DIR"
  printf -v escaped_root '%q' "$FLUTTER_ROOT_DIR"
  printf -v command_string '%q ' "$@"
  bash -lc "export PATH=${escaped_path}; export PUB_CACHE=${escaped_cache}; if [[ -n ${escaped_root} ]]; then export FLUTTER_ROOT=${escaped_root}; fi; ${command_string}"
}

refresh_flutter_metadata() {
  phase_begin refresh-flutter-metadata
  if flutter_metadata_is_fresh; then
    printf '[android-integration] %s phase=refresh-flutter-metadata-skip reason=fresh-metadata\n' "$(date --iso-8601=seconds)"
    phase_end refresh-flutter-metadata
    return
  fi
  cleanup_generated_state
  run_flutter flutter pub get
  phase_end refresh-flutter-metadata
}

prepare_homeserver() {
  if [[ "$PREPARE_HOMESERVER" != "1" ]]; then
    return
  fi

  log prepare-homeserver
  phase_begin prepare-homeserver
  prepare_test_users
  SYNAPSE_PORT="$SYNAPSE_PORT" HOMESERVER="localhost:${SYNAPSE_PORT}" USER1_NAME="$USER1_NAME" USER1_PW="$USER1_PW" USER2_NAME="$USER2_NAME" USER2_PW="$USER2_PW" \
    bash scripts/prepare_integration_test.sh
  phase_end prepare-homeserver
}

build_apk() {
  phase_begin build-apk
  run_flutter flutter build apk --debug --no-pub \
    --dart-define="HOMESERVER=$HOMESERVER"
  phase_end build-apk
}

install_apk() {
  phase_begin install-apk
  if [[ "$RESET_APP_STATE" == "1" ]]; then
    adb -s "$DEVICE_ID" uninstall "$PACKAGE_ID" >/dev/null 2>&1 || true
  fi
  adb -s "$DEVICE_ID" install -r "$APK_PATH"
  phase_end install-apk
}

reset_app_state() {
  if [[ "$RESET_APP_STATE" != "1" ]]; then
    return
  fi

  phase_begin reset-app-state
  adb -s "$DEVICE_ID" shell bmgr enable false >/dev/null 2>&1 || true
  adb -s "$DEVICE_ID" shell am force-stop "$PACKAGE_ID" >/dev/null 2>&1 || true
  adb -s "$DEVICE_ID" shell pm clear "$PACKAGE_ID" >/dev/null 2>&1 || true
  phase_end reset-app-state
}

run_tests() {
  phase_begin run-tests
  resolve_flutter_root
  refresh_flutter_metadata
  local test_args=(
    integration_test/mobile_test.dart
    -d "$DEVICE_ID"
    --no-pub
    --reporter=expanded
    --dart-define="HOMESERVER=$HOMESERVER"
    --dart-define="USER1_NAME=$USER1_NAME"
    --dart-define="USER1_PW=$USER1_PW"
    --dart-define="USER2_NAME=$USER2_NAME"
    --dart-define="USER2_PW=$USER2_PW"
  )

  if [[ -n "$TEST_NAME" ]]; then
    test_args+=("--plain-name=$TEST_NAME")
  fi

  local escaped_path escaped_cache escaped_root command_string
  printf -v escaped_path '%q' "$HOST_PATH"
  printf -v escaped_cache '%q' "$PUB_CACHE_DIR"
  printf -v escaped_root '%q' "$FLUTTER_ROOT_DIR"
  printf -v command_string '%q ' flutter test "${test_args[@]}"

  timeout "${TEST_TIMEOUT_SECONDS}s" bash -lc "export PATH=${escaped_path}; export PUB_CACHE=${escaped_cache}; if [[ -n ${escaped_root} ]]; then export FLUTTER_ROOT=${escaped_root}; fi; ${command_string}"
  phase_end run-tests
}

case "$MODE" in
  build)
    ensure_device
    prepare_homeserver
    build_apk
    ;;
  install)
    ensure_device
    install_apk
    reset_app_state
    ;;
  run)
    ensure_device
    prepare_homeserver
    install_apk
    reset_app_state
    run_tests
    ;;
  all)
    ensure_device
    prepare_homeserver
    build_apk
    install_apk
    reset_app_state
    run_tests
    ;;
  -h|--help|help)
    usage
    ;;
  *)
    usage
    exit 1
    ;;
esac

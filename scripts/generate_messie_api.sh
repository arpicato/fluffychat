#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SPEC_PATH="$REPO_ROOT/docs/messie-openapi.yaml"
OUTPUT_PATH="$REPO_ROOT/packages/messie_api"

cd "$REPO_ROOT"

npx @openapitools/openapi-generator-cli generate \
  -i "$SPEC_PATH" \
  -g dart-dio \
  -o "$OUTPUT_PATH" \
  --additional-properties=pubName=messie_api,pubLibrary=messie_api

cd "$OUTPUT_PATH"
flutter pub get
dart run build_runner build --delete-conflicting-outputs

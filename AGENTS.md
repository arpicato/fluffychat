## Agent Instructions (repo-local)

These instructions apply to any AI agent working in this repo.

### Project Overview

FluffyChat is the primary Matrix client for the Messie ecosystem. It is a Flutter fork of the upstream FluffyChat project, customized to integrate with the Messie backend. The Messie Svelte client is being replaced by this Flutter client.

### Product Direction

- FluffyChat is the client; `messie-messenger` is the backend and reference implementation
- Treat Messie frontend code and docs as UX/reference material, but implement the actual client in Flutter here
- Todo integration: target UX is the Messie workspace model with todos as a first-class surface (list/detail flows, item CRUD, collaborators, eventual unified timeline/calendar integration)
- Current integration validates Matrix OpenID -> backend JWT auth and todo rendering

### Dev Flow

- Bootstrap when needed: `/workspace/dev-fluffychat-bootstrap.sh`
- Normal web run: `/workspace/dev-fluffychat-web.sh`
- Release web run for realistic perf checks: `/workspace/dev-fluffychat-web-prod.sh`
- Use VS Code port forwarding for port `3000`
- The web script uses `flutter run -d web-server --no-pub` for faster reruns; if dependencies changed, run bootstrap or a manual `flutter pub get` before rerunning

### Rebuild/Restart Handling

- Manage Flutter rebuilds/restarts yourself instead of pushing that work back to the user
- Do not hand off mid-investigation with only harness/debugging progress; only ask the user to verify when there is a concrete product change or a stable runtime checkpoint to check
- If a rebuild or image build is the next required step for progress or verification, do it directly without asking for confirmation first
- Prefer the tmux helpers so the user keeps terminal access while Flutter runs:
  - `bash /workspace/fluffy-tmux-start`
  - `bash /workspace/fluffy-tmux-attach`
  - `bash /workspace/fluffy-tmux-restart`
  - `bash /workspace/fluffy-tmux-stop`
  - `bash /workspace/fluffy-tmux-status`
  - `bash /workspace/fluffy-tmux-logs`
- Release web helpers (port `3001` to coexist with dev server on `3000`):
  - `bash /workspace/fluffy-prod-tmux-start`
  - `bash /workspace/fluffy-prod-tmux-attach`
  - `bash /workspace/fluffy-prod-tmux-restart`
  - `bash /workspace/fluffy-prod-tmux-stop`
  - `bash /workspace/fluffy-prod-tmux-status`
  - `bash /workspace/fluffy-prod-tmux-logs`
- `start` and `restart` are detached/background flows; do not tell the user to attach unless they explicitly want live logs
- Workspace-mounted scripts may need to be invoked through `bash` even when marked executable
- If `tmux` is unavailable in the container, fall back to starting `bash /workspace/dev-fluffychat-web.sh` in the background and report any startup failure
- After changing Flutter code, restart the tmux-managed Flutter app before handing off

### Messie API Generation

- Local Messie API generation lives in this repo, not `messie-messenger`
- Source spec: `docs/messie-openapi.yaml`
- Generator config: `openapitools.json`
- Regeneration: `bash /workspace/fluffychat/scripts/generate_messie_api.sh`

### Dockerized Build & Deploy (Web Prod)

- This agent runs on the NixOS host, NOT inside the /workspace VM. Flutter is not available directly here.
- Web prod builds use `Dockerfile.web` which has Flutter + Rust toolchain baked in.
- Build: `cd /home/arpin/code/fluffychat && docker build -f Dockerfile.web -t fluffychat-web:prod .`
- Preferred helper: `bash scripts/build_web_prod.sh`
- The build takes ~15-25 min first time (Rust/WASM compile), but Docker layer caching makes subsequent builds fast if only Dart code changed.
- Deploy target: `arpin-hp.local` (Windows host running Docker Desktop)
- Cannot pull images there; must `docker save | gzip | ssh arpin-hp.local "docker load"`
- Treat `arpin-hp.local` as a no-pull deploy target for both client and backend images: build locally, transfer with `docker save | gzip | ssh arpin-hp.local "docker load"`, then restart containers there instead of rebuilding remotely with `docker compose build`
- Deploy sequence:
  ```
  docker save fluffychat-web:prod | gzip | ssh arpin-hp.local "docker load"
  ssh arpin-hp.local "docker stop fluffychat-web && docker rm fluffychat-web && docker run -d --name fluffychat-web --network messie-messenger_default -p 3000:80 fluffychat-web:prod"
  ```
- APK builds use `Dockerfile.apk` (arm64 only, ~20 min)
- Preferred APK builder: `bash scripts/build_apk_docker.sh`
- `scripts/build_apk_docker.sh` exports the artifact to `build/android/app-release.apk` by default instead of leaving it inside the image
- Upgrade-compatible APK builds require local signing material in `android/key.properties`; use `APK_SIGNING_MODE=dev` only for disposable local installs that will conflict with an already-installed release-signed app
- Linux desktop build: `Dockerfile.linux` + `run-linux.sh` (X11 forwarding)
- Preferred helper: `bash scripts/build_linux_docker.sh`
- `run-linux.sh` launches `FLUFFYCHAT_LINUX_IMAGE` if set, otherwise `fluffychat-linux:latest`; when rebuilding Linux images for testing, also tag the build as `fluffychat-linux:latest` unless you intentionally want a side tag only, so desktop runs do not silently use a stale image
- Build logs go to `/tmp/opencode/` for post-mortem
- Preferred one-command build+deploy helper: `bash scripts/build_and_deploy_web_remote.sh`
- Direct deploy helper when images are already built: `bash scripts/deploy_web_remote.sh`

### Git

- Branch: `main`
- For every new issue or feature, create a new feature branch from `main`
- Make small checkpoint commits; amend after user runtime/device feedback
- Do not commit directly to `main`
- Squash merge completed feature branches into `main` when user approves
- Preferred squash helper: `bash scripts/squash_merge_branch.sh <feature-branch> "<commit subject>"`
- Prefer targeted `flutter test --no-pub` and `dart analyze`/`flutter analyze --no-pub` over broad full-project verification

### Smoke Tests

- Prefer a two-layer smoke-test workflow:
  - fast widget smoke tests in `test/` for keyboard/navigation regressions
  - full `flutter test` suite in Docker for stable automated coverage across services, widgets, and app logic
- Default entrypoint: `bash scripts/run_smoke_tests.sh widget`
- Broader automated suite: `bash scripts/run_smoke_tests.sh full`
- For experimental end-to-end smoke tests: `bash scripts/run_smoke_tests.sh integration`
- For user-requested visible/manual inspection of Linux integration tests: `VISIBLE=1 bash scripts/run_smoke_tests.sh integration`
- Headless Linux smoke-test image: `Dockerfile.test-linux`
- The smoke-test script runs `flutter pub get` inside the container against the bind-mounted workspace before running tests
- Current widget smoke suite includes:
  - `test/shortcut_resolver_test.dart`
  - `test/shortcut_help_model_test.dart`
  - `test/shortcut_context_conditions_test.dart`
- The current reliable automation path is `widget` plus `full`; Linux/web integration remains experimental because Linux desktop is blocked by libsecret runtime behavior and Flutter web integration is not supported by `integration_test`
- Keep existing unit/widget tests and integration tests; add new smoke tests rather than replacing them
- Use widget smoke tests as the default pre-handoff verification for keyboard/navigation work because they are much faster than Synapse-backed integration tests
- Android emulator is the primary local integration target when end-to-end verification is needed; prefer `bash scripts/run_android_integration.sh run` for narrowed reruns
- To minimize Android rerun cost, prefer ABI-limited local emulator builds via `TARGET_ABI_FILTERS=x86_64` and reset app state before each narrowed rerun
- The Android integration runner clears app data by default before each run so stale sessions do not mask real UI failures
- When reproducing first-login/bootstrap flows, also reset homeserver state with `PREPARE_HOMESERVER=1`; app-only reset is not enough because Synapse account data persists across reruns

### Automated Workflow

- Default development loop for UI/keyboard/navigation changes:
  1. make the code change
  2. run `bash scripts/run_smoke_tests.sh widget`
  3. fix failures before moving on
  4. run `bash scripts/run_smoke_tests.sh full` before handoff
  5. if the change specifically touches Synapse-backed integration wiring, optionally investigate `bash scripts/run_smoke_tests.sh integration`, but do not treat it as the required green gate
- Use the headless widget smoke suite as the first-line regression net during development; do not wait until the end of a task to run it
- Escalate from widget smoke tests to the full Dockerized `flutter test` suite when changes affect:
  - focus/keyboard behavior across multiple screens
  - routing or page-open/close behavior
  - server-backed flows such as login, messaging, archive, todos, or calendar
- Use Linux integration tests only as extra investigation when specifically debugging the integration harness
- Use `VISIBLE=1 bash scripts/run_smoke_tests.sh integration` only when the user explicitly asks for a visible/manual run; otherwise prefer headless mode
- When adding a new keyboard/navigation feature or fixing a regression, add or update a widget smoke test in the same turn so the workflow stays increasingly automated
- For Android integration debugging, prefer this loop:
  1. `SYNAPSE_PORT=40280 HOMESERVER=localhost:40280 bash scripts/prepare_integration_test.sh`
  2. `bash scripts/run_android_integration.sh build`
  3. `TEST_NAME="Login and logout flow" bash scripts/run_android_integration.sh run`
  4. repeat step 3 for narrowed reruns until the failure is understood
- For first-login/bootstrap debugging, prefer `PREPARE_HOMESERVER=1 TEST_NAME="Login and logout flow" bash scripts/run_android_integration.sh run` so server-side SSSS state is reset too
- Keep tool-output token use low during debugging and verification:
  - prefer saving large command output to `/tmp/opencode/...` or other files instead of pasting it into chat
  - grep or otherwise return only decisive lines back into context
  - avoid repeated full-log reads when a narrow follow-up read or search will do

### Keyboard Shortcuts

- To minimize upstream merge conflicts, keep keyboard shortcut architecture concentrated under `lib/utils/keyboard/` whenever possible
- Prefer central resolver/registry files plus thin page-level adapter registration over embedding large amounts of keyboard behavior directly in `chat.dart`, `chat_list.dart`, or other upstream-heavy controller/view files
- Extracted widgets that reduce conflict surface:
  - `lib/pages/chat/chat_keyboard_actions.dart` (was inline in `chat_view.dart`)
  - `lib/pages/chat/message_focus_wrapper.dart` (was inline in `chat_event_list.dart`)
  - `lib/pages/chat_list/chat_list_entries.dart` (was inline in `chat_list_body.dart`)
- Still pending extraction (lower priority):
  - keyboard Actions wrapper from `chat_list_body.dart` to own widget
  - todo/calendar filtering logic from `chat_list_body.dart` to controller helper
  - `fluffy_chat_app.dart` StatelessWidget restoration with extracted keyboard host

### Upstream Merge Strategy

- `chat_list_body.dart` is the highest-conflict file because it contains our todo/calendar interleaving, keyboard navigation wrappers, and bridge presentation alongside upstream's chat list rendering
- When merging upstream, prefer taking their version of structural layout changes and re-adding our features on top, rather than trying to resolve inline conflicts
- Upstream's `_customEnterKeyHandling` in `chat.dart` adds up-arrow-to-edit-last-message which conflicts with our message navigation; we remove that block and handle it through our resolver instead
- Keep fork additions in clearly separated sections where possible, but do not churn shared files just to move code around
- Prefer extracting fork-only policy, data shaping, service loading, and route-builder logic into fork-owned helpers instead of extracting mostly-upstream widget or page structure
- Do not extract shared UI/layout blocks just to make a file smaller; only extract when the moved block is mostly fork-owned or already heavily diverged from upstream
- Good extraction targets are helper seams like:
  - bridge notification suppression or homeserver migration policy from `matrix.dart`
  - bridge catalog loading and login-number mapping from `chat_list.dart`
  - Messie-only auth, calendar, todos, and connections route builders from `routes.dart`
- Bad extraction targets are mostly-upstream UI scaffolds like large chunks of `chat_list_item.dart`, `chat_list_view.dart`, or shell/widget tree structure in `routes.dart`
- Treat these files as persistent high-conflict shared files and avoid opportunistic reshaping unless a new fork-only seam appears:
  - `lib/pages/chat_list/chat_list.dart`
  - `lib/pages/chat_list/chat_list_item.dart`
  - `lib/pages/chat_list/chat_list_view.dart`
  - `lib/pages/chat/chat.dart`
- Remove temporary debug instrumentation from shared upstream-owned files as soon as it is no longer needed; debug residue in files like `matrix.dart` causes avoidable merge conflicts later
- When touching shared files, prefer tiny local substitutions over structural rewrites:
  - inject fork-computed values
  - register fork helpers/adapters
  - add a narrow fork-specific branch
  - avoid reshaping the whole widget tree
- Use public extracted classes and helpers (not private `_` prefixed) so they can live in separate files

### Known SDK Issues

- Old Linux `SqfliteFfiException(database is locked)` errors during Matrix sync/key upload appear to come from the upstream `matrix` package transaction flow, not from FluffyChat chat UI changes
- Likely root cause: `Client._innerSync` opens a database transaction, emits `onSync` before that transaction fully finishes, and `KeyManager.uploadInboundGroupSessions()` then performs separate DB reads on the same SQLite file
- Treat this as an SDK-level re-entrant DB access issue unless new evidence points to app code
- Current decision: document it and leave it alone locally rather than carrying a fork patch without a live repro or upstreamable fix

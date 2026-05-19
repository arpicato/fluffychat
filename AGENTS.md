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
- The build takes ~15-25 min first time (Rust/WASM compile), but Docker layer caching makes subsequent builds fast if only Dart code changed.
- Deploy target: `arpin-hp.local` (Windows host running Docker Desktop)
- Cannot pull images there; must `docker save | gzip | ssh arpin-hp.local "docker load"`
- Deploy sequence:
  ```
  docker save fluffychat-web:prod | gzip | ssh arpin-hp.local "docker load"
  ssh arpin-hp.local "docker stop fluffychat-web && docker rm fluffychat-web && docker run -d --name fluffychat-web --network messie-messenger_default -p 3000:80 fluffychat-web:prod"
  ```
- APK builds use `Dockerfile.apk` (arm64 only, ~20 min)
- Linux desktop build: `Dockerfile.linux` + `run-linux.sh` (X11 forwarding)
- Build logs go to `/tmp/opencode/` for post-mortem

### Git

- Branch: `main`
- For every new issue or feature, create a new feature branch from `main`
- Make small checkpoint commits; amend after user runtime/device feedback
- Do not commit directly to `main`
- Squash merge completed feature branches into `main` when user approves
- Prefer targeted `flutter test --no-pub` and `dart analyze`/`flutter analyze --no-pub` over broad full-project verification

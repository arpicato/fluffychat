#!/usr/bin/env bash

set -euo pipefail

bash scripts/build_web_prod.sh
bash scripts/build_linux_docker.sh
bash scripts/deploy_web_remote.sh

#!/usr/bin/env bash

set -euo pipefail

existing_homeserver="${HOMESERVER-}"
existing_user1_name="${USER1_NAME-}"
existing_user1_pw="${USER1_PW-}"
existing_user2_name="${USER2_NAME-}"
existing_user2_pw="${USER2_PW-}"
synapse_port="${SYNAPSE_PORT:-80}"

# SPDX-FileCopyrightText: 2019-Present Christian Kußowski
# SPDX-FileCopyrightText: 2019-Present Contributors to FluffyChat
#
# SPDX-License-Identifier: AGPL-3.0-or-later

source integration_test/data/integration_users.env

if [[ -n "$existing_homeserver" ]]; then HOMESERVER="$existing_homeserver"; fi
if [[ -n "$existing_user1_name" ]]; then USER1_NAME="$existing_user1_name"; fi
if [[ -n "$existing_user1_pw" ]]; then USER1_PW="$existing_user1_pw"; fi
if [[ -n "$existing_user2_name" ]]; then USER2_NAME="$existing_user2_name"; fi
if [[ -n "$existing_user2_pw" ]]; then USER2_PW="$existing_user2_pw"; fi

REGISTRATION_SHARED_SECRET="$(python3 - <<'PY'
from pathlib import Path
import re

text = Path('integration_test/synapse/data/homeserver.yaml').read_text()
match = re.search(r'^registration_shared_secret:\s*"([^"]+)"\s*$', text, re.MULTILINE)
if not match:
    raise SystemExit('registration_shared_secret not found in homeserver.yaml')
print(match.group(1))
PY
)"

if command -v docker >/dev/null 2>&1; then
    docker rm -f synapse 2>/dev/null || true
    docker container ls -aq --filter name='^synapse$' | xargs -r docker rm -f >/dev/null 2>&1 || true

    docker run -d --name synapse --tmpfs /data \
        --volume="$(pwd)/integration_test/synapse/data/homeserver.yaml":/data/homeserver.yaml:rw \
        --volume="$(pwd)/integration_test/synapse/data/localhost.log.config":/data/localhost.log.config:rw \
        -p "${synapse_port}:80" matrixdotorg/synapse:latest
else
    echo "docker not available in this environment; assuming homeserver is managed externally"
fi

while ! curl -XGET "http://$HOMESERVER/_matrix/client/v3/login" >/dev/null 2>/dev/null; do
echo "Waiting for homeserver to be available... (GET http://$HOMESERVER/_matrix/client/v3/login)"
    sleep 2
done

echo "Homeserver is online!"

while ! curl -fsS "http://$HOMESERVER/_synapse/admin/v1/register" >/dev/null 2>/dev/null; do
echo "Waiting for admin registration endpoint... (GET http://$HOMESERVER/_synapse/admin/v1/register)"
    sleep 2
done

echo "Admin registration endpoint is online!"

# create users
register_user() {
    local username="$1"
    local password="$2"
    local nonce
    local mac

    nonce="$(curl -fsS "http://$HOMESERVER/_synapse/admin/v1/register" | python3 -c 'import json,sys; print(json.load(sys.stdin)["nonce"])')"
    mac="$(python3 - "$nonce" "$username" "$password" "$REGISTRATION_SHARED_SECRET" <<'PY'
import hmac
import sys

nonce, username, password, secret = sys.argv[1:5]
message = b"\x00".join([
    nonce.encode(),
    username.encode(),
    password.encode(),
    b"notadmin",
])
print(hmac.new(secret.encode(), message, "sha1").hexdigest())
PY
)"

    curl -fS --retry 3 \
        -H 'Content-Type: application/json' \
        -XPOST \
        -d "{\"nonce\":\"${nonce}\",\"username\":\"${username}\",\"password\":\"${password}\",\"admin\":false,\"mac\":\"${mac}\"}" \
        "http://$HOMESERVER/_synapse/admin/v1/register"
}

register_user "$USER1_NAME" "$USER1_PW"
register_user "$USER2_NAME" "$USER2_PW"

echo "Homeserver is ready."

#!/usr/bin/env bash
set -euo pipefail
host=${HEALTHCHECK_HOST:-127.0.0.1}
port=7777
curl --fail --silent --show-error "http://${host}:${port}/healthz"

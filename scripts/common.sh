#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
docker_cmd() {
  if docker info >/dev/null 2>&1; then
    docker "$@"
  elif id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
    local command
    printf -v command '%q ' docker "$@"
    if command -v sg >/dev/null 2>&1; then
      sg docker -c "$command"
    elif command -v newgrp >/dev/null 2>&1; then
      newgrp docker -c "$command"
    else
      echo 'Log out/in once to activate Docker group membership.' >&2
      return 1
    fi
  else
    echo 'Docker is unavailable. Enable Docker and log in with docker group membership.' >&2
    return 1
  fi
}
dc() {
  local compose_file="${COMPOSE_FILE:-$ROOT/compose/compose.yaml}"
  docker_cmd compose --env-file "$ROOT/.env" -f "$compose_file" "$@"
}

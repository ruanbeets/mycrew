#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
dc() {
  local args=(docker compose --env-file "$ROOT/.env" -f "$ROOT/compose/compose.yaml")
  if docker info >/dev/null 2>&1; then
    "${args[@]}" "$@"
  elif id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
    local command
    printf -v command '%q ' "${args[@]}" "$@"
    sg docker -c "$command"
  else
    echo 'Docker is unavailable. Enable Docker and log in with docker group membership.' >&2
    return 1
  fi
}

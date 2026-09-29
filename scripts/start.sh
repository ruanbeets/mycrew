#!/usr/bin/env bash
source "$(dirname -- "$0")/common.sh"
python3 "$ROOT/scripts/init.py"
curl --fail --silent http://127.0.0.1:11434/api/version >/dev/null || {
  echo 'Ollama is unavailable. Start its service first.' >&2; exit 1;
}
dc up -d postgres litellm
ready=false
for ((i=0; i<90; i++)); do
  if curl --fail --silent http://127.0.0.1:4000/health/liveliness >/dev/null; then
    ready=true; break
  fi
  sleep 2
done
if [[ "$ready" != true ]]; then
  echo 'LiteLLM failed to become ready; inspect scripts/logs.sh litellm.' >&2
  exit 1
fi
python3 "$ROOT/scripts/provision-key.py"
dc up -d hermes
echo 'Micru starting. Dashboard: http://127.0.0.1:9119 — scripts/health.sh checks readiness.'

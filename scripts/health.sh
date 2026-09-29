#!/usr/bin/env bash
source "$(dirname -- "$0")/common.sh"
failed=0
for endpoint in 'Ollama|11434/api/version' 'LiteLLM|4000/health/liveliness' 'Hermes|8642/health' 'Dashboard|9119/api/status'; do
  name="${endpoint%%|*}"; path="${endpoint#*|}"
  if curl --fail --silent --max-time 5 "http://127.0.0.1:$path" >/dev/null; then
    echo "$name: reachable"
  else
    echo "$name: unavailable"; failed=1
  fi
done
if dc exec -T postgres pg_isready -U mycrew -d mycrew; then :; else failed=1; fi
exit "$failed"

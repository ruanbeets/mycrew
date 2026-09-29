#!/usr/bin/env bash
source "$(dirname -- "$0")/common.sh"
dc stop
echo 'Micru containers stopped; data retained. Existing host Ollama/Tailscale services unchanged.'

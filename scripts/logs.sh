#!/usr/bin/env bash
source "$(dirname -- "$0")/common.sh"
dc logs --tail 100 -f "$@"

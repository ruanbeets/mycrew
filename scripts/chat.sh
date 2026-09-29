#!/usr/bin/env bash
source "$(dirname -- "$0")/common.sh"
# docker exec otherwise defaults to image root, so explicitly use the non-root account.
dc exec --user hermes -w /workspace hermes hermes chat "$@"

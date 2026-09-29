#!/usr/bin/env bash
source "$(dirname -- "$0")/common.sh"
"$ROOT/scripts/health.sh"
"$ROOT/scripts/status-json.sh" > "$ROOT/workspace/artifacts/host-status.json"
cp "$ROOT/workspace/artifacts/host-status.json" "$ROOT/logs/before-agent-test.json"
mission='Inspect this Micru installation using the timestamped host snapshot /workspace/artifacts/host-status.json. Call delegate_task once in batch mode with exactly two independent leaf workers: one evaluates host resource availability from that file, the other checks localhost service health using that file and harmless HTTP GET health endpoints. Use only read-only commands. No installations, configuration changes, external messages, paid APIs or destructive actions. Workers must distinguish host observations from container observations. Return one brief consolidated report including both workers findings and any limitations. Do not claim delegation unless the tool actually succeeded.'
# Bounded local test; timeout terminates this CLI session, never the gateway.
# The CLI runs explicitly as the unprivileged Hermes account.
set +e
dc exec -T --user hermes -w /workspace hermes timeout 300 hermes chat -q "$mission" -t terminal,delegation > "$ROOT/logs/agent-smoke.log" 2>&1
result=$?
set -e
"$ROOT/scripts/status-json.sh" > "$ROOT/logs/after-agent-test.json"
echo "Agent test exit: $result. Inspect logs/agent-smoke.log; exit zero alone does not prove delegation."
exit "$result"

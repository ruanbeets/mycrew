# Micru setup report

Status: configuration prepared; live stack verification in progress. This report
is deliberately explicit about incomplete work and is updated after live tests.

## Installed

Audited host: CachyOS, Intel i5-8400 (6 CPUs), approximately 16 GB RAM,
NVIDIA GTX 1660 SUPER 6 GB with existing driver 615.71.09.
Existing Docker 29.8.1 and Compose 5.5.1; existing Ollama 0.34.4.
Downloaded exactly one model: `qwen3:4b`, ID `359d7dd4bcda`, approximately 2.5 GB.
No desktop, dotfiles, drivers, kernel, boot or unrelated services were changed.

## Running services

Ollama was already running and enabled, bound to 127.0.0.1:11434; retained.
Docker and Tailscale were inactive at last audit. Starting them requires the
Captain's local sudo authentication. PostgreSQL, LiteLLM and Hermes are configured
in Compose but cannot be claimed running until Docker is available.
Containers use `unless-stopped`; official Hermes s6 supervises gateway/dashboard.

## Architecture

```text
Captain → Micru (Hermes) → ≤2 leaf sub-agents, depth 1
                    └──────────┴→ LiteLLM → Ollama qwen3:4b
                                    └→ PostgreSQL usage accounting
                                    └→ future cloud routes (disabled)
```

Hermes uses the official Docker distribution to isolate the personal home and
avoid installing dependencies into the desktop user's environment. PostgreSQL 17
uses a named persistent volume; `ledger` contains five minimal future-use tables.
They are not yet automatically populated from Hermes missions. LiteLLM owns
its separate usage/accounting tables.

## Network/security

Planned binds: Ollama 11434, LiteLLM 4000, PostgreSQL 5433, Hermes API 8642 and
dashboard 9119, all **127.0.0.1 only**. Database container port 5432 stays internal.
Hermes and LiteLLM use Linux host networking to reach the existing private Ollama;
this does not isolate them from host-local network services. Host files remain
restricted to explicit mounts. No Docker socket or sudo access for agents.
Supervisor commands use manual approvals; unattended/cron/child danger matches
are denied. Config is read-only in the container. Credentials are ignored by Git.
Hermes receives only a local-model virtual key, not the LiteLLM administrator key.
No public routes, Funnel, router changes or unrelated service changes.

## Models

The first 16K-context test loaded 77% on GPU / 23% CPU (Ollama report), with about
4,680 MiB total GPU VRAM used including the desktop. Generation was about
29.24 tokens/sec, with 68.22 seconds cold-start wall time. The 120-token response
budget was exhausted on reasoning instead of a completed answer, so this is
inference verification, **not** a successful supervisor capability test.
The final **8K context** fits **100% on GPU**, using approximately 4,402 MiB total
VRAM including the desktop. With native thinking enabled and temperature 0.2,
the model returned a correct, concise definition in **5.81 seconds**, generating
at **73.67 tokens/sec**. Forced thinking-off produced reasoning leakage with this
model template, so native thinking is retained. These are short-answer results;
long prompts and concurrent requests will be slower. Ollama unloads after 5 idle
minutes, freeing model VRAM. There is still only one downloaded model.

## Costs

No paid APIs called; cloud spend **US$0**. Local electricity/download costs are
not estimated. Cloud examples are not loaded and no provider credentials are
required. Future cloud access must use a separate budget-limited virtual key;
do not attach a shared global budget that disables the free local route.

## Resource baseline

Initial approximate desktop baseline: 6.85 GiB RAM used, 9.07 GiB available;
GPU 758–800 MiB VRAM, 7–8% utilization, 36°C. This is a live desktop, not a clean
server-idle benchmark. Machine-readable observations are in ignored `logs/`.
Full idle/control-plane and agent-test measurements await container startup.

## How I use it

From the repository: `scripts/chat.sh`, `scripts/status.sh`, `scripts/health.sh`,
`scripts/start.sh`, `scripts/stop.sh`, `scripts/restart.sh`, `scripts/logs.sh`.
Dashboard: http://127.0.0.1:9119 once running.
The official dashboard exposes session/gateway state, token/cost analytics, and
a Host view with CPU/RAM/load/disk data when psutil is installed. Container limits
affect how host values should be interpreted. GPU instrumentation is in status.sh.
Use `scripts/smoke-test.sh` for a bounded local-only two-worker test, not health.sh.

## Remote access

Tailscale installation/service/authentication pending. After the administrator
commands, run `sudo tailscale up` and follow its login URL. See docs/REMOTE.md.
SSH server and public exposure are not configured.

## Telegram

Not configured; no bot token supplied. Exact BotFather, allowlist and restart
steps are in docs/REMOTE.md. Missing credentials do not block local use.

## Voice

Native Telegram voice/STT/TTS options documented in [docs/VOICE_PHASE2.md](docs/VOICE_PHASE2.md).
STT is disabled in Phase 1; no separate voice models or services installed.

## Tests

- Python compilation and shell syntax checks passed.
- Docker Compose configuration validates.
- Image manifests resolved and exact x86_64 digests pinned. Hermes's documented
  `stable` tag was unavailable in the registry, so the official `latest` image
  was resolved and pinned by digest instead.
- Ollama local inference executed; GPU acceleration verified, with CPU spill at 16K.
- A completed 8K-context local inference test passed, fully GPU-resident.
- Full proxy/database/dashboard/delegation/recovery tests pending Docker availability.
- No reboot performed; boot persistence must be checked through enabled units and
  restart policies, not assumed from a successful start.

## Problems

Administrator authentication is needed to start Docker/install Tailscale.
Small-model delegation reliability is not yet established. No cloud fallback has
been silently enabled. Do not treat this as a production autonomous system yet.

## Next phase

1. Complete live stack/delegation validation and inspect resource measurements.
2. Authenticate Tailscale and verify private access.
3. Connect allowlisted Telegram if desired.
4. If the small model is insufficient, authorize one tightly budgeted cloud route.
5. Validate backup restoration before entrusting persistent missions.

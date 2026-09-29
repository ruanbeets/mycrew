# Mycrew setup report

Status: installed and checked on the host. Local services and data persistence
work. The small local model did not pass the Hermes delegation test.

## Installed

Audited host: CachyOS, Intel i5-8400 (6 CPUs), approximately 16 GB RAM,
NVIDIA GTX 1660 SUPER 6 GB with existing driver 615.71.09.
Existing Docker 29.8.1 and Compose 5.5.1; existing Ollama 0.34.4.
Downloaded exactly one model: `qwen3:4b`, ID `359d7dd4bcda`, approximately 2.5 GB.
No desktop, dotfiles, drivers, kernel, boot or unrelated services were changed.

## Running services

Ollama 0.34.4 runs as its existing enabled service, bound to 127.0.0.1:11434.
Docker 29.8.1, Compose 5.5.1, Tailscale 1.102.4, PostgreSQL 17, Hermes 0.21.5,
and LiteLLM (official image pinned by immutable digest) are installed/running. PostgreSQL reports
healthy; the `mycrew` database and login role are active. The five ledger tables
are present. Tailscale is authenticated; this node is `batcomputer` at
100.83.141.62. Its status reports a systemd-resolved/NetworkManager MagicDNS
warning, so use the Tailscale IP until DNS is corrected. Docker, Ollama and
Tailscale are enabled services; containers use `unless-stopped`; Hermes s6
supervises the gateway and dashboard.

## Architecture

```text
Captain → Mycrew (Hermes) → ≤2 leaf sub-agents, depth 1
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

Verified binds: Ollama 11434, LiteLLM 4000, PostgreSQL 5433, Hermes API 8642 and
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
Hermes requires at least a **64K context**, so the local route is configured at
that size. Qwen loaded with a 65,536-token context and about 3.8 GB of model VRAM.
A short direct local inference at 8K returned a correct definition in 5.81 seconds
at 73.67 tokens/sec; this is not representative of full-context agent work.
During the 64K Hermes attempt, total host RAM use reached about 12.9 GiB, available
RAM fell to 3.0 GiB, GPU use peaked near 97% (about 4.6 GiB VRAM), and CPU use
reached about 74%. The model repeatedly reasoned about the delegation instructions
and did not call its delegation tool within roughly two minutes; the bounded test
was stopped. **Qwen3:4b is not currently a reliable Hermes supervisor/delegator on
this machine.** Local inference is available, but use Hermes for consequential
or multi-step work only after a capable route is configured and tested. No cloud
provider route or key is enabled. The context can also create memory pressure on
this 16 GB desktop.

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

| Observation | RAM used / available | CPU sample / 1-min load | GPU VRAM / utilization |
|---|---|---|---|
| Initial desktop baseline | 6,860 / 9,060 MiB | 5.8% / 1.90 | 622 MiB / 20% |
| Control plane, after short inference | 8,128 / 7,792 MiB | 5.0% / 1.54 | 860 MiB / 10% |
| 64K model during Hermes test | 12,837 / 3,083 MiB | 74% / 5.34 | 4,618 MiB / 100% |

These are brief desktop snapshots, not sustained-load averages. The control plane
was idle and healthy after the test, with about 3.7 GiB RAM available while the
local model remained loaded. Light 24/7 service operation appears practical; full
context local inference leaves little memory headroom on this desktop.

## How I use it

From the repository: `scripts/chat.sh`, `scripts/status.sh`, `scripts/health.sh`,
`scripts/start.sh`, `scripts/stop.sh`, `scripts/restart.sh`, `scripts/logs.sh`.
Dashboard: http://127.0.0.1:9119. Hermes reports gateway, dashboard, storage and
API-server health as `ok`; CPU/RAM/disk summary and session/token/cost views are
available there. GPU and host resource details are in `scripts/status.sh`.
The official dashboard exposes session/gateway state, token/cost analytics, and
a Host view with CPU/RAM/load/disk data when psutil is installed. Container limits
affect how host values should be interpreted. GPU instrumentation is in status.sh.
Use `scripts/smoke-test.sh` for a bounded local-only two-worker test, not health.sh.

## Remote access

Tailscale is authenticated. The MagicDNS warning is in the status above. No SSH
server, Funnel, public bind or router port forwarding was configured. See
docs/REMOTE.md for safe private access guidance.

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
- Local health check passed for Ollama, LiteLLM, Hermes, the dashboard and PostgreSQL.
- PostgreSQL contains `missions`, `tasks`, `agent_runs`, `model_calls` and `system_events`.
- Two-worker test did not succeed: local Qwen reasoned without issuing a delegation
  tool call and was stopped after about two minutes. No child workers ran.
- Tailscale is authenticated; status has a MagicDNS integration warning.
- No reboot performed; boot persistence must be checked through enabled units and
  restart policies, not assumed from a successful start.
- Re-running secret initialization preserved the existing `.env` byte-for-byte;
  its file permissions exclude other users. Runtime and secret paths are ignored.
- Database and current volume naming were migrated to Mycrew. A private SQL backup
  is in ignored `backups/`; the original Docker volume remains unmodified for rollback.
- All intended tracked files reviewed for credentials; configuration/scripts/docs
  committed in logical commits and pushed to `git@github.com:ruanbeets/mycrew.git`.

## Problems

Local Qwen can answer short inference tests, but did not demonstrate delegation
and consumes substantial RAM at the minimum Hermes context size. Cloud routes
remain disabled; choose and explicitly authorize a budget-limited capable model
before relying on agent delegation. Tailscale MagicDNS may not work until the
systemd-resolved/NetworkManager integration is fixed.

## Next phase

1. Select and authorize one low-cost model capable of Hermes tool use.
2. Fix/verify Tailscale MagicDNS, or keep using the private Tailscale IP.
3. Configure an allowlisted Telegram bot if desired.
4. Validate restoration from the private PostgreSQL/Hermes backups.
5. Run a boot recovery check during a planned maintenance window.

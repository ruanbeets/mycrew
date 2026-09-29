# Micru

A small, private AI supervisor on CachyOS: Hermes, one local Ollama model,
LiteLLM routing/accounting and PostgreSQL. This existing `mycrew` repository
is the portable source of truth. No desktop or dotfile changes.

## Quick install

On x86_64 CachyOS/Arch with working NVIDIA drivers, adequate disk space, Git and SSH:

```bash
git clone git@github.com:ruanbeets/mycrew.git ~/dev/mycrew
cd ~/dev/mycrew
./install.sh
```

Read `install.sh` first. It installs missing official repository packages,
enables Docker/Ollama/Tailscale, downloads one model and the official container
images, generates local secrets once, and starts the stack. Docker group
membership grants host administration privileges **to you**, never to Hermes.
Existing NVIDIA drivers and host Ollama installation are preserved.

## Use

```bash
./scripts/chat.sh                 # talk to the supervisor
./scripts/status.sh               # host/service observations, no model calls
./scripts/status-json.sh          # JSON for a future console
./scripts/health.sh               # readiness, nonzero if unavailable
./scripts/start.sh
./scripts/stop.sh                 # preserves all persistent data
./scripts/restart.sh
./scripts/logs.sh                 # Ctrl-C exits the log viewer only
```

Dashboard: **http://127.0.0.1:9119**. Do not bind it publicly.
Local model: `qwen3:4b`; cloud routes are disabled examples, not active fallback.
The initial small model is an experiment in tool reliability, not a promise of
strong autonomous engineering performance. See [SETUP_REPORT.md](SETUP_REPORT.md).

```text
Captain → Hermes supervisor → at most 2 leaf workers
                   └──────────────┴→ LiteLLM → Ollama / qwen3:4b
                                       └→ PostgreSQL usage records
                                       └→ cloud routes (disabled)
```

## Boundaries and persistence

Only `workspace/` and Hermes's own private `state/hermes/` are writable host
mounts inside Hermes. No host home, Docker socket, banking credentials or sudo.
Container runtime files and local model credentials are necessarily visible
to the agent; these credentials cannot select cloud models or administer LiteLLM.
Dangerous-command matching uses manual approval; unattended and worker requests
are denied. This is layered containment, not a guarantee against every malicious
command. Host networking allows localhost service access and normal outbound
network access; it is not a network isolation boundary.

Config and SOUL are mounted read-only: edit the versioned files and restart.
Hermes sessions/memory persist in `state/hermes`; PostgreSQL persists in Docker's
named `micru_ledger` volume. LiteLLM records actual calls in its own tables.
The five `ledger.*` tables are an empty expansion foundation, not an invented
automatic mission-accounting integration. No cron jobs or outreach are created.

Docker restart policies and Hermes's official s6 supervision recover crashes.
After `stop.sh`, containers deliberately remain stopped across reboots until
`start.sh` is used. No automatic operating-system reboot is performed.

## Secrets, backup and updates

Never commit `.env`, `state/`, `logs/`, `workspace/`, database dumps or credentials.
Secrets are generated with private file permissions. `scripts/init.py` preserves
existing values. Back up `.env`, `state/hermes/` and the database together to a
private destination; the database password and LiteLLM salt must be retained.

Before updating configuration, copy the existing version to `backups/` and review
the Git diff. Stop Hermes before copying its SQLite state. Export PostgreSQL with:

```bash
mkdir -p backups
chmod 700 backups
bash -c 'source scripts/common.sh; dc exec -T postgres pg_dump -U micru micru' > backups/micru.sql
chmod 600 backups/micru.sql
```

Container images are pinned by digest for x86_64. Pull repository updates, review changes and run `start.sh`. To update container
images deliberately, review upstream release notes and image pins, back up first,
then pull and recreate. Never use `docker compose down -v`: it destroys the ledger.
Rollback configuration with Git after preserving local edits; restoring database
backups may be required after application schema migrations.

Remote access and Telegram: [docs/REMOTE.md](docs/REMOTE.md).
Voice preparation: [docs/VOICE_PHASE2.md](docs/VOICE_PHASE2.md).
Official references: [docs/SOURCES.md](docs/SOURCES.md).

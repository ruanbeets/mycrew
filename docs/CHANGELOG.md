# Mycrew setup changes

2026-09-29:

- Audited host hardware, memory, GPU, ports, Ollama/Docker/Tailscale and existing Git repo.
- Used existing `/home/batman/dev/mycrew` repository; did not create a second repository.
- Downloaded `qwen3:4b` into the existing Ollama service's normal model store.
- Tested direct local inference at 8K, then configured Hermes's 64K minimum context.
- Added versioned Hermes/SOUL, LiteLLM, disabled cloud examples, minimal SQL schema,
  Compose, install/lifecycle/monitoring/smoke scripts and documentation.
- Generated ignored private `.env` using cryptographic randomness; no existing secrets overwritten.
- Created ignored runtime/workspace/log/backup directories. No existing user configuration
  required replacement, so there are no pre-existing files to restore at this stage.
- Pinned official container image manifests; no cloud provider was called.
- Enabled Docker and Tailscale; authenticated Tailscale.
- Migrated the existing database and persistent volume to Mycrew identifiers. Kept
  the original volume unmodified and a private SQL dump in ignored backups for rollback.
- Verified localhost health for Ollama, LiteLLM, Hermes, its dashboard and PostgreSQL;
  confirmed all five ledger tables exist.
- Tested local Hermes delegation. Qwen3:4b did not call the delegation tool within
  the bounded run, so no workers ran; no cloud calls or spend occurred.

No boot, display, shell, driver, filesystem, partition, desktop or unrelated-service
configuration was modified. See SETUP_REPORT.md for final verified status.

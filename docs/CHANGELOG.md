# Micru setup changes

2026-09-29:

- Audited host hardware, memory, GPU, ports, Ollama/Docker/Tailscale and existing Git repo.
- Used existing `/home/batman/dev/mycrew` repository; did not create a second repository.
- Downloaded `qwen3:4b` into the existing Ollama service's normal model store.
- Tested 16K and 8K contexts. Selected 8K after confirming complete GPU residency.
- Added versioned Hermes/SOUL, LiteLLM, disabled cloud examples, minimal SQL schema,
  Compose, install/lifecycle/monitoring/smoke scripts and documentation.
- Generated ignored private `.env` using cryptographic randomness; no existing secrets overwritten.
- Created ignored runtime/workspace/log/backup directories. No existing user configuration
  required replacement, so there are no pre-existing files to restore at this stage.
- Pinned official container image manifests; no cloud provider was called.
- Administrator service enablement and live container tests pending at this entry.

No boot, display, shell, driver, filesystem, partition, desktop or unrelated-service
configuration was modified. See SETUP_REPORT.md for final verified status.

# Official references checked during setup (2026-09-29)

- [Hermes installation](https://hermes-agent.nousresearch.com/docs/getting-started/installation/)
- [Official Hermes Docker deployment and s6 supervision](https://hermes-agent.nousresearch.com/docs/user-guide/docker)
- [Hermes security and approvals](https://hermes-agent.nousresearch.com/docs/user-guide/security/)
- [Hermes dashboard](https://hermes-agent.nousresearch.com/docs/user-guide/features/web-dashboard/)
- [Hermes Telegram and voice](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/telegram/)
- [Ollama Linux](https://docs.ollama.com/linux), [GPU support](https://docs.ollama.com/gpu), [qwen3:4b](https://ollama.com/library/qwen3:4b)
- [LiteLLM deployment](https://docs.litellm.ai/docs/proxy/deploy), [virtual keys](https://docs.litellm.ai/docs/proxy/virtual_keys), [Ollama tools](https://docs.litellm.ai/docs/providers/ollama)
- [MiMo V2.6 provider syntax](https://docs.litellm.ai/blog/mimo_v2_6)
- [DeepSeek provider syntax: deepseek-flash currently denotes V4.1 Flash](https://docs.litellm.ai/docs/providers/deepseek)
- [Official PostgreSQL image](https://hub.docker.com/_/postgres)
- [Tailscale Linux installation](https://tailscale.com/docs/install/linux), [Arch package/service](https://wiki.archlinux.org/title/Tailscale)

Cloud routes are examples only. Check current provider IDs and prices again before
enabling them. Use a separate cloud-only virtual key with an explicit small budget
and concurrency limit; do not add a global budget that disables local inference.

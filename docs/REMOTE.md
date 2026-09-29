# Private remote access and Telegram

## Tailscale

After installing/enabling Tailscale, authenticate locally:

```bash
sudo tailscale up
tailscale status
```

Follow the displayed login URL. Do not enable Funnel or router port forwarding.
The dashboard intentionally remains on localhost. Later, if SSH maintenance is
separately enabled and restricted to your tailnet, use a laptop SSH tunnel:

```bash
ssh -N -L 9119:127.0.0.1:9119 batman@YOUR_TAILSCALE_HOST
```

Then open http://127.0.0.1:9119 on the laptop. This phase does not install an SSH
server or alter firewall/router rules. A phone browser needs a separately reviewed
authenticated Tailscale Serve setup; do not change the dashboard to a public bind.

## Telegram (optional, not configured by default)

1. In Telegram, open the verified **@BotFather**, run `/newbot`, and retain its token.
2. Obtain your numeric Telegram user ID (for example via @userinfobot).
3. Add these to private `state/hermes/.env` without quotes or inline comments:

```dotenv
TELEGRAM_BOT_TOKEN=YOUR_BOT_TOKEN
TELEGRAM_ALLOWED_USERS=YOUR_NUMERIC_USER_ID
```

4. Run `./scripts/restart.sh`, open your bot, and send `/start`, then a harmless message.
5. Check `./scripts/logs.sh hermes`. Never share tokens or commit this file.

Hermes's gateway uses outbound Telegram polling; no public incoming port is
required. Keep the allowlist populated, use private direct messages initially,
and verify approval interactions before assigning consequential work. Daily
summaries/alerts require later explicit scheduling; none are set up yet.

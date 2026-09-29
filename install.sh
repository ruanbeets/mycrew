#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"
source /etc/os-release
if [[ "$ID" != cachyos && "$ID" != arch && " ${ID_LIKE:-} " != *' arch '* ]]; then
  echo 'This bootstrap supports CachyOS/Arch only.' >&2; exit 1
fi
[[ "$EUID" != 0 ]] || { echo 'Run as your normal user, not root.' >&2; exit 1; }
[[ "$(uname -m)" == x86_64 ]] || { echo 'Image pins currently target x86_64.' >&2; exit 1; }
sudo pacman -S --needed docker docker-compose tailscale python curl
sudo systemctl enable --now docker tailscaled
if ! command -v ollama >/dev/null; then
  # Official repository CUDA build, without replacing NVIDIA drivers.
  sudo pacman -S --needed ollama-cuda
fi
sudo systemctl enable --now ollama
if ! id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
  sudo usermod -aG docker "$USER"
fi
python3 scripts/init.py
ollama pull qwen3:4b
source scripts/common.sh
dc pull
scripts/start.sh
echo 'Optional remote access: sudo tailscale up. Telegram steps: docs/REMOTE.md.'
echo 'No reboot required. Log out/in to use docker directly in other terminals.'

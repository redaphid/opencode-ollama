#!/usr/bin/env bash
# Install opencode and uv on macOS or Linux, then link `oc` onto PATH.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
have() { command -v "$1" >/dev/null 2>&1; }

have node || { echo "Install Node.js 18+ first (https://nodejs.org or your package manager)." >&2; exit 1; }
have opencode || npm i -g opencode-ai

if ! have uv; then
  if have brew; then brew install uv; else curl -LsSf https://astral.sh/uv/install.sh | sh; fi
fi

mkdir -p "$HOME/.local/bin"
ln -sf "$HERE/bin/oc" "$HOME/.local/bin/oc"
case ":$PATH:" in *":$HOME/.local/bin:"*) ;; *) echo "Add \$HOME/.local/bin to PATH." ;; esac

echo "Done. Set CF_ACCESS_CLIENT_ID and CF_ACCESS_CLIENT_SECRET (see README), then run scripts/check.sh and oc."

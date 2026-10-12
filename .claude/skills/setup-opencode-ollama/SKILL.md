---
name: setup-opencode-ollama
description: Set up opencode on this machine to use the remote Ollama host (qwen3.8:27b) behind Cloudflare Access. Use when the user wants to install or reconfigure this harness on a new Mac, Linux, or Windows box.
---

# Set up opencode with remote Ollama

This repo's `config/opencode.json` points opencode at `https://ollama.hypnodroid.com/v1`.
The host sits behind Cloudflare Access, so `bin/oc` fetches a token with `cloudflared`
and passes it as `OLLAMA_ACCESS_TOKEN`. Never write that token to a file or commit it.

## Steps

1. Run the installer for the OS: `scripts/install.sh` (macOS/Linux) or `scripts/install.ps1` (Windows).
2. Ask the user to run `cloudflared access login https://ollama.hypnodroid.com` themselves
   (it opens a browser). In Claude Code they can type it with the `!` prefix.
3. Run `scripts/check.sh` (Git Bash or WSL on Windows). It lists models and makes a real tool call.
4. Run `oc run "Reply with exactly: pong"`.
5. To test MCP: `OPENCODE_CONFIG_CONTENT='{"mcp":{"hello-fastmcp":{"enabled":true}}}' oc run "Use the add tool to add 2 and 3"`.

## Changing the model or host

Edit `provider.ollama` in `config/opencode.json`. The model key must match `ollama list`
on the server. Keep `limit.context` at or below the server's context length
(check `/api/ps`, field `context_length`).
If the user's own Ollama is local, set `baseURL` to `http://localhost:11434/v1` and drop `headers`.

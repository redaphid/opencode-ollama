# opencode + remote Ollama

Run [opencode](https://opencode.ai) (a terminal coding agent, similar to Claude Code) against
a model on a remote Ollama server, and use it to explore MCP servers such as
[FastMCP](https://gofastmcp.com) ones. Works on macOS, Linux, and Windows.

Default model: `qwen3.8:27b` on `https://ollama.hypnodroid.com`, which is behind Cloudflare Access.

## What's here

| Path | Purpose |
|---|---|
| `config/opencode.json` | Provider, model, and an example MCP server |
| `bin/oc`, `bin/oc.ps1` | Launcher: gets an Access token, warms the model, starts opencode with this config |
| `scripts/install.sh`, `scripts/install.ps1` | Install opencode, cloudflared, and uv |
| `scripts/check.sh` | Checks host, model, and tool calling |
| `examples/hello_server.py` | Tiny FastMCP server for testing |
| `.claude/skills/` | Skills so Claude Code can set this up or debug it for you |

## Quick start

1. Clone and install:
   - macOS/Linux: `scripts/install.sh`
   - Windows (PowerShell): `scripts/install.ps1`, then open a new terminal
2. Sign in to Cloudflare Access (opens a browser; repeat about once a day):
   `cloudflared access login https://ollama.hypnodroid.com`
3. Check the connection: `scripts/check.sh` (on Windows, use Git Bash)
4. Run `oc` in any project directory.

## Try MCP

`hello-fastmcp` is defined but disabled. Enable it for one run:

```sh
OPENCODE_CONFIG_CONTENT='{"mcp":{"hello-fastmcp":{"enabled":true}}}' oc run "Use the add tool to add 1234 and 4321"
```

Add your own servers under `mcp` in `config/opencode.json`
([opencode MCP docs](https://opencode.ai/docs/mcp-servers/)).

## Using a different host or model

- Different host: set `OLLAMA_APP_URL` for the launcher and change `baseURL` in the config.
- Local Ollama: set `baseURL` to `http://localhost:11434/v1` and remove `headers`.
- Different model: change the key under `models` and the top-level `model`. It must appear in `/api/tags`.

## Known limits

- **Cold starts.** Ollama unloads idle models. Reloading a 27B model can exceed Cloudflare's
  100 s limit and return 502/524. The launcher retries a warm-up request. Setting
  `OLLAMA_KEEP_ALIVE` on the server avoids it.
- **Token lifetime.** The login token lasts about a day. Restart `oc` after it expires.
  A Cloudflare Access service token would avoid this but is not wired in yet.
- **Model quality.** A 27B local model handles simple tool calls well but is weaker than Claude
  on long, multi-step coding tasks. Keep tasks small.

## Secrets

Nothing secret is stored here. The token is read from `cloudflared` at launch and passed through
the `OLLAMA_ACCESS_TOKEN` environment variable.

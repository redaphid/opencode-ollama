---
name: troubleshoot-opencode-ollama
description: Diagnose failures running opencode against the remote Ollama host: 302/401/403, 502/524, missing model, no tool calls. Use when `oc` errors or hangs.
---

# Troubleshoot opencode + remote Ollama

Run `scripts/check.sh` first; it separates auth, model, and tool-call problems.

| Symptom | Cause | Fix |
|---|---|---|
| HTML 302 / redirect to `cloudflareaccess.com` | Credentials missing or wrong, or the app has no Service Auth policy for the token | Check both `CF_ACCESS_*` variables are set in this process; confirm the token is in a Service Auth policy and has not expired |
| 502 or 524 on the first request | Cold model load outlasts Cloudflare's 100 s limit; the load still finishes | Retry. `bin/oc` already warms the model with retries. Raise `OLLAMA_KEEP_ALIVE` on the server to avoid unloads |
| `model not found` | Tag differs from config | `curl` `/api/tags` with the token; update the key in `config/opencode.json` |
| Model prints tool JSON as text, no tool call | Model or template lacks tool support | Confirm with `scripts/check.sh`; try another model |
| Truncated or forgetful answers | `limit.context` larger than the server's real context | Match `context_length` from `/api/ps` |
| `hello-fastmcp` fails to start | `uv` not on PATH | Install uv; reopen the terminal |

Service tokens expire on the date chosen at creation; rotate then.

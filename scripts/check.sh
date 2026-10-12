#!/usr/bin/env bash
# Verify the Ollama host is reachable, has the model, and can do tool calls.
set -euo pipefail
APP="${OLLAMA_APP_URL:-https://ollama.hypnodroid.com}"
MODEL="${OLLAMA_MODEL:-qwen3.8:27b}"
TOKEN="$(cloudflared access token -app="$APP")"
H="cf-access-token: $TOKEN"

echo "== models on $APP"
curl -fsS -m 20 -H "$H" "$APP/api/tags" | python3 -c "import sys,json; [print(' ',m['name']) for m in json.load(sys.stdin)['models']]"

echo "== tool call against $MODEL (first call may be slow while the model loads)"
curl -fsS -m 300 -H "$H" -H 'content-type: application/json' "$APP/v1/chat/completions" -d "{
  \"model\":\"$MODEL\",
  \"messages\":[{\"role\":\"user\",\"content\":\"What is the weather in Paris? Use the tool.\"}],
  \"tools\":[{\"type\":\"function\",\"function\":{\"name\":\"get_weather\",\"description\":\"Get weather\",\"parameters\":{\"type\":\"object\",\"properties\":{\"city\":{\"type\":\"string\"}},\"required\":[\"city\"]}}}]
}" | python3 -c "import sys,json; c=json.load(sys.stdin)['choices'][0]['message'].get('tool_calls'); print(' OK', c[0]['function']) if c else sys.exit(' FAIL: no tool call')"

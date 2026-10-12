# Launch opencode against the remote Ollama host behind Cloudflare Access.
# Needs CF_ACCESS_CLIENT_ID and CF_ACCESS_CLIENT_SECRET (Access service token) in the environment.
$ErrorActionPreference = 'Stop'
$HarnessDir = Split-Path -Parent $PSScriptRoot
$App = if ($env:OLLAMA_APP_URL) { $env:OLLAMA_APP_URL } else { 'https://ollama.hypnodroid.com' }
$model = if ($env:OLLAMA_MODEL) { $env:OLLAMA_MODEL } else { 'qwen3.8:27b' }

if (-not $env:CF_ACCESS_CLIENT_ID -or -not $env:CF_ACCESS_CLIENT_SECRET) {
  throw 'Set CF_ACCESS_CLIENT_ID and CF_ACCESS_CLIENT_SECRET (see README).'
}

# A cold 27B load can outlast Cloudflare's 100s limit (502/524); the load still
# finishes server-side, so retry a tiny request until the model is resident.
for ($i = 1; $i -le 6; $i++) {
  try {
    Invoke-RestMethod -Method Post -Uri "$App/api/generate" -TimeoutSec 130 `
      -Headers @{ 'CF-Access-Client-Id' = $env:CF_ACCESS_CLIENT_ID; 'CF-Access-Client-Secret' = $env:CF_ACCESS_CLIENT_SECRET } `
      -Body (@{ model = $model; keep_alive = '30m' } | ConvertTo-Json) | Out-Null
    break
  } catch { Write-Host "Warming $model (attempt $i)..." }
}

$env:OPENCODE_HARNESS_DIR = ($HarnessDir -replace '\', '/')
$env:OPENCODE_CONFIG = Join-Path $HarnessDir 'config/opencode.json'
opencode @args
exit $LASTEXITCODE

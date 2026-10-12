# Launch opencode against the remote Ollama host behind Cloudflare Access.
$ErrorActionPreference = 'Stop'
$HarnessDir = Split-Path -Parent $PSScriptRoot
$App = if ($env:OLLAMA_APP_URL) { $env:OLLAMA_APP_URL } else { 'https://ollama.hypnodroid.com' }

$token = (cloudflared access token "-app=$App" 2>$null) -join ''
if ($LASTEXITCODE -ne 0 -or -not $token) {
  Write-Host "No Cloudflare Access token for $App; logging in..."
  cloudflared access login $App
  $token = (cloudflared access token "-app=$App") -join ''
}

# A cold 27B load can outlast Cloudflare's 100s limit (502/524); the load still
# finishes server-side, so retry a tiny request until the model is resident.
$model = if ($env:OLLAMA_MODEL) { $env:OLLAMA_MODEL } else { 'qwen3.8:27b' }
for ($i = 1; $i -le 6; $i++) {
  try {
    Invoke-RestMethod -Method Post -Uri "$App/api/generate" -TimeoutSec 130 `
      -Headers @{ 'cf-access-token' = $token } `
      -Body (@{ model = $model; keep_alive = '30m' } | ConvertTo-Json) | Out-Null
    break
  } catch { Write-Host "Warming $model (attempt $i)..." }
}

$env:OLLAMA_ACCESS_TOKEN = $token
$env:OPENCODE_HARNESS_DIR = ($HarnessDir -replace '\', '/')
$env:OPENCODE_CONFIG = Join-Path $HarnessDir 'config/opencode.json'
opencode @args
exit $LASTEXITCODE

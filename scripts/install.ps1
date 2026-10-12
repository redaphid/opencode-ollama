# Install opencode and uv on Windows, then put `oc` on PATH.
$ErrorActionPreference = 'Stop'
$Here = Split-Path -Parent $PSScriptRoot
function Have($n) { [bool](Get-Command $n -ErrorAction SilentlyContinue) }

if (-not (Have node)) { winget install --id OpenJS.NodeJS.LTS -e --silent }
# Prefer scoop: a stable shim on PATH. npm globals under fnm/nvm land in per-shell dirs that vanish.
if (-not (Have opencode)) {
  if (Have scoop) { scoop install opencode } else { npm i -g opencode-ai }
}
if (-not (Have uv)) { winget install --id astral-sh.uv -e --silent }

$bin = Join-Path $Here 'bin'
$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if ($userPath -notlike "*$bin*") {
  [Environment]::SetEnvironmentVariable('Path', "$userPath;$bin", 'User')
  Write-Host "Added $bin to your user PATH."
}
# oc.cmd lets `oc` work from cmd.exe and PowerShell alike.
Set-Content -Path (Join-Path $bin 'oc.cmd') -Value '@pwsh -NoProfile -File "%~dp0oc.ps1" %*'
Write-Host 'Done. Open a new terminal, then run: oc'

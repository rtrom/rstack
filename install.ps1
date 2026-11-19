# rstack installer (Windows PowerShell 5.1+ or PowerShell 7)
#
#   .\install.ps1               plugin install via the claude CLI; falls back to -Copy
#   .\install.ps1 -Plugin       plugin install only
#   .\install.ps1 -Copy         copy skills, agents, and the guard hook into ~\.claude
#   .\install.ps1 -Uninstall    remove a -Copy install
#
# If scripts are blocked: powershell -ExecutionPolicy Bypass -File .\install.ps1
[CmdletBinding()]
param([switch]$Plugin, [switch]$Copy, [switch]$Uninstall)

$ErrorActionPreference = 'Stop'
$Repo      = if ($env:RSTACK_REPO) { $env:RSTACK_REPO } else { 'rtrom/rstack' }
$ClaudeDir = if ($env:CLAUDE_CONFIG_DIR) { $env:CLAUDE_CONFIG_DIR } else { Join-Path $HOME '.claude' }
$Here      = $PSScriptRoot

function Say($m)  { Write-Host "==> $m" -ForegroundColor Cyan }
function Warn($m) { Write-Host "!! $m" -ForegroundColor Yellow }
function Die($m)  { Write-Host "xx $m" -ForegroundColor Red; exit 1 }

function Get-Src {
  if ($Here -and (Test-Path (Join-Path $Here '.claude-plugin/plugin.json'))) { return $Here }
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Die "git is required to fetch $Repo" }
  $tmp = Join-Path ([IO.Path]::GetTempPath()) ("rstack-" + [guid]::NewGuid())
  git clone --depth 1 -q "https://github.com/$Repo.git" $tmp
  if ($LASTEXITCODE -ne 0) { Die "could not clone $Repo (private repo? clone it and run .\install.ps1)" }
  return $tmp
}

function Install-Plugin {
  if (-not (Get-Command claude -ErrorAction SilentlyContinue)) { return $false }
  Say 'Installing with the claude CLI'
  $target = $Repo
  if ($Here -and (Test-Path (Join-Path $Here '.claude-plugin/marketplace.json'))) { $target = $Here }
  claude plugin marketplace add $target
  if ($LASTEXITCODE -ne 0) { claude plugin marketplace update rstack; if ($LASTEXITCODE -ne 0) { return $false } }
  claude plugin install rstack@rstack
  if ($LASTEXITCODE -ne 0) { return $false }
  Say 'Installed. Skills are namespaced: /rstack:setup, /rstack:build, ...'
  return $true
}

function Convert-Names([string]$text, [string]$name) {
  # Plugin names (/rstack:build, rstack:implementer) become rstack-build, rstack-implementer.
  $text = $text -replace 'rstack:', 'rstack-'
  return [regex]::Replace($text, "(?m)^name: $([regex]::Escape($name))\r?$", "name: rstack-$name")
}

function Write-Utf8NoBom($path, $text) {
  [IO.File]::WriteAllText($path, $text, (New-Object Text.UTF8Encoding $false))
}

function Install-Copy {
  if (-not (Get-Command node -ErrorAction SilentlyContinue)) { Die 'node is required for the guard hook (Claude Code ships with it)' }
  $src = Get-Src
  Say "Copying rstack into $ClaudeDir (skills and agents get an rstack- prefix)"
  foreach ($d in 'skills','agents','hooks') { New-Item -ItemType Directory -Force -Path (Join-Path $ClaudeDir $d) | Out-Null }

  Get-ChildItem (Join-Path $src 'skills') -Directory | ForEach-Object {
    $name = $_.Name
    $dest = Join-Path $ClaudeDir "skills/rstack-$name"
    if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
    Copy-Item -Recurse $_.FullName $dest
    Get-ChildItem $dest -Recurse -Filter *.md | ForEach-Object {
      Write-Utf8NoBom $_.FullName (Convert-Names (Get-Content -Raw $_.FullName) $name)
    }
  }

  Get-ChildItem (Join-Path $src 'agents') -Filter *.md | ForEach-Object {
    $name = $_.BaseName
    Write-Utf8NoBom (Join-Path $ClaudeDir "agents/rstack-$name.md") (Convert-Names (Get-Content -Raw $_.FullName) $name)
  }

  $guard = Join-Path $ClaudeDir 'hooks/rstack-guard.mjs'
  Copy-Item (Join-Path $src 'hooks/guard.mjs') $guard -Force
  node (Join-Path $src 'hooks/settings-merge.mjs') add (Join-Path $ClaudeDir 'settings.json') $guard
  if ($LASTEXITCODE -ne 0) { Die 'could not update settings.json' }

  Say 'Installed. Skills are /rstack-setup, /rstack-build, ... Restart Claude Code to load them.'
}

function Uninstall-Copy {
  Say "Removing the -Copy install from $ClaudeDir"
  Get-ChildItem (Join-Path $ClaudeDir 'skills') -Directory -Filter 'rstack-*' -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
  Get-ChildItem (Join-Path $ClaudeDir 'agents') -Filter 'rstack-*.md' -ErrorAction SilentlyContinue | Remove-Item -Force
  Remove-Item (Join-Path $ClaudeDir 'hooks/rstack-guard.mjs') -Force -ErrorAction SilentlyContinue
  $settings = Join-Path $ClaudeDir 'settings.json'
  if (Test-Path $settings) { node (Join-Path (Get-Src) 'hooks/settings-merge.mjs') remove $settings }
  Say 'Done. A plugin install is removed with: claude plugin uninstall rstack@rstack'
}

if     ($Uninstall) { Uninstall-Copy }
elseif ($Copy)      { Install-Copy }
elseif ($Plugin)    { if (-not (Install-Plugin)) { Die 'plugin install failed (is the claude CLI on PATH?)' } }
else {
  if (-not (Install-Plugin)) { Warn 'claude CLI unavailable or plugin install failed; using -Copy'; Install-Copy }
}

Write-Host ''
Say 'Next: open a repo in Claude Code and run setup once.'

[CmdletBinding()]
param(
  [string]$Branch = "main",
  [switch]$AllowInit,
  [switch]$Commit,
  [switch]$Push,
  [string]$Remote = "origin",
  [string]$CommitMessage = "inventory-stream7-rescue: publish-ready update"
)

$ErrorActionPreference = "Stop"

function Write-Step([string]$Message) {
  Write-Host ("[deploy] {0}" -f $Message)
}

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  throw "git is required."
}

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $RepoRoot

if (-not (Test-Path ".git")) {
  if (-not $AllowInit) {
    throw "No .git directory found. Re-run with -AllowInit to initialize the repository intentionally."
  }
  Write-Step "Initializing git repository"
  git init | Out-Null
  git checkout -b $Branch 2>$null | Out-Null
}

$required = @(
  "README.md",
  "docs/README.md",
  "multiplatform/linux-general/run_linux_general.sh",
  "multiplatform/windows-ps5-general/run_windows_general_ps5.ps1",
  "legacy/windows-ps4-general/run_windows_general_ps4.ps1",
  "stream7/stream7-linux-specialized/run_stream7_final.sh"
)
$missing = @($required | Where-Object { -not (Test-Path $_) })
if ($missing.Count -gt 0) {
  throw ("Missing required files:`n- " + ($missing -join "`n- "))
}

$gitName = git config user.name
$gitMail = git config user.email
if ([string]::IsNullOrWhiteSpace($gitName) -or [string]::IsNullOrWhiteSpace($gitMail)) {
  throw "git user.name and user.email must be configured before commit/push."
}

$status = git status --porcelain
if ($status -match 'UU ') {
  throw "Unresolved merge conflicts detected."
}

if ($Commit) {
  Write-Step "Staging files"
  git add .
  $hasCommits = $true
  try { git rev-parse --verify HEAD | Out-Null } catch { $hasCommits = $false }
  if ($status -or -not $hasCommits) {
    Write-Step "Creating commit"
    git commit -m $CommitMessage
  } else {
    Write-Step "Nothing to commit"
  }
}

if ($Push) {
  Write-Step ("Pushing to {0}/{1}" -f $Remote, $Branch)
  git push $Remote HEAD:$Branch
} else {
  Write-Step "Push not requested. Review the repo and push manually when ready."
}

Write-Step "Done"


Write-Step "Recommended before public release:"
Write-Step "  - run shared\ip\generate_release_evidence.ps1"
Write-Step "  - preserve the release zip locally"
Write-Step "  - keep screenshots/PDF of the public surface"

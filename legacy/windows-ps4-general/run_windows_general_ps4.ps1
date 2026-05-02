param([string]$Mode = "Menu")
$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Show-Help {
@"
WINDOWS PS4 LEGACY TOOLKIT

Hint:
- This lane exists for older PowerShell 4-compatible environments.
- Start with probe.
- Use help before full on the first run.
- Reports are written under output/<device>/<os>/reports/.
"@
}

function Run-Probe { & "$ScriptRoot\scripts\10_probe.ps1" }
function Run-Assess { & "$ScriptRoot\scripts\20_assess.ps1" }
function Run-Report { & "$ScriptRoot\scripts\30_report.ps1" }
function Run-Flow { & "$ScriptRoot\scripts\40_operational_flow.ps1" }

function Show-Menu {
  while ($true) {
    Clear-Host
    Write-Host "===== WINDOWS PS4 LEGACY MENU ====="
    Write-Host "Hint: 1) Probe -> 2) Assess -> 3) Report -> 4) Flow"
    Write-Host "1) Probe"
    Write-Host "2) Assess"
    Write-Host "3) Report"
    Write-Host "4) Flow"
    Write-Host "5) Help"
    Write-Host "6) Full"
    Write-Host "0) Exit"
    $o = Read-Host "Option"
    switch ($o) {
      '1' { Run-Probe; Pause }
      '2' { Run-Assess; Pause }
      '3' { Run-Report; Pause }
      '4' { Run-Flow; Pause }
      '5' { Show-Help; Pause }
      '6' { Run-Probe; Run-Assess; Run-Report; Run-Flow; Pause }
      '0' { return }
      default { Write-Host 'Invalid option'; Start-Sleep -Seconds 1 }
    }
  }
}

switch ($Mode.ToLower()) {
  'menu' { Show-Menu }
  'probe' { Run-Probe }
  'assess' { Run-Assess }
  'report' { Run-Report }
  'flow' { Run-Flow }
  'full' { Run-Probe; Run-Assess; Run-Report; Run-Flow }
  default { Show-Help }
}

. "$PSScriptRoot\common.ps1"
$p = Get-ToolkitPaths
$out = Join-Path $p.Reports '05_WINDOWS_PS4_OPERATIONAL_FLOW.txt'
Write-Log 'Windows PS4 legacy operational flow'

@"
WINDOWS PS4 LEGACY OPERATIONAL FLOW

1. Run Probe
2. Run Assess
3. Run Report
4. Review whether to:
   - keep as legacy support endpoint
   - optimize lightly
   - migrate later
   - retire from primary use

Warning:
This legacy lane is for bounded audit and reporting, not for pretending old systems are equivalent to modern baselines.
"@ | Out-File -FilePath $out -Encoding utf8

Write-Host "Report: $out"

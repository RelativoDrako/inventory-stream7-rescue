. "$PSScriptRoot\common.ps1"
$p = Get-ToolkitPaths
$out = Join-Path $p.Reports '04_windows_ps4_executive_report.md'
Write-Log 'Windows PS4 legacy report'

@"
# WINDOWS PS4 LEGACY EXECUTIVE REPORT

- Device: $($p.DeviceName)
- OS: $($p.OSName)
- Assessment status: run assess before relying on recommendations

Base artifacts:
- 01_windows_ps4_probe.txt
- 02_windows_ps4_assessment.txt
- 03_windows_ps4_recommendations.md
- 05_WINDOWS_PS4_OPERATIONAL_FLOW.txt

This lane exists to preserve audit/reporting capability on older Windows baselines.
"@ | Out-File -FilePath $out -Encoding utf8

Write-Host "Report: $out"

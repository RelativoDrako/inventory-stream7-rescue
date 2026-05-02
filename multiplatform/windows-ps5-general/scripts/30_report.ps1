. "$PSScriptRoot\common.ps1"
$p = Get-ToolkitPaths
$out = Join-Path $p.Reports '05_windows_general_executive_report.md'
Write-Log 'Windows general executive report'

$jsonPath = Join-Path $p.Reports '03_windows_general_assessment.json'
if (Test-Path $jsonPath) {
  $summary = Get-Content $jsonPath -Raw | ConvertFrom-Json
  $assessmentStatus = 'assessment_loaded'
} else {
  $arch = Get-ArchProfile
  $summary = [PSCustomObject]@{
    Architecture = $arch.Family
    BestRole = 'assessment_not_generated'
    RecommendedOS = 'run_assess_first'
    RecommendedStack = @()
    OverallScore = 'N/A'
  }
  $assessmentStatus = 'assessment_missing'
}

@"
# WINDOWS GENERAL EXECUTIVE REPORT

## Identification
- Device: $($p.DeviceName)
- OS: $($p.OSName)
- Architecture: $($summary.Architecture)
- Assessment status: $assessmentStatus

## Summary
- Best role: $($summary.BestRole)
- Recommended OS path: $($summary.RecommendedOS)
- Recommended stack: $([string]::Join(', ', @($summary.RecommendedStack)))
- Overall score: $($summary.OverallScore)

## Base artifacts
- 01_windows_general_probe.txt
- 02_windows_general_assessment.txt
- 04_windows_general_recommendations.md
- 06_WINDOWS_OPERATIONAL_FLOW.txt

## Reading rule
Review the recommendations and operational flow before changing OS, drivers, or workload expectations.
"@ | Out-File -FilePath $out -Encoding utf8

Write-Host "Report: $out"

. "$PSScriptRoot\common.ps1"
$p = Get-ToolkitPaths
$out = Join-Path $p.Reports '06_WINDOWS_OPERATIONAL_FLOW.txt'
Write-Log 'Windows general operational flow'

$jsonPath = Join-Path $p.Reports '03_windows_general_assessment.json'
$summary = $null
$assessmentStatus = 'assessment_missing'
if (Test-Path $jsonPath) { $summary = Get-Content $jsonPath -Raw | ConvertFrom-Json; $assessmentStatus = 'assessment_loaded' }

@"
WINDOWS OPERATIONAL FLOW
Assessment status: $assessmentStatus

1. Run Probe
   - Review 01_windows_general_probe.txt

2. Run Assess
   - Review architecture, role, score, and OS path

3. Run Report
   - Review the executive summary

4. Review optimization priorities
   - storage pressure
   - update cost
   - driver viability
   - remote-first operation when constrained

5. Before changing OS or drivers
   - export reports
   - record build and drivers
   - validate vendor support
   - confirm workload expectations

Current summary
- Best role: $($summary.BestRole)
- Recommended OS: $($summary.RecommendedOS)
- Recommended stack: $([string]::Join(', ', @($summary.RecommendedStack)))
"@ | Out-File -FilePath $out -Encoding utf8

Write-Host "Report: $out"

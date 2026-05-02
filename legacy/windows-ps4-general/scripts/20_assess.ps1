. "$PSScriptRoot\common.ps1"
$p = Get-ToolkitPaths
$out = Join-Path $p.Reports '02_windows_ps4_assessment.txt'
$rec = Join-Path $p.Reports '03_windows_ps4_recommendations.md'
Write-Log 'Windows PS4 legacy assessment'

$cs = Get-WmiObject Win32_ComputerSystem
$os = Get-WmiObject Win32_OperatingSystem
$cpu = Get-WmiObject Win32_Processor | Select-Object -First 1
$ramGB = [math]::Round(($cs.TotalPhysicalMemory / 1GB),2)
$sysdrv = Get-WmiObject Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3 -and $_.DeviceID -eq 'C:'}
$freeGB = if ($sysdrv) { [math]::Round(($sysdrv.FreeSpace / 1GB),2) } else { 0 }
$bestRole = 'legacy_support_endpoint'
$recommendedOS = 'keep_current_legacy_windows_until_review'
$recommendedStack = 'browser_light,office_light,remote_support'
$overall = 36
$notes = @()

if ($ramGB -lt 4) {
  $notes += 'Low RAM: keep workloads light and prioritize recovery/support roles.'
} else {
  $overall += 8
  $notes += 'Moderate RAM detected for a legacy baseline.'
}
if ($freeGB -lt 20) {
  $notes += 'Low free disk: avoid heavy updates and preserve storage carefully.'
  $overall -= 5
}
if ($os.OSArchitecture -match '64') {
  $overall += 4
  $notes += '64-bit legacy Windows detected: modernization may be easier than on 32-bit systems.'
} else {
  $notes += '32-bit legacy Windows detected: modernization path must be chosen conservatively.'
}

@(
  '=== WINDOWS PS4 LEGACY ASSESSMENT ===',
  "DeviceName=$($p.DeviceName)",
  "OSName=$($p.OSName)",
  "OSArchitecture=$($os.OSArchitecture)",
  "CPU=$($cpu.Name)",
  "RAMGB=$ramGB",
  "FreeDiskGB=$freeGB",
  "BestRole=$bestRole",
  "RecommendedOS=$recommendedOS",
  "RecommendedStack=$recommendedStack",
  "OverallScore=$overall",
  '--- NOTES ---',
  ($notes -join "`r`n")
) | Out-File -FilePath $out -Encoding utf8

@"
# Windows PS4 Legacy Recommendations

- Device: `$($p.DeviceName)`
- OS: `$($p.OSName)`
- Best role: `$bestRole`
- Recommended OS path: `$recommendedOS`
- Recommended stack: `$recommendedStack`
- Overall score: `$overall`

## Notes
$((($notes | ForEach-Object { '1. ' + $_ }) -join "`r`n"))

## Next step
Generate the report and review whether this device should remain legacy, be repurposed, or be migrated.
"@ | Out-File -FilePath $rec -Encoding utf8

Write-Host "Assessment: $out"

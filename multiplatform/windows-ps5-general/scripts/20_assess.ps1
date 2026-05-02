. "$PSScriptRoot\common.ps1"
$p = Get-ToolkitPaths
$out = Join-Path $p.Reports '02_windows_general_assessment.txt'
$json = Join-Path $p.Reports '03_windows_general_assessment.json'
$rec = Join-Path $p.Reports '04_windows_general_recommendations.md'
Write-Log 'Windows PS5 operational assessment'

$cs = Get-CimInstance Win32_ComputerSystem
$os = Get-CimInstance Win32_OperatingSystem
$cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
$gpu = Get-GpuAssessment
$arch = Get-ArchProfile
$ramGB = [math]::Round(($cs.TotalPhysicalMemory / 1GB),2)
$sysdrv = Get-CimInstance Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3 -and $_.DeviceID -eq 'C:'}
$freeGB = if ($sysdrv) { [math]::Round(($sysdrv.FreeSpace / 1GB),2) } else { 0 }
$gpuNames = ($gpu | ForEach-Object {$_.Name}) -join '; '
$notes = New-Object System.Collections.Generic.List[string]
$bestRole='general_endpoint'
$recommendedOS='keep_current_os'
$recommendedStack=@('browser','office','ssh','monitoring')
$overall=52
$operationAlternatives=@()

switch ($arch.Family) {
  'x86_32' {
    $bestRole='legacy_light_ops'
    $recommendedOS='keep_legacy_windows_or_migrate_to_light_linux'
    $recommendedStack=@('browser_light','office_light','ssh','remote_support')
    $overall=34
    $notes.Add('32-bit Windows baseline: prioritize recovery, thin-client, or limited support roles.')
  }
  'arm64' {
    $bestRole='light_remote_ops_or_modern_mobile_class_endpoint'
    $recommendedOS='keep_supported_windows_arm_or_vendor_supported_linux'
    $recommendedStack=@('browser','office','remote_support','monitoring')
    $overall=48
    $notes.Add('ARM64-like platform: validate driver/application compatibility before selecting heavier workloads.')
  }
  default {
    if ($ramGB -lt 4) {
      $bestRole='thin_client_light_ops'
      $recommendedOS='windows_light_or_debian_lxde'
      $recommendedStack=@('ssh','rdp','browser_light','monitoring')
      $overall=38
      $notes.Add('RAM under 4 GB: limit local workloads and prioritize remote-first operation.')
    } elseif ($ramGB -lt 8) {
      $bestRole='daily_driver_light'
      $recommendedOS='current_windows_or_light_linux'
      $recommendedStack=@('browser','office','ssh','rdp','monitoring')
      $overall=58
      $operationAlternatives += 'Daily driver (light)'
    } else {
      $bestRole='daily_driver_and_remote_ops'
      $recommendedOS='windows11_or_ubuntu_lts'
      $recommendedStack=@('browser','office','ssh','rdp','monitoring')
      $overall=68
      $operationAlternatives += 'Daily driver'
      $operationAlternatives += 'Remote operations'
    }
  }
}

if ($gpuNames -match 'NVIDIA' -and $ramGB -ge 16) {
  $bestRole='developer_workstation_or_ml_edge_control'
  $recommendedOS='windows11_or_ubuntu_lts'
  $recommendedStack=@('docker','python','vscode','browser','monitoring')
  $overall += 10
  $notes.Add('NVIDIA + higher RAM detected: candidate for heavier development or remote-control workloads.')
}

if ($freeGB -lt 20) {
  $overall -= 8
  $notes.Add('Free disk below 20 GB: high risk for updates, caches, and modern applications.')
}

@(
'=== WINDOWS GENERAL ASSESSMENT ===',
"DeviceName=$($p.DeviceName)",
"OSName=$($p.OSName)",
"Architecture=$($arch.Family)",
"CPU=$($cpu.Name)",
"RAMGB=$ramGB",
"FreeDiskGB=$freeGB",
"GPU=$gpuNames",
"BestRole=$bestRole",
"RecommendedOS=$recommendedOS",
"RecommendedStack=$($recommendedStack -join ',')",
"OverallScore=$overall",
'--- NOTES ---',
($notes -join "`r`n")
) | Out-File -FilePath $out -Encoding utf8

$summary = [PSCustomObject]@{
  DeviceName=$p.DeviceName
  OSName=$p.OSName
  Architecture=$arch.Family
  CPU=$cpu.Name
  RAMGB=$ramGB
  FreeDiskGB=$freeGB
  GPU=$gpu
  BestRole=$bestRole
  RecommendedOS=$recommendedOS
  RecommendedStack=$recommendedStack
  OperationAlternatives=$operationAlternatives
  OverallScore=$overall
  Notes=$notes
}
$summary | ConvertTo-Json -Depth 6 | Out-File -FilePath $json -Encoding utf8

@"
# Windows General Recommendations

- Device: `$($p.DeviceName)`
- OS: `$($p.OSName)`
- Architecture: `$($arch.Family)`
- Best role: `$bestRole`
- Recommended OS path: `$recommendedOS`
- Recommended stack: `$([string]::Join(', ', $recommendedStack))`
- Overall score: `$overall`

## Optimization priorities
$((($notes | ForEach-Object { '1. ' + $_ }) -join "`r`n"))

## Next step
Run `report` and `flow`, review outputs, and only then apply invasive changes.
"@ | Out-File -FilePath $rec -Encoding utf8

Write-Host "Assessment: $out"
Write-Host "Recommendations: $rec"

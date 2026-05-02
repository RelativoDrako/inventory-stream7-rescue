$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Base = Split-Path -Parent $ScriptRoot

function Get-ToolkitPaths {
  $cs = Get-CimInstance Win32_ComputerSystem
  $os = Get-CimInstance Win32_OperatingSystem
  $deviceName = (($cs.Manufacturer + '_' + $cs.Model) -replace '\s+','_' -replace '[^A-Za-z0-9_\-]','').ToLower()
  $osName = (($os.Caption + '_' + $os.Version) -replace '\s+','_' -replace '[^A-Za-z0-9_\-]','').ToLower()
  $outBase = Join-Path $Base ("output\" + $deviceName + "\" + $osName)
  $reports = Join-Path $outBase 'reports'
  $logs = Join-Path $outBase 'logs'
  New-Item -ItemType Directory -Path $reports -Force | Out-Null
  New-Item -ItemType Directory -Path $logs -Force | Out-Null
  return @{DeviceName=$deviceName;OSName=$osName;OutBase=$outBase;Reports=$reports;Logs=$logs}
}

function Write-Log {
  param([string]$Message)
  $p = Get-ToolkitPaths
  $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
  $line | Out-File -Append -FilePath (Join-Path $p.Logs 'toolkit.log') -Encoding utf8
  Write-Host $line
}


function Get-CimSafe {
  param(
    [Parameter(Mandatory=$true)][string]$ClassName,
    [string[]]$Properties,
    [switch]$First,
    $Fallback = $null
  )

  try {
    $result = Get-CimInstance -ClassName $ClassName -ErrorAction Stop
    if ($Properties) { $result = $result | Select-Object -Property $Properties }
    if ($First) { $result = $result | Select-Object -First 1 }
    return $result
  } catch {
    return $Fallback
  }
}

function Get-SectionText {
  param(
    [Parameter(ValueFromPipeline=$true)]$InputObject,
    [ValidateSet('List','Table','Raw')][string]$Mode = 'List',
    [string[]]$Properties,
    [string]$EmptyText = 'N/A'
  )

  if ($null -eq $InputObject -or @($InputObject).Count -eq 0) {
    return $EmptyText
  }

  switch ($Mode) {
    'Table' {
      if ($Properties) {
        return ($InputObject | Format-Table -Property $Properties -AutoSize | Out-String)
      }
      return ($InputObject | Format-Table -AutoSize | Out-String)
    }
    'Raw' {
      return ($InputObject | Out-String)
    }
    default {
      if ($Properties) {
        return ($InputObject | Format-List -Property $Properties | Out-String)
      }
      return ($InputObject | Format-List | Out-String)
    }
  }
}

function Get-ArchProfile {
  $cpu = Get-CimSafe -ClassName 'Win32_Processor' -First
  $os = Get-CimSafe -ClassName 'Win32_OperatingSystem' -First
  $archLabel = if ($os) { $os.OSArchitecture } else { 'unknown' }
  $family = 'unknown'
  if ($archLabel -match '64') { $family = 'x64_or_arm64' } elseif ($archLabel -match '32') { $family = 'x86_32' }
  $isArm = $false
  if ($cpu -and $cpu.Name -match 'ARM|Qualcomm|Snapdragon') { $isArm = $true }
  if ($isArm -and $archLabel -match '64') { $family = 'arm64' }
  return [PSCustomObject]@{
    Family = $family
    OSArchitecture = $archLabel
    CpuAddressWidth = if ($cpu) { $cpu.AddressWidth } else { 'unknown' }
    CpuName = if ($cpu) { $cpu.Name } else { 'unknown' }
  }
}

function Get-GpuAssessment {
  $controllers = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue
  $gpuSummary = @()
  foreach ($g in $controllers) {
    $vendor='Unknown'
    if ($g.Name -match 'NVIDIA') { $vendor='NVIDIA' }
    elseif ($g.Name -match 'Intel') { $vendor='Intel' }
    elseif ($g.Name -match 'AMD|Radeon') { $vendor='AMD' }
    elseif ($g.Name -match 'Qualcomm|Adreno|Mali') { $vendor='ARM_SOC' }
    $gpuSummary += [PSCustomObject]@{
      Vendor=$vendor
      Name=$g.Name
      RAMMB= if ($g.AdapterRAM) { [math]::Round(($g.AdapterRAM/1MB),0) } else { 0 }
      Driver=$g.DriverVersion
    }
  }
  return $gpuSummary
}

function Get-InstalledAppsSafe {
  $apps = @()
  $paths = @(
    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
  )
  foreach ($p in $paths) {
    try {
      $apps += Get-ItemProperty $p -ErrorAction SilentlyContinue |
        Where-Object { $_.DisplayName } |
        Select-Object DisplayName,DisplayVersion,Publisher,InstallDate
    } catch {}
  }
  $apps | Sort-Object DisplayName -Unique
}

function Get-ServicesSummary {
  Get-Service | Sort-Object Status,DisplayName | Select-Object Status,Name,DisplayName,StartType
}

function Try-Command($scriptBlock, $fallback='N/A') {
  try { & $scriptBlock } catch { $fallback }
}

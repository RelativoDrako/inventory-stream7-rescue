$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$Base = Split-Path -Parent $ScriptRoot

function Get-ToolkitPaths {
  $cs = Get-WmiObject Win32_ComputerSystem
  $os = Get-WmiObject Win32_OperatingSystem
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

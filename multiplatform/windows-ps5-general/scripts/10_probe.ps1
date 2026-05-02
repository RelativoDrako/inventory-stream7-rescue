. "$PSScriptRoot\common.ps1"
$p = Get-ToolkitPaths
$out = Join-Path $p.Reports '01_windows_general_probe.txt'
Write-Log 'Windows PS5 detailed probe'

$cs = Get-CimSafe -ClassName 'Win32_ComputerSystem' -First
$os = Get-CimSafe -ClassName 'Win32_OperatingSystem' -First
$cpu = Get-CimSafe -ClassName 'Win32_Processor' -First
$bios = Get-CimSafe -ClassName 'Win32_BIOS' -First
$gpu = Try-Command { Get-GpuAssessment } @()
$disks = Get-CimSafe -ClassName 'Win32_DiskDrive' -Fallback @()
$logical = Get-CimSafe -ClassName 'Win32_LogicalDisk' -Fallback @()
$volumes = Get-CimSafe -ClassName 'Win32_Volume' -Fallback @()
$pnpsigned = Get-CimSafe -ClassName 'Win32_PnPSignedDriver' -Fallback @()
$net = Try-Command { Get-CimInstance Win32_NetworkAdapter -ErrorAction Stop | Where-Object { $_.PhysicalAdapter -eq $true } } @()
$netcfg = Try-Command { Get-NetIPConfiguration | Format-List * | Out-String }
$batt = Get-CimSafe -ClassName 'Win32_Battery' -Fallback @()
$baseboard = Get-CimSafe -ClassName 'Win32_BaseBoard' -First
$mem = Get-CimSafe -ClassName 'Win32_PhysicalMemory' -Fallback @()
$features = Try-Command { Get-WindowsOptionalFeature -Online | Where-Object {$_.State -eq 'Enabled'} | Select-Object FeatureName,State | Sort-Object FeatureName | Format-Table -AutoSize | Out-String }
$apps = Try-Command { Get-InstalledAppsSafe | Select-Object -First 300 | Format-Table -AutoSize | Out-String }
$services = Try-Command { Get-ServicesSummary | Where-Object {$_.Status -eq 'Running'} | Select-Object -First 200 | Format-Table -AutoSize | Out-String }
$arch = Get-ArchProfile
$batteryText = if ($batt -and @($batt).Count -gt 0) {
  $batt | Format-List * | Out-String
} else {
  'No battery class exposed.'
}

@(
'=== WINDOWS GENERAL PROBE ===',
"ARCH_FAMILY=$($arch.Family)",
"OS_ARCHITECTURE=$($arch.OSArchitecture)",
"CPU_ADDRESS_WIDTH=$($arch.CpuAddressWidth)",
'=== COMPUTER SYSTEM ===', (Get-SectionText -InputObject $cs -Mode List -Properties Manufacturer,Model,TotalPhysicalMemory,NumberOfLogicalProcessors,PCSystemType),
'=== OS ===', (Get-SectionText -InputObject $os -Mode List -Properties Caption,Version,BuildNumber,OSArchitecture,InstallDate,LastBootUpTime),
'=== CPU ===', (Get-SectionText -InputObject $cpu -Mode List -Properties Name,Manufacturer,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed,AddressWidth),
'=== MEMORY MODULES ===', (Get-SectionText -InputObject $mem -Mode Table -Properties Manufacturer,PartNumber,Capacity,Speed,ConfiguredClockSpeed),
'=== BIOS / UEFI ===', (Get-SectionText -InputObject $bios -Mode List -Properties Manufacturer,SMBIOSBIOSVersion,ReleaseDate,Version,SerialNumber),
'=== BASEBOARD ===', (Get-SectionText -InputObject $baseboard -Mode List -Properties Manufacturer,Product,Version,SerialNumber),
'=== GPU ===', (Get-SectionText -InputObject $gpu -Mode Table),
'=== DISKS ===', (Get-SectionText -InputObject $disks -Mode Table -Properties Model,InterfaceType,Size,MediaType,SerialNumber,FirmwareRevision),
'=== LOGICAL DISKS ===', (Get-SectionText -InputObject $logical -Mode Table -Properties DeviceID,VolumeName,FileSystem,Size,FreeSpace,DriveType),
'=== VOLUMES ===', (Get-SectionText -InputObject $volumes -Mode Table -Properties DriveLetter,Label,FileSystem,Capacity,FreeSpace,DriveType),
'=== BATTERY ===', $batteryText,
'=== NETWORK ADAPTERS ===', (Get-SectionText -InputObject $net -Mode Table -Properties Name,MACAddress,AdapterType,Manufacturer,NetConnectionStatus,Speed,GUID),
'=== IP CONFIGURATION ===', $netcfg,
'=== DISPLAY DRIVERS ===', (Get-SectionText -InputObject ($pnpsigned | Where-Object {$_.DeviceClass -match 'DISPLAY'}) -Mode Table -Properties DeviceName,DriverVersion,DriverProviderName,InfName),
'=== ENABLED WINDOWS FEATURES ===', $features,
'=== RUNNING SERVICES (subset) ===', $services,
'=== INSTALLED APPS (subset) ===', $apps
) | Out-File -FilePath $out -Encoding utf8

Write-Host "Report: $out"

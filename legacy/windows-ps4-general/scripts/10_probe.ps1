. "$PSScriptRoot\common.ps1"
$p = Get-ToolkitPaths
$out = Join-Path $p.Reports '01_windows_ps4_probe.txt'
Write-Log 'Windows PS4 legacy probe'

$cs = Get-WmiObject Win32_ComputerSystem
$os = Get-WmiObject Win32_OperatingSystem
$cpu = Get-WmiObject Win32_Processor | Select-Object -First 1
$bios = Get-WmiObject Win32_BIOS
$gpu = Get-WmiObject Win32_VideoController
$disks = Get-WmiObject Win32_DiskDrive
$logical = Get-WmiObject Win32_LogicalDisk
$net = Get-WmiObject Win32_NetworkAdapter | Where-Object { $_.PhysicalAdapter -eq $true }
$arch = $os.OSArchitecture

@(
'=== WINDOWS PS4 LEGACY PROBE ===',
"OS_ARCHITECTURE=$arch",
'=== COMPUTER SYSTEM ===', ($cs | Format-List Manufacturer,Model,TotalPhysicalMemory,NumberOfLogicalProcessors | Out-String),
'=== OS ===', ($os | Format-List Caption,Version,BuildNumber,OSArchitecture,InstallDate,LastBootUpTime | Out-String),
'=== CPU ===', ($cpu | Format-List Name,Manufacturer,NumberOfCores,NumberOfLogicalProcessors,MaxClockSpeed,AddressWidth | Out-String),
'=== BIOS ===', ($bios | Format-List Manufacturer,SMBIOSBIOSVersion,ReleaseDate,Version | Out-String),
'=== GPU ===', ($gpu | Format-Table Name,DriverVersion,AdapterRAM,CurrentHorizontalResolution,CurrentVerticalResolution -AutoSize | Out-String),
'=== DISKS ===', ($disks | Format-Table Model,InterfaceType,Size,SerialNumber -AutoSize | Out-String),
'=== LOGICAL DISKS ===', ($logical | Format-Table DeviceID,VolumeName,FileSystem,Size,FreeSpace,DriveType -AutoSize | Out-String),
'=== NETWORK ===', ($net | Format-Table Name,MACAddress,Manufacturer,Speed -AutoSize | Out-String),
'=== SYSTEMINFO ===', ((systeminfo | Out-String))
) | Out-File -FilePath $out -Encoding utf8

Write-Host "Report: $out"

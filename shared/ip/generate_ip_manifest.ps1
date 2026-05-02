param([string]$Root = (Get-Location).Path)
$OutDir = Join-Path $Root 'shared\ip\evidence'
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null
$Ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$Out = Join-Path $OutDir ("ip_manifest_{0}.txt" -f $Ts)
"# IP MANIFEST" | Out-File -FilePath $Out -Encoding utf8
"generated_at=$Ts" | Out-File -FilePath $Out -Append -Encoding utf8
"root=$Root" | Out-File -FilePath $Out -Append -Encoding utf8
Get-ChildItem -Path $Root -Recurse -File |
  Where-Object { $_.FullName -notmatch '\\.git\\|\\output\\' -and $_.Extension -ne '.zip' } |
  Sort-Object FullName |
  ForEach-Object {
    $hash = Get-FileHash -Algorithm SHA256 -Path $_.FullName
    "{0}  {1}" -f $hash.Hash, $_.FullName
  } | Out-File -FilePath $Out -Append -Encoding utf8
Write-Host "Manifest: $Out"

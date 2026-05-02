param([string]$Root = (Get-Location).Path)

$OutDir = Join-Path $Root 'shared\ip\evidence'
New-Item -ItemType Directory -Path $OutDir -Force | Out-Null

$Ts = Get-Date -Format 'yyyyMMdd_HHmmss'
$Manifest = Join-Path $OutDir ("release_manifest_{0}.sha256" -f $Ts)
$Inventory = Join-Path $OutDir ("release_inventory_{0}.txt" -f $Ts)
$Meta = Join-Path $OutDir ("release_metadata_{0}.txt" -f $Ts)

$commit = 'not_available'
$branch = 'not_available'
try { $commit = (git -C $Root rev-parse HEAD) } catch {}
try { $branch = (git -C $Root rev-parse --abbrev-ref HEAD) } catch {}

"# RELEASE METADATA" | Out-File -FilePath $Meta -Encoding utf8
"generated_at=$Ts" | Out-File -FilePath $Meta -Append -Encoding utf8
"root=$Root" | Out-File -FilePath $Meta -Append -Encoding utf8
"git_commit=$commit" | Out-File -FilePath $Meta -Append -Encoding utf8
"git_branch=$branch" | Out-File -FilePath $Meta -Append -Encoding utf8

$files = Get-ChildItem -Path $Root -Recurse -File |
  Where-Object {
    $_.FullName -notmatch '\\.git\\' -and
    $_.FullName -notmatch '\\output\\' -and
    $_.FullName -notmatch '\\shared\\ip\\evidence\\' -and
    $_.Extension -ne '.zip'
  } |
  Sort-Object FullName

$files.FullName | Out-File -FilePath $Inventory -Encoding utf8

foreach ($file in $files) {
  $hash = Get-FileHash -Algorithm SHA256 -Path $file.FullName
  "{0}  {1}" -f $hash.Hash, $file.FullName | Out-File -FilePath $Manifest -Append -Encoding utf8
}

Write-Host "metadata=$Meta"
Write-Host "inventory=$Inventory"
Write-Host "manifest=$Manifest"

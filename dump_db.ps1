# Dump the 'nms' database to a gzipped SQL file for distribution (attach to a GitHub Release).
# Usage:  .\dump_db.ps1  [-User peq] [-Password peqpass] [-Db nms]
param(
  [string]$User = "peq",
  [string]$Password = "peqpass",
  [string]$Db = "nms",
  [string]$MariaBin = "C:\Program Files\MariaDB 11.6\bin",
  [string]$OutDir = ".\dump"
)
$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Force $OutDir | Out-Null
$stamp = Get-Date -Format "yyyyMMdd"
$sql = Join-Path $OutDir "$Db-$stamp.sql"
$gz  = "$sql.gz"

Write-Host "Dumping $Db -> $sql ..."
# --routines/--events/--triggers so quests' stored logic and progression carry over.
& "$MariaBin\mysqldump.exe" -u $User "-p$Password" --single-transaction --routines --events --triggers $Db > $sql
if ($LASTEXITCODE -ne 0) { throw "mysqldump failed ($LASTEXITCODE)" }

Write-Host "Compressing -> $gz ..."
$in = [System.IO.File]::OpenRead($sql)
$out = [System.IO.File]::Create($gz)
$gzip = New-Object System.IO.Compression.GzipStream($out, [System.IO.Compression.CompressionLevel]::Optimal)
$in.CopyTo($gzip); $gzip.Dispose(); $out.Dispose(); $in.Dispose()
Remove-Item $sql
Write-Host "Done: $gz  ($([math]::Round((Get-Item $gz).Length/1MB,1)) MB)"
Write-Host "Attach this file to a GitHub Release (it is .gitignored, do not commit it)."

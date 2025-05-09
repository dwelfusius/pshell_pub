$MyCollection = New-Object System.Collections.ArrayList
$dir = ""

$dirs = Get-ChildItem $dir -Directory
[long]$val = 5000000000
$i = 0
foreach ($f in $dirs.fullname) {
   Write-Progress -Activity "Searching $f and subfolders" -PercentComplete ($i++/$dirs.Length * 100)
   Get-ChildItem -Path $f -Recurse -File -ErrorAction SilentlyContinue |Where-Object {$_.Length -gt $val}|Select-Object FullName, Length, LastAccessTime, LastWriteTime | % { 
   $MyCollection.Add([pscustomobject]@{'Fullname' = $_.fullname;'length' = ($_.Length / 1GB) ; 'lastacccesstime' = (Get-Date $_.LastAccessTime -Format yyyyMMddHHmm); 'lastwritetime' = (Get-Date $_.LastWriteTime -Format yyyyMMddHHmm) }) | Out-Null }
}
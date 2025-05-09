$paths = @(1..6)
$logs = @()
$after = (get-date).AddHours(-1)
$before = (get-date).AddHours(-0)

foreach ($s in $paths)
{
    $progress = “{0:P0}” -f ($s/6)
    Write-Progress -Activity "Aggregating logs: $progress" -PercentComplete ($s/6*100)
    $path = "\\SVWEXCHANGE0$($s)P\d$\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\ProtocolLog\"
    $logs += ((Get-ChildItem $path -Recurse -File|?{$_.LastWriteTime -gt $after -and $_.LastWriteTime -lt $before}|Get-Content))
}

$query = Read-Host -Prompt "Enter search query: "
($logs|Select-String -SimpleMatch $query).line|ogv
$paths = @(1..6)
$logs = @()
$after = (get-date "1/18/2021 10:00").AddDays(-0)
$before = (Get-Date).AddDays(-3)
 
#$after = (Get-Date -Date "10/6/2020 10:00")
#$before = (Get-Date -Date "10/6/2020 13:00")

<#
$after = (Get-Date -Date "10/5/2020 6:00")
$before = (Get-Date -Date "10/5/2020 8:00")
#>


foreach ($s in $paths)
{
    $progress = {0:P0} -f ($s/6)
    Write-Progress -Activity "Aggregating logs: $progress" -PercentComplete ($s/6*100)
    $path = "\\SVWEXCHANGE0$($s)P\d$\Program Files\Microsoft\Exchange Server\V15\TransportRoles\Logs\FrontEnd\ProtocolLog\"
    $logs += ((Get-ChildItem $path -Recurse -File|Where-Object {$_.LastWriteTime -gt $after -and $_.LastWriteTime -lt $before}|Get-Content))
}

##$logs|out-file c:\temp\relayissue.txt
##$logs|ogv

$query = Read-Host -Prompt "Enter search query: "
($logs | Select-String -SimpleMatch $query).line | Out-GridView
get-content c:\temp\logsercam.log|ogv
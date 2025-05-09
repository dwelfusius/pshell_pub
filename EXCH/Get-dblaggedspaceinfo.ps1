Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
##Check mailbox database threshold values and alert accordingly.
Get-Date

$Databases = Get-MailboxDatabase | where{$_.name -like "mdb*"}|sort-object name #Get-mailboxdatabase mdb0005
$Servers   = (Get-ExchangeServer).name

Foreach($database in $Databases) {
    Get-MailboxDatabase $Database.Name -Status | select name,@{name='databasesize';Expression={$_.databasesize.ToGB()}},AvailableNewMailboxSpace
    $FolderName = $database.Name

    Foreach($Server in $Servers) {
        $Laggedcopy = Get-MailboxDatabaseCopyStatus $FolderName\$Server| select -ExpandProperty activationpreference
        $date = If ($Laggedcopy -ne 4 ){(Get-Date).AddDays(-1)}Else {(Get-Date).AddDays(-7)}

        $Folderpath = "\\$Server\d$\Mountpoints\$FolderName\log"
        $Item = Get-ChildItem -Path $Folderpath |Measure-Object -property length -sum 
        $Age = Get-ChildItem -Path $Folderpath -File *.log | where {$_.CreationTime -lt $date}|measure
        $Laggedcopy = Get-MailboxDatabaseCopyStatus $FolderName\$Server| select -ExpandProperty activationpreference
        
        Write-Host
        Write-host -ForegroundColor Cyan "There is $(((Get-MailboxDatabaseCopyStatus $FolderName\$Server).DiskFreeSpacePercent))% free on mountpoint." 
        "{0:N2}" -f ($Item.sum / 1MB) + " MB","\\$Server\d$\Mountpoints\$FolderName\log"
        if($age.Count -gt 2) {
            if ($Laggedcopy -eq 4 ){
                Write-Host -ForegroundColor Magenta "$($age.count) files in this LAGGED copy folder are older than 7 days."
            }
            else {
                Write-Host -ForegroundColor Magenta "$($age.count) files in this NON-LAGGED copy folder are older than 1 days."
            }
        }
    }
    Write-Host
}
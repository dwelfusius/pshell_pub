Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$BulkImport = Import-Csv "\\degroof.be\admin\backup\exchange\pst\bulk\bulk.csv"
ForEach ($Entry in $BulkImport) {
Write-host “Executing users : “$Entry.user
Write-host “using userpath : “$Entry.userpath
New-MailboxImportRequest -Mailbox $Entry.user -filepath $Entry.userpath -TargetRootFolder "ComplaintsMB"
}

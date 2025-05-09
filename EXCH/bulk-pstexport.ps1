Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$batchname = Read-Host "Please enter a batch name"
$content = "rkg" #get-content "c:\temp\dedoublage.txt"
foreach ($user in $content) 
{

$username = Get-Recipient $user |select firstname,lastname
$username = $username.FirstName+"_"+$username.LastName


New-MailboxExportRequest -Name "$username mb" -Mailbox $user -FilePath "\\degroof.be\admin\backup\exchange\pst\$($username)_mailbox.pst" -BatchName $batchname
New-MailboxExportRequest -Name "$username archive" -Mailbox $user -IsArchive -FilePath "\\degroof.be\admin\backup\exchange\pst\$($username)_archive.pst" -BatchName $batchname
} 

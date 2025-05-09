$mailbox = Read-Host -Prompt "Enter alias of mailbox on which to apply permissions."

$folders = Get-MailboxFolderStatistics $mailbox|select -ExpandProperty folderpath #|Out-String
$folders = $folders.Replace("/","\")

$users = @("lmr","bpc")
$user = foreach ($u in $users) {Get-recipient $u |select samaccountname }

foreach ($f in $folders){
      $f = "$($mailbox):$($f)"
    foreach ($u in $user){
     
     #add-MailboxFolderPermission $f -User $u.SamAccountName -AccessRights "Reviewer"
     
     #Add-MailboxFolderPermission $mailbox -User $u.SamAccountName -AccessRights "Reviewer"
     
     ###Check permissions
     #Get-MailboxFolderPermission $f
     }}
$users = "nmh","yml","gdh"
$obj = New-Object System.Collections.ArrayList

foreach($u in $users){
$array = Get-aduser $u -Properties *|select -ExpandProperty memberof|?{$_ -like "*exchange_sharedmailbox*"}
#$list = foreach ($a in $array){$a.trimstart("CN=EXCHANGE_SharedMailboxAccess_").trimend(",OU=Exchange,OU=Security,OU=Groups,OU=BDB,DC=degroof,DC=be")}
foreach ($a in $array){

$obj += New-Object psobject -Property @{
"User" = Get-aduser $u|select -ExpandProperty name
"Mailboxaccess" = $a.tostring()
"Mailboxfolders" = get-mailbox $a.remove(0,32).replace(",OU=Exchange,OU=Security,OU=Groups,OU=BDB,DC=degroof,DC=be","")|Get-MailboxFolderStatistics |measure|select -ExpandProperty count
"Mailboxsize" = $((Get-MailboxStatistics $a.remove(0,32).replace(",OU=Exchange,OU=Security,OU=Groups,OU=BDB,DC=degroof,DC=be","")).TotalItemSize.value.toMB()).tostring() +" MB"
"Groupmembers" = ((Get-ADGroupMember $a -Recursive |select -ExpandProperty name) -join ",")

}


}





}
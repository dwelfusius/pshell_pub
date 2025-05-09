$folders = @("rfp.datacenter:\"
,"rfp.datacenter:\Calendar"                                                                                                                                  
,"rfp.datacenter:\Contacts"                                                                                                                                  
,"rfp.datacenter:\Drafts"                                                                                                                                    
,"rfp.datacenter:\Inbox"                                                                                                                                     
,"rfp.datacenter:\Junk Email"                                                                                                                                
,"rfp.datacenter:\Notes"                                                                                                                                     
,"rfp.datacenter:\Outbox"                                                                                                                                    
,"rfp.datacenter:\Sent Items") 

$users = @("Stephanie Bongartz","Frederic Mencigar")
$user = foreach ($u in $users) {Get-recipient $u |select samaccountname }

foreach ($f in $folders){
    
    foreach ($u in $user){
    add-MailboxFolderPermission $f -User $u.SamAccountName -AccessRights "PublishingEditor"}}
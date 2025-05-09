Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
Import-Module ActiveDirectory
$FormatEnumerationLimit = -1


## get enabled users with delegatesBL populated
$strUsers = Get-ADUser -SearchBase "OU=pMUsers,DC=degroof,DC=be" -Properties * -LDAPFilter "(&(msexchdelegatelistbl=*)(useraccountcontrol=512))"|select name,displayname,msexchdelegatelistbl


function get-del{
foreach ($u in $strUsers){

## check mailboxes in AD field  for group access permissions

    $strRights = $u.msexchdelegatelistbl | %{Get-MailboxPermission $_ }|Where-Object user -Like "*exchange_sharedmailboxaccess*" |select user,identity
        foreach ($r in $strRights){

## make output matching expected search criteria
        $rg = $r.user -replace "degroof\\",""
        $strMembers = Get-ADGroupMember $rg -Recursive | select -ExpandProperty name

## recursively check if user has permission via group           
            If($strMembers -contains $u.name){
             continue  #Write-Host $u.displayname" exists in the $rg group"
            } Else {
             
              Write-Host -ForegroundColor yellow $u.displayname" does not exist in the $rg group"
            }
            
   New-Object psobject -Property @{ 
  #
       name = $u.name
       displayname = $u.displayname
       mailbox = $r.Identity
   }}}}

$(get-del) |ConvertTo-Html > c:\temp\dlbl.html


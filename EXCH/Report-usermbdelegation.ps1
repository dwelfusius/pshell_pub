WORK IN PROGRESS!

function get-mbfolderperm(){

    $rights = [System.Collections.Arraylist]@()
    $mbs = Get-Mailbox -RecipientTypeDetails usermailbox -ResultSize unlimited
    foreach ($m in $mbs)
    {
        $r = @()
        $folders = Get-MailboxFolderStatistics $m.Name | ?{$_.foldertype -like '*inbox' -or $_.foldertype -like 'notes*' -or $_.foldertype -like 'contacts*'}
        Get-MailboxFolderPermission $m.Name |?{$_.user -notlike '*Default*' -and $_.user -notlike '*Anonymous*'  -and $_.user -notlike $m.displayname}|select @{n='Mailbox';e={$m.DisplayName}},foldername,user,accessrights -OutVariable +r
        foreach ($f in $folders)
        {
            Get-MailboxFolderPermission "$($m.Name):\$($f.name)" |?{$_.user -notlike '*Default*' -and $_.user -notlike '*Anonymous*' -and $_.user -notlike $m.displayname}|select @{n='Mailbox';e={$m.DisplayName}},foldername,user,accessrights -OutVariable +r
        }
    
        $rights.add($r)
    }

    $csv = [System.Collections.Arraylist]@()
    foreach ($r in $rights)
    {
     foreach ($row in $r)
     {
        $o = [pscustomobject]@{
        Mailbox = $row.mailbox
        Foldername = $row.foldername
        User = $row.user
        AccessRights = [string]$row.accessrights
        }
        $csv.Add($o)
     }
    }

$csv|Export-Csv -Delimiter ';' -NoTypeInformation -Path c:\temp\usermbpermission.csv
    
}



function get-mailboxperm(){
$rights = [System.Collections.Arraylist]@()
$mbs = Get-Mailbox -RecipientTypeDetails usermailbox -ResultSize unlimited
$ignore =@('DEGROOF\Delegated Setup',
'DEGROOF\Domain Admins',
'DEGROOF\Enterprise Admins',
'DEGROOF\Exchange Servers',
'DEGROOF\Exchange Trusted Subsystem',
'DEGROOF\Managed Availability Servers',
'DEGROOF\Organization Management',
'DEGROOF\Public Folder Management',
'DEGROOF\SOGRAIADM',
'DEGROOF\svc_adm_xylos01p',
'DEGROOF\XYLKRNADM',
'FSERVE\mail_archiver',
'NT AUTHORITY\NETWORK SERVICE',
'NT AUTHORITY\SELF',
'NT AUTHORITY\SYSTEM',
'DEGROOF\svc_enterprisevault')
foreach ($m in $mbs)
{
    $r = @()
    $r = Get-MailboxPermission $m.Name | ?{$_.user -notin $ignore -and $_.user -notlike "Degroof\$($m.samaccountname)" -and $_.user -notlike 'Fserve\*' -and $_.user -notlike '*svc_*'}

    if ($r){
    $rights.add($r) }
}

$csv = [System.Collections.Arraylist]@()
foreach ($r in $rights)
{
 foreach ($row in $r)
 {
    $o = [pscustomobject]@{
    Mailbox = (get-mailbox $row.identity).displayname
    User = $row.user
    AccessRights = [string]$row.accessrights
    }
    $csv.Add($o)
 }
}


$csv|Export-Csv -Delimiter ';' -NoTypeInformation -Path c:\temp\usermbFApermission.csv
}




function get-sendonbehalf() {
$sendonbehalf = foreach ($m in $mbs){
    Get-Mailbox $m |select displayname,GrantSendOnBehalfTo
}
$sendonbehalf|?{$_.grantsendonbehalfto -like '*'}|select displayname,@{n='sendonbehalf';e={[string]$_.grantsendonbehalfto}}|Export-Csv -Delimiter ';' -NoTypeInformation -Path c:\temp\usersendonbehalf.csv
}


function get-sendas() {
## for this one I opted to use the get-acl instead of get-adpermission cmdlet because the speed is way higher on big volumes. Get-Adpermission (exchange cmdlet) is still preferred for smaller operations

$mbs = get-mailbox -RecipientTypeDetails usermailbox -ResultSize unlimited
$csv = [System.Collections.Arraylist]@()

foreach ($mb in $mbs){

$rights = (Get-Acl $mb.distinguishedname).Access.Where({($_.ActiveDirectoryRights -eq "ExtendedRight") -and ($_.objectType -eq "ab721a54-1e2f-11d0-9819-00aa0040529b") -and $_.IdentityReference -notlike "*fserve*" -and $_.IdentityReference -notlike 'NT AUTHORITY\SELF*' -and $_.identityreference -notlike "DEGROOF\$($mb.name)"})

foreach ($r in $rights)
{
    $o = [pscustomobject]@{
    Mailbox = $mb.displayname
    User = $r.IdentityReference
    AccessRights = "Send-As"
    }
    $csv.Add($o)
 }

}


$csv |Export-Csv -Delimiter ';' -NoTypeInformation -Path c:\temp\usersendas.csv -Encoding utf8
}



Send-MailMessage -Attachments c:\temp\usersendonbehalf.csv -To a.richoux@degroofpetercam.com -From gen_Exchange_Tier1_2@degroofpetercam.com -SmtpServer smtp.degroof.be -DeliveryNotificationOption OnSuccess -Subject 'User sendonbehalf rights'
Send-MailMessage -Attachments c:\temp\usermbpermission.csv -To a.richoux@degroofpetercam.com -From ktc@degroofpetercam.com -SmtpServer smtp.degroof.be -DeliveryNotificationOption OnSuccess -Subject 'User mailboxfolders accessrights'
Send-MailMessage -Attachments c:\temp\usermbpermission.csv -To a.richoux@degroofpetercam.com -From ktc@degroofpetercam.com -SmtpServer smtp.degroof.be -DeliveryNotificationOption OnSuccess -Subject 'User fullaccess permissions'
Send-MailMessage -Attachments c:\temp\usersendas.csv -To a.richoux@degroofpetercam.com -From gen_Exchange_Tier1_2@degroofpetercam.com -SmtpServer smtp.degroof.be -DeliveryNotificationOption OnSuccess -Subject 'User send as rights'
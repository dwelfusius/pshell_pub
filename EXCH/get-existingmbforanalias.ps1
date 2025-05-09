Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn 
# Get all mailboxes
$mailboxes = get-mailbox -ResultSize unlimited;
$miamailboxes = "dpg.gestion" #Get-Content C:\temp\mailmia.txt
$FormatEnumerationLimit = -1


foreach ($m in $miamailboxes){ 
## Loop through each mailbox
foreach ($mailbox in $mailboxes) {
    $emailaddresses = $mailbox.emailaddresses

        # Change the domain name below to what you want to remove
        if ($emailaddresses[$i].smtpaddress -like "*$m*") {
 
            # Remove the unwanted email address
            Write-Host $mailbox.alias "has an alias for $m" -ForegroundColor Red 
            Get-MailboxPermission $mailbox.alias |Where-Object {(($_.accessrights -eq "fullaccess") -and ($_.isinherited -eq $false)) }|ft user,access* -HideTableHeaders
            $emailaddresses.smtpaddress
            " "

         } 
     }
 }

#Get-Recipient -Filter {emailaddresses -like "*cdo*"}|fl name,emailaddresses
#Get-MailboxPermission itgroupware |Where-Object {(($_.accessrights -eq "fullaccess") -and ($_.isinherited -eq $false)) }|ft user,access*
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
$buk = Import-Csv -Delimiter "," \\degroof.be\public\users\KTC\meetingchange.csv

ForEach ($entry in $buk){

#Set-Mailbox -Identity $entry.original -Name $entry.visname -Alias $entry.name -DisplayName $entry.visname -SamAccountName $entry.account -userPrincipalName "$($entry.account)@degroof.be" -emailaddresses @{add="$($entry.name)@degroofpetercam.com","$($entry.name)@degroof.be"}
#Set-Mailbox $entry.name -SingleItemRecoveryEnabled $true -Office $entry.office -EmailAddressPolicyEnabled $false 
Set-User $entry.name -FirstName $entry.fname -lastname $entry.lname -Office $entry.office
}
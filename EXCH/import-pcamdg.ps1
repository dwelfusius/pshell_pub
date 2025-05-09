#$groups = import-csv 'N:\My Files\importdgpcamfinal.csv' -Delimiter ";"
$groups = import-csv 'n:\my files\singleimport.csv' -Delimiter ";"
foreach ($group in $groups)
{
$contact = get-recipient $group.name -OrganizationalUnit "OU=GALSYNC,DC=degroof,DC=be" -ErrorAction SilentlyContinue|where {$_.name -eq $group.name}
$group.name
#if($contact){
write-host "Processing $contact ..." -ForegroundColor Magenta

#$x500 = $contact.EmailAddresses.proxyaddressstring|?{(($_ -like "x500:/o=bdg*") -or ($_ -like "x500:/o=petercam*"))}
$x500 = $group.x500

$alias = ($group.groupmail -split "@")[0]
$group.members
#Remove-ADObject $contact.DistinguishedName -server srvwndc01p.degroof.be -Confirm:$false
#Write-host "Deleting $($contact.distinguishedname)." -ForegroundColor green
#Get-Recipient $contact |Update-Recipient

$exists = Get-ADObject  -Filter 'samaccountname -like $alias'
#start-sleep 30
if($exists){
do{Write-host "$($exists.DistinguishedName) already exists, please fix this before continuing.";$a=Read-Host "Press enter to continue."}
#until ($exists -eq $null)}
until ($a -eq "0")}
New-DistributionGroupDP -Alias $alias -DisplayName $group.name -IntorExt External -Description "Distribution group $($group.name) migrated from Petercam" -ManagedBy $group.managedby -Members $group.members -Confirm False
Start-Sleep 10
Set-DistributionGroup $alias -EmailAddresses @{add=$x500} -DomainController srvwndc01p.degroof.be
Read-Host "..."
#}

}
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
$dl = Read-Host -prompt "Enter name of distribution group";
$intorext = Read-Host -prompt "(i)nternal or (e)xternal";

function get-ou{
    If($intorext -eq "i") {"Internal"}
    Else {"External"}
}


New-DistributionGroup $dl -OrganizationalUnit "OU=$(get-ou),OU=Distribution,OU=Groups,OU=BDB,DC=degroof,DC=be"
Start-Sleep 15
#$content = get-content "n:\members.txt"

Set-DistributionGroup $dl@degroofpetercam.com -RequireSenderAuthenticationEnabled $false -EmailAddressPolicyEnabled $false
#$content| Add-DistributionGroupMember "$dl" 

$addmembers = Read-Host -prompt "add members from txt file now? (y)es or (n)o";
    If($addmembers -eq "n") {break}
Get-Content "\\degroof.be\public\users\ktcadm\members.txt"|Add-DistributionGroupMember $dl@degroofpetercam.com
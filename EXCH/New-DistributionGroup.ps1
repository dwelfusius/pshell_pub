Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$strAlias = Read-Host -prompt "Enter alias of distribution group";
$strDispName =  Read-Host -prompt "Enter display name of distribution group";
$intorext = Read-Host -prompt "(i)nternal or (e)xternal";
$comment = Read-Host -Prompt "Please enter a description for the group"

## validate $strManagedby
do
{
     $strManagedby = Read-Host -Prompt "Enter the name or trigramme of the person that is responsible for this group"
     $user = Get-ADUser -Properties * -Filter {(samaccountname -eq $strManagedby) -or (displayname -like $strManagedby)}
}
until ($user -ne $null)

## to check which OU is needed
    function get-ou
    {
        do
        {
            If(($intorext -eq "i") -or ($intorext -eq "e")){test-ou}
           
            Else {Write-Host "Please type e or i."}
        }
        Until (($intorext -eq "i") -or ($intorext -eq "e"))
    }

## define proper OU
    function test-ou
    {     
        If($intorext -eq "i") {"Internal"}
        Else {"External"}
    }


##Creation of distribution group

    Write-Host -ForegroundColor Yellow "Creating distribution group $strDispName"
    Read-Host "Press enter to continue"

        New-DistributionGroup $strAlias.ToLower() -OrganizationalUnit "OU=$(get-ou),OU=Distribution,OU=Groups,OU=BDB,DC=degroof,DC=be" -DisplayName "$strDispName" -Notes $comment -DomainController svwdcd101p
        #Start-Sleep 15
       
    Write-Host -ForegroundColor Yellow "Editing distribution group attributes..."

        #Set-DistributionGroup $strAlias@degroofpetercam.com -RequireSenderAuthenticationEnabled $false -EmailAddressPolicyEnabled $false -Name "$strDispName".Replace(" ","") -ManagedBy $user.SamAccountName
        Set-DistributionGroup $strAlias -RequireSenderAuthenticationEnabled $false -EmailAddressPolicyEnabled $false -Name "$strDispName" -ManagedBy $user.SamAccountName -DomainController svwdcd101p

        Get-DistributionGroup $strAlias -DomainController svwdcd101p |select emailaddresses

## To add members to a distribution group



$addmembers = Read-Host -prompt "Add members from txt file now? (y)es or (n)o";
        If($addmembers -eq "n") {break}

    Get-Content "n:\members.txt"|Get-Recipient| Add-DistributionGroupMember $strAlias@degroofpetercam.com -DomainController svwdcd101p

    Write-Host ""
    Write-Host -ForegroundColor Green "Distribution Group members: $strDispName - $strAlias@degroofpetercam.com"
    #Start-Sleep 2
    Get-DistributionGroupMember $strAlias -DomainController svwdcd101p | ft name,displayname,PrimarySmtpAddress -HideTableHeaders 

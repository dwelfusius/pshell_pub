<# Import/Export Distribution Lists

Changelog:
2017-05-09: Added WhenCreated and WhenModified columns to capture WhenCreated/WhenModified Dates.
			Added -Manager parameter to capture ManagedBy
2017-04-06: Added OnlyProcessMembers param to skip processing adding distribution groups
            and only add missing members to lists. Added counter to provide a better
            status on how many contacts are left to process. Updated -Filter query for
            export to use server side filtering instead of client side filtering. Added
            CheckForSynchronizedGroups switch to skip trying to update members of groups
            that are synchronized from on-premises.  Added LegacyExchangeDN to export and
            import.
2017-02-28: Updated logic for adding proxy addresses; add contacts for missing recipients.
2016-06-15:	Added logfile param; added checking for contacts objects that were
			already imported.
2016-06-10: Added Distribution group proxy addresses, import/export modes, and
			export filter; updated documentation and help content
2014-10-08:	Updated DG mail attribute, added user alias attribute, fixed DG 
			mail attribute issue where report was displaying member email
			address instead of DG email address; added GroupType
2014-10-07:	Added Distribution Group Mail Attribute.

THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY
OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE.
THE ENTIRE RISK OF USE, INABILITY TO USE, OR RESULTS FROM THE USE OF THIS CODE 
REMAINS WITH THE USER.
#>

#>
<#
.SYNOPSIS
Exports a CSV of all distribution groups and members, one group / member
per line.

.DESCRIPTION
This script will create and export a list of all distribution groups and
their direct members. The output is in the following format:
"Distribution Group","DisplayName","PrimarySmtpAddress"

.PARAMETER CreateContactsForMissingRecipients
Create a mail-enabled contact for recipients that do not exist in the organization or tenant.

.PARAMETER CheckForSynchronizedGroups
When target is an Office 365 tenant, check to see if the group is synchronized. Synchronized groups
can only be updated on-premises.

.PARAMETER Filename
This parameter is used to specify the output file name.

.PARAMETER Filter
Specify filter as a domain (domain.com or sub.domain.com) or as an individual
SMTP address (group@domain.com).

.PARAMETER Logfile
Specify a logfile to be created.

.PARAMETER Manager
Extract the SMTP address for the ManagedBy attribute.

.PARAMETER Mode
Used to select Import or Export mode.

.PARAMETER OnlyProcessMembers
Only update group members; don't try to create new groups.

.EXAMPLE
.\DistributionGroupImportExport.ps1 -Mode Export -Filename DistributionGroups.csv
Export all distribution groups to file DistributionGroups.csv.

.EXAMPLE
.\DistributionGroupImportExport.ps1 -Mode Export -Filename DistributionGroups.csv -Filter sub.contoso.com
Export all distribution groups matching domain 'sub.contoso.com' to file DistributionGroups.csv.

.EXAMPLE
.\DistributionGroupImportExport.ps1 -Mode Export -Filename DistributionGroups.csv -Filter group@contoso.com
Export single distribution group 'group@contoso.com' to fic:<le DistributionGroups.csv.

.EXAMPLE
.\DistributionGroupImportExport.ps1 -Mode Import -Filename DistributionGroups.csv
Import distribution groups and members from file DistributionGroups.csv.

.EXAMPLE
.\DistributionGroupImportExport.ps1 -Mode Import -Filename DistributionGroups.csv -CreateContactsForMIssingRecipients
Import distribution groups and members from file DistributionGroups.csv and create new mail contacts
for members that are not recipients in the Exchange organization.

.LINK
For an updated version of this script, check the Technet
Gallery at http://gallery.technet.microsoft.com/http://gallery.technet.microsoft.com/Distribution-Group-Report-d32c4788.
#>

Param(
	[Parameter(Mandatory=$false,HelpMessage="Check for synchronized groups")]
		[switch]$CheckForSynchronizedGroups,
	[Parameter(Mandatory=$false,HelpMessage="Create contacts for missing recipients")]
        [switch]$CreateContactsForMissingRecipients,
	[Parameter(Mandatory=$true,HelpMessage="Input or Output file name")]
		[string]$Filename,
	[Parameter(Mandatory=$false,HelpMessage="Domain or individual group SMTP Address")]
		[string]$Filter,
	[Parameter(Mandatory=$false,HelpMessage="Enable logging")]
		[string]$Logfile,
	[Parameter(Mandatory = $false, HelpMessage = "Managed By")]
		[switch]$Manager,
	[Parameter(ParameterSetName='RunMode')]
		[ValidateSet("Export", "Import")]
		[string]$Mode,
    [Parameter(Mandatory=$false,HelpMessage="Import only group members")]
		[switch]$OnlyProcessMembers
	)

If (!($Logfile))
	{
	$TimeStamp = Get-Date -Format yyyy-MM-dd_hhmmss
	$Logfile = "DistributionGroupImportExport_$TimeStamp"+".txt"
	}

Function Write-Log {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $false,Position = 0)]
        	[String]$Message = "",
		[Parameter()]
			[switch]$WriteFile,
        [Parameter()]
        	[switch]$WriteOut,
		[Parameter()]
			[ValidateSet("Info","Warning","Error","Verbose")]
			[string]$EntryType
		)

	# Output the message for verbose logging.
    Write-Verbose -Message $Message

    # WriteOut writes to Console
    If ($WriteOut) 
		{
        Write-Output $Message
    	}

	# WriteFile writes to log
    If ($WriteFile)
		{
        $MessageFinal = ("{0} {1}" -f $(Get-Date -Format "MM-dd-yyyy hh:mm:ss"), $EntryType.ToUpper() +": " + $Message)

        Try 
			{
            Add-Content -Path $LogFile -Value $MessageFinal -ErrorAction Stop
        	}
        Catch 
			{
            throw $("Could not write to log file: {0}" -f $_.Exception.Message)
        	}
    	} #END -writeFile
	} #End Function Write-Log

Switch ($Mode)
	{
	Export
		{
		$DistributionGroupReports=@()
		If ($Filter)
			{
			If ($Filter -like "*@*")
				{
				# We think filter is an individual group
				[array]$Groups = Get-DistributionGroup $Filter
				}
			Else
				{
				# We think filter is a domain
				[array]$Groups = Get-DistributionGroup -ResultSize Unlimited  -Filter { WindowsEmailAddress -like "*$($Filter)"}
				}
			}
		Else
			{
			[array]$Groups = Get-DistributionGroup -ResultSize Unlimited -OrganizationalUnit "OU=Distribution,OU=Groups,OU=BDB,DC=degroof,DC=be"
			}
		Write-Host -NoNewLine "Total number of Distribution Groups Matching Filter: "; Write-Host -ForegroundColor Green $Groups.Count
		$i = 1
		$Groups| ForEach {
			$GroupName = $_.DisplayName
			$GroupMail = $_.PrimarySmtpAddress
			$GroupProxies = $_.EmailAddresses
			$GroupType = $_.RecipientTypeDetails
			$GroupLegDN = $_.legacyExchangeDN
			$WhenCreated = $_.WhenCreated
			$WhenChanged = $_.WhenChanged
			Write-Host -NoNewline "Procesing "; Write-Host -ForegroundColor Green "[$($i)/$($Groups.Count)] $GroupName ..."
			If ($Manager)
			{ $managedby = $null
                if ($_.managedby -like "*"){
				$ManagedBy = Get-aduser $_.ManagedBy.DistinguishedName -Properties emailaddress  | select -ExpandProperty emailaddress
                Write-Host -ForegroundColor DarkGreen $managedby	}			

				$DistributionGroupReport = Get-DistributionGroupMember -ErrorAction SilentlyContinue -ResultSize Unlimited -Identity $_.Identity | Select @{ Name = 'DistributionGroup'; Expression = { [String]::join(";", $($GroupName)) } }, @{ Name = 'EmailAddresses'; Expression = { [string]::Join("|", $($GroupProxies)) } }, @{ Name = 'mail'; Expression = { [string]::Join(";", $($GroupMail)) } }, @{ Name = 'GroupType'; Expression = { [string]::Join(";", $($GroupType)) } }, DisplayName, PrimarySmtpAddress, alias, @{n="DN";e={ get-aduser $_.distinguishedname -Properties *|select -ExpandProperty canonicalName}}, @{ Name = 'LegacyDN'; Expression = { $($GroupLegDN) } }, @{ Name = 'GroupWhenCreated'; Expression = { $($WhenCreated) } }, @{ Name = 'GroupWhenModified'; Expression = { $($WhenChanged) }}, @{ Name = 'GroupManagedBy'; Expression = { $($ManagedBy) } }
				$DistributionGroupReports = $DistributionGroupReports + $DistributionGroupReport
			}
			Else
			{
				$DistributionGroupReport = Get-DistributionGroupMember -ErrorAction SilentlyContinue -ResultSize Unlimited -Identity $_.Identity | Select @{ Name = 'DistributionGroup'; Expression = { [String]::join(";", $($GroupName)) } }, @{ Name = 'EmailAddresses'; Expression = { [string]::Join("|", $($GroupProxies)) } }, @{ Name = 'mail'; Expression = { [string]::Join(";", $($GroupMail)) } }, @{ Name = 'GroupType'; Expression = { [string]::Join(";", $($GroupType)) } }, DisplayName, PrimarySmtpAddress, alias, legacyExchangeDN, @{ Name = 'GroupWhenCreated'; Expression = { $($WhenCreated) } }, @{ Name = 'GroupWhenModified'; Expression = { $($WhenChanged) }}
				$DistributionGroupReports = $DistributionGroupReports + $DistributionGroupReport
			}
			$i++
		 	}
		 
		 $DistributionGroupReports | Export-Csv -NoType -Path $Filename -ErrorAction SilentlyContinue
		 } # End Export
	Import
		{
        # Add Filter Support
        If ($Filter)
			{
			If ($Filter)
				{
                [array]$GroupsTemp = Import-Csv $Filename
                [array]$Groups = $GroupsTemp | ? { $_.EmailAddresses -match $Filter }
                $GroupsTemp = $null 
				}
			}
        Else
            {
            $Groups = Import-Csv $Filename
            }
		[array]$UniqueGroups = $Groups | Select DistributionGroup,EmailAddresses,Mail | Sort -Unique -Property Mail
 		Write-Log -Message "Processing $($UniqueGroups.Count) Distribution Groups." -WriteFile -WriteOut -EntryType Info
        If (!($OnlyProcessMembers))
            {
            Foreach ($Group in $UniqueGroups)
			    {
			    # Check to see if Distribution Group Exists
                $CheckGroupExists = Get-DistributionGroup $Group.Mail -ea SilentlyContinue
			
                # If Group doesn't exist, then create it
                If (!($CheckGroupExists))
				    {
				    Write-Log -Message "Creating Distribution Group $($Group.DistributionGroup)" -WriteOut -WriteFile -EntryType Info
				    New-DistributionGroup -Name $Group.DistributionGroup -DisplayName $Group.DistributionGroup -PrimarySmtpAddress $Group.Mail
				    } # End If CheckGroupExists
			
                # If Group already exists, note it
                Else
				    {
				    Write-Log -Message "Distribution Group $($Group.DistributionGroup) already exists." -WriteOut -WriteFile -EntryType Info
				    } # End Else
                # Process Proxy Addresses
                Write-Log -Message "     Adding Proxy Addresses." -WriteOut -WriteFile -EntryType Verbose
			    Write-Log -Message "     $($Group.EmailAddresses)" -WriteFile -EntryType Verbose

                # If Group Exists, just set a different variable for later
                If ($CheckGroupExists)
                    {
                    $GroupToUpdate = $CheckGroupExists
                    }
            
                # If Group didn't exist, it would have been newly created above, so set the GroupToUpdate to the results of the Get-DistributionGRoup
                Else
                    {
                    $GroupToUpdate = Get-DistributionGroup $Group.Mail
                    }
            			
                # Split the CSV input's EmailAddresses into a new array item (ProxyArray)
                [array]$ProxyArray = $Group.EmailAddresses.Split("|") | Sort -Unique
            
                # Add the ProxyArray variable from the CSV input to the GroupToUpdate Email Addresses Array and leave only unique values
                $LegacyExchangeDN = "x500:"+$Group.legacyExchangeDN
                $ProxyArray += $LegacyExchangeDN
                $GroupToUpdate.EmailAddresses += $ProxyArray
			    $GroupToUpdate.EmailAddresses = $GroupToUpdate.EmailAddresses | Sort -Unique
			
                Write-Log -Message "List of proxy addresses to be added to $($Group.DistributionGroup):" -WriteFile -EntryType Verbose
			    Write-Log -Message "$($GroupToUpdate.EmailAddresses)" -WriteFile -EntryType Verbose
			    Set-DistributionGroup -Identity $GroupToUpdate.PrimarySmtpAddress -EmailAddresses $GroupToUpdate.EmailAddresses
				If ($GroupToUpdate.ManagedBy)
				{
					Set-DistributionGroup -Identity $GroupToUpdate.PrimarySmtpAddress -ManagedBy $GroupToUpdate.ManagedBy -ea SilentlyContinue
				}
				} # End Foreach ($Group in $UniqueGroups)
		    Write-Log -Message "============================================================================" -WriteFile -WriteOut -EntryType Info
            }
        Write-Log -Message "Processing group memberships." -WriteFile -WriteOut -EntryType Info
        $i = 1
        Foreach ($Group in $Groups)
			{
			Write-Log -Message "[$($i)/$($Groups.Count)] Processing $($Group.PrimarySmtpAddress) for $($Group.DistributionGroup)." -WriteOut -WriteFile -EntryType Info
            If ($CheckForSynchronizedGroups)
                {
                $LastDirSyncTime = (Get-MsolGroup -SearchString $Group.Mail).LastDirSyncTime
                If ($LastDirSyncTime)
                    {
                    Write-Log "$($Group.DistributionGroup) is synchronzied from on-premises." -WriteFile -WriteOut -EntryType Error
                    $i++
                    Continue
                    }
                Else
                    {
                    If (!(Get-Recipient -Identity $Group.PrimarySmtpAddress -EA SilentlyContinue))
				        {
				        Write-Log -Message "Recipient $($Group.PrimarySmtpAddress) not found." -WriteOut -WriteFile -EntryType Error
                        If ($CreateContactsForMissingRecipients)
                            {
                            Write-Log "Adding new contact for $($Group.PrimarySmtpAddress)." -WriteFile -EntryType Info
                            Write-Host -ForegroundColor Green "Adding new contact for $($Group.PrimarySmtpAddress)."
                            New-MailContact -Name $Group.DisplayName -DisplayName $Group.DisplayName -Alias $Group.Alias -ExternalEmailAddress $Group.PrimarySmtpAddress
                            }
				        }
			
			        # See if member is already in the group
			        $CheckGroupMembershipMember = Get-DistributionGroupMember -ResultSize Unlimited -Identity $Group.Mail | Select DisplayName,PrimarySmtpAddress,ExternalEmailAddress
                    If ($Group.PrimarySmtpAddress -notin $CheckGroupMembershipMember.PrimarySmtpAddress)
				        {
				        Try
                            {
                            Write-Log "Adding $($Group.PrimarySmtpAddress) to $($Group.DistributionGroup)." -WriteFile -EntryType Info
				            Add-DistributionGroupMember -Identity $Group.DistributionGroup -Member $Group.PrimarySmtpAddress -ea SilentlyContinue
				            }
                        Catch
                            {
                            Write-Log "Failed to add $($Group.PrimarySmtpAddress) to group $($Group.DistributionGroup)." -WriteFile -WriteOut -EntryType Error
                            }
                        Finally
                            {
                            }
                        }
			        Else
				        {
				        Write-Log "     Object $($Group.PrimarySmtpAddress) already a member of $($Group.DistributionGroup)." -WriteFile -WriteOut -EntryType Info
				        }
                    $i++
                    }
                }		
            Else
                {
			    # See if member exists
			    If (!(Get-Recipient -Identity $Group.PrimarySmtpAddress -EA SilentlyContinue))
				    {
				    Write-Log -Message "Recipient $($Group.PrimarySmtpAddress) not found." -WriteOut -WriteFile -EntryType Error
                    If ($CreateContactsForMissingRecipients)
                        {
                        Write-Log "Adding new contact for $($Group.PrimarySmtpAddress)." -WriteFile -EntryType Info
                        Write-Host -ForegroundColor Green "Adding new contact for $($Group.PrimarySmtpAddress)."
                        New-MailContact -Name $Group.DisplayName -DisplayName $Group.DisplayName -Alias $Group.Alias -ExternalEmailAddress $Group.PrimarySmtpAddress
                        }
				    }
			
			    # See if member is already in the group
			    $CheckGroupMembershipMember = Get-DistributionGroupMember -ResultSize Unlimited -Identity $Group.Mail | Select DisplayName,PrimarySmtpAddress,ExternalEmailAddress
                If ($Group.PrimarySmtpAddress -notin $CheckGroupMembershipMember.PrimarySmtpAddress)
				    {
				    Try
                        {
                        Write-Log "Adding $($Group.PrimarySmtpAddress) to $($Group.DistributionGroup)." -WriteFile -EntryType Info
				        Add-DistributionGroupMember -Identity $Group.DistributionGroup -Member $Group.PrimarySmtpAddress -ea SilentlyContinue
				        }
                    Catch
                        {
                        Write-Log "Failed to add $($Group.PrimarySmtpAddress) to group $($Group.DistributionGroup)." -WriteFile -WriteOut -EntryType Error
                        }
                    Finally
                        {
                        }
                    }
			    Else
				    {
				    Write-Log "     Object $($Group.PrimarySmtpAddress) already a member of $($Group.DistributionGroup)." -WriteFile -WriteOut -EntryType Info
				    }
                $i++
			    } 
            }   # End Foreach ($Group in $Groups)
		} # End Import
	} # End Switch
#
# Lists or Updates the content of a distribution group
# Author : KTC
# IT Operations 2020
#
# List : .\Update-Distributiongroups.ps1 <mailing list> -list
#        .\Update-Distributiongroups.ps1 "spoc.acceptance" -list 
#
# Set  : .\Update-Distributiongroups.ps1 <mailing list> -set <comma separated emails or trigrams>
#        .\Update-Distributiongroups.ps1 "spoc.acceptance" -set "MME,DJA,SAP,SOGAAB"
#
# Add  : .\Update-Distributiongroups.ps1 <mailing list> -add <comma separated emails or trigrams>
#        .\Update-Distributiongroups.ps1 "spoc.acceptance" -add "MKH"
#
# Remove:.\Update-Distributiongroups.ps1 <mailing list> -remove <comma separated emails or trigrams>
#        .\Update-Distributiongroups.ps1 "spoc.acceptance" -remove "MKH"
#


   [CmdletBinding()]
   param (
      [Parameter(Mandatory,
	  position=0)]
      [string]$group,

      [Parameter(Mandatory,
               ParameterSetName="SetMembers",
               HelpMessage="List of members to set separated by commas.")]
	  [Alias('set')]
      [string] $members ,

      [Parameter(Mandatory,
                ParameterSetName="AddMembers",
                HelpMessage="List of members to add separated by commas.")]
      [string] $add,

      [Parameter(Mandatory,
                ParameterSetName="RemoveMembers",
                HelpMessage="List of members to remove separated by commas.")]
      [string] $remove,

      [Parameter(ParameterSetName="ListMembers")]
      [switch] $list 
   )


   function Get-MemberObject
   {
      param(
      [Parameter(Mandatory)]
      [string] $list
      )
         
      foreach ($m in $list.Split(','))
      {
        $m
         Get-ADObject -LDAPFilter "(|(name=$m)(mail=$m))"
      }
   }

      $g = Get-ADGroup $group -Properties * |Where-Object {$_.groupcategory -eq 'Distribution'}
      
      if ($list)
      {
         (Get-ADGroupMember $group|%{Get-adobject $_ -Properties displayname,mail})|
         Sort-Object displayname|Format-Table displayname,mail -Autosize
      }

      elseif ($members)
      {
         $g.Members.Clear()
         Set-ADGroup -Instance $g
         Add-ADGroupMember $group -Members (Get-MemberObject $members)
      }

      elseif($add)
      {
         Add-ADGroupMember $group -Members (Get-MemberObject $add)
      }

      elseif($remove)
      {
         Remove-ADGroupMember $group -Members (Get-MemberObject $remove) -Confirm:$false
      }
     
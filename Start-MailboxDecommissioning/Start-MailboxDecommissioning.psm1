function Start-MailboxDecommissioning{
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True,Position=1)]
        $User
        
    )

    Import-Module ActiveDirectory

    $ValidatedUser = Get-ADUser $user
    while ($ValidatedUser.distinguishedname -notlike "*_disabled*" )
    {
      Write-host 'This user is not yet moved to the disabled OU.Please do so or auto decommisioning will not work.' -ForegroundColor DarkYellow
      Write-Host 'Press enter to continue or 0 to cancel' -NoNewline
      if ((Read-Host) -eq 0){
      Stop- }
    }
    
    
   
    Write-Host "Checking for EV Archive group membership..." -ForegroundColor Yellow -BackgroundColor Gray
      
      $EVgroupmember = Get-ADUser $ValidatedUser.SAMAccountName -Properties *|select -ExpandProperty memberof|Where-Object {$_ -like "CN=EV_ARCH_EVAULT0*"}
      IF ($EVgroupmember -notlike $null)
      {
          Read-Host -Prompt "Press enter to remove $ValidatedUser from $($EVgroupmember.Substring(3,16))."
          Remove-ADGroupMember $EVgroupmember -Members $ValidatedUser.SAMAccountName -Confirm:$false
 
          Write-Host "$ValidatedUser removed from group $($EVgroupmember.Substring(3,16))."
      }
 
         
          Add-ADGroupMember -Identity "EV_ARCH_LEAVERS" -Members $ValidatedUser.SAMAccountName
          Get-ADUser $ValidatedUser.SAMAccountName -Properties *|select -ExpandProperty memberof

  
    
}


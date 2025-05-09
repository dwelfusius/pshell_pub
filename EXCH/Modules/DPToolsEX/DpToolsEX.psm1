function Edit-DPRoom {
   #.EXTERNALHELP .\En-us\DpToolsEX-help.xml
    [CmdletBinding(ConfirmImpact='High',SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        $Oldname,
        [Parameter(Mandatory)]
        [Alias('NewName')]
        $Name,
        [Parameter()]
        $DC = $env:LOGONSERVER.Substring(2)
    )
 
    Write-Verbose 'Change mail nick and change primary address'
    $Parameters = @{
        Identity           = $Oldname
        Name               = $Name
        Alias              = $Name
        DisplayName        = $Name
        SamAccountName     = (New-DPAccName $name -SAM)
        userPrincipalName  = "$(New-DPAccName $name)@degroof.be"
        PrimarySmtpAddress = "$Name@degroofpetercam.com"
    }
    
    if ($PSCmdlet.ShouldProcess($oldname, "change name and primary SMTP to $name"))
    {  
        Set-Mailbox @Parameters
        Set-Mailbox $Name	-EmailAddresses @{add = "$Name@degroof.be" }
    }
}
 
function Remove-DPAlias {
   #.EXTERNALHELP .\En-us\DpToolsEX-help.xml
    param (
        [Parameter(Mandatory)]
        [Alias('Identity')]
        $Name
    )
 
    $mb = try {
        Get-Mailbox $Name -ErrorAction Stop
    }#try
    catch {
        Write-Warning -Message "The mailbox $Name cannot be found."
        return
    }#catch
     
    $selAlias = $mb.Emailaddresses |
    Write-Verbose 'Retrieving proxy addresses'
    Where-Object -Property prefixstring -CEQ 'smtp' |    
    Out-GridView -PassThru -Title 'Select the addresses you want to remove and press ok'
 
    if ($selAlias) {
        Write-Host -ForegroundColor Yellow "You are about to remove alias(es) $($selAlias.smtpaddress) from mailbox $name" 
        Write-Verbose 'Removing selected proxy addresses'
        Set-Mailbox $mb -EmailAddresses @{remove = $selAlias.smtpaddress } -Confirm:$true 
    }#if
}
 
function New-DPAccName {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 0)]
        [string]
        $Name,
        [Parameter()]
        [Switch]
        $SAM
    )
    
    $params = @{
        InputObject = $Name
        OutVariable = 'm' 
    }
    switch ($SAM) {
        $True { $params += @{'Pattern' = '(?<=BE-).{1,20}' } }
        $False { $params += @{'Pattern' = '(?<=BE-).+' } }
    }
    Select-String @params | Out-Null
    $m[0].Matches.Value
}
 
function New-DPRoom {
   #.EXTERNALHELP .\En-us\DpToolsEX-help.xml
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [Parameter(Mandatory)]
        $Name,
        [Parameter(Mandatory)]
        $Seats,
        [Parameter()]
        $DC = $env:LOGONSERVER.Substring(2),
        [Parameter()]
        $OU = "OU=Room Mailbox,OU=Exchange,OU=Users,OU=BDB,DC=degroof,DC=be",
        [Parameter()]
        [String[]]
        $Details = 'Room'
         
    )
 
    $newmb_param = @{
        Name               = $Name
        Alias              = $Name
        DisplayName        = $Name
        SamAccountName     = (New-DPAccName $Name -SAM)
        UserPrincipalName  = "$(New-DPAccName $Name)@degroofpetercam.com"
        PrimarySMTPAddress = "$Name@degroofpetercam.com"
        ResourceCapacity   = $Seats
        Office             = $Name.Substring(0, 10)
        DomainController   = $DC
        OrganizationalUnit = $OU
        Room               = $True
    }
    
    if ($PSCmdlet.ShouldProcess($name, "creating room mailbox"))
    {  
      New-mailbox @newmb_param
    }
 
    $setmb_param = @{
      Identity                  = $Name
      EmailAddressPolicyEnabled = $false
      DomainController          = $DC
      EmailAddresses            = @{add = "$Name@degroof.be" }
   }
    if ($PSBoundParameters.ContainsKey('Details')) {
      $setmb_param += @{ResourceCustom = $Details }
    }
   
    if ($PSCmdlet.ShouldProcess($name, "adding resource details")){
      Set-Mailbox @setmb_param
      }
    }


 
Function Merge-Hashtables {
    $Output = @{ }
    ForEach ($Hashtable in ($Input + $Args)) {
        If ($Hashtable -is [Hashtable] -or $Hashtable -is 
        [System.Management.Automation.PSBoundParametersDictionary] ) {
            ForEach ($Key in $Hashtable.Keys) { 
               $Output.$Key = $Hashtable.$Key }
        }
    }
    $Output
}

function Trace-DPmessage {
   #.EXTERNALHELP .\En-us\DpToolsEX-help.xml
   [CmdletBinding(DefaultParameterSetName='NoMisc')]
   [Alias()]
   [OutputType([int])]
   Param
   (
      [Parameter(ParameterSetName='NoMisc')]
      [Alias('Date')]
      $Start = (Get-Date -Format 'd/M/yyyy'),
      [Parameter(ParameterSetName='NoMisc')]
      $Hour = 0,
      [Parameter(ParameterSetName='NoMisc')]
      [Parameter(ParameterSetName='Advanced')]
      [string]
      $Sender,
      [Parameter()]
      $Recipients,
      [Parameter(ParameterSetName='NoMisc')]
      [Parameter(ParameterSetName='Advanced')]
      $ResultSize = 'Unlimited',
      [Parameter(ParameterSetName='NoMisc')]
      [Parameter(ParameterSetName='Advanced')]
      $MessageSubject,
      [Parameter(ParameterSetName='NoMisc')]
      [int]
      $Window = 24,
      [Parameter(ParameterSetName='Advanced')]
      [hashtable]
      $Misc = @{},
      [Parameter(ParameterSetName='NoMisc')]
      [Parameter(ParameterSetName='Advanced')]
      [switch]
      $JournalMails
   )

   Begin {
      write-host $MyInvocation.BoundParameters
      $hour = "$('{0:d2}' -f $hour):00"
      $Start = [datetime]::ParseExact("$Start $hour", 'd/M/yyyy HH:mm', $null)
      
      if ($Window -eq 0){
         $End = (get-date)
      }
      else {
         $End = $Start.addhours($window)
      }
   }
   Process {

      Function Merge-Hashtables {
         $Output = @{}
         ForEach ($Hashtable in ($Input + $Args)) {
            If ($Hashtable -is [Hashtable] -or $Hashtable -is [System.Management.Automation.PSBoundParametersDictionary] ) {
               ForEach ($Key in $Hashtable.Keys) { $Output.$Key = $Hashtable.$Key }
            }
         }
         $Output
      }

      $o = (@"
Timestamp
RecipientStatus
MessageSubject
Sender
Recipients
RecipientCount
TotalBytes
ConnectorId
MessageId
ClientHostname
EventId
Source
SourceContext
"@).Split('', [System.StringSplitOptions]::RemoveEmptyEntries)

      $PSBoundParameters['Start'] = $start
      $fix_param = @{'Start' = $Start
         'resultsize'        = $ResultSize
         'End'               = $end
      }
      Write-Verbose "$($misc.Values)"
      Write-Verbose "$($PSBoundParameters.Values)"
      #$full_param = $fix_param,$misc,[hashtable]$PSBoundParameters| Merge-Hashtables
      $full_param = $fix_param,[hashtable]$PSBoundParameters,$misc| Merge-Hashtables
      Write-Verbose $full_param.Values
      [hashtable]$fuller_param = @{}
      #gettting enum to go over the items
      $full_param.GetEnumerator() | 
      #removing all items that have a key that isn't accepted by get-messagetrackinglog command
         Where-Object { $_.name -in ((Get-Command Get-MessageTrackingLog).Parameters.Keys) } | 
         # changing every object from a dictionary item back into a hashtable
            ForEach-Object { $fuller_param += [hashtable]@{$_.name = $_.value } }
      Write-Verbose "$($fuller_param.keys)" 
      Write-Verbose "$($fuller_param.Values)" 
      if (-not $JournalMails){
         (Get-ExchangeServer).name  |
            Get-MessageTrackingLog @fuller_param|
                  Select-Object $o |
                     Where-Object {$_.recipients -ne 'belgium-smtp@degroofpetercamarchive.local'}
      }
      else {
         (Get-ExchangeServer).name  |
            Get-MessageTrackingLog @fuller_param|
               Select-Object $o
      }
   }
   End {
   }
}
function Add-DPSharedMailboxPermission {
   #.EXTERNALHELP .\En-us\DpToolsEX-help.xml
   [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
   param (
      # Mailbox to add access to
      [Parameter(ValueFromPipelineByPropertyName,Mandatory)]
      [ValidateScript({ Get-Mailbox $_ })]
      [Alias('Identity')]
      [string]
      $Name,
      # Group to grant access, if naming based group should be overridden
      [Parameter(ValueFromPipelineByPropertyName)]
      [Alias('User')]
      [string]
      $Group,
      # Parameter help description
      [Parameter(ValueFromPipeline)]
      [System.Object]
      $InputObject
   )
   
begin {}
process {
   foreach ($Name in $Name){
   $mb = Get-Mailbox $local:Name
   if (-not $PSBoundParameters.ContainsKey('Group')) {
      "EXCHANGE_SharedMailboxAccess_$($mb.alias)" | 
         Select-String '.{1,64}' -OutVariable m |
            Out-Null
      $group = $m[0].Matches.Value       
   }
   try {
      Get-ADGroup $group -ErrorAction Stop | Out-Null
   }
   catch {
      Write-Warning "Group $group cannot be found. Stop processing $($mb.alias)"
      return
   }
   
   $operation = "Adding full-access and send-as permissions for $group"
   if ($PSCmdlet.ShouldProcess($mb.displayname, $operation)){
      Write-Verbose "$operation to $($mb.Displayname)"
      $params = @{
         Identity = (Get-Mailbox $Name).name
         User = $group 
         ErrorAction = 'Stop'
      }
      try {
         Add-MailboxPermission @params -AccessRights FullAccess | 
            Out-Null
         Add-ADPermission @params -ExtendedRights Send-As | 
            Out-Null
      } #try
      catch {
         Write-Warning -Message "$($Error[0].Exception)"
         Write-Warning -Message  "Please verify manually, permissions
         not applied or unfinished"
      } #catch
   }
   }#foreach
}}
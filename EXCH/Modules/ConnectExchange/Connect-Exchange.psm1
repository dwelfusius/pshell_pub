<#
.Synopsis
   Quick module to manage the remoting to exchange
.DESCRIPTION
   This module can be used to either start or stop the connection to exchange with user degroof\gen_exchange_tier2_1.
   Will be updated once cyberark allows more dynamic credential fetching
.EXAMPLE
   Connect-Exchange -Action Start
.EXAMPLE
   Connect-Exchange -Action Stop
#>

function Connect-Exchange
{
    [CmdletBinding()]
    [OutputType([int])]
     Param(
     [parameter(Mandatory=$true)]
     [ValidateSet("Start", "Stop","Custom")]
     [String[]]$Action
   )

    $global:ConnectionUri = 'https://mail.degroof.be/powershell/'
    $PSDefaultParameterValues=@{ 
    "Import-PSSession:DisableNameChecking"=$True;
    "Import-PSSession:AllowClobber"=$True }

    switch ($Action)
    {
        'Start'  {
            $global:ldapcred = (get-credential)
            New-PASSession -Credential $ldapcred -BaseURI https://keypass.degroofpetercam.local -type LDAP
            $user = 'degroof\gen_exchange_tier2_1'
            $plainpassword = (Get-PASAccount -search 'gen_exchange_tier2_1'|
            Get-PASAccountPassword -Reason "Connect Exchange Script").password
            $global:password = ConvertTo-SecureString -string $plainpassword -AsPlainText -Force
            $global:credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $password
            $global:SessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck 
            $global:Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $ConnectionUri -Credential $credential -Authentication Basic -AllowRedirection -SessionOption $sessionOption
            Import-Module (Import-PSSession $global:Session) -Global -DisableNameChecking}
         'Stop'   {
            Get-PSSession |?{$_.computername -eq 'mail.degroof.be'}|Remove-PSSession
            }
         'Custom' {
            $global:credential = (Get-Credential)
            $global:sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck 
            $global:Session = New-PSSession -ConfigurationName Microsoft.Exchange  -ConnectionUri $ConnectionUri -Credential $credential -Authentication Basic -AllowRedirection -SessionOption $sessionOption
            Import-PSSession $global:session -AllowClobber -Disablenamechecking}
    }


}
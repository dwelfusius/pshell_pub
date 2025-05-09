[CmdletBinding(SupportsShouldProcess=$true)]
param (
   [Parameter(Mandatory=$true)]
   [string]
   $ComputerName,

   # Log path
   [Parameter()]
   [ValidateScript({Test-Path $LogPath})]
   [string]
   $LogPath = '.\'
)

function Get-DPDate {
   Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
}


# Script needs to run with -IA SilentlyContinue due to a bug in pshell 5.1,
# otherwise write-info doesn't show in transcripts. Run with confinue in int. mode

Start-Transcript -Path "$LogPath$(Get-Date -Format 'yyyyMMdd')_$ComputerName-STOP.log"

Write-Information -Message "$(Get-DPDate)[VERBOSE] - Getting service from $Computername"

@("EnterpriseVaultTaskControllerService","EnterpriseVaultShoppingService",
   "EnterpriseVaultIndexingService","EnterpriseVaultStorageService",
   "Enterprise Vault Directory Service") | 
      Get-Service -ComputerName $ComputerName -OutVariable ev_services

foreach ($ev_service in $ev_services){
   Write-Information -Message "$(Get-DPDate) [VERBOSE] - Stopping $($ev_service.name) on $Computername"
   Stop-Service -InputObject $ev_service
}

Write-Information -Message "$(Get-DPDate) [VERBOSE] - Testing service status"
$i = 0
do {
   $ev_services.Refresh()
   Start-Sleep 10
   $i++
} 
until ((-not ($ev_services.Status -notmatch 'Stopped')) -or (
      $i -gt 360))

if ($i -gt 360){
   $ev_services
   Write-Warning -Message "The services are taking longer than 30 minutes to stop."
}

Write-Information -Message "$(Get-DPDate) [VERBOSE] - Stopping the EV Admin service."

Get-Service EnterpriseVaultAdminService -ComputerName $ComputerName -OutVariable ev_admsrv
$ev_admsrv | Stop-Service
Start-Sleep 10
$i = 0
while ($ev_admsrv.Status -ne 'Stopped' -and $i -lt 360){
   $ev_admsrv.Refresh()
   $i++
}
if ($i -gt 360) {
   Write-Error -Message "The $($ev_admsrv.ServiceName) could not be stopped in time."
   Write-Warning "The admin service is having issues stopping. Manual action required."
}
else {
   Write-Information -Message "$(Get-DPDate) [VERBOSE] - All services have been stopped succesfully"
   $ev_admsrv
}

Stop-Transcript
exit $Error.Count
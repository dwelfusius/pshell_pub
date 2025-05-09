Function Test-Service {
    <#
.SYNOPSIS
    Tests if services conform to a desired state
.DESCRIPTION
    By checking the returned status of a service object the command will determine if the service
    is in the desired state defined in the DesiredState parameter
.EXAMPLE
    if(((Get-Service)[0..1]|Test-Service -DesiredState Stopped) -contains $false) {
    'One or more services do not have the desired state'}
    
    Fed by pipeline input this command will determine the compliance of every service one-by-one
.EXAMPLE
    (Test-Service -ObjServ (Get-Service)[0..1] -DesiredState Stopped)

    Feeding an array of services directly will cause the command to check the entire set in one go, only returning true if ALL
    Services are in the desired state
.INPUTS
    System.ServiceProcess.ServiceController
.OUTPUTS
    Boolean
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
            ValueFromPipeline = $True)]
        [System.ServiceProcess.ServiceController[]]
        $ObjServ,
        [Parameter(Mandatory = $true)]
        [ValidateSet('Stopped', 'Running')]
        [string]
        $DesiredState
    )
    Begin {}
    Process {
        (-not ($ObjServ.Status -notmatch $DesiredState))
    }
    End {}
}

(Test-Service -ObjServ (Get-Service)[0..1] -DesiredState Stopped)
if(((Get-Service)[0..12]|Test-Service -DesiredState Stopped) -contains $false) {'tttrrrr'}





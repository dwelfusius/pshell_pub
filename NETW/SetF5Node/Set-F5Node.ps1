[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Enabled","Disabled")]
    [string] $ToStatus,
    [Parameter(Mandatory=$True)]
    [string[]] $Computername,
    [Parameter(Mandatory)]
    [ValidateSet('TST','ACC','PRD')]
    [string] $Environment,
    [Parameter(Mandatory)]
    [Alias('LB)')]
    [ValidateSet('WAF','LTM')]
    [string] $LoadBalancer
)

if (-not(Get-module F5-LTM )){
    Import-Module .\F5-LTM -Force
}

[Byte[]] $key = (1..16)
$password = "76492d1116743f0423413b16050a5345MgB8AG8ALwBMAEcAWAB0AGUAMABkAFQANwBmAGMAOQB1ADYAcgBoADIATABaAHcAPQA9AHwAMwA4ADYAZQA0ADIAZQA3AGQAYQA3AGUAZAA1AGYAYgBjADMAZgAzADEAMAAxAGUAMgAwAGEANQBhAGMAMQA2ADQAZgBhADAAZAAwADIANAA3AGYANAA5ADgAYgBjAGYAMwBjADkAZQA0AGEAMQAxADEAOQA0ADIAMwAxAGYANQA4AGIAZQA2AGYAMQA0AGUAZQBkADMAMgBhADQAMgBkAGQANAAxADkANwBhADgAZABmAGYAMwAwADIANgAxADYA" |
ConvertTo-SecureString -Key $key
$user = 'svc_winscript_F5_RW'
$cred = [pscredential]::new($user,$password)

switch($LoadBalancer){
    'WAF' {
        $ip = switch($Environment)
        {
            'TST' {''}
            'ACC' {'',''}
            'PRD' {'10.193.15.33','10.193.15.34'}
        } 
    }
    'LTM' {
        $ip = switch($Environment)
        {
            'TST' {'10.193.15.47' }
            'ACC' {'10.193.15.46','10.193.15.45'}
            'PRD' {'10.193.15.43','10.193.15.44'}
        } 
    }
}

function Get-F5ActiveSession {
    $n = -1
    do {
        $n++
        $i = $ip[$n]
        Write-Verbose "Trying to connect to $i."
        $script:session = New-F5Session -LTMName $i -LTMCredentials $cred  -PassThrough
        Get-F5Status -F5Session $session
    }
    until ('ACTIVE')
}

Get-F5ActiveSession | Out-Null
foreach ($computer in $computername){
    $node = try {
        Get-Node -F5Session $session -ErrorAction Stop | 
            Where-Object {$_.name -eq $computer}
    }
    catch {
        Write-Host $_.exception -Foregroundcolor Red
        break
    }

    Write-Debug '$node'
    if ($null -eq $node){
        Write-Warning "The node: $computer could not be found."
        break
    }

    switch ($ToStatus) {
        'Disabled' { 
            try {
                if ($PSCmdlet.ShouldProcess("$($node.name) - $($LoadBalancer)", "Disabling node")) {
                    Disable-Node -F5Session $session -InputObject $node  -Force -ErrorAction Stop |Out-Null
                }
            }
            catch {
                Write-Host $_.exception -Foregroundcolor Red
                break
            }
        }
        'Enabled' {
            try {
                if ($PSCmdlet.ShouldProcess("$($node.name) - $($LoadBalancer)", "Enabling node")) {
                    Enable-Node  -F5Session $session -InputObject $node -ErrorAction Stop | Out-Null
                }
            }
            catch {
                Write-Host $_.exception -Foregroundcolor Red
                break
            }
        }
    }

    $n = Get-NodeStats -Name  $node.Name -F5Session $session
    if ($n.'status.enabledState'.description -eq $ToStatus ) {
        Write-Verbose "Node: $($node.Name) has been set to $($n.'status.enabledState'.description)."
        #return $true
    }
    else {
        Write-Verbose "Node: $($node.Name) has been set to $($n.'status.enabledState'.description)."
        #return $false
    }
}
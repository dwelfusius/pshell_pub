[CmdletBinding(SupportsShouldProcess=$true)]
param (
   # Environment
   [Parameter(Mandatory)]
   [ValidateSet('T','A','P')]
   [string]
   $Environment, 
   # Path you want to clean up, if unvalid script will not run
   [Parameter(Mandatory)]
   [ValidateScript({ Test-Path $_ })]
   [string]
   $Path,
   # Minimum age of the files to be deleted in days
   [Parameter(Mandatory)]
   [int]
   $Age,
   # When used processes subdirectories as well
   [Parameter()]
   [switch]
   $Recurse,
   # Name of the logfile
   [Parameter(Mandatory)]
   [string]
   $Logname,
   # Path for the logfiles
   [Parameter()]
   [ValidateScript({ Test-Path $_ })]
   [string]
   $LogPath, #= '\\svwmom01p\r\dco\logfiles\'
   # Filter for the files
   [Parameter()]
   [string]
   $Filter = '*'
   
)

$Date = (Get-Date)
$MinAge = (Get-Date).AddDays(-$Age)
$ValLogname = $Logname.Replace(' ','')
if(-not $PSBoundParameters.ContainsKey('LogPath')){
   $LogPath = "\\svwmom01$Environment\r\dco\logfiles\"
}
$Paths = (Get-ChildItem $Path).FullName

Start-Transcript "$logpath$($date.ToString('yyyyMMdd'))-cleanup_$ValLogname.log" -Append

Write-Host @"
------------------------------------------------------------------------
$date - Retention:$age

$path
-----------------------------------------------------------------------
"@

foreach ($path in $Paths){
    If ($recurse){
       Get-ChildItem -Path $Path -Filter $Filter -File -Recurse |
          Where-Object {$_.lastwritetime -lt $MinAge} |
             Remove-Item -Confirm:$False -WhatIf:$WhatIfPreference
    }
    else {
       Get-ChildItem -Path $Path -Filter $Filter -File |
          Where-Object {$_.lastwritetime -lt $MinAge} |
             Remove-Item -Confirm:$False -WhatIf:$WhatIfPreference
    }
}

Stop-Transcript
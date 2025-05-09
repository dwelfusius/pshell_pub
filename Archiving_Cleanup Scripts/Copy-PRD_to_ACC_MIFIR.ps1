[CmdletBinding()]
   param (
      [Parameter(position=0)]
      [int]$job,
        
      [Parameter(Position=1)]
      [string]$date  
)

#Tests if job number is passed along, aborts if not!
if (-not($job)){
   Write-Error "There is no job number filled in! Aborting script.." -ErrorAction Stop
}


#Tests if date paramer is passed along, aborts if not!
if (-not($date))
{
   Write-Error "There is no date parameter filled in! Aborting script.." -ErrorAction Stop
}

#Test if date parameter is Null or Empty, aborts if so !
if ([string]::IsNullOrWhiteSpace($date) -Or [string]::IsNullOrEmpty($date))
{
   Write-Error "Date parameter cannot be Null or Empty! Aborting script.." -ErrorAction Stop
}

#Creates the job number array -> adjust when adding extra job configs
$nr   = @(1..5)
$root = '\\degroof.be\public\degroof\'

#Creates the source files array - entries equal to amount of job parameters configured
$sources = (@"
IT_BE_DWH_DTM_FM_PRD\MIFIR_IN_FROM_ODDO\Arch\MIFIR-TRANSACTION-REPORTING-DEGROOF-$date*.csv
IT_BE_DWH_DTM_FM_PRD\MIFIR_IN_FROM_ULLINK\Arch\PRO_549300NBLHT5Z7ZV1241_$($date)T*_MI*.CSV
IT_BE_DWH_DTM_FM_PRD\MIFIR_IN_FROM_ULLINK\Arch\PRO_NCKZJ8T1GQ25CDCFSD44_$($date)T*_MI*T.CSV
IT_DWH_DTM_FM_PRD_EMIR_IN\ETD_SPHERE\Arch\ETD_Trades_BDB_$date*.csv
IT_DWH_DTM_FM_PRD_EMIR_IN\ETD_SPHERE\Arch\ETD_Trades_BDL_$date*.csv
"@).Split('', [System.StringSplitOptions]::RemoveEmptyEntries)

#Creates the destination path array - entries equal to amount of job parameters configured
$destinations = (
   @"
IT_BE_DWH_DTM_FM_ACC\MIFIR_IN_FROM_ODDO\
IT_BE_DWH_DTM_FM_ACC\MIFIR_IN_FROM_ULLINK\
IT_BE_DWH_DTM_FM_ACC\MIFIR_IN_FROM_ULLINK\
IT_DWH_DTM_FM_ACC_EMIR_IN\ETD_SPHERE\Arch\
IT_DWH_DTM_FM_ACC_EMIR_IN\ETD_SPHERE\Arch\
"@
).Split('', [System.StringSplitOptions]::RemoveEmptyEntries)

#Creates an array of arrays based on previous arrays
$pairings   = @()
$pairings   = @{job = $nr }, @{source = $sources }, @{dest = $destinations }

#Fetches the correct values by looking up the job number in the array
$index      = $pairings.job.IndexOf($job)
$sourcePath = $pairings.source[$index]
$destPath   = $pairings.dest[$index]

#Gets the fileattributes and tests if file exist - on fail script stops
$file = Get-Item ($root + $sourcePath)
try {
   Test-Path -Path $file -ErrorAction Stop
}
catch {
   Write-Error "There is no file $sourcepath! Aborting script.." -ErrorAction Stop
}

#Copies the file based on job requirements
try {
   if ($job -eq 2 -or $job -eq 3) {
      Copy-Item  $file.FullName -Destination ($root + $destPath + ($file.name -replace "PRO_", "SIM_")) -ErrorAction Stop
   }
   else{
   Copy-Item  $file.FullName -Destination ($root + $destPath + $file.name) -ErrorAction Stop
   }
}
catch {
   Write-Warning -Message "File could not be copied. Check manually."
}
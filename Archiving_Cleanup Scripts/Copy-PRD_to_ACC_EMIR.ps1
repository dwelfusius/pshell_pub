[CmdletBinding()]
   param (
      [Parameter(position=0)]
      [int]$job,
      
      [Parameter(Position=1)]
      [string]$date
   )
#Tests if job number is passed along, aborts if not!
if (-not($job))
{
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

#Check if date string parameter is a valid date, aborts if not!
try {
   [datetime]::parseexact($date, 'yyyyMMdd',$null)
}
catch {
   Write-Error "'$date' was not recognized as a valid Date ! Aborting script..." -ErrorAction Stop
}

#Sets the correct date value
#$date = (Get-Date).AddDays(-1).ToString('yyyyMMdd')
#$date = (Get-Date).AddDays(-4).ToString('yyyyMMdd')
#Creates the job number array -> adjust when adding extra job configs
$nr   = @(1..7)
$root = '\\degroof.be\public\degroof\'

#Creates the source files array - entries equal to amount of job parameters configured
$sources = (@"
IT_LU_DWH_DTM_FM_PRD_EMIR_IN\BDPL_INPUTS\EMICIS_$date*.TXT
IT_DWH_DTM_FM_PRD_EMIR_IN\ETD_SPHERE\Arch\ETD_Trades_BDB_$date*.csv
IT_DWH_DTM_FM_PRD_EMIR_IN\ETD_SPHERE\Arch\ETD_Trades_BDL_$date*.csv
IT_DWH_DTM_FM_PRD_EMIR_IN\ETD_SPHERE\Arch\ETD_Valuation_BDB_$date*.csv
IT_DWH_DTM_FM_PRD_EMIR_IN\ETD_SPHERE\Arch\ETD_Valuation_BDL_$date*.csv
IT_DWH_DTM_FM_PRD_EMIR_IN\ETD_SPHERE\Arch\ETD_Positions_BDB_$date*.csv
IT_DWH_DTM_FM_PRD_EMIR_IN\ETD_SPHERE\Arch\ETD_Positions_BDL_$date*.csv
"@).Split('', [System.StringSplitOptions]::RemoveEmptyEntries)

#Creates the destination path array - entries equal to amount of job parameters configured
$destinations = (
   @"
IT_LU_DWH_DTM_FM_ACC_EMIR_IN\BDPL_INPUTS\
IT_DWH_DTM_FM_ACC_EMIR_IN\ETD_SPHERE\
IT_DWH_DTM_FM_ACC_EMIR_IN\ETD_SPHERE\
IT_DWH_DTM_FM_ACC_EMIR_IN\ETD_SPHERE\
IT_DWH_DTM_FM_ACC_EMIR_IN\ETD_SPHERE\
IT_DWH_DTM_FM_ACC_EMIR_IN\ETD_SPHERE\
IT_DWH_DTM_FM_ACC_EMIR_IN\ETD_SPHERE\
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
   Copy-Item  $file.FullName -Destination ($root + $destPath + $file.name) -ErrorAction Stop
}
catch {
   Write-Warning -Message "File could not be copied. Check manually."
}


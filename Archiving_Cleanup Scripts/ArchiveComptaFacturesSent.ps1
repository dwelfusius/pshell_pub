#Sets date equal to the month of which the files will be backed up
$datemin = (Get-Date).AddMonths(-3)
$datemax = ((Get-Date).AddMonths(-12).AddDays(-1))
$name = Get-Date -Format yyyy

# TO BE USED IN NEED OF MANUAL RUN
<#
$datemin = (Get-Date 9/1/2020).AddMonths(-3)
$datemax = ((Get-Date 9/1/2020).AddMonths(-12).AddDays(-1))
$name = Get-Date -Format yyyy
#>

#Creating list of all files in directory and immediate child directories
$source = "\\degroof.be\public\Compta\Factures_entrantes\Sent"
$files = Get-ChildItem $source -file -recurse -depth 1 |?{$_.name -like "*.pdf"}
$destination = "\\degroof.be\public\AR_Compta\Purchase_journal\$name"
#Creating new year folder if not present yet
if (-not(Test-Path $destination)){ New-Item -Type Directory $destination}

foreach ($file in $files) {
   #loop for files younger than 3 months - COPY + OVERWRITE
   if ($file.CreationTime -gt $datemin) {
      $name = ($file.fullname -split '\\')[-2]
      $destination = "\\degroof.be\public\AR_Compta\Purchase_journal\$name" 
      Copy-Item $file.FullName -Destination "$destination\$($file.name)" -Force -Verbose
   }
   #loop for files older than 3 months and younger than 12 months - MOVE + OVERWRITE
   elseif (($file.CreationTime -lt $datemin) -and ($file.CreationTime -gt $datemax)) {
      $name = ($file.fullname -split '\\')[-2]
      $destination = "\\degroof.be\public\AR_Compta\Purchase_journal\$name" 
      Move-Item $file.fullname -Destination "$destination\$($file.name)" -Verbose -Force
      } 
   #loop for files older than 12 months - MOVE
   else {
      try {
            $name = ($file.fullname -split '\\')[-2]
            $destination = "\\degroof.be\public\AR_Compta\Purchase_journal\$name" 
            Move-Item $file.fullname -Destination "$destination\$($file.name)" -Verbose -ErrorAction Stop
      }
      catch [System.IO.IOException] {
         if ($_.exception.message -like "The file exists*") {
            "$($file.fullname) already exists and is no longer in the acceptable modification date range"|
            Out-File -FilePath '\\degroof.be\public\AR_Compta\Purchase_journal\anomalies.txt' -Append 
         }
      } 
   }
}  
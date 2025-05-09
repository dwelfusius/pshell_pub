#Sets date equal to the month of which the files will be backed up
$date = ((Get-Date).AddMonths(-9))
$foldername = Get-Date $date -Format yyyyMM
#Files must be moved from the nsm TEST server to the shared drives
$source = "\\srvnsmtst\unishare$\Logs"
$destination = "\\DEGROOF.be\public\ar_it\ITSystems\Automation - TNG\Backup\SRVNSMTST\Log\$($date.year)\"

#Logging start
Start-Transcript -path "\\DEGROOF.BE\public\AR_IT\ITSystems\Automation - TNG\Backup\SRVNSMTST\Log\JobLogs\BackupLog_$foldername.txt"

#This line of code creates a new folder based on the date -13 months
if (-not (Test-Path "$destination\$foldername")) 
{ New-Item -Path "$destination" -Type Directory -Name $foldername }

#This part of the code moves the specified files to their destination
Get-ChildItem $source -file | Where-Object { $_.LastWriteTime -lt $date } | Move-Item -Destination "$destination\$foldername" -Force -Verbose

Write-Host "Creating zip file..."
Compress-Archive -Path "$destination\$foldername" -DestinationPath "$destination\$foldername.zip" -Confirm:$false -CompressionLevel Optimal
$foldersize = (Get-ChildItem $destination\$foldername|Measure-Object Length -Sum).Sum
$zipsize = (Get-Item $destination\$foldername.zip).Length

if ((Test-Path "$destination\$foldername.zip") -and ($zipsize -gt ($folderzize / 7 ))) { 
   Write-Host "The zipped folder size was : $($foldersize /(1024*1024))"
   Write-Host "The zipped file size is : $($zipsize /(1024*1024))"
   Write-Host "Removing folder..."
   Remove-Item $destination\$foldername -Recurse  -Confirm:$false -Force
   
}

else {
   Write-Host "Folder wasnt removed due to zip file not present or not large enough."
}

# Logging end
Stop-Transcript
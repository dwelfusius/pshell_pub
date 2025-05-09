#Sets date equal to the month of which the files will be backed up
$date = ((Get-Date).AddMonths(-12))
$today = Get-Date -Format yyyyMMdd
$zipfoldername = "Backup_ARCHIVE_TYPE_MOV_NAV_POS_$today"

#Folders must be moved from F:\NEW_FUND_DATA\archive\MOV, F:\NEW_FUND_DATA\archive\NAV and F:\NEW_FUND_DATA\archive\POS
$MOV = "F:\NEW_FUND_DATA\archive\MOV"
$NAV = "F:\NEW_FUND_DATA\archive\NAV"
$POS = "F:\NEW_FUND_DATA\archive\POS"

#To F:\NEW_FUND_DATA\Backup   
$destination = "F:\NEW_FUND_DATA\Backup"

#This line of code creates a new folder based on the date -12 months
if (-not (Test-Path "$destination\$zipfoldername")) 
{ New-Item -Path "$destination" -Type Directory -Name $zipfoldername }

#This part of the code selects the folders older than 12 months
$folders = Get-ChildItem -path $MOV, $NAV, $POS | Where-Object { [datetime]::parseexact($_, 'yyyyMMdd', $null) -lt $date } 


#This part of the code moves the specified folders to their destination F:\NEW_FUND_DATA\Backup
foreach ($foldername in $folders)
{
    $zipsource = $foldername.FullName

    Write-Host " foldername '$zipsource'"
    Write-Host " foldername '$foldername'"

    #Retrieve the folder and its parent directory name
    $nn = $zipsource.SubString($zipsource.Length-12)
    $kk = $nn.replace('\','_')

    $tt = $zipsource.replace($foldername,$kk)

    #Rename a folder by its name and the name of its parent directory as Move-Item cannot duplicate folder name
    Rename-Item $zipsource $tt

    Move-Item -Path $tt -Destination "$destination\$zipfoldername" -Force -Verbose
}   

Write-Host "Creating zip file..."
Compress-Archive -Path "$destination\$zipfoldername" -DestinationPath "$destination\$zipfoldername.zip" -Confirm:$false -CompressionLevel Optimal

#if ((Test-Path "$destination\$zipfoldername.zip") -and ($zipsize -gt ($folderzize / 7 ))) {  
if ((Test-Path "$destination\$zipfoldername.zip")) {  

   Write-Host "Removing folder..."
   Remove-Item $destination\$zipfoldername -Recurse  -Confirm:$false -Force
   
}

else {
   Write-Host "Folder wasnt removed due to zip file not present or not large enough."
}


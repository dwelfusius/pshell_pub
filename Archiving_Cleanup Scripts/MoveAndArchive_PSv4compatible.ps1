

#Sets date equal to the maximum creation date of files/folders to be processed
$date = (Get-Date).AddDays(-3)


### Use for manual run!!!
#$date = (Get-Date).AddDays(-5)

#Sets the required path variables
$source = "E:\ARCH\EXECUTIONFILES"
$destination = "E:\ARCH\EXECUTIONFILES\OLD"
$path = "E:\ArchiveScript\BackupLog_$(get-date -Format yyyyMMdd)"
$filters = @("\IBBA\","")


#Logging start
Start-Transcript -path "$path.txt"

#This part of the code gets folders younger than today-7days
$folders = Get-ChildItem $source -Directory | Where-Object {($_.CreationTime -lt $date) -and ($_.Name -ne "OLD")} #| Move-Item -Destination "$destination\$foldername" -Force -Verbose

#This loop passes through elegible folder in the list
foreach ($filter in $filters)
{
    foreach ($foldername in $folders)
    {
        $name = (get-date $foldername.LastWriteTime -Format MMMM)
        $zipsource = $foldername.FullName + $filter
        if (-not(Test-Path $zipsource)){
         continue}
        write-host $foldername
        if ($filter -ne ""){
        $zipdestination = "$destination\CRE\$($foldername.Name).zip"}
        else {$zipdestination = "$destination\REFERENTIALS\$($foldername.Name).zip"}
        


    #This is where the magic happens
    #Step 1 - create zip file from folder with the foldername as filename.

    if (-not (Test-Path $zipdestination)){
        Write-Host "Creating zip file..."
        Add-Type -assembly "system.io.compression.filesystem"
        [io.compression.zipfile]::CreateFromDirectory($zipsource,$zipdestination )
        }

        $foldersize = (Get-ChildItem $zipsource -Recurse |Measure-Object Length -Sum).Sum
        $zipsize = (Get-Item $zipdestination).Length

    #Step 2 - If the expected zip is found AND the zip filesize is greater than what we could expect with the measured compression rate
    #the source data is deleted.

        if (Test-Path $zipdestination) {
           $zip = [System.IO.Compression.ZipFile]::OpenRead($zipdestination)
           if (($zip.Entries |measure).count -ge (Get-ChildItem $zipsource -File -Recurse|measure).Count)
           {
           Write-Host "The zipped folder size was : $($foldersize /(1024*1024))"
           Write-Host "The zipped file size is : $($zipsize /(1024*1024))"
           Write-Host "Removing folder..."
           Remove-Item $zipsource -Recurse  -Confirm:$false -Force
           $zip.Dispose()
           }
        }
   
        else {
           Write-Host "Folder wasnt removed due to zip file not present or not large enough."
        }
    }
}

# Logging end
Stop-Transcript
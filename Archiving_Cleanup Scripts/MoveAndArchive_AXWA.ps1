[CmdletBinding(SupportsShouldProcess)]
param(
    [parameter()]
    [int]$Days = 3
)
    
#Sets date equal to the maximum creation date of files/folders to be processed
$date = (Get-Date).AddDays(-$Days)
Write-Debug $date.ToLongDateString()

#Sets the required path variables
$source = 'D:\ARCH\EXECUTIONFILES'
$destination = 'E:\ARCH\EXECUTIONFILES\OLD'
$path = "E:\ArchiveScript\BackupLog_$(Get-Date -Format yyyyMMdd_HHmm)"
$filters = @(@('??BA*', 'CRE'), @('', 'REFERENTIALS'))
#$filters = @(@{'??BA*'='CRE'},@{''='REFERENTIALS'})

#Logging start
Start-Transcript -Path "$path.txt" -WhatIf:$false

#This part of the code gets folders younger than today -3days
$folders = Get-ChildItem $source -Directory | 
    Where-Object { [DateTime]::ParseExact($_.Name, 'yyyyMMdd', $null) -lt $date } 
$folders.Count
#This loop passes through each filter in the list
foreach ($filter in $filters) {
    #This loop passes through elegible folder in the list
    foreach ($foldername in $folders) {
        Write-Debug -Message 'Checking the folders'
        $name = (Get-Date $foldername.LastWriteTime -Format MMMM)
        $zipsource = if ($filter[0] -ne '') {
            Get-ChildItem $foldername.FullName -Filter $filter[0] | 
                Where-Object { $_.name -ne 'SUBACCOUNT' }
        }
        else {
            Get-ChildItem $foldername.FullName
        }
        #$zipsource = Get-ChildItem $foldername.FullName -Filter $filter.keys | Where-Object {$_.name -ne 'SUBACCOUNT'}

        Write-Debug -Message 'Checking the zipsource'
        if (-not($zipsource)) {
            continue
        }

        Write-Verbose -Message @"

Processing following path(s)..


$($zipsource.FullName|Out-String)
"@


        $zipdestination = "$destination\$($filter[1])\$($foldername.Name).zip"
        #$zipdestination = "$destination\$($filter.values)\$($foldername.Name).zip"

        Write-Verbose -Message "Writing to $zipdestination `n"
        
        #Step 1 - create zip file from folder with the foldername as filename.
        if ($PSCmdlet.ShouldProcess("$zipdestination", 'Compressing files')) {

            $zipsource | Compress-Archive -DestinationPath $zipdestination -Update
        }        


        # Step 2 - If the expected zip is found AND the zip file content is equal to the zip source content
        # the source data is deleted.
    
        if (Test-Path $zipdestination) {
            $zip = [System.IO.Compression.ZipFile]::OpenRead($zipdestination)
           
            # removing some double entries to be able to compare actual files, needed due to comparing via .net + powershell mixed
            $a = ($zip.entries.fullname |
                    Where-Object { $_.EndsWith('\') -eq $false })
            $b = Get-ChildItem $zipsource.FullName -Recurse -File |
                ForEach-Object { $_.fullname.Substring(32) }
           
            $comp = Compare-Object -ReferenceObject $a -DifferenceObject $b
           
            if ($null -eq $comp) { 
                if ($PSCmdlet.ShouldProcess("$($foldername.name)", "Removing results from filter $($filter[1]) in folder")) {
                    Write-Verbose 'Removing the zipped files'
                    Write-Debug 'Check to be removed items'
                    Remove-Item $zipsource.FullName -Recurse  -Confirm:$false -Force
                    if ($filter[1] -eq 'REFERENTIALS' -and (Get-ChildItem $foldername.FullName).count -eq 0) {
                        Write-Host  -ForegroundColor Blue   "Deleting $($foldername.FullName)"
                        Remove-Item $foldername.FullName -Recurse -Force
                    }
                    else { Write-Warning $foldername.FullName }
                } # whatif comp

                else {
                    Write-Warning 'Folder(s) not removed due to zip file not identical to source.'
                }#else comp

                $zip.Dispose()
            } #if comp
        }
   
        else {
            Write-Warning "Folder wasn't removed due to zip file not present."
        } #else test-zip path
    }

}

$logs = Get-ChildItem E:\ArchiveScript\Backuplog_* | Where-Object { $_.LastWriteTime -lt (Get-Date).AddMonths(-3) } 
if ($PSCmdlet.ShouldProcess('Log files older than 3 months', 'Removal')) {
    $logs | Remove-Item -Confirm:$false  
}


# Logging end
Stop-Transcript
# Mail address
#$mailTo = "italertexchange@degroofpetercam.com"
$mailTo = "ktc@degroofpetercam.com"
# $debug = $true
$debug = $false

# Connect to MS Exchange
[Byte[]] $key = (1..16)
$username = "degroof\svc_script_runas"
$pwdTxt = "76492d1116743f0423413b16050a5345MgB8AEcATwBxAGgANwBsAFMAVwBIAEcARAAxAHYAaQBQAFcAcgBhADAAYQBOAFEAPQA9AHwAZQBiADAAMABlAGMAMQA3ADQAMAAwADIAOAA3ADkAZAAxAGMAZgBkADMAMQAwAGUAMgA2ADIANAA5AGMAMAAzADUANgAwADIAMAA3AGIAOQBiAGUAOABkAGIAMAAyAGIAZQA3AGMAOABhADIANwBhAGQAZAAzAGMANwBhAGMAYwA="
$securePwd = $pwdTxt | ConvertTo-SecureString -Key $key
$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd
$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://mail.degroof.be/powershell/ -Credential $credObject -Authentication Basic -AllowRedirection -SessionOption $sessionOption
Import-PSSession $session

# Get list of Databases and Exchange servers
$Databases = Get-MailboxDatabase  | Where-Object{$_.name -like "mdb*"} | Sort-Object Name
$Servers   = (Get-ExchangeServer | Sort-Object Name).name
$content = "<html>"
$content += "<h1 style='border:2px solid DodgerBlue;'>Exchange: Free space on mountpoints.</h1>"

# Go through the list of databases
Foreach($database in $Databases) {
    $FolderName = $database.Name
    $content += "</br>"
    # Check further info on each of the Exchange servers
    Foreach($Server in $Servers) {
        Write-Host "`n`tChecking $database on $server..."
        if ($null -ne (Get-MailboxDatabaseCopyStatus $FolderName\$Server -Erroraction SilentlyContinue)) {
            if ((test-path "\\$Server\d$\Mountpoints\$FolderName") -eq $true) {
                # Check the percentage free on mountpoint
                $percentFree = $(((Get-MailboxDatabaseCopyStatus $FolderName\$Server).DiskFreeSpacePercent))

                switch ($percentFree) {
                    {$_ -ge 15} { 
                        Write-host "`tThere is $percentFree% free on mountpoint." -ForegroundColor Green
                        $content += "<p>$FolderName\$Server - $percentFree% free on mountpoint</p>"
                    }
                    {($_ -lt 15) -and ($_-ge 5)} { 
                        Write-host "`tThere is $percentFree% free on mountpoint." -ForegroundColor Yellow
                        $content += "<p style='color:Orange;'><b>$FolderName\$Server - $percentFree% free on mountpoint</b></p>"
                        if ($debug -ne $true) { cawto -n srvnsmwklp -c orange -k -a reverse "$FolderName\$Server - $percentFree% free on mountpoint" }
                    }
                    {($_ -lt 5)} { 
                        Write-host "`tThere is $percentFree% free on mountpoint." -ForegroundColor Red
                        $content += "<p style='color:Red;'><b>$FolderName\$Server - $percentFree% free on mountpoint</b></p>"
                        if ($debug -ne $true) { cawto -n srvnsmwklp -c red -k -a reverse "$FolderName\$Server - $percentFree% free on mountpoint" }
                    }
                }

                # Informational message about logsize & path
                $Folderpath = "\\$Server\d$\Mountpoints\$FolderName\log"
                $Item = Get-ChildItem -Path $Folderpath |Measure-Object -property length -sum 
                $logsize = "{0:N2}" -f ($Item.sum / 1MB) + " MB"
                $logpath =  "\\$Server\d$\Mountpoints\$FolderName\log"
                Write-Host "`t$logsize - $logpath"

                # Check on age of the logfiles
                $Laggedcopy = Get-MailboxDatabaseCopyStatus $FolderName\$Server | Select-Object -ExpandProperty activationpreference
                $date = (Get-Date).AddDays(-1)
                $Age = (Get-ChildItem -Path $Folderpath -File *.log | Where-Object {$_.CreationTime -lt $date} | Measure-Object).Count

                if ($_ -gt 2) { 
                        Write-Host -ForegroundColor Red "`t$age files in this NON-LAGGED copy folder are older than 1 day - $Folderpath"
                        $content += "<p style='color:Red;'></br><b>$age files in this NON-LAGGED copy folder are older than 1 day - $Folderpath</b></p>"
                    }
                    default {}
                }
            } else {
                Write-Host "`t$FolderName is not mounted on $Server " -ForegroundColor Yellow -Back Black
            }
        } else { Write-Host "`t$FolderName does not exist on $Server "}
    }


$content += "</html>"
Send-MailMessage -Subject "Exchange report DB size and free space on mountpoints" -Body $content -From "svwscript01p@degroofpetercam.com" -To $MailTo -SmtpServer "smtp.degroof.be" -BodyAsHtml
$content = $null
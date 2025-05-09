# Script:    TotalEmailsSentReceivedPerHour.ps1 
# Purpose:    Get the number of e-mails sent and received per hour 
# Author:    Nuno Mota 
# Date:        October 2010 
 

$Servers = (Get-ExchangeServer).name
$Path = "\\degroof.be\department\dpit\ITWindows\Logs\Exchange\MessageTracking\Heatmap\"
$CSVheader = "Server,DayOfWeek,Date,00:00,01:00,02:00,03:00,04:00,05:00,06:00,07:00,08:00,09:00,10:00,11:00,12:00,13:00,14:00,15:00,16:00,17:00,18:00,19:00,20:00,21:00,22:00,23:00"
 
 
 
foreach ($strServer in $Servers)
{
    [Int64] $intSent = 0 
    [Int64] $intRec = 0 
    [String] $strTotalSent = $null 
    [String] $strTotalRec = $null
    $strSent = $null
    $strRec = $null

    $From = Get-Date (Get-Date '00:00').AddDays(-7)
    
    if((Test-Path -Path "$path$(get-date -Format yyyy-MM)_RECEIVED.csv") -eq $False){
    $CSVheader|Out-File "$path$(get-date -Format yyyy-MM)_RECEIVED.csv"}
    
    if((Test-Path -Path "$path$(get-date -Format yyyy-MM)_SENT.csv") -eq $False){
    $CSVheader|Out-File "$path$(get-date -Format yyyy-MM)_SENT.csv"}

    Do 
    { 
        If ($From.Hour -eq "0") { 
                        
            if ($strSent -ne $null) { $strSent|Out-File "$path$(get-date -Format yyyy-MM)_SENT.csv" -Append }
            
            if ($strRec -ne $null) { $strRec | Out-File "$path$(get-date -Format yyyy-MM)_RECEIVED.csv" -Append}

            $strSent = "$strServer,$($From.DayOfWeek),$($From.ToShortDateString())," 
            $strRec = "$strServer,$($From.DayOfWeek),$($From.ToShortDateString())," 
            $strSent
            $strRec

            Write-Host "Searching $From" 
        } 
     
     
        # It is faster to search the Transport Logs this way then by doing a Get-TransportServer | Get-MessageTrackingLog -ResultSize Unlimited -Start $From -End $To and then checking if it is a sent or received e-mail  
        # Sent E-mails 
        $intSent = ( Get-MessageTrackingLog -Server $strServer -ResultSize Unlimited -EventId RECEIVE -Start $From -End $To | Where {$_.Source -eq "STOREDRIVER" -and $_.MessageSubject -ne "Folder Content" -and $_.Sender -notlike "HealthMailbox*" -and $_.Sender -notlike "maildeliveryprobe*" -and $_.Sender -notlike "inboundproxy*" -and $_.Recipients -notmatch "belgium-smtp@degroofpetercamarchive.local"}).Count 
        $strSent += "$intSent," 
     
        # Received E-mails 
        Get-MessageTrackingLog -Server $strServer -ResultSize Unlimited -EventId DELIVER -Start $From -End $To | Where {$_.MessageSubject -ne "Folder Content" -and $_.Sender -notlike "HealthMailbox*" -and $_.Sender -notlike "maildeliveryprobe*" -and $_.Sender -notlike "inboundproxy*" -and $_.Recipients -notmatch "belgium-smtp@degroofpetercamarchive.local"} | ForEach {$intRec += $_.RecipientCount} 
        $strRec += "$intRec," 
        $intRec = 0 
 
        $From = $From.AddHours(1) 
        $To = $From.AddHours(1) 
    } 
    While ($To -lt (Get-Date))} 

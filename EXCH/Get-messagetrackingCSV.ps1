Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$logs = Get-ExchangeServer| Get-MessageTrackingLog -Start "12/20/2017 14:00" -End "12/20/2017 17:00" -ResultSize unlimited |select *
#$logs = get-exchangeserver| Get-MessageTrackingLog -MessageSubject "prodwkf" -Start "10/26/2017" -end 12/13/2017  -ResultSize unlimited |select *
$logs |select Timestamp,Source,EventId,MessageId,@{Expression={@($_.Recipients) -join ';'};Label="Recipients"},TotalBytes,RecipientCount,@{Expression={(@($_.MessageSubject) -join ';')};Label="MessageSubject"},Sender,ReturnPath,Directionality,OriginalClientIp,{$_.EventData} |convertto-csv -NoTypeInformation |Out-File n:\messagelogs.csv  #export-csv -NoTypeInformation -Path C:\temp\2012cpuissue.csv -Delimiter "^"

#@{Expression={($_.RecipientStatus|Out-String)};Label="RecipientStatus"},SourceContext






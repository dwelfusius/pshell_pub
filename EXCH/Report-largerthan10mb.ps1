# Connect to MS Exchange
Start-Transcript log.txt -Force
[Byte[]]$key = (1..16)
$username = "degroof\svc_script_runas"
$pwdTxt = "76492d1116743f0423413b16050a5345MgB8AEcATwBxAGgANwBsAFMAVwBIAEcARAAxAHYAaQBQAFcAcgBhADAAYQBOAFEAPQA9AHwAZQBiADAAMABlAGMAMQA3ADQAMAAwADIAOAA3ADkAZAAxAGMAZgBkADMAMQAwAGUAMgA2ADIANAA5AGMAMAAzADUANgAwADIAMAA3AGIAOQBiAGUAOABkAGIAMAAyAGIAZQA3AGMAOABhADIANwBhAGQAZAAzAGMANwBhAGMAYwA="
$securePwd = $pwdTxt | ConvertTo-SecureString -Key $key
$credObject = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $securePwd
$sessionOption = New-PSSessionOption -SkipCACheck -SkipCNCheck -SkipRevocationCheck
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://mail.degroof.be/powershell/ -Credential $credObject -Authentication Basic -AllowRedirection -SessionOption $sessionOption
Import-PSSession $session

#$fromdate = (Get-Date 00:00:00).AddDays(0)
$fromdate = (Get-Date -Day 1 00:00:00).AddMonths(-1)
#$todate = (Get-Date  00:00:00).AddDays(1)
$todate = (Get-Date -Day 1 00:00:00).AddSeconds(-1)
$ruleid = '*ETR|ruleId=a0e010c3-a99f-46bb-9578-d6ed355d60a7*'

$mails = (Get-ExchangeServer svwexchange1*).name |
   ForEach-Object { Get-MessageTrackingLog -Server $_ -Start $fromdate -End $todate -resultsize unlimited -EventId agentinfo |
         Where-Object { $_.eventdata -like $ruleid } |
            Select-Object Timestamp, Sender, TotalBytes, MessageSubject, MessageId, internalmessageid }


$report = [System.Collections.ArrayList]@()

foreach ($mail in ($mails | Where-Object { $_.TotalBytes -gt 0 })) {

   $m = [PSCustomObject]@{
      Date         = (Get-Date $mail.Timestamp -Format dd-MM-yyyy)
      Time         = ($mail.Timestamp).ToString("HH:mm:ss")
      Sender       = $mail.Sender
      Subject      = $mail.MessageSubject
      Size         = $mail.TotalBytes
      MessageID    = $mail.MessageId
      IntMessageID = ($mail.InternalMessageId).ToString()
   }

   $report.Add($m)
}

$report | Export-Csv -NoTypeInformation -Delimiter ';' -LiteralPath c:\temp\report_10mb.csv -Encoding UTF8 -Force
$params = @{
   From       = "exchange.report@degroofpetercam.com"
   To         = 'e.vanpoucke@degroofpetercam.com'
   #To = 'k.cornelis@degroofpetercam.com'
   Subject    = "Report mail larger than 10MB for $($date.month)"
   Smtpserver = "smtp.degroof.be"
}
if ((Get-Item c:\temp\report_10mb.csv).Length -gt 0 -and (-not($null -eq $mails))) {
   $params += @{
      Attachment = 'c:\temp\report_10mb.csv'
   }
}
else {
   $params += @{
      Body = '<b>No mails larger than 10mb were found this time.</b>'
   }
}
Send-MailMessage @params

Stop-Transcript
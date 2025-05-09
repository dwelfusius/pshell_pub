Import-module ActiveDirectory
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$path = "D:\Scripts\Exchange\mailFlow"
$Days = 7
$logdate = Get-Date -format "yyyyMMdd"
$Outfiles = "MailGT10MB-last7days.csv"

$date = (get-date).AddDays(-$days).ToString("M/d/yyyy hh:mm:ss tt")
$mail = Get-ExchangeServer | where {$_.isHubTransportServer -eq $true -or $_.isMailboxServer -eq $true} | Get-messagetrackinglog  -Start $date -resultsize unlimited |?{$_.totalbytes -gt 10485760}|?{$_.Sender -notmatch "MicrosoftExchange"} | Select Messageid,Sender,@{l="Recipients";e={$_.Recipients -join " : "}},MessageSubject,Timestamp,@{label="SizeinMB"; Expression={$_.totalbytes/1mb}},SourceContext | sort-object -Property messageid -Unique
$mailidevices = Get-ExchangeServer | where {$_.isHubTransportServer -eq $true -or $_.isMailboxServer -eq $true} | Get-messagetrackinglog  -Start $date -resultsize unlimited |?{$_.EventID -match "SUBMIT"}|?{$_.SourceContext -match "AirSync"}

Foreach ($email in $mail){
		$Time = $Null
		$Sender= $Null
		$Recipients = $Null
		$Subject = $Null
		$SizeInMB = $Null
		$Displayname = $Null
		$Department = $Null
		$userfromexchange = $Null
		$Company = $Null
		$SamAccountName = $null
		$ManagerName = $Null
		$ManagerEmailAddress = $Null
		$user = $Null
		$SourceDevice = "Desktop"
		
		Foreach ($idevicemail in $mailidevices){
			If (($idevicemail.messageid) -eq ($email.messageid)){
			$SourceDevice = "iDevice"
			Continue
			}
		}
		
		$Time = $email.TimeStamp
		$Sender= $email.Sender
		$Recipients = $email.Recipients
		$Subject = $email.MessageSubject
		$SizeInMB = $email.SizeinMB
		
		If ($Sender -like "*@degroofpetercam.lu"){
		$userfromexchange = get-recipient -ResultSize unlimited | where {$_.emailaddresses -match "$Sender"} | select SamAccountName
		$SamAccountName = $userfromexchange.SamAccountName
		$user = Get-ADUser -identity $SamAccountName -Properties Name,emailaddress,Manager,Department,Company 
		$Displayname = ($user).Name
		$Company = ($user).Company
		$Department = ($user).Department
		$ManagerName = ($user | select @{name='ManagerName';expression={(Get-ADUser -Identity $_.manager | Select-Object -ExpandProperty name)}}).ManagerName
		$ManagerEmailAddress = ($user | select @{name='ManagerEmailAddress';expression={(Get-ADUser -Identity $_.manager -Properties emailaddress | Select-Object -ExpandProperty emailaddress)}}).ManagerEmailAddress
		}
		

		$Output =New-Object -TypeName PSObject -Property @{
			Time = $Time
			Sender = $Sender
			Recipients = $Recipients
			Subject = $Subject
			SizeInMB = $SizeInMB
			Displayname = $Displayname
			Company = $Company
			Department = $Department	
			SenderManagerName = $ManagerName
			SenderManagerEmailAddress = $ManagerEmailAddress
			SourceDevice = $SourceDevice 
		} | Select-Object Time,Company,Department,Displayname,Sender,Recipients,Subject,SizeInMB,SenderManagerName,SenderManagerEmailAddress,SourceDevice  | Export-Csv "$Path\$logdate$Outfiles"  -Append -NoTypeInformation 
		
	}

#SendMail#####################

###########Define Variables########

$fromaddress = "svwadmsrv01p@degroofpetercam.lu"
$toaddress = "m.mahlaoui@degroofpetercam.lu"
$bccaddress = ""
$CCaddress = "j.melon@degroofpetercam.lu"
$Subject = "Rapport hebdo automatique - Mail > 10 MB"
$body = "Rapport hebdo automatique - Mail > 10 MB"
$attachment = "$Path\$logdate$Outfiles"
$smtpserver = "smtp.bdlint.local"

####################################

$message = new-object System.Net.Mail.MailMessage
$message.From = $fromaddress
$message.To.Add($toaddress)
$message.CC.Add($CCaddress)
$message.Bcc.Add($bccaddress)
$message.IsBodyHtml = $True
$message.Subject = $Subject
$attach = new-object Net.Mail.Attachment($attachment)
$message.Attachments.Add($attach)
$message.body = $body
$smtp = new-object Net.Mail.SmtpClient($smtpserver)
$smtp.Send($message)

#################################################################################
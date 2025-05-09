#new mailbox to refer to
$alias = ""

#out-of-office message
$message = @"
The mail address you are sending to is going out of commision next month.
Please use $alias@degroofpetercam.com for all future communications.
 
Bank Degroof Petercam
"@

$mailbox = "app.feedback"
$verMailbox = try {Get-Mailbox $mailbox} catch{}
if ($verMailbox){
Set-MailboxAutoReplyConfiguration -Identity $verMailbox -InternalMessage $message -ExternalMessage $message -ExternalAudience All -Confirm:$false -AutoReplyState Enabled
Get-MailboxAutoReplyConfiguration $verMailbox
}

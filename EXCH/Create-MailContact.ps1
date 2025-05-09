
$alias = "b.baudhuin"
$displayname = "Benoît Baudhuin"

$splat = @{
   Name                 = $alias
   DisplayName          = $displayname
   Alias                = $alias
   PrimarySmtpAddress   = $alias + "@degroofpetercam.com"
   ExternalEmailAddress = "SMTP:" + $alias + "@degroofpetercam.ch"
}


New-MailContact @splat -OrganizationalUnit "degroof.be/BDB/Users/Exchange/Contacts"
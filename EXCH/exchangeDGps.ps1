$UserCredential = Get-Credential;
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://svwexchange06p.degroof.be/PowerShell/ -Authentication Kerberos -Credential $UserCredential;
Import-PSSession $Session
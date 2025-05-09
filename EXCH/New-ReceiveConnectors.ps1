$params = @{
AuthMechanism = "Tls"
Bindings = ("[::]:587","0.0.0.0:587")
Fqdn = "relay-s.degroofpetercam.local"
Name = "EXT - Auth Allow Relay" 
PermissionGroups = "Anonymous"
TransportRole = "FrontendTransport"
RemoteIPRanges = "10.196.1.9"
ProtocolLoggingLevel = "Verbose"}



(Get-ExchangeServer svwexchange10*)|New-ReceiveConnector @params
Get-ReceiveConnector | Where-Object {$_.name -like "*Auth Allow*"} |Add-ADPermission -ExtendedRights ms-Exch-SMTP-Accept-Any-Recipient -User 'NT AUTHORITY\ANONYMOUS LOGON'

$params = @{
AuthMechanism = "Tls"
Bindings = ("[::]:587","0.0.0.0:587")
Fqdn = "smtp-s.degroofpetercam.local"
Name = "INT - Avaloq Relay" 
PermissionGroups = "Anonymous"
TransportRole = "FrontendTransport"
RemoteIPRanges = "10.196.1.2"
ProtocolLoggingLevel = "Verbose"}

(Get-ExchangeServer svwexchange10*)|New-ReceiveConnector @params
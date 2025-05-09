##START BLOCK##
 
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
$server = $env:COMPUTERNAME
$n = Read-Host -Prompt "Which server do you want to redirect traffic to? 1,2,3,4,5,6?"
 
 
#If you run Exchange 2013 servers in a DAG, you need to put the server into maintenance mode before you perform any maintenance to inform Exchange Managed Availability monitoring
#and recovery infrastructure that the server is under administrator control and is not a candidate to accept workload.
#Step   Action
#1  Logon to an Exchange server and open an Exchange Managed Shell as administrator.
#2  Drain the Transport Queues, doing so will stop the server to deliver messages:
#
Set-ServerComponentState $server -Component HubTransport -State Draining -Requester Maintenance
 
#Restart the Transport service - and the Transport FrontEnd if a multi-role server.
 
Restart-Service MSExchangeTransport
Restart-Service MSExchangeFrontEndTransport
 
#3  Redirect any messages in the local queues to a different server:
 
Redirect-Message -Server $server -Target SVWEXCHANGE10$($n)P.degroof.be -Confirm:$false
Start-Sleep 60
 
#4  Pause the cluster node:
 
Suspend-ClusterNode $server
 
#5  Move the active databases:
 
Set-MailboxServer $server -DatabaseCopyActivationDisabledAndMoveNow $True
Dismount-Database EVDB00$($server[-2]) -Confirm:$false
Move-ActiveMailboxDatabase -Server $server
#6  Disable database activation - if a mailbox server:
 
Set-MailboxServer $server -DatabaseCopyAutoActivationPolicy Blocked
 
#7  Activate the actual maintenance on the server:
 
Set-ServerComponentState $server -Component ServerWideOffline -State Inactive -Requester Maintenance
 
#Restart the Transport service - and the Transport FrontEnd if a multi-role server.
 
Restart-Service MSExchangeTransport
Restart-Service MSExchangeFrontEndTransport
 
##END BLOCK##
 
 
#3.3    Verify the server is in maintenance mode
#To verify that a server is ready for maintenance.
#Step   Action
#1  Logon to an Exchange server and open an Exchange Managed Shell as administrator.
#2  To verify the server has been placed into maintenance mode, run:
 
Get-ServerComponentState $server | ft Component,State –Autosize
 
#All components should show “Inactive” except for Monitoring and RecoveryActionsEnabled.
#3  To verify the server is not hosting any active database copies, run:
 
Get-MailboxServer $server | ft DatabaseCopy* -Autosize
 
#4  To verify that the node is paused, run:
 
Get-ClusterNode $server | fl
 
#5  To verify that all transport queues have been drained, run:
 
Get-Queue
 
#6  To verify that all mounted db's have switched over or are dismounted:
Get-MailboxDatabaseCopyStatus
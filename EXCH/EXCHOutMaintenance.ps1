Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
$server = $env:COMPUTERNAME
 
# No linked errors detected.
# 3.5.4 Take Exchange Server out of Maintenance Mode
# Step  Action
# 1 Logon to an Exchange server and open an Exchange Managed Shell as administrator.
Set-ServerComponentState –Identity $server –Component ServerWideOffline –State Active –Requester Maintenance
 
Resume-ClusterNode –Name $server
 
Set-MailboxServer –Identity $server –DatabaseCopyAutoActivationPolicy Unrestricted
 
Set-MailboxServer –Identity $server –DatabaseCopyActivationDisabledAndMoveNow $False
 
Set-ServerComponentState –Identity $server –Component HubTransport –State Active –Requester Maintenance
 
Mount-Database EVDB00$($server[-2]) -Confirm:$false
 
# 7 To verify the server is not maintenance mode, run:
 
Get-ServerComponentState $server| ft Component,State –Autosize
 
Start-Sleep 20
 
# All server components should show as “Active”.
# 3.5.5 Check Database Copy Status
# use the Get-MailboxDatabaseCopyStatus cmdlet to verify that all database copies, copy/replay queues, and content indexes are healthy.
Get-MailboxDatabaseCopyStatus
 
# 4 Aftercare
# 4.1   Rebalance Mailbox Databases
#You can use the RedistributeActiveDatabases.ps1 script to balance the active mailbox databases copies across a DAG. This script moves databases between their copies in an attempt to have an equal number of mounted databases on each server in DAG.
#Step   Action
#1  Logon to an Exchange server and open an Exchange Managed Shell as administrator.
#2  Change the command directory to the Exchange scripts folder:
 
cd "D:\Program Files\Microsoft\Exchange Server\V15\Scripts\"
 
# 3 Run the following script to re-balance the active database copies:
 
.\RedistributeActiveDatabases.ps1 –DagName 'CVWEXCDAG101P' –BalanceDbsByActivationPreference -Confirm:$false
 
# 4 Show the current database distribution for a DAG, including preference count list:
 
.\RedistributeActiveDatabases.ps1 -DagName 'CVWEXCDAG101P' -ShowDatabaseDistributionByServer | ft
Write-Host -ForegroundColor Yellow "Press enter to continue..."
Read-Host
 
Get-MailboxDatabaseCopyStatus
Write-Host -ForegroundColor Yellow "Press enter to continue..."
Read-Host
 
Test-ServiceHealth|ft Role,RequiredServicesRunning,ServicesNotRunning,ServicesRunning -AutoSize
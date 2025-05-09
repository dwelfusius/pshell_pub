
Import-Module EnterpriseVault

## EV backup index check Zabbix

if ($a.backupmode -contains $True) {
   $message = "There are index locations still in backup mode."
$Parameters = @{
	Message = $message
	EventId = 65000
	EntryType = 'Warning'
	LogName = 'Application'
	Source = 'Enterprise Vault'
	Category = 106
}
   Write-EventLog @Parameters
}
else {
$Parameters = @{
	Message = 'All indexes are out backup mode'
	EventId = 65000
	EntryType = 'Information'
	LogName = 'Application'
	Source = 'Enterprise Vault'
	Category = 106
}
   Write-EventLog @Parameters
}

## EV task state check Zabbix
$errTask = [System.Collections.Arraylist]@()
foreach ($t in (Get-EVTask)) {
   if ((Get-EVTaskState $t.EntryID) -in 'Error', 'Failed', 'Stopped') {
      $errTask.Add($t.Name) | Out-Null
   }
}
if ($errTask) {
   $message = 
   @"

Tasks :

$($errTask |Out-String)    
are not in an active or expected state, please verify.
"@

$Parameters = @{
	Message = $message
	EventId = 65001
	EntryType = 'Warning'
	LogName = 'Application'
	Source = 'Enterprise Vault'
	Category = 106
}
   Write-EventLog @Parameters
}
else {
$Parameters = @{
	Message = 'All tasks are running as expected'
	EventId = 65001
	EntryType = 'Information'
	LogName = 'Application'
	Source = 'Enterprise Vault'
	Category = 106
}
   Write-EventLog @Parameters 
}



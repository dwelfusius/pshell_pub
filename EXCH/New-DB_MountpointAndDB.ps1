## Part 1 - getting the disk, putting it online if needed,creating the volume and mounting it in the newly created folder

$dbNr = Read-host -Prompt 'Fill in the DB number as such "019" '

$point = New-Item -Path "D:\Mountpoints\MDB$dbNr" -ItemType Directory

$disk = Get-Disk | Where-Object OperationalStatus -EQ 'Offline' |Out-GridView -PassThru 
Set-Disk $disk.DiskNumber -IsOffline $false
#Initialize-Disk -UniqueId $disk.UniqueId -PartitionStyle GPT
Set-Disk -UniqueId $disk.UniqueId -PartitionStyle GPT


New-Partition -UseMaximumSize -DiskNumber $disk.Number

$Partition = Get-Partition -DiskNumber $disk.Number -PartitionNumber 2
$Partition | Add-PartitionAccessPath -AccessPath $point.FullName
$Partition | Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel "ExVol$($disk.DiskNumber)" -Confirm:$false


## Part 2 - setting up the exchange DB and copies

$server = $env:COMPUTERNAME
$dbNr = Read-host -Prompt 'Fill in the DB number as such "019" '

$servernr = $server[-2]
$dbcopy = switch($servernr){
1 {3,5}
2 {4,6}
3 {5,1}
4 {6,2}
5 {1,3}
6 {2,4}
}


function Test-DBMoveStatus($ComputerName) {
Start-Sleep 10
if(-not (Get-MailboxDatabaseCopyStatus -Server $ComputerName -Active |Where-Object -Property Name -Like "MDB*")){
    $true
    }
else {$false}
}

function Restart-ISService($Computername){
    Get-Service 'MsexchangeIS' -ComputerName $ComputerName | Restart-Service
}




# Create new DB
$newDB = @{
    Name="MDB$dbNr"
    Server=$server
    edbfilepath="D:\MountPoints\MDB$dbNr\DB\MDBMDB$dbNr.edb"
    logfolderpath="D:\Mountpoints\MDB$dbNr\LOG"
}
New-mailboxdatabase @newdb

#set DB preferences
$setDB = @{
	Identity = "MDB$dbNr"
	DeletedItemRetention = 30
	IssueWarningQuota = 'unlimited'
	ProhibitSendReceiveQuota = 'unlimited'
	ProhibitSendQuota = 'unlimited'
	OfflineAddressBook = "\Default Offline Address Book"
}
Set-MailboxDatabase @setDB

# Move active DB's
Move-ActiveMailboxDatabase -Server $server
#restart Msexchange IS Service IF no more active MDB DB's (retry if needed)
if (Test-DBMoveStatus($server)){
    Restart-ISService($server)
}

#mount db
Get-mailboxdatabase -Identity "MDB$dbNr" | Mount-Database

#create DB copies
$server2 = "SVWEXCHANGE10$($dbcopy[0])P"
$server3 = "SVWEXCHANGE10$($dbcopy[1])P"

Add-mailboxdatabasecopy -Identity "MDB$dbNr" -MailboxServer $server2 -ActivationPreference 2
Add-mailboxdatabasecopy -Identity "MDB$dbNr" -MailboxServer $server3 -ActivationPreference 3

# Move active DB's and restart IS
Move-ActiveMailboxDatabase -Server $server2
Test-DBMoveStatus($server2){
    Restart-ISService($server2)
}

Move-ActiveMailboxDatabase -Server $server3
Test-DBMoveStatus($server3){
    Restart-ISService($server3)
}

Get-MailboxDatabaseCopyStatus -Server $server3 |
    Where-Object {$_.ActivationPreference -eq 1 -and $_.DatabaseName -like 'MDB*'} |
    ForEach-Object {Move-ActiveMailboxDatabase $_.DatabaseName -SkipMoveSuppressionChecks -Confirm:$false}

#check activation and pref
Get-mailboxdatabasecopystatus "MDB$dbNr" |
    Select-Object name,activedatabasecopy,activationpreference |
    Sort-Object name

Get-MailboxDatabaseCopyStatus MDB* -Active |Sort-Object name |Format-Table -AutoSize

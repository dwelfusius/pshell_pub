$uneven = '1,3,5,7,9,11,13' -split ','
$even = '2,4,6,8,10,12' -split ','

if ((Read-Host -Prompt "Even or Uneven?:") -like 'even*')
{$set = $even}
else {$set = $uneven}

$set
Read-Host -Prompt "Press enter to continue..."

$set[0..$($set.count -3)]|%{New-Item -Type Directory -Name "MDB00$_" -Path D:\MountPoints }
$set[$($set.count -2)..$($set.Count -1)]|ForEach-Object {New-Item -Type Directory -Name "MDB00$_" -Path D:\MountPoints }

Read-Host -Prompt "Press enter to continue..."

Get-Disk |?{$_.partitionstyle -eq 'RAW'}|Initialize-Disk -PartitionStyle GPT


$disk = Get-Disk |?{$_.partitionstyle -eq "GPT"}

$points = Get-ChildItem D:\MountPoints -Directory |select -ExpandProperty Name
$i = 0

Read-Host -Prompt "Press enter to continue..."

foreach ($d in $disk)
{
 

New-Partition -UseMaximumSize -DiskNumber $d.Number

$Partition = Get-Partition -DiskNumber $d.Number -PartitionNumber 2
$Partition | Add-PartitionAccessPath -AccessPath "D:\MountPoints\$($points[$i])"
$Partition | Format-Volume -FileSystem NTFS -AllocationUnitSize 65536 -NewFileSystemLabel $points[$i] -Confirm:$false
$i++

}


$Servers = 'svwentvault01p', 'svwentvault02p'
$Servers | ForEach-Object { 
    Get-WinEvent -ListLog * -ComputerName $_  | Where-Object {
        $_.recordcount -gt 0 } }

$Result | ForEach-Object { Get-WinEvent -LogName $_.logname | 
    Where-Object { 
        $_.timecreated -gt (
        Get-Date -Hour 7 -Minute 0) -and $_.timecreated -lt (
        Get-Date -Hour 9 -Minute 0) }}
$Result | Out-GridView
Remove-Variable -Name 'Result'




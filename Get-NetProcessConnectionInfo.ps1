$connections = Get-NetTCPConnection
$list = [System.Collections.ArrayList] @()


foreach ($conn in $connections){
$d = (Get-CimInstance -Filter "processid=$($conn.owningprocess)" -ClassName Win32_Process -Property *)|select processname,commandline,executablepath,description


$c = $conn|Select-Object LocalAddress,LocalPort,RemoteAddress,RemotePort,State,AppliedSetting,OwningProcess,@{
N="Process";E={($d.processname)}},@{
N='commandline';E={$d.commandline}},@{
N='ex_path';E={$d.executablepath}},@{
N='description';E={$d.description}}
$list.Add($c)|out-null
}
$list|ogv


function Get-Session(){
[CmdletBinding()]
param($computer)
quser /server:$computer
}
$users = Read-Host -Prompt "Enter user(s) seperated by comma:"
#$global:users = "gen_exchange_tier1_2","gen_exchange_tier0_2","gen_windows_tier1_2","gen_windows_tier0_2"
$sessionlist = [System.Collections.ArrayList]@()

foreach ($comp in (Get-ADComputer -Filter {name -like "s*vw*p" -and enabled -eq $true}).name){

        if (Test-NetConnection $comp -InformationLevel Quiet -WarningAction SilentlyContinue){
        foreach ($user in $users){
            try {$session = (Get-Session -computer $comp -ErrorAction Stop| Where-Object { $_ -match $user })}
            catch {continue}
            if ($session){
                ###logs off user
                $o = [pscustomobject] @{
                    'computer'= $comp
                    'session'= $session
                    'sessionid'= ($session -split ' +')[2]
                }
                if ($o.sessionid  -as [int]){
                    $sessionlist.Add($o)
                }
                else{
                    $o.sessionid = ($session -split ' +')[3]
                    $sessionlist.Add($o)
                }        
            }
        }
    }
}


foreach ($s in ($sessionlist|Out-GridView -PassThru -Title 'Select the sessions you want to logoff and press ok')){
    Logoff $s.sessionid /server:$($s.computer)
}
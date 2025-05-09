$whatifpreference = $true

$mbs = get-aduser -LDAPFilter "(msexchdelegatelistlink=*)" -Properties msexchdelegatelistlink

foreach ($m in $mbs) {
    if ($m.msexchdelegatelistlink -like "*_disabled,*"){
    $m.msexchdelegatelistlink
    $m.msexchdelegatelistlink|?{$_ -like "*_disabled*"}|%{set-aduser $m.distinguishedname -Remove @{msexchdelegatelistlink=$_} -WhatIf -Verbose}
}}
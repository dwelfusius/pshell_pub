$exchange= (Get-ExchangeServer).name

$mdb = foreach($e in $exchange)
{ Get-mailboxdatabasecopystatus -Server $e | #?{$_.ActivationPreference -like "4*"}|
    select name,activationpreference,copyqueuelength,replayqueuelength,truncationlag,replaylagstatus #-AutoSize | sort-object replaylagstatus
   #activedatabasecopy

 }

 $mdb|ogv


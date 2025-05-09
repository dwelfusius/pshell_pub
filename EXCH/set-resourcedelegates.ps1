Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

$rooms = Get-Mailbox BE-IN44-02-MEETING-ROOM-01 -RecipientTypeDetails RoomMailbox
#$user = "Xavier Guillaume"
$user = 

function remove-resourcedelegate
{
    foreach ($room in $rooms)
        {
        $delegates = Get-CalendarProcessing $room
        $delegates.resourcedelegates.name|fl
        $delegates.resourcedelegates -= (Get-Mailbox $user).Identity
        Set-CalendarProcessing $room -ResourceDelegates $delegates.ResourceDelegates
        Get-CalendarProcessing $room|fl identity,resourcedelegates
        }
}


function add-resourcedelegate
{
    foreach ($room in $rooms)
        {
        $delegates = Get-CalendarProcessing $room
        $delegates.resourcedelegates.name
        $delegates.resourcedelegates += (get-mailbox $user).Identity  
        Set-CalendarProcessing $room -ResourceDelegates $delegates.ResourceDelegates
        Get-CalendarProcessing $room|fl identity,resourcedelegates
        }
}

Write-host -ForegroundColor Yellow "
1. Add resource delegate
2. Remove resource delegate `n"
    


do
{
$action = Read-Host "What do you want to do?"
    if($action -eq 1)
        {
        Add-resourcedelegate
        }
    elseif($action -eq 2)
        {
        Remove-resourcedelegate
        }
}
until(($action -eq 1) -or ($action -eq 2))
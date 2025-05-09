$dc = ($env:LOGONSERVER).TrimStart("\\\\")

<# $rooms = Import-Csv \\degroof.be\public\users\ktc\spainrooms.csv -Delimiter ";"
 foreach ($room in $rooms){
 $sam = $room.name.tostring().Remove(0,3).replace("MEETING-","")
 $linked = "$($room.name)@dgfptcsp.local"
 new-mailbox -LinkedRoom -Name $room.name -DisplayName $room.name -SamAccountName $sam -ResourceCapacity $room.capacity -Phone $room.phone -LinkedMasterAccount $linked  -Office $room.location -DomainController srvwndc03p -LinkedDomainController spdc02.dgfptcsp.local -OrganizationalUnit "OU=ES Room Mailboxes,OU=DGP Spain Mail Users,OU=pMUsers,DC=degroof,DC=be"
 Set-Mailbox $room.name -ResourceCapacity $room.CAPACITY -DomainController srvwndc03p
 }#>


$rooms = Import-Csv \\degroof.be\department\DPIT\itwindows\Logs\Exchange\meetingrooms.csv -Delimiter ";"
foreach ($room in $rooms){
    $sam = $room.name.tostring().Remove(0,3)
    if ($sam.Length -gt 20){$sam = $sam.substring(0,20)}
    $room.name
    #New-mailbox -Room -Name $room.name -FirstName $room.fn -LastName $room.sn -Alias  $room.name -DisplayName $room.displayname -SamAccountName $sam -ResourceCapacity $room.capactiy  -Office $room.location -DomainController $dc -OrganizationalUnit "OU=Room Mailbox,OU=Exchange,OU=Users,OU=BDB,DC=degroof,DC=be" -Database mdb0005 -Verbose
    #New-mailbox -Room -Name $room.name -FirstName $room.fn -LastName $room.sn -Alias  $room.name -DisplayName $room.displayname -SamAccountName $sam -ResourceCapacity $room.capactiy  -Office $room.location -DomainController $dc -OrganizationalUnit "OU=Room Mailbox,OU=Exchange,OU=Users,OU=BDB,DC=degroof,DC=be" -Database mdb0005
    #Set-Mailbox $room.name -ResourceCapacity $room.CAPACTiY -resourcecustom ($room.equipment -split ",") -DomainController $dc 
    Get-Mailbox $room.name|Set-CalendarProcessing -BookInPolicy ($room.Bookinpolicy -split ",") -ResourceDelegates ($room.Resourcedelegates -split ",") -AllBookInPolicy $false # -AllRequestInPolicy $true -AllowRecurringMeetings $false -TentativePendingApproval $false
    #Get-Mailbox $room.name|Set-CalendarProcessing -BookInPolicy $null -ResourceDelegates $null -AllBookInPolicy $true -AllRequestInPolicy $true -AllowRecurringMeetings $false -TentativePendingApproval $false
    #Set-Mailbox $room.name -MailTip "Do NOT book, these rooms are still being tested.For now still use hotesses"
    
    #set-MailboxFolderPermission "$($room.name):\calendar" -AccessRights editor -User CEN
}


#$sam = "ES-BCN-P2-MEETING-ROOM-01".tostring().Remove(0,3).replace("MEETING-","")
#
#new-mailbox -Room -Name "ES-BCN-P2-MEETING-ROOM-01" -DisplayName "ES-BCN-P2-MEETING-ROOM-01" -SamAccountName $sam -ResourceCapacity 6 -Phone 1249 -Office "ES-BCN-P2" -OrganizationalUnit "OU=ES Room Mailboxes,OU=DGP Spain Mail Users,OU=pMUsers,DC=degroof,DC=be" -Database mdb0004
#Set-Mailbox $room.name -ResourceCapacity $room.CAPACITY -DomainController srvwndc03p
#
#
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn
Import-Module ActiveDirectory
$FormatEnumerationLimit = -1

$user = read-host "Please write the name of the user you need"
$user = Get-ADUser $user -Properties *
$msexchBL = $user.msExchDelegateListBL|%{Get-Mailbox $_ |select displayname,distinguishedname} |ogv -Title "Please select the mailboxes to remove" -PassThru|select -ExpandProperty distinguishedname
$info = @()
foreach ($mb in $msexchBL)
    {
    get-aduser $mb |Set-ADUser -Remove @{msexchdelegatelistlink=$user.DistinguishedName}
    $info += "User $($user.displayname) was removed from $(get-mailbox $mb|select -ExpandProperty displayname)"
    Write-Host "User "-NoNewline
    Write-Host "$($user.displayname)" -ForegroundColor Red -NoNewline
    Write-Host " was removed from "-NoNewline
    Write-Host "$(get-mailbox $mb|select -ExpandProperty displayname)."  -ForegroundColor Red
    }

    $info|Out-File -FilePath \\degroof.be\department\DPIT\Public\mb-automapremoval.log -Append
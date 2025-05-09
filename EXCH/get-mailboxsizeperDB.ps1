Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

##mind the -archive parameter

$mb = @()
$mb = get-mailbox -RecipientTypeDetails UserMailbox,sharedmailbox  -ResultSize unlimited
$result = New-Object -TypeName "System.Collections.ArrayList"
foreach($m in $mb){
    $msize = Get-MailboxStatistics $m -ErrorAction SilentlyContinue |select totalitemsize,itemcount
    #$mcount = Get-MailboxFolderStatistics $m -ErrorAction SilentlyContinue|measure
    #New-Object psobject -Property  @{
    $result.Add([pscustomobject]@{
    name = $m.SamAccountName;
    displayname = $m.DisplayName;
    sizeMB = ($msize.totalitemsize).Value.ToMb();
    email = $m.WindowsEmailAddress;
    database = $m.database;
    #foldercount = $mcount.Count
    type = $m.recipienttypedetails;
    #itemcount = $msize.itemcount
    #"when changed" = ($m.WhenChanged).ToShortDateString()
 })}

 $result|export-csv  -LiteralPath \\degroof.be\department\DPIT\itwindows\Logs\Exchange\allmbsandsizes.csv
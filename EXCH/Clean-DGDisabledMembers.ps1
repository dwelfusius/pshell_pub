$groups = Get-DistributionGroup -ResultSize unlimited |?{$_.grouptype -like "*security*"} |select name,distinguishedname
$disabled = [system.collections.arraylist]@()

$count = 0
foreach ($g in $groups)
{
#if (-not((Get-ADGroup $g.distinguishedname -Properties members).members -like "*"))
if ((Get-ADGroup $g.distinguishedname -Properties members).members -like "*ou=_disabled*")
{

$o = New-Object -TypeName pscustomobject -Property @{name="";disabled="";members=""}
$o.name = $g.DistinguishedName
$o.disabled = (Get-ADGroupMember $g.distinguishedname |?{$_.distinguishedname -like "*_disabled*"}|measure).count
$o.members = (Get-ADGroupMember $g.distinguishedname |?{$_.distinguishedname -like "*_disabled*"}).name -join ','
$disabled.add($o)
<#>
$g.Name

Remove-ADGroupMember $g.DistinguishedName -members (Get-ADGroupMember $g.distinguishedname |?{$_.distinguishedname -like "*_disabled*"}) -Confirm:$false -Verbose

Write-host ($count++) -ForegroundColor Green
#>
}
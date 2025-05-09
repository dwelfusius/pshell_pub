Import-Module pspas
#ldap acc + pwd
$cred = (get-credential)
$search = Read-host -Prompt 'Which account(s) are you looking for? (f.e exchange will return all accounts with exchange in it)'
$accounts = Get-PASAccount -search $search
New-PASSession -Credential $cred -BaseURI https://keypass.degroofpetercam.local -type LDAP
foreach($acc in $accounts){Get-PASAccountPassword -AccountID $acc.id |ft *,@{n='user';e={$acc.username}} -Autosize}
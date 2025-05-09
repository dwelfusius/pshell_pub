$ErrorActionPreference = "Stop"

Import-Module pspas
[SecureString]$securePwd = ConvertTo-SecureString -string $EffectivePassword$ -AsPlainText -Force
[pscredential]$cred = New-Object System.Management.Automation.PSCredential ("ktc",$securePwd)
$accounts = "gen_exchange_tier1_2,gen_exchange_w_tier1" -split ','

New-PASSession -Credential $cred -BaseURI https://keypass.degroofpetercam.local -type LDAP

$ID = 100001

[System.Collections.ArrayList]$array = @()
foreach ($a in $accounts) {
    $array.Add((
        New-Object System.Management.Automation.PSObject -Property @{
            "Type" = "Credential"
            "Name" = $a
            "Username" = $a
            "Password" = (Get-PASAccount -search $a|Get-PASAccountPassword -Reason "RoyalTSProc").password
            "CredentialsFromParent" = "true"
            "ID" = $id++
            }
        )) | Out-Null
}
$array = $array | Sort-Object -Property Path
$hash = @{ }
$hash.add("Objects", $array)

$hash| ConvertTo-Json -Depth 100
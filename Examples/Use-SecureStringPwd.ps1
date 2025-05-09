# create a secure string pwd
[Byte[]] $key = (1..16)
$Password = "somestring" | ConvertTo-SecureString -AsPlainText -Force
$Password | ConvertFrom-SecureString -key $key

#use a secure string pwd
[Byte[]] $key = (1..16)
$password = "someSECUREstring" | ConvertTo-SecureString -Key $key
$user = 'degroof\a_user_p'
$cred = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, $password
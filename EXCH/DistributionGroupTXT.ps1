$DistList=Read-Host -Enter "Distribution group name";

Get-DistributionGroupMember $DistList|ft name,PrimarySmtpAddress -AutoSize >> n:\$DistList.txt;

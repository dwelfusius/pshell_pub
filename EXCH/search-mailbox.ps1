Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn

#Search-Mailbox pfm -SearchQuery 'sent>"10/23/2015" AND sent<"12/14/2016"' -EstimateResultOnly #-TargetMailbox ktcadm -TargetFolder Audit -LogLevel Full -WhatIf

$date= @("10/23/2015",
"11/17/2015",
"12/23/2015",
"01/12/2016",
"02/16/2016",
"02/17/2016",
"02/24/2016",
"03/09/2016",
"03/17/2016",
"05/06/2016",
"05/25/2016",
"07/05/2016",
"07/07/2016",
"07/15/2016",
"07/27/2016",
"09/01/2016",
"09/02/2016",
"09/06/2016",
"09/21/2016",
"10/12/2016",
"10/20/2016",
"10/25/2016",
"12/14/2016")


foreach ($d in $date){ Search-Mailbox BWM -SearchQuery received>=11/02/2017 -TargetMailbox ktcadm -TargetFolder BWMleave -LogLevel Full}
$folder = 'G:\temp\audit-11102022'

Start-Transcript
#$csv = import-csv "\\cifs.clients-nasbxl02.degroof.be\evault\Transfert\evaudit.csv" -delimiter ';'

$about = '(Salt OR Pepper OR Dancing OR “Disco Fever”)'
$uJournal = 'Mister Lollipo,Space Man,Saper Delipoupette' -split ','
$uArchive = 'Mister Lollipo,Space Man,Saper Delipoupette' -split ','


$bDate = '2012-01-01'
$eDate = '2022-09-20'
$jDate = '2017-11-01'

$folder = 'G:\temp\audit-11102022'

$param = @{
Format = 'PST'
MaxThreads = 100 
MaxPSTSizeMB = 20000
}


foreach ($u in $uJournal)
{
#for ($i = 100/$uJournal.Count; $i -le $uJournal.Count; $i++ ) {
#    Write-Progress -Activity "Search in Progress for $u" -Status "$i% Complete:" -PercentComplete $i
#}
Export-EVArchive -ArchiveID  “1A8FB85FBDBE05C4493FEC9591864B9C81110000evaultsrv01” -OutputDirectory “$folder\FROM_$u” @param -Searchstring "from:$u date:$jDate..$eDate about:$about" 
Export-EVArchive -ArchiveID  “1F73C2B579A4E1A4FB4B7CD25CCA87A231110000evaultsrv01” -OutputDirectory “$folder\FROM_$u” @param -Searchstring "from:$u date:$jDate..$eDate about:$about" 
Export-EVArchive -ArchiveID  “1A8FB85FBDBE05C4493FEC9591864B9C81110000evaultsrv01” -OutputDirectory “$folder\TO_$u” @param -Searchstring "to:$u date:$jDate..$eDate about:$about" 
Export-EVArchive -ArchiveID  “1F73C2B579A4E1A4FB4B7CD25CCA87A231110000evaultsrv01” -OutputDirectory “$folder\TO_$u” @param -Searchstring "to:$u date:$jDate..$eDate about:$about" 
}

Clear-Variable u

foreach ($u in $uArchive)
{
#for ($i = 100/$uArchive.Count; $i -le $uArchive.Count; $i+(100/$uArchive.Count) ) {
#    Write-Progress -Activity "Search in Progress for $u" -Status "$i% Complete:" -PercentComplete $i
#}
Get-EVArchive -ArchiveName $u | Export-EVArchive @param -OutputDirectory “$folder\FROM_$u” -Searchstring "from:'$u' date:$bDate..$jDate about:$about" 
Get-EVArchive -ArchiveName $u | Export-EVArchive @param -OutputDirectory "$folder\TO_$u" -Searchstring "to:'$u' date:$bDate..$jDate about:$about" 
}

$datemin = (Get-Date).AddYears(-2)
$folder = Get-Date $datemin -Format yyyy
$destination = "\\degroof.be\public\AR_Compta\Purchase_journal\$folder"
$zip = '0,2000,2001,4000,4001,6000,6001,8000,8001,10000,10001,12000,12001,14000,14001,16000,16001,18000' -split ','

function Get-FileNumber {
   [CmdletBinding()] 
   param (
      [string] $name
   )
   
   [int]($name -replace '.pdf', '')
}

for ($i = 0; $i -lt $($zip.Count - 1); $i = $i + 2) {
   
   ## Get appropriate filename and filelist
   $zipname = "$destination\$($zip[$i])-$($zip[$i + 1]).zip"
   
   Measure-Command {
      $a = (Get-ChildItem $destination).Where( { $_.extension -ne '.zip' })
      $files = $a.Where( { (Get-FileNumber $_.name ) -in $zip[$i]..$zip[$i + 1] }) 
   }

   if ($files) {

      ## Compress to zip
      Write-Host "Creating zip file..."
      $files | Compress-Archive -DestinationPath  $zipname -Update 
   
      ## Measure zip and files before deleting them
      $filesize = ($files | Measure-Object Length -Sum).Sum
      $zipsize = (Get-Item $zipname).Length

      if ((Test-Path "$zipname") -and ($zipsize -gt ($filesize * 0.7  ))) { 
         Write-Host "Removing files.."
         $files | Remove-Item #-Confirm:$false
      }
      else {
         Write-Host "Files weren't removed due to zip file not present or not large enough."
      }

   }
   Clear-Variable zipname, a, files, filesize, zipsize   
}




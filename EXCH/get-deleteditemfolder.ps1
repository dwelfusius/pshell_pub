 $mbs = Get-Mailbox -ResultSize unlimited| Get-MailboxfolderStatistics
 $mbs | Where-Object {$_.folderpath -like "/Deleted Items*"}|select-object -Property identity,@{label="FolderSize";expression={($_.FolderSize).tomb()}},@{label="ItemsDirSubdir";expression={($_.ItemsInFolderAndSubfolders)}},@{label="DirSubdirSizeMB";expression={($_.FolderAndSubfolderSize).tomb()}}|ogv

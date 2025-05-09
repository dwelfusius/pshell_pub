

Function CheckSession()
{

    # Check if an active session is available. If not, start a new session.

    $CheckSession =  Get-PSSession | Where {($_.ConfigurationName -eq "Microsoft.Exchange") -and ($_.ComputerName -eq $PowerShellUrl)}

    if ($CheckSession -eq $null)
    {
        
        #Show an error message

        Write-Host "Error:" -ForegroundColor Red
        Write-Host "------" -ForegroundColor Red       
        Write-Host "No active connection to Exchange is available." -ForegroundColor Red
        Write-Host "Please connect to Exchange before using this script." -ForegroundColor Red

        #Exit the script
        Exit
    }
    Else
    {
        ShowMainMenu
    }
}

Function ShowMainMenu()
{

    #This function builds the main menu of the script

    #Let's start with a nice, clean terminal

    Clear-Host

    Write-Host "Welcome to the Exchange Menu" -ForegroundColor Yellow
    Write-Host "----------------------------" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please select the action you want to perform:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1.  " -ForegroundColor Yellow
    Write-Host "2.  " -ForegroundColor Yellow
    Write-Host "3.  " -ForegroundColor Yellow
    Write-Host "4. Manage Full-Access Groups" -ForegroundColor Yellow
    Write-Host "5.  " -ForegroundColor Yellow
    Write-Host "0.  " -ForegroundColor Yellow
    Write-Host ""
    
    #Input validation

    do
    {
        Write-Host "Please make your selection: " -ForegroundColor Yellow -NoNewline
        $MainMenuSelection = Read-Host
    }
    until (($MainMenuSelection -ge 0) -and ($MainMenuSelection -le 5))

    #Select the following functions

    switch ($MainMenuSelection)
    {
        1{
            CreateMailbox
        }
        2{
            RemoveMailboxMenu
        }
        3{
            OoOMenu
        }
        4{
            GroupMenu
        }
        5{
            OtherMenu
        }
        0{
            Exit
        }
    }
}

Function GroupMenu()
{
    
    #This function lets you manage the Full-Access groups for Shared Mailboxes

    #Clear the terminal screen

    Clear-Host

    Write-Host "Please select the action you want to perform" -ForegroundColor Yellow
    Write-Host "--------------------------------------------" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Show members of a distribution group" -ForegroundColor Yellow
    Write-Host "2. Show members of a distribution group and export to file" -ForegroundColor Yellow
    Write-Host "0. Cancel and return to the menu" -ForegroundColor Yellow
    Write-Host ""

    #Input validation
    
    do
    {
        Write-Host "Please make your selection: " -ForegroundColor Yellow -NoNewline
        $SelectedGroupAction = Read-Host
    }
    until (($SelectedGroupAction -ge 0) -and ($SelectedGroupAction -le 2))

    #Select the following functions

    switch ($SelectedGroupAction)
    {
        1{
            ShowDistrMembers
        }
        2{
            ShowDistrMembersAndExport
        }
        0{
            ShowMainMenu
        }
    }
}

Function ShowDistrMembers()
{

    #This function lets you add users to a full-access group

    #Clear the terminal screen

    Clear-Host

#   Write-Host "Add users to a Full-Access Group" -ForegroundColor Yellow
#   Write-Host "--------------------------------" -ForegroundColor Yellow
#   Write-Host ""
#   Write-Host "To add users to a Full-Access Group, the group is identified by the name of the Shared Mailbox."`
#              "You can keep adding users to the group until you enter on an empty line." -ForegroundColor Yellow
#   Write-Host ""
#   Write-Host "Enter 0 to cancel the process at any time" -ForegroundColor Magenta
#   Write-Host ""

    # User input and validation
$Distlist=Read-Host -Prompt "Name of the distribution group"
    
Get-DistributionGroupMember $DistList|ft name,PrimarySmtpAddress -AutoSize >> n:\$DistList.txt
    
    Write-Host "Please press enter to return to the menu..." -ForegroundColor Yellow
    Read-Host
    ShowMainMenu
    }




 # 
 #$Distlist=Read-Host -Prompt "Name of the distribution group";
 #
 #
 #Get-DistributionGroupMember $DistList|ft name,PrimarySmtpAddress -AutoSize >> n:\$DistList.txt;
 #
$scriptblock = @"
##region <Initialise> ================================================================
#   ## DIGITAL GUARDIAN #######################################################      
#   ########:::######::: ######::::::: ########: ########:::: ###:::: ##:::: ##
#   ##.... ##: ##... ##: ##... ##:::::... ##..:: ##.....:::: ## ##::: ###:: ###
#   ##:::: ##: ##:::..:: ##:::..::::::::: ##:::: ##:::::::: ##:. ##:: ####'####
#   ########::. ######:: ##:: ####::::::: ##:::: ######:::'##:::. ##: ## ### ##
#   ##.....::::..... ##: ##::: ##:::::::: ##:::: ##...:::: #########: ##. #: ##
#   ##::::::::'##::: ##: ##::: ##:::::::: ##:::: ##::::::: ##.... ##: ##:.:: ##
#   ##::::::::. ######::. ######::::::::: ##:::: ########: ##:::: ##: ##:::: ##
#   ##::::::::.:::::::::: Robot Framework Installer © 2021                   ##
#   ## AUTHOR: dbaldree@digitalguardian.com :::::::::::::::::::::::::::::::::##
#   ##:##############################################################  v 1.0 ##
#   ##   RUNNING DEPLOYMENT TASK: STEP 1                                     ##
#   ###########################################################################
##End region <Initialise> ============================================================
"@
Write-Host $scriptblock -ForegroundColor yellow

#MSGBOX
#do you have chrome installed
#do you have notepad++ installed
#do you have GIT installed
#do you have 7Z installed


#Setup Persistent Environment Var Function
function Set-EnvironmentVariable
{
  param
  (
    [Parameter(Mandatory=$true)]
    [String]
    $Name,
    
    [Parameter(Mandatory=$true)]
    [String]
    $Value,
    
    [Parameter(Mandatory=$true)]
    [EnvironmentVariableTarget]
    $Target
  )
  [System.Environment]::SetEnvironmentVariable($Name, $Value, $Target)
}

Write-Host "`r`nSetting up environment profile...`r`n" -for cyan

#Creates Windows Explorer reg keys on user login
	
#Test if path exists before use!
$regpath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CabinetState"
if( ! (Test-Path -Path $regpath)) {
    #-Force is important to recurisvely create path if needed.
    New-Item $regpath -Force
}
Set-ItemProperty -Path $regpath -Name FullPath -Value 0
Set-ItemProperty -Path $regpath -Name FullPathAddress -Value 1
$regpath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
if( ! (Test-Path -Path $regpath)) {
    New-Item $regpath -Force
}
Set-ItemProperty -Path $regpath -Name NavPaneShowAllFolders -Value 1
Set-ItemProperty -Path $regpath -Name NavPaneExpandToCurrentFolder -Value 1
Set-ItemProperty -Path $regpath -Name AlwaysShowMenus -Value 1
Set-ItemProperty -Path $regpath -Name Hidden -Value 1
Set-ItemProperty -Path $regpath -Name HideDrivesWithNoMedia -Value 0
Set-ItemProperty -Path $regpath -Name HideFileExt -Value 0
Set-ItemProperty -Path $regpath -Name ShowSuperHidden -Value 1
Set-ItemProperty -Path $regpath -Name ForceClassicControlPanel -Value 1
Set-ItemProperty -Path $regpath -Name AutoCheckSelect -Value 0
Set-ItemProperty -Path $regpath -Name EnableAutoTray -Value 0
Set-ItemProperty -Path $regpath -Name MapNetDrvBtn -Value 1
#Show all icons on status bar
$regpath2 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\ControlPanel"
if( ! (Test-Path -Path $regpath2)) {
    #-Force is important to recurisvely create path if needed.
    New-Item $regpath2 -Force
}
Set-ItemProperty -Path $regpath2 -Name AllItemsIconView -Value 1 -Force
#Setup Environment Variables
Set-EnvironmentVariable -Name Home -Value $Env:USERPROFILE -Target User 
Set-EnvironmentVariable -Name Home -Value $Env:USERPROFILE -Target Machine
Set-EnvironmentVariable -Name HOMEDRIVE -Value $Env:SYSTEMDRIVE -Target User 
Set-EnvironmentVariable -Name HOMEDRIVE -Value $Env:SYSTEMDRIVE -Target Machine
Set-EnvironmentVariable -Name TEST_RESULTS -Value "$($Env:USERPROFILE)\Documents\$($FolderName)\Test_Results" -Target User 
Set-EnvironmentVariable -Name TEST_RESULTS -Value "$($Env:USERPROFILE)\Documents\$($FolderName)\Test_Results" -Target Machine
Set-EnvironmentVariable -Name TEST_SRCFILES -Value "C:\Automation\DGAutomation\TEST_DATA\SRC" -Target User 
Set-EnvironmentVariable -Name TEST_SRCFILES -Value "C:\Automation\DGAutomation\TEST_DATA\SRC" -Target Machine
$Path = $Env:Path
$Path += ";C:\Python27;C:\Python27\Scripts;C:\tools;C:\tools\AgentTools64;C:\Program Files\Git\bin;C:\Program Files\Git\usr\bin;"
Set-EnvironmentVariable -Name PATH -Value $Path -Target Machine
#PSG remote runner vars
Set-EnvironmentVariable -Name PSGROOTDIR -Value "c:\Automation_PSG" -Target User 
Set-EnvironmentVariable -Name PSGROOTDIR -Value "c:\Automation_PSG" -Target Machine

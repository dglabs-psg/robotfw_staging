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
#   ##   RUNNING DEPLOYMENT TASK: STEP 2                                     ##
#   ###########################################################################
##End region <Initialise> ============================================================
"@
Write-Host $scriptblock -ForegroundColor yellow  

Write-Host "`r`nSetting up::: Robot Framework components and finishing off deployment...`r`n" -for cyan

#Temporarily stop defender
Set-MpPreference -DisableRealtimeMonitoring $true
Set-MpPreference -DisableIOAVProtection $true

#Set alias
New-Alias -Name git -Value "$Env:ProgramFiles\Git\bin\git.exe" 

#redirect git stdout
$env:GIT_REDIRECT_STDERR = '2>&1'

## Deploy Python27
Write-Host "Deploying Python 2.7 Interpretor..." -for cyan
Invoke-WebRequest -Uri "https://www.python.org/ftp/python/2.7.13/python-2.7.13.msi" -OutFile "C:\deploy\python-2.7.13.x86.msi"
$ArgumentList = "/i c:\deploy\python-2.7.13.x86.msi ALLUSERS=1 ADDLOCAL=ALL /qn"
$ExitCode = (Start-Process -FilePath "MsiExec.exe" -ArgumentList $ArgumentList -Wait -PassThru).ExitCode
if($ExitCode -eq 0){Write-Host "Success: Code=$ExitCode" -for green}else{Write-Host "Failed: Code=$ExitCode" -for red}

##update pip
Write-Host "Updating pip..." -for cyan
&c:\python27\python -m pip install --upgrade pip

#Deploy Python 2.7 ArgParse Mod
Write-Host "Deploying Python 2.7 ArgParse mod..." -for cyan
&C:\Python27\Scripts\pip.exe install argparse
Write-Host "Success: Code=0" -for green

#Deploy Python 2.7 PyWin32 Mod
Write-Host "Deploying Python 2.7 PyWin32 mod..." -for cyan
&C:\Python27\Scripts\pip.exe install pywin32==223
Write-Host "Success: Code=0" -for green

#AutoIT3
Write-Host "Deploying AutoIt3..." -for cyan
Invoke-WebRequest -Uri "https://www.autoitscript.com/cgi-bin/getfile.pl?autoit3/autoit-v3-setup.exe" -OutFile "C:\deploy\autoit-v3-setup.exe"
$ArgumentList = "/S"
$ExitCode = (Start-Process -FilePath "c:\deploy\autoit-v3-setup.exe" -ArgumentList $ArgumentList -Wait -PassThru).ExitCode
if($ExitCode -eq 0){Write-Host "Success: Code=$ExitCode" -for green}else{Write-Host "Failed: Code=$ExitCode" -for red}

#AutoIt Library 1.1
Write-Host "Deploying AutoIt Library 1.1. from Google..." -for cyan
Invoke-WebRequest -Uri "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/robotframework-autoitlibrary/AutoItLibrary-1.1.zip" -OutFile "C:\deploy\AutoItLibrary-1.1.zip"
Expand-Archive -LiteralPath "C:\deploy\AutoItLibrary-1.1.zip" -DestinationPath "$Env:SYSTEMDRIVE\"
#Setup AutoIt Library 1.1
&cmd.exe /c "cd $Env:SYSTEMDRIVE\AutoItLibrary-1.1\ & c:\python27\python.exe `"$Env:SYSTEMDRIVE\AutoItLibrary-1.1\setup.py`" install"
Write-Host "Success: Code=0" -for green

#ROBOT FRAMEWORK
##install robotframework & selenium library
Write-Host "Deploying robotframework & selenium library..." -for cyan
pip install robotframework-remoterunner
pip install robotframework==3.1.1
pip install wheel
pip install wxPython==4.1.0
pip install robotframework==3.1.1
pip install robotframework-archivelibrary==0.4.0
pip install robotframework-autoitlibrary==1.1.0
pip install decorator
pip install robotframework-selenium2library==1.8.0
pip install pyodbc
pip install jdcal
pip install et-xmlfile
pip install openpyxl
pip install xlwt
pip install xlrd
pip install xlutils
pip install checksumdir
pip install xlwings
pip install psutil


#FETCH AUTOMATION_PSG LIBRARY
Write-Host "Deploying AUTOMATION_PSG LIBRARY (requires manual login to GIT)..." -for cyan
Set-Service ssh-agent -StartupType Manual
ssh-agent -s
$cmdmsg = '!!MANUAL INTERACTION NECESSARY!!'
$cmdtorun = 'ssh-keygen -b 4096 -t rsa -f id_rsa -q -N ""Your_passphrase_here""'
$shell = new-object -comobject "WScript.Shell"
$shell.popup("Run this command in another Administrator PS window and then click OK to continue on.`r`n`r`n$cmdtorun",0,$cmdmsg,0)
$keyPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath('~/.ssh')
ssh-agent -s
ssh-add "$keyPath\id_rsa"
$cmdmsg = '!!NEW SSH KEYPAIR CREATED!!'
$cmdtorun = Get-Content "$keyPath\id_rsa.pub"
Start-Process notepad.exe "$keyPath\id_rsa.pub" -WindowStyle Minimized
$shell.popup("Copy this public key into GITHUB as a new deploy token for the robotfw repo. and then click OK to continue on. Notepad will have opened (minimised) just copy/paste. `r`n`r`n NOTE: Just read only write is not necessary and a risk.`r`n`r`n$cmdtorun",0,$cmdmsg,0)
mkdir c:/Automation_PSG
cd c:/Automation_PSG
git init

#TRYING TO GET AROUND 1GB RAM issue with GIT. GIT needs more than 1G
#set GIT_TRACE_PACKET=1
#set GIT_TRACE=1
#set GIT_CURL_VERBOSE=1
#git config pack.packSizeLimit 1g
#git config pack.deltaCacheSize 1g
#git config pack.windowMemory 1g
#git config core.packedGitLimit 1g
#git config core.packedGitWindowSize 1g

$mygit = Read-Host "Enter your git ssh repository string (e.g., git@github.com:<MYORG>/<MYREPO>.git)" -AsSecureString
git pull $mygit


#add exclusions and set defender back on
Add-MpPreference -ExclusionPath "C:\Automation_PSG";
Add-MpPreference -ExclusionPath "C:\AutoItLibrary-1.1";
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -DisableIOAVProtection $false

Write-Host "[COMPLETED DEPLOYMENT]: Sleeping for 60 seconds before final reboot..." -for green
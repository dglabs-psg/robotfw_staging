[cmdletbinding()]
param(
[Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=0)] 
[string]$help=$false
)
<# 
.Synopsis 
   Installer script to stage a virtual machine with::: Robot Framework and DGAutomation libraries. 
   This is the _LITE_ version for remote runner purposes and subset of re-rewritten use cases and libraries to support remote
   execution.
.DESCRIPTION 
   This script will make necessary changes to the OS, install required packages.    
.PARAMETER <none>
   The are no parameters other then -help to display this blob. 
.EXAMPLE 
   powershell Provision_RPA.ps1 
.NOTES
 ##region <Initialise> ===========================================================
 # © 2021 Digital Guardian
 # NAME:	Provision_RPA.ps1
 # TYPE:	MASTER Script with dependencies (functions)
 # AUTHOR:	Daniel Baldree, Digital Guardian, dbaldree@digitalguardian.com
 # STARTED:	16/06/2021
 # PURPOSE: Stage a virtual machine with::: Robot Framework and DGAutomation libraries
 # DEPENDENCIES: Yes calls other ps1 files (MODULES folder).
 # VERSION:	1.0.0
 # 			| | +-- Bug fix level
 # 			| +---- Feature update level
 # 			+------ Major version level
 ## <Version History> =============================================================
 # v1.0.0 | Initial release 16/06/2021
 ## ===============================================================================
#>
cls
cd c:\deploy
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
#   NAME:`t`tProvision_RPA.ps1
#   MASTER `t`tScript with dependencies (functions)
#   AUTHOR:`t`tDaniel Baldree, Digital Guardian -
#   `t`t`t- dbaldree@digitalguardian.com
#   STARTED:`t`t16/06/2021
#   PURPOSE:`t`tStage a virtual machine with::: Robot Framework and - 
#   `t`t`t- DGAutomation libraries.
#   DEPENDENCIES:`tYes calls other ps1 files (MODULES folder).
#   VERSION:`t`t1.0.0.x
#   `t`t`t| | | +- Last Modified
#   `t`t`t| | +--  Bug fix level
#   `t`t`t| +----  Feature update level
#   `t`t`t+------  Major version level
##[ <Version History> ================================================================
# `tv1.0.0 | Initial release 16/06/2021
## end <Version History> ]============================================================
##[ <Execution:> =====================================================================
# `tpowershell Provision_RPA.ps1 (-help $true optional)
## end <Execution> ]==================================================================
##[ <Steps:> =========================================================================
# `t--Each step requires a reboot checkpoint--:
# `t1.`tProvision Env. vars, user folders, explorer settings & deploy software
# `t2.`tDeploy Robot Framework & DGAutomation Libraries
## end <Steps> ]======================================================================
##End region <Initialise> ============================================================
"@
#\ARGUMENT Handler
if ($help -eq $True) {
   Write-Host $scriptblock -ForegroundColor yellow    
}
#actually I want to show always...
Write-Host $scriptblock -ForegroundColor yellow    
Write-Host "`r`n...initialising..." -ForegroundColor magenta 
Sleep 15

#Start Transcript service
Start-Transcript -Path "C:\Deploy\Provision_RPA.log" -Append

################################################## [ OS VALIDATOR ################################################################

#PSG Performs this task so will already have prepared valid server.
$SupportedOS = $true

################################################## OS VALIDATOR ] (end) #############################################################
if($SupportedOS -eq $true){

    $Path = "SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FileExts\.jpeg\UserChoice"
    $SubKey = [Microsoft.Win32.Registry]::CurrentUser.OpenSubKey($Path, [Microsoft.Win32.RegistryKeyPermissionCheck]::ReadWriteSubTree, [System.Security.AccessControl.RegistryRights]::ChangePermissions)
    $Acl = $SubKey.GetAccessControl()
    $RemoveAcl = $Acl.Access | Where-Object {$_.AccessControlType -eq "Deny"}
    $Acl.RemoveAccessRule($RemoveAcl)
    $SubKey.SetAccessControl($Acl)
    $SubKey.Close()

	#Configure registry checkpoint mechanism
	$regpath = "HKCU:\Software\DigitalGuardian\"
	if(Test-Path($regpath)){}else{New-Item –Path $regpath -Name "RPA" -Force}


	#Functions
	function get-regitem($key, $ValName) {
		$vName = $key.getvaluenames()
		foreach($Name in $vName){
			if($Name -eq $ValName){
				[pscustomobject] @{
					Name = $Name
					Value = $Key.GetValue($ValName)
					Type = $Key.GetValueKind($ValName)
				 }
			}
		}
	}
	function set-regitem($key, $ValName, $Value) {
		Set-ItemProperty -Path $key -Name $ValName -Value $Value 
	}


	#Retrive checkpoint status (if a previous exec has occured)
	$regpath = "HKCU:\Software\DigitalGuardian\RPA"
	$Status = 0; #always assume script has never ran before
	$checkpointHive = Get-Item -path $regpath
	$checkpointStatus = get-regitem $checkpointHive "Status" -ErrorAction SilentlyContinue
	if($checkpointStatus){
		$Status = $checkpointStatus.Value
	}else{
		Set-ItemProperty -Path $regpath -Name "Status" -Value 0 -Type Dword
		$Status = 0 #never run before this
	}

	#Setup steps
	$regpath = "HKCU:\Software\DigitalGuardian\RPA"
	$Step1 = 0; #always assume script has never ran before
	$Step2 = 0; #always assume script has never ran before
	$checkpointHive = Get-Item -path $regpath
	$checkpointStep1 = get-regitem $checkpointHive "Step1" -ErrorAction SilentlyContinue
	$checkpointStep2 = get-regitem $checkpointHive "Step2" -ErrorAction SilentlyContinue


	#Step1 check
	if($checkpointStep1){
		$Step1 = $checkpointStep1.Value
	}else{
		Set-ItemProperty -Path $regpath -Name "Step1" -Value 0 -Type Dword
		$Step1 = 0 #never run before this
	}

	#Step2 check
	if($checkpointStep2){
		$Step2 = $checkpointStep2.Value
	}else{
		Set-ItemProperty -Path $regpath -Name "Step2" -Value 0 -Type Dword
		$Step2 = 0 #never run before this
	}

	#~[start]~~~~~~~~~~~~~~~~~~METHOD OF PROCEDURE~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
	$regpath = "HKCU:\Software\DigitalGuardian\RPA"


	# --- DEPLOYING STEP 1 ----
	if($Step1 -eq 0 -and $Status -eq 0){
		try{
		Write-Host "Starting deployment step 1/2: BASE CONFIG...`r`n" -for cyan
		#...
		C:\Deploy\Modules\Win_Initial.ps1
		#...
		$s1completed = 1;
		}
		catch{
		  Write-Host "An error occurred:"
		  #ScriptStackTrace, Exception, and ErrorDetails
		  Write-Host $_
		  $s1completed = 0;
		  }
		finally{if($s1completed -eq 1){set-regitem $regpath "Status" 1;set-regitem $regpath "Step1" 1;Write-Host "`r`n[STEP 1]: COMPLETED`r`n" -for green; Sleep 300}} #Sleep is to prevent step crawl

	}

	# --- DEPLOYING STEP 2 ----
	if($Step2 -eq 0 -and $Status -eq 1 -and $Step1 -eq 1){
		try{
		Write-Host "Starting deployment step 2/2: Deploying::: Robot Framework...`r`n" -for cyan		
		#...
		C:\Deploy\Modules\Deploy_DGAutomation.ps1
		#...
		$s2completed = 1;
		}
		catch{
		  Write-Host "An error occurred:"
		  #ScriptStackTrace, Exception, and ErrorDetails
		  Write-Host $_
		  $s2completed = 0;
		  }
		finally{if($s2completed -eq 1){$Step2 = 1;set-regitem $regpath "Status" 200;$Status=200;set-regitem $regpath "Step2" 1;Write-Host "`r`n[STEP 2]: COMPLETED`r`n" -for green;}}
	}

	#~[end]~~~~~~~~~~~~~~~~~~METHOD OF PROCEDURE~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#


	#remove script from run path
	if($Status -eq 200){
		#stop transcript service if all steps satisfied
		Stop-Transcript;
	}
} else {
	Stop-Transcript;
}
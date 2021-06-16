#Creates new RPA User/set workgroup/disable oobe
$Username = "jfusco"
$Workgroup = "acelab"
$Password = ConvertTo-SecureString "Bend3r" -AsPlainText -Force
$PasswordClearTxt = "Bend3r"
#Add machine to new workgroup
Add-Computer -WorkGroupName $Workgroup
New-LocalUser $Username -Password $Password -FullName "Robotics User" -Description "Account used for running::: Robot Framework." -AccountNeverExpires
Add-LocalGroupMember -Group "Administrators" -Member $Username
#Disables OOBE Privacy Screen
$RegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OOBE"
$RegParentPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows"
if(Test-Path $RegPath){
	Set-ItemProperty $RegPath "DisablePrivacyExperience" -Value "1" -type DWORD
} else {
	New-Item -Path $RegParentPath -Name OOBE
	Set-ItemProperty $RegPath "DisablePrivacyExperience" -Value "1" -type DWORD
}
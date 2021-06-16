$Locale = "EN-GB"
$TimeZone = "GMT Standard Time"

##set timezone
Write-Host "`r`nSetting Time Zone ($TimeZone)...`r`n" -ForegroundColor Green;
tzutil /s $TimeZone
 
##Set region/Language to UK
Write-Host "`r`nSetting Locale; Region Settings; Language (to $Locale)...`r`n" -ForegroundColor Green;
$RegKeyPath = "HKU:\Control Panel\International"

#Set Location to United Kingdom
Set-WinSystemLocale $Locale
if($Locale -eq 'EN-GB'){
    Set-WinHomeLocation -GeoId 0xF2 #Set-WinHomeLocation -GeoId 0xF2 for (UK)
}
if($Locale -eq 'EN-US'){
    Set-WinHomeLocation -GeoId 0xF4 #Set-WinHomeLocation -GeoId 0xF4 for (US)
}
# Set regional format (date/time etc.) to English (United Kingdon) - this applies to all users
Set-Culture $Locale
# Check language list for non-US input languages, exit if found
Get-WinUserLanguageList
# Set the language list for the user, forcing English (United Kingdom) to be the only language
Set-WinUserLanguageList $Locale -Force
Set-WinUILanguageOverride -Language $Locale
Get-WinUserLanguageList
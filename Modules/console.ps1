##set console layout
$UserCmdKey = "HKCU:\Console\%SystemRoot%_system32_cmd.exe"
if( ! (Test-Path -Path $UserCmdKey)) {
    New-Item $UserCmdKey -Force
}
Set-ItemProperty -Path $UserCmdKey -Name "WindowSize" -Type DWORD -Value 3014804
$UserCmdKey = "HKCU:\Console"
Set-ItemProperty -Path $UserCmdKey -Name "WindowSize" -Type DWORD -Value 3014804
exit 1
# List installed software

# wmic product get identifyingnumber,name

Get-ItemProperty  HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\* `
| Select-Object PSChildName, DisplayName, DisplayVersion, Publisher, InstallDate `
| Sort-Object -Property DisplayName `
| ConvertTo-Csv -NoTypeInformation -Delimiter "`t" `
| % {$_ -replace '"',''} 

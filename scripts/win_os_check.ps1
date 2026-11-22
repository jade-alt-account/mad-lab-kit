# win_os_check.ps1: basic operating system facts on a Windows computer
Get-ComputerInfo -Property OsName, OsVersion, OsLastBootUpTime
Get-Service | Where-Object Status -eq 'Running' | Measure-Object
Get-NetFirewallProfile | Select-Object Name, Enabled
Get-LocalGroupMember -Group 'Administrators'

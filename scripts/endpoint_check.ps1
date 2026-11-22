# endpoint_check.ps1: basic facts about a Windows PC (run in PowerShell)
Get-CimInstance -ClassName Win32_ComputerSystem |
    Select-Object Manufacturer, Model, TotalPhysicalMemory
Get-BitLockerVolume -MountPoint "C:" | Select-Object MountPoint, ProtectionStatus
Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 5

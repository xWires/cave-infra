$ErrorActionPreference = "Stop"

# Remove generated copies of the unattended file
Remove-Item C:\Windows\Panther\unattend.xml, C:\Windows\Panther\Unattend\Unattend.xml -Force -ErrorAction SilentlyContinue

$action = New-ScheduledTaskAction -Execute "C:\Windows\System32\Sysprep\sysprep.exe" -Argument "/generalize /oobe /shutdown /quiet"
Register-ScheduledTask -TaskName Sysprep -Action $action -User SYSTEM -RunLevel Highest -Force | Out-Null
Start-ScheduledTask -TaskName Sysprep

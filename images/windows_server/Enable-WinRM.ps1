$ErrorActionPreference = "Stop"

# WinRM's firewall exception and some auth modes don't work on a Public network profile
Get-NetConnectionProfile | Set-NetConnectionProfile -NetworkCategory Private -ErrorAction SilentlyContinue

# Enable WinRM
Enable-PSRemoting -Force

$cert = New-SelfSignedCertificate `
    -DnsName $env:COMPUTERNAME, 'localhost' `
    -CertStoreLocation Cert:\LocalMachine\My `
    -KeyAlgorithm RSA -KeyLength 2048 -HashAlgorithm SHA256 `
    -NotAfter (Get-Date).AddYears(10)

# Replace the HTTP listener with an HTTPS one
Get-ChildItem WSMan:\localhost\Listener | Where-Object { $_.Keys -contains 'Transport=HTTP' -or $_.Keys -contains 'Transport=HTTPS' } | Remove-Item -Recurse -Force
New-Item -Path WSMan:\localhost\Listener -Transport HTTPS -Address * -CertificateThumbPrint $cert.Thumbprint -Force

Set-Item WSMan:\localhost\Service\Auth\Basic $true
Set-Item WSMan:\localhost\Service\AllowUnencrypted $false
Set-Item WSMan:\localhost\MaxTimeoutms 1800000

# Remove the rule for the insecure listener
Get-NetFirewallRule -DisplayGroup 'Windows Remote Management' -ErrorAction SilentlyContinue | Disable-NetFirewallRule
# Add a rule for the new HTTPS listener
New-NetFirewallRule -DisplayName 'WinRM HTTPS' -Direction Inbound -Protocol TCP -LocalPort 5986 -Action Allow -Profile Any

Set-Service WinRM -StartupType Automatic
Restart-Service WinRM

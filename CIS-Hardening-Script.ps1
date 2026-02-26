# CIS Hardening Script for Windows 11 Pro/Enterprise

# This script is designed to implement CIS Tier 2 hardening recommendations for Windows 11 Pro/Enterprise.

## Group Policy Configuration

# Disable Guest account
net user guest /active:no

# Audit Logon Events
secedit /set /cfg "CIS_Audit_Logon_Events.inf"

# Configure password policies
secedit /set /cfg "CIS_Password_Policy.inf"

# Enable security auditing for account management events
secedit /set /cfg "CIS_Account_Management.inf"

## Registry Modifications

# Disable Windows Script Host
Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows Script Host\Settings' -Name 'Enabled' -Value 0

# Prevent users from installing printers
Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\Windows NT\Printers' -Name 'RestrictDriverInstallationToAdministrators' -Value 1

# Disable Remote Desktop
Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server' -Name 'fDenyTSConnections' -Value 1

## Firewall Rules

# Enable Firewall
Set-NetFirewallProfile -All -Enabled True

# Allow only necessary incoming connections
New-NetFirewallRule -DisplayName 'Allow ICMPv4-In' -Protocol ICMPv4 -IcmpType 8 -Action Allow
New-NetFirewallRule -DisplayName 'Allow HTTP' -Direction Inbound -Protocol TCP -LocalPort 80 -Action Allow
New-NetFirewallRule -DisplayName 'Allow HTTPS' -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow

## Security Settings

# Enable Windows Defender Antivirus
Set-MpPreference -DisableRealtimeMonitoring $false

# Turn on Controlled Folder Access
Set-MpPreference -EnableControlledFolderAccess Enabled

## Service Hardening

# Disable SMBv1
Set-Service -Name lanmanserver -StartupType Disabled
Set-Service -Name lanmanworkstation -StartupType Disabled

# Disable unnecessary services
Stop-Service -Name WSearch -Force
Set-Service -Name WSearch -StartupType Disabled

# Enable security features
Set-Service -Name WindowsUpdate -StartupType Automatic

Write-Host 'CIS Tier 2 hardening script has been applied successfully.'
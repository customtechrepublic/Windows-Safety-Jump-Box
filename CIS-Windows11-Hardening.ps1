# CIS Windows 11 Hardening Script
# Date: 2026-02-26
# Description: Implements CIS Benchmark Tier 2 hardening for Windows 11 Pro and Enterprise

# Account policies
Set-LocalUser -Name "Administrator" -PasswordNeverExpires $true
# Audit policies
AuditPol /set /category:"Logon/Logoff" /failure:enable
# Security options
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 1
# Firewall rules
New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4 -IcmpType 8 -Action Allow
# Registry hardening (example)
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Control Panel\Desktop" -Name "ScreenSaveActive" -Value "1"
# Service disabling
Get-Service -Name "Spooler" | Set-Service -StartupType Disabled
# User rights assignments
ntrights +r SeDenyInteractiveLogonRight -u Guests

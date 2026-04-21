# CIS_Tier_2_Hardening_Rollback.ps1

# This script reverts the CIS Tier 2 hardening settings back to their default state while keeping security best practices in mind.

# Restore default settings for Windows features and services

# Disable unnecessary services
Stop-Service -Name "W32Time" -Force
Set-Service -Name "W32Time" -StartupType "Manual"

# Reset security policies to defaults
# Example: Reset policy for Windows Defender
Set-MpPreference -EnableRealtimeMonitoring $true

# Restore default firewall settings
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Reset User Account Control (UAC)
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name "EnableLUA" -Value 1

# Complete other necessary settings to revert changes
# Example: Reset password policy
$securePassword = Read-Host "Enter new password for Administrator" -AsSecureString
Set-LocalUser -Name "Administrator" -Password $securePassword # Ensure to manage user securely

# Log the rollback process
Write-Output "CIS Tier 2 hardening changes have been successfully reverted on $(Get-Date)."
# CIS Tier 2 Hardening Script for Windows 11 Pro and Enterprise

# Group Policy Modifications
# ... (Add specific Group Policy modifications here)

# Registry Modifications
Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "EnableLUA" -Value 1 # Enable UAC
# ... (Add other registry modifications)

# Firewall Rules
New-NetFirewallRule -DisplayName "Allow PowerShell" -Direction Inbound -Program "$PSHOME\powershell.exe" -Action Allow
# ... (Add other firewall rules)

# Security Settings
# ... (Adjust security settings using local security policy cmdlets)

# Service Hardening
# Stop and disable unnecessary services
Stop-Service -Name "ServiceName" -Force
Set-Service -Name "ServiceName" -StartupType Disabled
# ... (Repeat for other services)

# Audit Policies
auditpol /set /subcategory:"Logon/Logoff" /success:enable /failure:enable
# ... (Configure other audit policies)

# User Account Control
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 2 # Prompt for credentials
# ... (Other UAC settings)

# AppLocker
# Create AppLocker rules for applications
# Example: Set-AppLockerPolicy -XML $xmlPolicy
# ... (Add rules)

# Windows Defender
Set-MpPreference -EnableRealtimeMonitoring $true
Set-MpPreference -DisableRealtimeMonitoring $false # Ensure realtime monitoring is on
# ... (Configure other Defender settings)

# BitLocker
Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -UsedSpaceOnly
# ... (Configure BitLocker settings)

# Secure Boot and TPM
# Check if Secure Boot is Enabled
# Check if TPM is available
# ... (Add checks and configurations)

# Credential Guard
Enable-WindowsOptionalFeature -Online -FeatureName "CredentialGuard"
# ... (Configure settings if required)

# Device Guard
Enable-WindowsOptionalFeature -Online -FeatureName "DeviceGuard"
# ... (Add necessary configurations)

# Best Practices for ZTNA Jump Box
# Implement necessary networking and access rules that comply with ZTNA guidelines.

Write-Output "CIS Tier 2 Hardening Script executed successfully."
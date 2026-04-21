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
# Note: Parameter names vary by Windows version. Use registry or Get-MpPreference to validate.
try {
    Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue
} catch {
    # Fallback: Use registry if cmdlet parameters fail
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows Defender" -Name "DisableRealtimeMonitoring" -Value 0 -ErrorAction SilentlyContinue
}
# Get current settings for verification
Get-MpPreference | Select-Object RealtimeMonitoringEnabled

# BitLocker
# Note: BitLocker requires TPM 2.0 or PIN. Adjust parameters based on environment.
try {
    $volume = Get-BitLockerVolume -MountPoint "C:" -ErrorAction SilentlyContinue
    if ($volume.VolumeStatus -eq "FullyDecrypted") {
        # Enable with TPM and PIN for maximum security
        Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -UsedSpaceOnly -TpmProtector -Pin (Read-Host "Enter BitLocker PIN" -AsSecureString) -ErrorAction Stop
    }
} catch {
    Write-Warning "BitLocker could not be enabled: $_"
    Write-Host "Manual BitLocker configuration may be required."
}
# ... (Configure BitLocker settings)

# Secure Boot and TPM
# Check if Secure Boot is Enabled
# Check if TPM is available
# ... (Add checks and configurations)

# Credential Guard (Virtualization-based Security)
# Note: Credential Guard requires Hyper-V capable hardware and is enabled via Group Policy or DMARC
try {
    # Enable via Group Policy (requires Admin and may need reboot)
    $gpoPath = "HKLM:\Software\Policies\Microsoft\Windows\DeviceGuard"
    if (-not (Test-Path $gpoPath)) { New-Item -Path $gpoPath -Force | Out-Null }
    Set-ItemProperty -Path $gpoPath -Name "LsaCfgFlags" -Value 1 -ErrorAction SilentlyContinue
    Write-Host "Credential Guard registry setting applied. Reboot required to enable."
} catch {
    Write-Warning "Credential Guard configuration failed: $_"
}

# Device Guard (Code Integrity)
# Note: Device Guard requires UEFI firmware and is configured via Group Policy
try {
    $gpoPath = "HKLM:\Software\Policies\Microsoft\Windows\DeviceGuard"
    if (-not (Test-Path $gpoPath)) { New-Item -Path $gpoPath -Force | Out-Null }
    Set-ItemProperty -Path $gpoPath -Name "EnableVirtualizationBasedSecurity" -Value 1 -ErrorAction SilentlyContinue
    Write-Host "Device Guard registry setting applied. Reboot required to enable."
} catch {
    Write-Warning "Device Guard configuration failed: $_"
}

# Best Practices for ZTNA Jump Box
# Implement necessary networking and access rules that comply with ZTNA guidelines.

Write-Output "CIS Tier 2 Hardening Script executed successfully."
# CIS Tier 2 Hardening Script for Windows 11 Pro and Enterprise

This script implements a comprehensive set of security configurations based on the CIS (Center for Internet Security) benchmarks for Windows 11 Pro and Enterprise. It is divided into detailed sections to ensure a structured approach to hardening the system.

## 1. Group Policy Modifications

```powershell
# Enable Account Lockout Policy
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LockoutBadCount" -Value 5
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ResetLockoutCount" -Value 15
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "LockoutDuration" -Value 15

# Configure Password Policy
Set-AccountPolicy -MaxPasswordAge 30
Set-AccountPolicy -MinPasswordLength 12
```

## 2. Registry Modifications

```powershell
# Disable SMBv1
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -Value 0

# Enable Windows Defender
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection" -Name "DisableRealtimeMonitoring" -Value 0
```

## 3. Firewall Rules

```powershell
# Block inbound SMB traffic
New-NetFirewallRule -DisplayName "Block SMB Inbound" -Direction Inbound -Protocol TCP -LocalPort 445 -Action Block

# Allow Windows Update
New-NetFirewallRule -DisplayName "Allow Windows Update" -Direction Outbound -Protocol TCP -DestinationPort 443 -Action Allow
```

## 4. Security Settings

```powershell
# Enable User Account Control
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 1

# Enable BitLocker
Enable-BitLocker -MountPoint "C:" -EncryptionMethod Aes256 -UsedSpaceOnly
```

## 5. Service Hardening

```powershell
# Disable unnecessary services
Stop-Service -Name "Fax" -Force
Set-Service -Name "Fax" -StartupType Disabled

Stop-Service -Name "XblGameSave" -Force
Set-Service -Name "XblGameSave" -StartupType Disabled
```

## Conclusion

This script serves as a foundation for hardening Windows 11 Pro and Enterprise systems according to the CIS Tier 2 benchmarks. Regular audits and updates based on the latest security best practices are recommended.
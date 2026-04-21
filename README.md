```
   ╔═══════════════════════════════════════════════════════════════════════════╗
   ║                                                                           ║
   ║        ██████╗ ███████╗██████╗ ██╗   ██╗██████╗ ██╗     ██╗ ██████╗       ║
   ║        ██╔════╝ ██╔════╝██╔══██╗██║   ██║██╔══██╗██║     ██║██╔════╝      ║
   ║        ██║  ███╗█████╗  ██████╔╝██║   ██║██████╔╝██║     ██║██║           ║
   ║        ██║   ██║██╔══╝  ██╔═══╝ ██║   ██║██╔══██╗██║     ██║██║           ║
   ║        ╚██████╔╝███████╗██║     ╚██████╔╝██████╔╝███████╗██║╚██████╗      ║
   ║         ╚═════╝ ╚══════╝╚═╝      ╚═════╝ ╚═════╝ ╚══════╝╚═╝ ╚═════╝      ║
   ║                                                                           ║
   ║              🛡️  CUSTOM PC REPUBLIC  🛡️                                  ║
   ║         IT Synergy Energy for the Republic                                ║
   ║                                                                           ║
   ║     CIS Level 2 Hardened Windows Image Builder & Deployment Suite         ║
   ║                                                                           ║
   ╚═══════════════════════════════════════════════════════════════════════════╝
```
<img width="800" height="436" alt="brandlogo" src="https://github.com/user-attachments/assets/6f4dde71-852a-4305-8f16-ed1c4527cab8" />

# CIS Level 2 Hardened Windows Image Builder & Deployment Suite

**🛡️ Custom PC Republic - Enterprise-grade hardened Windows imaging solution**
<img width="800" height="436" alt="brandlogo" src="https://github.com/user-attachments/assets/974df4cc-8dfa-4137-8be3-5db24df2e64e" />



> *"IT Synergy Energy for the Republic"* - Secure, auditable, and repeatable Windows deployments with incident response capabilities.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Architecture](#architecture)
- [Usage Workflows](#usage-workflows)
- [Deployment Options](#deployment-options)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Custom PC Republic Branding](#custom-pc-republic-branding)
- [Contributing](#contributing)

---

## Overview

This project provides a **complete solution** for:

✅ **Creating** CIS Level 2 hardened Windows installations  
✅ **Capturing** and generalizing customized Windows configurations  
✅ **Distributing** hardened images in multiple formats (WIM, VHDX, ISO)  
✅ **Deploying** to physical systems, VMs, USB media, and cloud platforms  
✅ **Securing** against BIOS/UEFI malware and persistence threats  
✅ **Auditing** CIS compliance post-deployment  
✅ **Rolling back** hardening if issues arise  

### Key Differentiators

- **Two workflow options**: Fully automated pipeline OR guided manual process
- **Three hardening profiles**: Mandatory Only, Level 1 Complete, or Level 1+2 Complete
- **Multi-format output**: WIM, VHDX, ISO for maximum flexibility
- **Forensics-capable Windows PE**: Boot media for incident response
- **BitLocker integration**: Full disk encryption with TPM validation
- **Rollback capability**: Restore pre-hardening configuration if needed
- **Enterprise security**: AppLocker + ASR rules + audit logging
- **Custom PC Republic Branded**: Professional branding throughout

---

## Features

### 🔐 Security Hardening

| Feature | Description | Status |
|---------|-------------|--------|
| **CIS Benchmarks** | L1 & L2 controls for Windows 11/Server 2022 | ✅ Implemented |
| **User Account Control** | UAC hardening with secure desktop enforcement | ✅ Configured |
| **Firewall** | Windows Defender Firewall with default block outbound | ✅ Configured |
| **Windows Defender** | Real-time monitoring + Cloud protection + Network protection | ✅ Enabled |
| **Exploit Protection** | ASLR, DEP, CFG, SEH system-wide | ✅ Enforced |
| **Credential Guard** | Hypervisor-enforced credentials protection | ✅ Enabled |
| **Device Guard** | Hypervisor-enforced code integrity | ✅ Enabled |
| **SMB Hardening** | SMBv1 disabled, packet signing required | ✅ Enforced |
| **BitLocker** | Full-disk encryption with TPM 2.0 | ✅ Optional |
| **AppLocker** | Application whitelisting policies | ✅ Customizable |
| **ASR Rules** | Attack surface reduction rules | ✅ Included |
| **Audit Logging** | Comprehensive event logging | ✅ Enabled |
| **Secure Boot** | UEFI Secure Boot verification | ✅ Validated |

### 📦 Image Formats

- **WIM** - Windows Imaging Format (primary, smallest)
- **VHDX** - Hyper-V virtual disk format
- **ISO** - Bootable installation media
- **Boot.wim** - Windows PE kernel for deployment

### 🚀 Deployment Methods

| Method | Use Case | Status |
|--------|----------|--------|
| **USB Media** | Physical systems, bare metal, disaster recovery | ✅ Supported |
| **Network PXE** | Enterprise deployment via DHCP/TFTP | ✅ Framework ready |
| **VM Direct** | Hyper-V, VMware, Azure VMs | ✅ Supported |
| **Cloud Upload** | Azure Blob Storage, AWS S3 | ✅ Framework ready |
| **Docker/Container** | Development environments | ✅ Framework ready |

### 🔄 Workflows

**Workflow 1: Automated Pipeline**
```
Packer VM Build → CIS Hardening (Auto) → Sysprep → WIM Capture → Format Conversion → Output
```

**Workflow 2: Guided Manual Process**
```
Create VM → Install Software → CIS Hardening (Interactive) → Sysprep → WIM Capture → Format Conversion → Output
```

**Workflow 3: Incident Response**
```
Boot Windows PE USB → Run Deploy-Image.ps1 → Clean System Deploy → Forensics Logging
```

---

## Prerequisites

### System Requirements

| Component | Requirement |
|-----------|-------------|
| **OS** | Windows 11 Pro/Enterprise or Windows Server 2022 |
| **RAM** | 16GB minimum (32GB recommended) |
| **Storage** | 100GB free space minimum |
| **CPU** | 4+ cores, virtualization capable |
| **TPM** | TPM 2.0 (for BitLocker) |

### Software Prerequisites

```powershell
# Install Windows ADK (Assessment and Deployment Kit)
# Download from: https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install

# Install Packer (optional, for automated builds)
# Download from: https://www.packer.io/downloads

# Install DISM (included with Windows, but verify):
dism /?

# Verify PowerShell version (requires 5.0+)
$PSVersionTable.PSVersion
```

### Permissions

- ✅ Local Administrator access
- ✅ Ability to create/manage Hyper-V VMs (optional)
- ✅ 30GB+ free disk space

---

## Quick Start

### Option 1: Automated Pipeline (Fastest)

```powershell
# Step 1: Configure and run automated build
cd hardening
.\Build-Hardened-Image-Full.ps1 `
  -OSType "Windows11-Enterprise" `
  -CISLevel "Mandatory" `
  -OutputDir "C:\output"

# Step 2: Deploy to target system
cd ..\deployment
.\Deploy-Image.ps1 `
  -ImagePath "C:\output\v1.0-L2-20260419-build42\install.wim" `
  -TargetDisk "\\?\PhysicalDrive1" `
  -EnableBitLocker $true

# Step 3: Verify compliance
cd ..\hardening
.\Verify-CIS-Compliance.ps1 -ExportReport "compliance.csv"
```

### Option 2: Guided Manual Process

```powershell
# Step 1: Create VM with your customizations
# - Install Windows 11 Enterprise
# - Install required software
# - Configure settings

# Step 2: Apply hardening (interactive mode)
cd hardening
.\Apply-CIS-Interactive.ps1 -Profile "Mandatory"
# (Review each setting before applying)

# Step 3: Prepare and capture
cd ..\capture
.\Prepare-System-for-Capture.ps1
.\Capture-Installation.ps1 -OutputPath "C:\output\custom.wim"

# Step 4: Deploy to targets
cd ..\deployment
.\Deploy-Image.ps1 -ImagePath "C:\output\custom.wim" -TargetDisk "C:"
```

### Option 3: Incident Response (USB Reimage)

```powershell
# Step 1: Create Windows PE boot USB
cd deployment
.\Create-Windows-PE.ps1 -OutputPath "C:\output\boot.iso" -IncludeForensics $true
.\Create-Deployment-USB.ps1 -ISOPath "C:\output\boot.iso" -USBDrive "E:"

# Step 2: Boot compromised system from USB
# (Instructions on screen)

# Step 3: Run clean image deployment from PE
# (Automated forensics logging included)

# Step 4: Post-deployment verification
.\Verify-CIS-Compliance.ps1
```

---

## Architecture

### Directory Structure

```
Windows-Safety-Jump-Box/
│
├── hardening/                    # CIS hardening scripts
│   ├── CIS_Level2_Mandatory.ps1         # Mandatory L2 controls only
│   ├── CIS_Level1+2_Complete.ps1        # All L1+L2 controls
│   ├── CIS_Rollback.ps1                 # Restore pre-hardening state
│   ├── Apply-CIS-Automated.ps1          # Run without prompts
│   ├── Verify-CIS-Compliance.ps1        # Audit compliance status
│   ├── configs/                  # JSON configuration templates
│   └── rollback/                 # Rollback snapshots
│
├── capture/                      # Image capture & customization
│   ├── Prepare-System-for-Capture.ps1   # Pre-capture cleanup
│   ├── Capture-Installation.ps1         # Sysprep orchestration
│   └── Convert-Image-Formats.ps1        # WIM→VHDX→ISO
│
├── deployment/                   # Deployment & imaging
│   ├── Deploy-Image.ps1                 # DISM deployment
│   ├── Create-Windows-PE.ps1            # Boot media builder
│   ├── Create-Deployment-USB.ps1        # USB creation tool
│   ├── Enable-BitLocker.ps1             # BitLocker configuration
│   ├── Post-Deployment-Tasks.ps1        # Final setup
│   └── forensics/                # Incident response tools
│
├── orchestration/                # Main pipelines
│   ├── Build-Hardened-Image-Full.ps1    # Automated full pipeline
│   ├── Build-Hardened-Image-Manual.ps1  # Guided manual workflow
│   └── Deploy-To-System.ps1             # Deploy with all hardening
│
├── build/                        # Image building tools
│   ├── packer/                   # Packer configurations
│   │   ├── windows11-enterprise.pkr.hcl
│   │   ├── windows11-pro.pkr.hcl
│   │   ├── windows-server-2022.pkr.hcl
│   │   └── provisioners/         # VM setup scripts
│   └── adk/                      # Windows ADK scripts
│
├── security-stack/               # Advanced security features
│   ├── AppLocker/                # Application whitelisting
│   └── ASR-Rules/                # Attack surface reduction
│
├── tests/                        # Compliance & functionality tests
│   ├── Test-CIS-Compliance.ps1
│   ├── Test-AppLocker.ps1
│   └── Test-BitLocker.ps1
│
├── cloud/                        # Cloud storage integration
│   ├── Sync-To-Cloud.ps1
│   ├── terraform/                # IaC for cloud resources
│   └── deploy/                   # Cloud deployment scripts
│
├── docs/                         # Documentation
│   ├── ARCHITECTURE.md           # Design document
│   ├── SECURITY-NOTES.md         # Malware/BIOS defense
│   ├── DEPLOYMENT-GUIDE.md       # Deployment procedures
│   ├── BRANDING.md               # Custom PC Republic branding
│   └── TROUBLESHOOTING.md        # Common issues
│
├── output/                       # Build artifacts
│   └── v1.0-L2-20260419-build42/
│       ├── install.wim           # Primary image
│       ├── install.vhdx          # Hyper-V format
│       ├── install.iso           # Bootable ISO
│       ├── boot.iso              # Windows PE boot media
│       ├── MANIFEST.json         # Build metadata
│       └── COMPLIANCE-REPORT.txt # Audit results
│
└── README.md                     # This file
```

---

## Usage Workflows

### Workflow A: Build & Capture Customized Setup

Perfect for: Creating a standardized corporate image with pre-installed software

```powershell
# 1. Create base VM
packer build build/packer/windows11-enterprise.pkr.hcl

# 2. Boot VM, install software, configure
# ... manual customization ...

# 3. Apply CIS hardening
cd hardening
.\Apply-CIS-Automated.ps1 -Profile "Mandatory"

# 4. Prepare and capture
cd ..\capture
.\Prepare-System-for-Capture.ps1
.\Capture-Installation.ps1 -OutputPath "C:\output\corporate-image.wim"

# 5. Convert to formats
.\Convert-Image-Formats.ps1 `
  -SourceWIM "C:\output\corporate-image.wim" `
  -OutputDir "C:\output\v1.0"

# 6. Deploy to fleet
foreach ($computer in @("PC01", "PC02", "PC03")) {
    .\Deploy-Image.ps1 `
      -ImagePath "C:\output\v1.0\install.wim" `
      -TargetDisk "\\$computer\C$" `
      -EnableBitLocker $true
}
```

### Workflow B: Incident Response (Clean Reimage)

Perfect for: Removing malware, resetting compromised systems to known good state

```powershell
# 1. Create Windows PE USB boot media
cd deployment
.\Create-Windows-PE.ps1 -OutputPath "C:\output\boot.iso" -IncludeForensics $true

# 2. Write to USB (use Rufus or PowerShell)
# Insert USB drive, run:
.\Create-Deployment-USB.ps1 -ISOPath "C:\output\boot.iso" -USBDrive "E:"

# 3. Boot compromised system from USB
# (Follow on-screen instructions)

# 4. Deploy clean hardened image
# (In Windows PE environment)
.\Deploy-Image.ps1 `
  -ImagePath "\\networkshare\install.wim" `
  -TargetDisk "C:" `
  -EnableBitLocker $true

# 5. Forensics automatically logged
# Review: C:\Windows\System32\winevt\Logs\System.evtx
```

### Workflow C: Compliance Verification

Perfect for: Auditing systems, generating compliance reports

```powershell
# Run compliance scan
cd hardening
.\Verify-CIS-Compliance.ps1 -ExportReport "compliance-20260419.csv"

# Output includes:
# - CIS control status (PASS/FAIL)
# - Compliance percentage
# - Detailed findings
# - Recommendations

# Import to Excel/Splunk for reporting
Import-Csv "compliance-20260419.csv" | Format-Table
```

### Workflow D: Rollback (If Issues Arise)

Perfect for: Reverting hardening if applications break

```powershell
# List available rollback points
cd hardening
.\CIS_Rollback.ps1 -List

# Restore specific rollback point
.\CIS_Rollback.ps1 -RollbackFile "rollback/rollback-20260419-120000.json"

# System reboots with previous configuration restored
```

---

## Deployment Options

### Option 1: USB Media Deployment

```powershell
# Create bootable USB with Windows PE
.\Create-Deployment-USB.ps1 `
  -ISOPath "C:\output\boot.iso" `
  -USBDrive "E:" `
  -IncludeFirmware "UEFI"

# Insert USB, boot, run:
# .\Deploy-Image.ps1 -ImagePath "install.wim" -TargetDisk "C:"
# System reboots with fresh hardened image
```

### Option 2: Network Deployment (PXE)

```powershell
# Copy WIM to network share
Copy-Item "C:\output\install.wim" "\\fileserver\deploymentshare\"

# Deploy via MDT/SCCM or script:
.\Deploy-Image.ps1 `
  -ImagePath "\\fileserver\deploymentshare\install.wim" `
  -TargetDisk "C:" `
  -EnableBitLocker $true
```

### Option 3: VM Deployment

```powershell
# Hyper-V
New-VM -Name "HardenedWorkstation" -VHDPath "C:\output\install.vhdx" -Generation 2
Start-VM "HardenedWorkstation"

# VMware
# Load install.vhdx as data disk in VMware Converter, deploy to vSphere

# Azure
az vm create \
  --resource-group "YourRG" \
  --name "hardened-vm" \
  --image "C:\output\install.vhd" \
  --os-type windows
```

### Option 4: Cloud Storage Sync

```powershell
# Sync to Azure Blob Storage
.\cloud\Sync-To-Cloud.ps1 `
  -Provider "Azure" `
  -StorageAccount "yourStorage" `
  -ContainerName "hardened-images" `
  -LocalPath "C:\output\v1.0"

# Sync to AWS S3
.\cloud\Sync-To-Cloud.ps1 `
  -Provider "AWS" `
  -BucketName "hardened-images" `
  -LocalPath "C:\output\v1.0"
```

---

## Security Considerations

### BIOS/UEFI Malware Protection

✅ **Protection Method:**
- Windows PE boots independently of installed OS → bypasses infected bootloader
- Deployment writes directly to MBR/GPT, overwriting any BIOS malware
- UEFI Secure Boot validation prevents unsigned code execution
- TPM attestation verifies system integrity

✅ **Additional Hardening:**
```powershell
# Enable UEFI Secure Boot
# Verify TPM 2.0 presence
Get-WmiObject -Class Win32_Tpm

# Validate boot integrity
Confirm-SecureBootUEFI
```

### Malware Persistence Prevention

✅ **Built-in Defenses:**
- Complete disk overwrite (not selective file restoration)
- BitLocker prevents offline disk modifications
- ASR rules block common persistence techniques:
  - WMI event subscriptions
  - Registry autorun keys
  - Task Scheduler exploitation
  - Startup folder modifications

✅ **Incident Response:**
```powershell
# Boot from clean Windows PE USB
# Deploy fresh hardened image over compromised drive
# Forensics automatically logged during deployment
# Review System Event Log for suspicious activity

Get-EventLog -LogName System -After (Get-Date).AddDays(-7) | Select-Object EventID, Message
```

### BitLocker Best Practices

✅ **Recommended Configuration:**
```powershell
# Enable BitLocker with TPM protector
.\Enable-BitLocker.ps1 -MountPoint "C:" `
  -RecoveryKeyPath "C:\BitLockerRecovery"

# Backup recovery keys to secure location
# Recommended: Azure Key Vault, LastPass, Password Manager

# Verify encryption status
Get-BitLockerVolume
```

---

## CIS Hardening Profiles

### Profile 1: Mandatory (Level 2 Critical Only)

**Use Case:** Minimal, targeted hardening for compatibility  
**Time to Deploy:** 5-10 minutes  
**Controls:** ~25 mandatory security settings

```powershell
.\Apply-CIS-Automated.ps1 -Profile "Mandatory"
```

**Includes:**
- ✅ UAC enforcement
- ✅ Firewall configuration
- ✅ Windows Defender real-time monitoring
- ✅ Audit policy enforcement
- ✅ Service hardening (DiagTrack, RemoteRegistry disabled)

### Profile 2: Complete (Level 1 + 2)

**Use Case:** Maximum security for high-value systems  
**Time to Deploy:** 15-20 minutes  
**Controls:** ~60+ security settings

```powershell
.\Apply-CIS-Automated.ps1 -Profile "Complete"
```

**Includes:**
- ✅ All Mandatory controls
- ✅ SMB hardening (v1 disabled, signing required)
- ✅ Network security parameters
- ✅ Credential Guard + Device Guard
- ✅ Exploit Protection system-wide
- ✅ Advanced audit logging
- ✅ AppLocker policies
- ✅ ASR rules

---

## Troubleshooting

### Issue: "BitLocker requires TPM 2.0"

```powershell
# Check TPM status
Get-WmiObject -Class Win32_Tpm -Namespace root\cimv2\security\microsofttpm

# If missing, enable in BIOS/UEFI:
# - Reboot and enter BIOS (Del/F2/F10 during startup)
# - Navigate to Security > TPM Settings
# - Enable TPM 2.0
# - Save and reboot

# For VMs, enable vTPM:
# Hyper-V: Generation 2 VMs have vTPM automatically
# VMware: VM > Settings > Add TPM Device
# Azure: Supported on newer VM sizes
```

### Issue: "Secure Boot not available"

```powershell
# Check UEFI firmware
Confirm-SecureBootUEFI

# To enable Secure Boot:
# 1. Enter BIOS/UEFI (Del/F2/F10 during startup)
# 2. Navigate to Boot Settings
# 3. Set boot mode to UEFI (not Legacy)
# 4. Enable Secure Boot
# 5. Save and reboot

# Verify after reboot:
Confirm-SecureBootUEFI -ErrorAction SilentlyContinue
```

### Issue: "DISM deployment fails"

```powershell
# Common cause: Wrong image index
# List available images in WIM:
dism /Get-ImageInfo /ImageFile:"C:\output\install.wim"

# If multiple images, specify index:
dism /Apply-Image /ImageFile:"C:\output\install.wim" `
  /Index:1 /ApplyDir:"C:\" 

# Check disk space (at least 15GB required):
Get-Volume -DriveLetter C | Select-Object Name, SizeRemaining
```

### Issue: "PowerShell execution disabled"

```powershell
# Check execution policy:
Get-ExecutionPolicy

# Temporarily allow script execution:
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope CurrentUser -Force

# For permanent change (not recommended):
# Only use after thorough security testing
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```

### Issue: "Image capture (Sysprep) hangs"

```powershell
# Check for pending system updates:
Get-WmiObject -Class Win32_QuickFixEngineering | Measure-Object

# Install all updates before Sysprep:
Update-Help
Get-HotFix

# Clear pending updates:
DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase

# Then retry Sysprep
```

### Issue: "BitLocker encryption is slow"

```powershell
# Check encryption progress:
manage-bde -status

# This is normal. Encryption can take several hours depending on:
# - Drive size
# - System performance  
# - Disk speed

# To use only unallocated space (faster):
Enable-BitLocker -MountPoint "C:" `
  -EncryptionMethod XtsAes256 `
  -UsedSpaceOnly
```

---

## Post-Deployment Tasks

### First Boot Configuration

```powershell
# Run post-deployment automation:
cd deployment
.\Post-Deployment-Tasks.ps1 -ComputerName "CORP-PC01" `
  -DomainJoin $true `
  -Domain "contoso.com" `
  -AdminAccount "admin@contoso.com"
```

### Enable Monitoring

```powershell
# Deploy monitoring agent:
.\deployment\Monitor-And-Sync.ps1 `
  -MonitoringAgent "MicrosoftDefenderForEndpoint" `
  -SyncCloud $true
```

### Compliance Reporting

```powershell
# Generate compliance report:
.\hardening\Verify-CIS-Compliance.ps1 `
  -ExportReport "compliance-$(Get-Date -Format 'yyyyMMdd').csv"

# Upload to compliance dashboard:
.\cloud\Sync-To-Cloud.ps1 -FileType "Reports"
```

---

## Customization

### Custom CIS Controls

Edit `hardening\configs\cis-baseline.json` to enable/disable specific controls:

```json
{
  "controls": {
    "uac": { "enabled": true, "level": "maximum" },
    "firewall": { "enabled": true, "defaultAction": "block" },
    "appLocker": { "enabled": true, "mode": "enforce" }
  }
}
```

### Custom AppLocker Policies

Modify `security-stack\AppLocker\AppLocker-Custom-Rules.xml`:

```xml
<FilePathRule 
  Name="Allow Corporate Software" 
  UserOrGroupSid="S-1-1-0" 
  Action="Allow">
  <Conditions>
    <FilePathCondition Path="C:\Program Files\OurCompany\*" />
  </Conditions>
</FilePathRule>
```

### Custom ASR Rules

Edit `security-stack\ASR-Rules\ASR-Rules-Custom.json`:

```json
{
  "rules": [
    {
      "id": "01cf1201-3e4f-4f94-9fa7-9999ffffffff",
      "action": "warn"
    }
  ]
}
```

---

## Version History & Tracking

Each build includes version metadata in `MANIFEST.json`:

```json
{
  "Version": "v1.0-L2-20260419-build42",
  "OSType": "Windows11-Enterprise",
  "CISLevel": "Mandatory",
  "Timestamp": "2026-04-19T12:34:56",
  "BuildNumber": 42,
  "Checksum": "SHA256:abc123...",
  "Organization": "Custom PC Republic",
  "Branding": "IT Synergy Energy for the Republic"
}
```

### Semantic Versioning

```
v{MAJOR}.{MINOR}-L{LEVEL}-{DATE}-build{NUMBER}

Examples:
v1.0-L2-20260419-build1     (Initial release, Mandatory)
v1.1-L2-20260420-build2     (Patch release)
v2.0-L12-20260501-build15   (Major release, Complete L1+L2)
```

---

## Custom PC Republic Branding

This project is branded for **Custom PC Republic** with the tagline *"IT Synergy Energy for the Republic"*.

### Branding Elements

- 🛡️ **Logo**: Neon-style shield with circuit board pattern (cyan/purple gradient)
- 📝 **Tagline**: "IT Synergy Energy for the Republic"
- 🎨 **Colors**: Cyan (#00D9FF) and Magenta/Purple (#D946FF)
- 📋 **Mission**: Enterprise-grade security hardening solutions

### Branding Usage

- All README and documentation files include the logo header
- PowerShell scripts display branding in console output
- Generated artifacts include organization metadata
- Professional presentation for clients and stakeholders

See [docs/BRANDING.md](docs/BRANDING.md) for detailed branding guidelines.

---

## Support & Contributing

### Getting Help

1. **Check Troubleshooting**: See [Troubleshooting](#troubleshooting) section above
2. **Review Logs**: Check `C:\Windows\System32\winevt\Logs\` for detailed event logs
3. **Test in Non-Production**: Always test in safe environment first
4. **Backup Before Hardening**: Full system backup recommended

### Reporting Issues

Report issues at: https://github.com/customtechrepublic/Windows-Safety-Jump-Box/issues

Include:
- Windows version and build number
- Error messages and log files
- Steps to reproduce
- Expected vs actual behavior

### Contributing

Contributions welcome! Please:

1. Test thoroughly in non-production environment
2. Follow existing code style
3. Document changes in commit messages
4. Update README.md with new features
5. Submit pull request with clear description

---

## License

This project is provided by **Custom PC Republic** for enterprise use.  
Ensure compliance with CIS Benchmark licensing and your organization's policies.

**Custom PC Republic - IT Synergy Energy for the Republic** 🛡️

---

## Disclaimer

⚠️ **IMPORTANT:**

- **Test in non-production environment first**
- **Maintain full system backups before applying hardening**
- **Document all customizations**
- **Have rollback procedure tested and ready**
- **Review all security changes for application compatibility**
- **CIS controls may impact performance or compatibility**
- **Use at your own risk**

This solution is provided as-is without warranty. The author assumes no liability for system damage, data loss, or compliance issues resulting from its use.

---

## Quick Reference

### Essential Commands

```powershell
# Build hardened image
.\orchestration\Build-Hardened-Image-Full.ps1

# Deploy image
.\deployment\Deploy-Image.ps1 -ImagePath "install.wim" -TargetDisk "C:"

# Check compliance
.\hardening\Verify-CIS-Compliance.ps1

# Enable BitLocker
.\deployment\Enable-BitLocker.ps1 -MountPoint "C:"

# Create USB boot media
.\deployment\Create-Deployment-USB.ps1 -ISOPath "boot.iso" -USBDrive "E:"

# Rollback changes
.\hardening\CIS_Rollback.ps1 -RollbackFile "rollback\rollback-20260419.json"

# List rollback points
.\hardening\CIS_Rollback.ps1 -List
```

### File Locations

| Item | Location |
|------|----------|
| Hardening scripts | `.\hardening\` |
| Deployment tools | `.\deployment\` |
| Build output | `.\output\v{version}\` |
| Rollback data | `.\hardening\rollback\` |
| Logs | `C:\Windows\System32\winevt\Logs\` |
| BitLocker keys | `C:\BitLockerRecovery\` |
| Compliance reports | `.\output\COMPLIANCE-REPORT.txt` |

---

## 🚀 Next Steps

1. **Review** the [Architecture](#architecture) section
2. **Try** the [Quick Start](#quick-start) in a test VM
3. **Customize** security settings for your environment
4. **Deploy** to production systems
5. **Monitor** and audit compliance regularly

---

**Custom PC Republic - Enterprise Hardening Solutions**  
*IT Synergy Energy for the Republic* 🛡️

**Version:** 1.0  
**Last Updated:** April 19, 2026  
**Organization:** Custom PC Republic  

---

## Additional Resources

- [CIS Benchmarks](https://www.cisecurity.org/benchmarks) - Official CIS benchmark documentation
- [Windows Security Baselines](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-security-baselines) - Microsoft security baselines
- [BitLocker Overview](https://docs.microsoft.com/en-us/windows/security/information-protection/bitlocker/bitlocker-overview) - BitLocker documentation
- [AppLocker](https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-defender-application-guard/wdag-admin-guide) - Application whitelisting guide
- [Windows PE](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-pe-intro) - Windows PE documentation

---

**For support or inquiries:** See [Support & Contributing](#support--contributing) section

**Found this helpful?** Consider starring the repository! ⭐

🛡️ **Custom PC Republic - IT Synergy Energy for the Republic** 🛡️

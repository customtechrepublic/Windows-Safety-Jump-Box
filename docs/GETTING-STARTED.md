```
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║                    GETTING STARTED                                       ║
║         Windows Safety Jump Box - First Time Setup Guide                 ║
║                                                                           ║
║              🛡️  CUSTOM PC REPUBLIC  🛡️                                 ║
║         IT Synergy Energy for the Republic                              ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

# Getting Started with Windows Safety Jump Box

Welcome! This guide will get you up and running with the Windows Safety Jump Box in about 5 minutes.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Start (5 Minutes)](#quick-start-5-minutes)
- [Automated vs. Manual Workflows](#automated-vs-manual-workflows)
- [Common Use Cases](#common-use-cases)
- [Troubleshooting First Steps](#troubleshooting-first-steps)
- [Next Steps](#next-steps)

---

## Prerequisites

### System Requirements

Check that you have the minimum requirements:

```powershell
# Check Windows version
[System.Environment]::OSVersion.VersionString
# Should show: Windows 11 Pro/Enterprise or Windows Server 2022

# Check PowerShell version
$PSVersionTable.PSVersion
# Should be 5.1 or later

# Check available disk space
Get-Volume | Format-Table Name, SizeRemaining
# Need at least 100 GB free
```

### Hardware Requirements

| Component | Requirement |
|-----------|-------------|
| **OS** | Windows 11 Pro/Enterprise or Windows Server 2022 |
| **RAM** | 16 GB minimum (32 GB recommended) |
| **Storage** | 100 GB free space minimum |
| **CPU** | 4+ cores with virtualization support |
| **TPM** | TPM 2.0 (optional, for BitLocker) |

### Software Installation

```powershell
# 1. Download Windows ADK (Assessment and Deployment Kit)
# https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install
# Run the installer and select: Deployment Tools, Windows PE Add-ons

# 2. Download and install Git (if not already installed)
# https://git-scm.com/download/win

# 3. Verify installations
dism /?                     # Should show DISM version
git --version              # Should show git version
```

### Git Cloning

```powershell
# Create projects directory
New-Item -ItemType Directory -Path "C:\Projects" -Force | Out-Null
cd C:\Projects

# Clone the repository
git clone https://github.com/customtechrepublic/Windows-Safety-Jump-Box.git
cd Windows-Safety-Jump-Box
```

---

## Quick Start (5 Minutes)

### Scenario: I want to harden my Windows system

#### Step 1: Create a Test VM (2 minutes)

```powershell
# It's strongly recommended to test on a VM first
# Create a new Hyper-V VM:

# 1. In Hyper-V Manager, click "New" > "Virtual Machine"
# 2. Name: "HardenedTest"
# 3. Memory: 16 GB
# 4. Network: Default switch
# 5. Storage: 50 GB
# 6. ISO: Windows 11 Enterprise installation media

# Or use this PowerShell command:
New-VM -Name "HardenedTest" `
  -MemoryStartupBytes 16GB `
  -NewVHDPath "C:\Hyper-V\HardenedTest.vhdx" `
  -NewVHDSizeBytes 50GB `
  -Generation 2

Start-VM -Name "HardenedTest"
```

#### Step 2: Install Windows (2 minutes)

1. Boot VM from Windows 11 Enterprise ISO
2. Follow Windows installation wizard
3. Choose Quick Installation settings
4. Create local admin account
5. Login to desktop

#### Step 3: Run Hardening (1 minute)

```powershell
# On the test system, open PowerShell as Administrator:

# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Navigate to hardening directory
cd C:\Path\To\Windows-Safety-Jump-Box\hardening

# Run the hardening script (Mandatory controls)
.\CIS-Windows11-Hardening.ps1 -Profile "Mandatory" -Verbose

# Script will:
# - Apply 25+ mandatory CIS controls
# - Take ~10 minutes
# - Show progress in PowerShell
# - Ask for confirmation for major changes
```

### ✅ That's it! Your system is now hardened.

Verify the hardening was applied:

```powershell
# Check compliance
cd C:\Path\To\Windows-Safety-Jump-Box\hardening
.\Verify-CIS-Compliance.ps1

# Output shows:
# - Control status (PASS/FAIL)
# - Compliance percentage
# - Detailed findings
```

---

## Automated vs. Manual Workflows

Choose the workflow that matches your needs:

### Workflow 1: Automated (Fastest)

**Best for:** Quick standardized deployments

```powershell
# Runs end-to-end with no prompts
.\orchestration\Build-Hardened-Image-Full.ps1 `
  -OSType "Windows11-Enterprise" `
  -CISLevel "Mandatory" `
  -OutputDir "C:\output"

# Timeline: 30-40 minutes total
# Produces: WIM, VHDX, ISO files ready to deploy
```

**Advantages:**
- ✅ Fastest (30-40 minutes)
- ✅ Repeatable and consistent
- ✅ Fully automated, no interaction needed
- ✅ Best for large deployments

**Disadvantages:**
- ❌ Less control over process
- ❌ Harder to debug if issues occur
- ❌ Cannot pause to make modifications

### Workflow 2: Guided Manual (Most Flexible)

**Best for:** Creating customized images

```powershell
# 1. Create VM manually (install custom software, etc.)

# 2. Apply hardening interactively
cd hardening
.\Apply-CIS-Interactive.ps1 -Profile "Mandatory"
# Script shows each setting and asks for confirmation

# 3. Prepare for capture
cd ..\capture
.\Prepare-System-for-Capture.ps1

# 4. Capture the image
.\Capture-Installation.ps1 -OutputPath "C:\output\custom.wim"

# Timeline: 1-2 hours total
# Produces: Customized WIM image
```

**Advantages:**
- ✅ Full control over each step
- ✅ Can customize before/after hardening
- ✅ Easy to debug
- ✅ Can pause and resume

**Disadvantages:**
- ❌ Takes longer (1-2 hours)
- ❌ Manual approval needed for each control
- ❌ More opportunities for human error

### Workflow 3: Incident Response (Emergency)

**Best for:** Removing malware, rapid reimage

```powershell
# 1. Create Windows PE boot USB
.\deployment\Create-Windows-PE.ps1 -OutputPath "boot.iso" -IncludeForensics $true
.\deployment\Create-Deployment-USB.ps1 -ISOPath "boot.iso" -USBDrive "E:"

# 2. Boot compromised system from USB
# (Physical machine boots from USB)

# 3. Deploy clean image from PE environment
.\Deploy-Image.ps1 -ImagePath "install.wim" -TargetDisk "C:"

# Timeline: 20-30 minutes total
# Result: System reimaged with clean hardened OS
```

**Advantages:**
- ✅ Fastest for emergency (20-30 min)
- ✅ Bypasses infected OS completely
- ✅ Includes forensics logging
- ✅ Clears all malware

**Disadvantages:**
- ❌ Data on drive will be wiped
- ❌ Requires USB boot capability
- ❌ Less customization

---

## Common Use Cases

### Use Case 1: Single System Hardening

**Goal:** Harden my one workstation

**Steps:**
1. Download the project
2. Run `CIS-Windows11-Hardening.ps1`
3. Verify compliance
4. Done!

**Time:** 15-20 minutes

```powershell
cd hardening
.\CIS-Windows11-Hardening.ps1 -Profile "Mandatory"
.\Verify-CIS-Compliance.ps1
```

### Use Case 2: Create Corporate Image

**Goal:** Build hardened image for 100+ computers

**Steps:**
1. Create test VM
2. Install corporate software
3. Apply hardening
4. Capture image
5. Deploy to fleet

**Time:** 2-3 hours total (including initial setup)

```powershell
# Create template
packer build build/packer/windows11-enterprise.pkr.hcl

# (Install software manually)

# Harden
cd hardening
.\Apply-CIS-Automated.ps1 -Profile "Mandatory"

# Capture
cd ..\capture
.\Prepare-System-for-Capture.ps1
.\Capture-Installation.ps1 -OutputPath "C:\output\corporate.wim"
.\Convert-Image-Formats.ps1 -SourceWIM "C:\output\corporate.wim"

# Deploy to fleet
cd ..\deployment
.\Deploy-Image.ps1 -ImagePath "C:\output\corporate.wim" -TargetDisk "\\PC01\C$"
```

### Use Case 3: Emergency Reimage

**Goal:** Clean malware from system quickly

**Steps:**
1. Create Windows PE USB
2. Boot system from USB
3. Deploy clean image
4. System is clean!

**Time:** 30 minutes

```powershell
cd deployment

# Create USB
.\Create-Windows-PE.ps1 -OutputPath "boot.iso"
.\Create-Deployment-USB.ps1 -ISOPath "boot.iso" -USBDrive "E:"

# Boot system from USB and deploy...
```

### Use Case 4: Compliance Audit

**Goal:** Check if system is CIS compliant

**Steps:**
1. Run compliance verification
2. Review report
3. Fix issues if needed

**Time:** 5-10 minutes

```powershell
cd hardening
.\Verify-CIS-Compliance.ps1 -ExportReport "compliance-$(Get-Date -Format 'yyyyMMdd').csv"

# Review results
Import-Csv "compliance-*.csv" | Format-Table
```

---

## Troubleshooting First Steps

### Issue: "PowerShell says execution is disabled"

```powershell
# Error: "cannot be loaded because running scripts is disabled"

# Solution: Enable script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Or for current session only:
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
```

### Issue: "Script requires administrator privileges"

```powershell
# Error: "You do not have permission to run this script"

# Solution: Run PowerShell as Administrator
# 1. Right-click PowerShell
# 2. Select "Run as administrator"
# 3. Click "Yes" when prompted

# Or use:
# Start-Process powershell -Verb RunAs
```

### Issue: "Cannot find module or script"

```powershell
# Error: "Cannot find path ... No such file or directory"

# Solution 1: Check current directory
Get-Location

# Solution 2: Navigate to correct directory
cd C:\Path\To\Windows-Safety-Jump-Box

# Solution 3: Use full path
C:\Path\To\Windows-Safety-Jump-Box\hardening\CIS-Windows11-Hardening.ps1
```

### Issue: "DISM not found"

```powershell
# Error: "DISM is not recognized as an internal or external command"

# Solution: Install Windows ADK
# Download: https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install
# Install "Deployment Tools" and "Windows PE Add-ons"

# Verify installation:
dism /?
```

### Issue: "Insufficient disk space"

```powershell
# Error: "Not enough space" or "Disk full"

# Check available space:
Get-Volume | Format-Table Name, SizeRemaining

# You need:
# - 100 GB minimum free space
# - 150 GB recommended
# - 200 GB if doing image capture

# Solution: Free up disk space
# - Delete old files
# - Archive to external drive
# - Use larger drive
```

### Issue: "BitLocker requires TPM"

```powershell
# Error: "BitLocker cannot be enabled. TPM 2.0 is required"

# Check TPM status:
Get-WmiObject -Class Win32_Tpm

# If TPM not found:
# 1. For physical systems: Enable in BIOS/UEFI
#    - Reboot, press Del/F2/F10 during startup
#    - Find Security > TPM Settings
#    - Enable TPM 2.0
#    - Save and reboot

# 2. For VMs: Enable vTPM
#    - Hyper-V: Gen 2 VMs have vTPM automatically
#    - VMware: VM > Edit Settings > Add TPM Device
#    - Azure: Supported on newer VM sizes

# Alternative: Skip BitLocker
# Don't use -EnableBitLocker parameter in deploy scripts
```

### Common Fixes Summary

| Problem | Quick Fix |
|---------|-----------|
| **Scripts won't run** | `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned` |
| **"Access denied"** | Run PowerShell as Administrator |
| **Can't find files** | Check working directory with `Get-Location` |
| **DISM missing** | Install Windows ADK |
| **No disk space** | Free up 100+ GB |
| **No TPM** | Enable in BIOS or use non-BitLocker deployment |
| **Network issues** | Check internet connection, firewall settings |
| **Permission denied** | Check file permissions, folder access |

---

## Next Steps

### After Initial Setup

1. ✅ **Read the Full README.md** - Comprehensive documentation
2. ✅ **Review Security Notes** - See `docs/SECURITY-NOTES.md`
3. ✅ **Explore Examples** - Check `examples/` directory
4. ✅ **Review Code** - Look at the hardening scripts
5. ✅ **Test in VM First** - Always test before production

### Choose Your Path

**Path 1: Just Harden This System**
- Run the hardening script
- Verify compliance
- Start using your hardened system

**Path 2: Build Custom Image**
- Create a template VM
- Install your software
- Follow the capture workflow
- Deploy to multiple systems

**Path 3: Learn the Project**
- Review the architecture (README.md)
- Study the hardening controls (hardening/ scripts)
- Understand the deployment process (deployment/ scripts)
- Experiment in test VMs

**Path 4: Contribute**
- Review `CONTRIBUTING.md`
- Find an issue to work on
- Submit improvements
- Help the community!

### Resources

- **Full Documentation:** See `docs/` directory
- **FAQ:** See `docs/FAQ.md`
- **Architecture:** See README.md → [Architecture](#architecture) section
- **Security Info:** See `SECURITY.md`
- **Contributing:** See `CONTRIBUTING.md`

### Getting Help

- **GitHub Issues:** Report bugs or request features
- **GitHub Discussions:** Ask questions
- **Documentation:** Check `docs/` for detailed guides
- **Troubleshooting:** See above "Troubleshooting First Steps"

---

## Common Questions

**Q: Is this safe to run on my production system?**
A: It's designed for production, but always:
- ✅ Test in VM first
- ✅ Have a rollback plan
- ✅ Keep backups
- ✅ Verify application compatibility

**Q: Will this break my software?**
A: Unlikely, but:
- ✅ Some applications may need configuration changes
- ✅ Test with your software first
- ✅ The rollback function can restore previous state
- ✅ See rollback documentation

**Q: Can I customize the hardening controls?**
A: Yes! Edit `hardening/configs/cis-baseline.json` to enable/disable specific controls.

**Q: How do I revert/rollback the hardening?**
A: Use the rollback function:
```powershell
cd hardening
.\CIS_Rollback.ps1 -RollbackFile "rollback/rollback-DATE.json"
```

**Q: What if I only want some CIS controls?**
A: Three profiles available:
- **Mandatory:** ~25 critical controls
- **Level 1:** ~40 recommended controls
- **Complete (L1+L2):** ~60+ advanced controls

---

**You're ready to get started! 🚀**

Try the Quick Start section above, and let us know if you have questions!

---

**Custom PC Republic - Enterprise Hardening Solutions**  
*IT Synergy Energy for the Republic* 🛡️

**Last Updated:** April 19, 2026  
**Organization:** Custom PC Republic

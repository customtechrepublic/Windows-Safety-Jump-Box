# Quick Start Guide - CIS Level 2 Hardened Windows Imaging

**🛡️ Custom PC Republic - IT Synergy Energy for the Republic**

*Get started in 30 minutes or less*

---

## Prerequisites

- ✅ Windows 11 Pro/Enterprise or Server 2022
- ✅ 16GB RAM, 100GB disk space
- ✅ Administrator access
- ✅ PowerShell 5.0+

## 5-Minute Setup

### 1. Clone/Download Repository

```powershell
cd C:\projects
git clone https://github.com/customtechrepublic/Windows-Safety-Jump-Box.git
cd Windows-Safety-Jump-Box
```

### 2. Run Compliance Check

```powershell
cd hardening
.\Verify-CIS-Compliance.ps1
```

**Output:** You'll see current compliance status

### 3. Apply Hardening (Mandatory Level)

```powershell
.\CIS_Level2_Mandatory.ps1 -RollbackPoint $true
```

**Result:**  
- ✅ System hardened with critical CIS controls
- ✅ Rollback point created automatically
- ⚠️ System reboot required

### 4. Verify Hardening Applied

```powershell
.\Verify-CIS-Compliance.ps1 -ExportReport "compliance-report.csv"
```

---

## Creating Your First Hardened Image

### Option A: Fully Automated (30 minutes)

```powershell
# All-in-one: Build VM → Harden → Capture → Convert
cd orchestration
.\Build-Hardened-Image-Full.ps1 `
  -OSType "Windows11-Enterprise" `
  -CISLevel "Mandatory" `
  -OutputDir "C:\output"

# Result in: C:\output\v1.0-L2-20260419-build42\
# ├─ install.wim
# ├─ install.vhdx
# ├─ install.iso
# └─ boot.iso
```

### Option B: Manual with Interactive Steps (1 hour)

```powershell
# 1. Create build VM
# - Install Windows 11 Enterprise from ISO
# - Install your software/drivers
# - Configure settings

# 2. Apply hardening interactively
cd hardening
.\Apply-CIS-Interactive.ps1 -Profile "Mandatory"
# (Review each setting)

# 3. Prepare and capture
cd ..\capture
.\Prepare-System-for-Capture.ps1
.\Capture-Installation.ps1 -OutputPath "C:\output\my-image.wim"

# 4. Convert formats
.\Convert-Image-Formats.ps1 `
  -SourceWIM "C:\output\my-image.wim" `
  -OutputDir "C:\output\v1.0"
```

---

## Deploying Your Image

### Deploy to USB (Bare Metal Deployment)

```powershell
# 1. Create bootable USB
cd deployment
.\Create-Deployment-USB.ps1 `
  -ISOPath "C:\output\v1.0\boot.iso" `
  -USBDrive "E:"

# 2. Boot target system from USB
# 3. Run deployment (instructions on screen)
# 4. System boots with hardened image
```

### Deploy to Hyper-V VM

```powershell
# 1. Create VM with VHDX
New-VM -Name "HardenedWin11" `
  -VHDPath "C:\output\v1.0\install.vhdx" `
  -Generation 2

# 2. Start VM
Start-VM "HardenedWin11"

# 3. First boot: Windows will boot with hardened configuration
```

### Deploy to Network

```powershell
# 1. Copy WIM to network share
Copy-Item "C:\output\v1.0\install.wim" `
  "\\fileserver\deploymentshare\"

# 2. From target system (via USB or network boot):
.\Deploy-Image.ps1 `
  -ImagePath "\\fileserver\deploymentshare\install.wim" `
  -TargetDisk "C:" `
  -EnableBitLocker $true
```

---

## Common Tasks

### Enable BitLocker

```powershell
cd deployment
.\Enable-BitLocker.ps1 -MountPoint "C:"
# Recovery key saved to: C:\BitLockerRecovery\
```

### Verify Compliance After Deployment

```powershell
cd hardening
.\Verify-CIS-Compliance.ps1 -ExportReport "post-deploy-compliance.csv"
```

### If Something Breaks (Rollback)

```powershell
cd hardening
.\CIS_Rollback.ps1 -RollbackFile "rollback\rollback-20260419-120000.json"
# System reverts to pre-hardening state
```

### Check Sysprep Log

```powershell
# If Sysprep hangs, check:
Get-Content "C:\Windows\System32\sysprep\Panther\setupact.log" -Tail 50
```

---

## Hardening Levels Explained

| Level | Controls | Time | Compatibility | Use Case |
|-------|----------|------|----------------|----------|
| **Mandatory** | 25+ | 10 min | 95%+ | Standard deployments |
| **Complete** | 60+ | 20 min | 85%+ | High-security systems |

### Which Should I Choose?

- **Mandatory** → Default choice, good security/compatibility balance
- **Complete** → Enterprise security, may need app compatibility testing

---

## Troubleshooting Quick Fixes

| Issue | Solution |
|-------|----------|
| **TPM not found** | Enable TPM 2.0 in BIOS/UEFI |
| **Secure Boot missing** | Set BIOS to UEFI (not Legacy) |
| **DISM fails** | Ensure 15GB+ free disk space |
| **PowerShell blocked** | `Set-ExecutionPolicy Bypass` |
| **Sysprep hangs** | Install all Windows updates first |
| **BitLocker slow** | Normal - can take several hours |

---

## Next Steps

1. ✅ Try Mandatory hardening on a test VM
2. ✅ Create first hardened image
3. ✅ Deploy to USB or VM
4. ✅ Verify compliance
5. ✅ Customize for your environment
6. ✅ Deploy to production

---

## Need Help?

1. Check README.md for detailed documentation
2. Review logs in `C:\Windows\System32\winevt\Logs\`
3. Check troubleshooting section
4. Report issues on GitHub

---

**Happy hardening! 🔐**

---

**Custom PC Republic - IT Synergy Energy for the Republic** 🛡️  
📧 Support: support@custompc.local

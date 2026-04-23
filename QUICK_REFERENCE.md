# Windows Factory - Quick Reference Guide

## Quick Start

```powershell
# 1. Download the Factory
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/custompcrepublic/Windows-Safety-Jump-Box/alpha-prerelease-community-edition/Build-Factory.ps1" -OutFile "$env:TEMP\Build-Factory.ps1"

# 2. Run it
powershell -ExecutionPolicy Bypass -File "$env:TEMP\Build-Factory.ps1"

# 3. Select a template
# 4. Wait for the build
# 5. Deploy!
```

---

## Available Templates

| Template | Command | Use Case |
|----------|---------|----------|
| Jump Box | `-TemplatePreset "JumpBox"` | Network admin with PuTTY/RDP |
| Kiosk | `-TemplatePreset "Kiosk"` | Family/locked-down browsing |
| App-Dedicated | `-TemplatePreset "AppDedicated"` | Quickbooks/POS server |
| Dev-Hardened | `-TemplatePreset "DevHardened"` | Developer with VS Code/Git |
| Forensic PE | `-TemplatePreset "ForensicPE"` | WinPE boot for IR/recovery |

---

## Commands

```powershell
# Interactive mode (menu selection)
.\Build-Factory.ps1

# Non-interactive with local ISO
.\Build-Factory.ps1 -LocalISO "C:\iso\Windows11.iso" -TemplatePreset "JumpBox"

# Skip compliance reports
.\Build-Factory.ps1 -LocalISO "C:\iso\Windows11.iso" -SkipCompliance

# Custom output directory
.\Build-Factory.ps1 -LocalISO "C:\iso\Windows11.iso" -OutputDirectory "D:\MyFactory"
```

---

## Prerequisites

- Windows 10/11 or Windows Server 2019/2022
- Administrator rights
- Windows ADK (for WIM manipulation)
- 15GB free disk space
- Windows ISO file

---

## File Structure

```
Windows-Safety-Jump-Box/
├── Build-Factory.ps1          # Main orchestrator
├── lib/
│   ├── ImageManagement.ps1    # WIM operations
│   ├── ComponentRemoval.ps1   # Appx/services removal
│   ├── CISHardening.ps1       # CIS controls
│   └── ComplianceReporting.ps1 # Audit reports
├── templates/
│   ├── JumpBox.ps1config      # Network admin
│   ├── Kiosk.ps1config       # Family/locked
│   ├── AppDedicated.ps1config # Business app
│   ├── DevHardened.ps1config # Developer
│   └── ForensicPE.ps1config  # Recovery
└── examples/
    └── Build-Example.ps1     # Example script
```

---

## Compliance Mappings

| Standard | Coverage |
|----------|----------|
| CIS Level 1 | Basic security controls |
| CIS Level 2 | Enhanced security (default) |
| NIST 800-53 | Access Control, Audit, System Comm |
| SOC2 | CC6.1, CC6.2, CC7.2 |
| GDPR | Article 32, 33, 34 |

---

## Support

- GitHub Issues: Report bugs
- GitHub Discussions: Ask questions
- Email: security@custompcrepublic.com

---

*Custom PC Republic - Sanctified Deployments*

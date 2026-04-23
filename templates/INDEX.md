# Windows Factory - Template Registry Index

## Available Templates

This directory contains Quick Start Templates for the Windows Factory. Each template is a `.ps1config` file that defines the configuration for a specific use case.

### Template List

| Template | File | Description | Target Audience |
|----------|------|-------------|-----------------|
| **Secure Jump Box** | `JumpBox.ps1config` | Network administration workstation with PuTTY, RDP, hardened with CIS Level 2 | IT/Network Admins |
| **App-Dedicated** | `AppDedicated.ps1config` | Minimalist single-application server (Quickbooks, POS, etc.) | Small Business |
| **Kiosk/Family** | `Kiosk.ps1config` | Locked-down machine for safe browsing only | Non-technical users |
| **Dev-Hardened** | `DevHardened.ps1config` | Developer workstation with VS Code, Git, Docker, CIS Level 1 | Developers |
| **Forensic/Recovery PE** | `ForensicPE.ps1config` | WinPE boot environment with Sysinternals, malware scanners | IT Security |

---

## Using Templates

### Via Build-Factory.ps1 (Interactive)

```powershell
.\Build-Factory.ps1 -LocalISO "C:\ISO\Windows11.iso"
# Follow the interactive menu to select a template
```

### Via Command Line (Preset)

```powershell
# Jump Box
.\Build-Factory.ps1 -LocalISO "C:\ISO\Windows11.iso" -TemplatePreset "JumpBox"

# Kiosk
.\Build-Factory.ps1 -LocalISO "C:\ISO\Windows11.iso" -TemplatePreset "Kiosk"

# App-Dedicated
.\Build-Factory.ps1 -LocalISO "C:\ISO\Windows11.iso" -TemplatePreset "AppDedicated"

# Dev-Hardened
.\Build-Factory.ps1 -LocalISO "C:\ISO\Windows11.iso" -TemplatePreset "DevHardened"
```

---

## Template Structure

Each template is a PowerShell hashtable with the following sections:

```powershell
@{
    # Metadata
    TemplateName = "Template Name"
    TemplateID = "unique-id"
    Version = "1.0.0"
    Author = "Author Name"
    Description = "Description of the template"
    
    # Compatibility
    TargetOS = @("Windows11-Pro", "Windows11-Enterprise")
    MinimumOSVersion = "22000"
    CISLevel = "Level1"  # or "Level2", "Custom", "N/A"
    
    # Component Removal
    RemoveComponents = @("App1", "App2", "App3")
    
    # Services
    DisableServices = @(
        @{Name="Service1"; DisplayName="Service 1"; Risk="Reason"}
    )
    
    # Hardening
    RegistryHardening = @(
        @{Path="..."; Name="..."; Value=...}
    )
    
    # Compliance Mapping
    Compliance = @{
        CIS = @("1.1.1", "2.1.1")
        NIST = @("AC-2", "SC-7")
        SOC2 = @("CC6.1")
        GDPR = @("32")
    }
}
```

---

## Creating Custom Templates

### Step 1: Copy an Existing Template

```powershell
cp templates/JumpBox.ps1config templates/MyCustom.ps1config
```

### Step 2: Modify the Configuration

Edit the following sections:
- `TemplateName` - Your template name
- `TemplateID` - Unique identifier (e.g., "custom-001")
- `Description` - What your template does
- `TargetOS` - Supported operating systems
- `RemoveComponents` - Apps to remove
- `DisableServices` - Services to disable
- `RegistryHardening` - Registry keys to apply
- `Compliance` - Standards mapping

### Step 3: Test Your Template

```powershell
.\Build-Factory.ps1 -LocalISO "C:\ISO\Windows11.iso" -TemplatePreset "MyCustom"
```

### Step 4: Submit to Community

Fork the repository, add your template, and submit a Pull Request!

---

## Community Templates

Community-contributed templates can be found in the `templates/community/` directory (when available).

### Template Voting

Vote for templates you want to see implemented:
- React with 👍 on GitHub Issues
- Create a feature request with `template-request` label

---

## Template Requirements

### Required Fields

- `TemplateName` (string)
- `TemplateID` (unique string)
- `Version` (semver string)
- `Description` (string)
- `TargetOS` (array)
- `CISLevel` (string: "Level1", "Level2", "Custom", "N/A")

### Best Practices

1. **Unique ID**: Use format `category-###` (e.g., "kiosk-001")
2. **Clear Description**: Explain what the template does in 1-2 sentences
3. **Compliance Mapping**: Include CIS, NIST, SOC2 mappings where applicable
4. **Usage Notes**: Add helpful information about the template
5. **Risk Assessment**: Document the security posture

---

## Template Categories

### Security-Focused
- Jump Box (Network Admin)
- Forensic/Recovery PE

### Productivity-Focused
- Kiosk (Family)
- Dev-Hardened

### Business-Focused
- App-Dedicated (Quickbooks, POS)

---

## References

- [TEMPLATE_SPECIFICATION.md](../TEMPLATE_SPECIFICATION.md) - Full specification
- [PHILOSOPHY.md](../PHILOSOPHY.md) - Why templates matter
- [MILESTONES.md](../MILESTONES.md) - Development roadmap

---

*Template Registry maintained by Custom PC Republic*

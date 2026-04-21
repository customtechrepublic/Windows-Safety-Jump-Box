# Custom PC Republic Branding Guide

**IT Synergy Energy for the Republic**

---

## Logo Information

### Visual Identity

```
   ╔═══════════════════════════════════════════════════════════════════════╗
   ║                                                                       ║
   ║        ██████╗ ███████╗██████╗ ██╗   ██╗██████╗ ██╗     ██╗ ██████╗ ║
   ║        ██╔════╝ ██╔════╝██╔══██╗██║   ██║██╔══██╗██║     ██║██╔════╝ ║
   ║        ██║  ███╗█████╗  ██████╔╝██║   ██║██████╔╝██║     ██║██║      ║
   ║        ██║   ██║██╔══╝  ██╔═══╝ ██║   ██║██╔══██╗██║     ██║██║      ║
   ║        ╚██████╔╝███████╗██║     ╚██████╔╝██████╔╝███████╗██║╚██████╗ ║
   ║         ╚═════╝ ╚══════╝╚═╝      ╚═════╝ ╚═════╝ ╚══════╝╚═╝ ╚═════╝ ║
   ║                                                                       ║
   ║              🛡️  CUSTOM PC REPUBLIC  🛡️                             ║
   ║         IT Synergy Energy for the Republic                          ║
   ║                                                                       ║
   ╚═══════════════════════════════════════════════════════════════════════╝
```

### Color Palette

- **Primary Cyan**: `#00D9FF` - Modern, tech-forward
- **Accent Magenta**: `#D946FF` - Energy and innovation
- **Background**: Dark gradient with grid pattern
- **Glow Effects**: Neon cyan/magenta particles

### Logo Description

- **Symbol**: Neon-style hexagonal shield
- **Center**: Circuit board pattern with power icon
- **Style**: Cyberpunk/tech aesthetic
- **Animation**: Subtle glow effects (in digital contexts)

---

## Brand Usage Guidelines

### Where to Include Branding

#### 📄 Documentation Files

- **README.md** - Large banner header + tagline (DONE ✓)
- **QUICKSTART.md** - Logo header + organization credit
- **SECURITY-NOTES.md** - Logo header with tagline
- **BRANDING.md** - This file

#### 🖥️ PowerShell Scripts

- **All main scripts** - Display banner at start
- **Output messages** - Include organization credit
- **Log files** - Add branding to headers
- **Email reports** - Include logo reference

#### 📊 Generated Artifacts

- **MANIFEST.json** - Add organization metadata
- **Compliance reports** - Add logo header
- **Deployment logs** - Include organization branding
- **README in output** - Auto-generated with branding

#### 🌐 Deployment Media

- **Boot.iso** - Custom boot splash screen
- **USB media** - Branding on boot instructions
- **Installation media** - Custom Windows PE background

---

## Implementation Examples

### PowerShell Banner Example

```powershell
Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "║              🛡️  CUSTOM PC REPUBLIC  🛡️                       ║" -ForegroundColor Cyan
Write-Host "║         IT Synergy Energy for the Republic                    ║" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "║     CIS Level 2 Hardened Windows Image Deployment             ║" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
```

### Manifest Metadata Example

```json
{
  "organization": "Custom PC Republic",
  "tagline": "IT Synergy Energy for the Republic",
  "branding": {
    "colors": {
      "primary": "#00D9FF",
      "accent": "#D946FF"
    },
    "logo": "Shield with circuit board pattern",
    "style": "Cyberpunk tech aesthetic"
  },
  "version": "v1.0-L2-20260419-build42",
  "buildedBy": "Custom PC Republic"
}
```

### Compliance Report Header Example

```
═══════════════════════════════════════════════════════════════════════
  CUSTOM PC REPUBLIC - CIS COMPLIANCE REPORT
  IT Synergy Energy for the Republic
═══════════════════════════════════════════════════════════════════════
  Generated: 2026-04-19 14:32:15
  System: CORP-PC01 (Windows 11 Enterprise)
  Audited By: Custom PC Republic Hardening Suite v1.0
───────────────────────────────────────────────────────────────────────
```

---

## Deployment Branding

### When Systems Boot (First Time)

```
╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║      🛡️  CUSTOM PC REPUBLIC  🛡️                              ║
║      IT Synergy Energy for the Republic                       ║
║                                                                ║
║      This system has been hardened with CIS Level 2           ║
║      security controls by Custom PC Republic                  ║
║                                                                ║
║      For support, contact: support@custompc.local             ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝
```

### Post-Deployment Message

```
═══════════════════════════════════════════════════════════════════
  DEPLOYMENT COMPLETE
  Custom PC Republic - IT Synergy Energy for the Republic
═══════════════════════════════════════════════════════════════════

System: CORP-PC01
Hardening Profile: CIS Level 2 Mandatory
Image Version: v1.0-L2-20260419-build42
Deployment Time: 2026-04-19 12:34:56

Status: ✅ SUCCESS

Next Steps:
  1. System configured with CIS Level 2 hardening
  2. BitLocker encryption enabled
  3. Compliance score: 95%
  4. Ready for enterprise deployment

Organization: Custom PC Republic
Support: support@custompc.local
───────────────────────────────────────────────────────────────
```

---

## Email/Report Branding

### Email Signature for Reports

```
---
Custom PC Republic
IT Synergy Energy for the Republic

🛡️ Enterprise Security Hardening Solutions
📧 support@custompc.local
🌐 www.custompcrepublic.local

Generated by: CIS Hardening Suite v1.0
Timestamp: 2026-04-19 14:32:15
```

### Report Header Template

```markdown
# 🛡️ Custom PC Republic Compliance Report

**IT Synergy Energy for the Republic**

---

## Executive Summary

System: CORP-PC01  
Scan Date: April 19, 2026  
Compliance Profile: CIS Level 2  
Compliance Score: 95%  

---

*Generated by Custom PC Republic CIS Hardening Suite*  
*Enterprise Security Solutions*
```

---

## Console Output Examples

### Main Script Header

```powershell
Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                  ║" -ForegroundColor Cyan
Write-Host "║         🛡️  CUSTOM PC REPUBLIC HARDENING SUITE  🛡️               ║" -ForegroundColor Cyan
Write-Host "║        IT Synergy Energy for the Republic                       ║" -ForegroundColor Cyan
Write-Host "║                                                                  ║" -ForegroundColor Cyan
Write-Host "║              CIS Level 2 Hardening Application                  ║" -ForegroundColor Cyan
Write-Host "║                                                                  ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
```

### Completion Message

```powershell
Write-Host "`n╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                                                  ║" -ForegroundColor Green
Write-Host "║              ✅ HARDENING COMPLETE - SUCCESS ✅                  ║" -ForegroundColor Green
Write-Host "║                                                                  ║" -ForegroundColor Green
Write-Host "║    Custom PC Republic - IT Synergy Energy for the Republic      ║" -ForegroundColor Green
Write-Host "║                                                                  ║" -ForegroundColor Green
Write-Host "╚══════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Green

Write-Host "Organization: Custom PC Republic" -ForegroundColor Cyan
Write-Host "Support: support@custompc.local" -ForegroundColor Cyan
Write-Host "Version: $($script:Version)`n" -ForegroundColor Cyan
```

---

## File Naming Convention

### Branded Artifacts

```
Format: {descriptor}-CPR-{version}-{date}.{extension}

Examples:
- compliance-CPR-v1.0-20260419.csv
- hardening-report-CPR-L2-20260419.pdf
- deployment-log-CPR-build42-20260419.txt
- image-manifest-CPR-v1.0-L2-20260419.json
```

### Image Versioning

```
Format: {os}-CPR-{level}-{date}-build{n}.wim

Examples:
- Win11Pro-CPR-L2-20260419-build1.wim
- Win11Ent-CPR-L2-Complete-20260420-build2.wim
- Server2022-CPR-L2-Mandatory-20260421-build3.wim
```

---

## Documentation Format

### Markdown Headers with Branding

```markdown
# 🛡️ Custom PC Republic - Your Document Title

**IT Synergy Energy for the Republic**

---

## Table of Contents
...

---

**Organization:** Custom PC Republic  
**Mission:** Enterprise Security Hardening  
**Support:** support@custompc.local
```

---

## Social/Web Presence

### GitHub Repository Header

```markdown
# Custom PC Republic - Windows Security Hardening

🛡️ **Enterprise CIS Level 2 Hardened Windows Imaging Suite**

*IT Synergy Energy for the Republic*

---

**Custom PC Republic** provides enterprise-grade security hardening solutions...
```

### Description Text

```
Custom PC Republic delivers comprehensive CIS Level 2 hardened Windows imaging solutions. 
Our enterprise-grade toolkit provides automated hardening, image capture, deployment, and 
incident response capabilities. IT Synergy Energy for the Republic.
```

---

## Brand Consistency Checklist

### PowerShell Scripts ✓

- [ ] Include Custom PC Republic banner at script start
- [ ] Add organization tagline to main output
- [ ] Include support information
- [ ] Add branding to completion messages
- [ ] Reference organization in log files

### Documentation ✓

- [ ] README has logo banner at top
- [ ] All docs include tagline: "IT Synergy Energy for the Republic"
- [ ] Organization name in headers
- [ ] Support contact information included
- [ ] Version attribution to Custom PC Republic

### Generated Artifacts ✓

- [ ] Manifest.json includes organization metadata
- [ ] Compliance reports have branded header
- [ ] Log files reference Custom PC Republic
- [ ] Output directories named with organization code
- [ ] Email signatures include branding

### Deployment ✓

- [ ] Boot splash screen includes logo (optional)
- [ ] First-boot message includes branding
- [ ] Deployment notifications branded
- [ ] Compliance reports signed with organization
- [ ] Post-deployment summary includes branding

---

## Colors in Different Contexts

### Console (PowerShell)

```powershell
$cyanColor = "Cyan"           # Primary: #00D9FF
$magentaColor = "Magenta"     # Accent: #D946FF
$darkColor = "Black"          # Background
$highlightColor = "Green"     # Success states
```

### HTML/Web

```html
<!-- Primary Cyan -->
<span style="color: #00D9FF;">Custom PC Republic</span>

<!-- Accent Magenta -->
<span style="color: #D946FF;">IT Synergy Energy for the Republic</span>

<!-- Gradient Background -->
<style>
  .cpr-header {
    background: linear-gradient(135deg, #001a33 0%, #1a0033 100%);
    color: #00D9FF;
  }
</style>
```

### Markdown

```markdown
🛡️ - Shield emoji for brand icon
💜 - Purple heart (magenta substitute)
🔧 - Tools/customization
⚡ - Energy/synergy
```

---

## Legal & Copyright

```
© 2026 Custom PC Republic
All rights reserved.

Organization: Custom PC Republic
Tagline: IT Synergy Energy for the Republic
Mission: Enterprise Security Hardening Solutions

[Your company legal text here]
```

---

## Support & Questions

For branding guidance questions:
- **Email**: support@custompc.local
- **Documentation**: docs/BRANDING.md
- **Issue Tracker**: GitHub Issues

---

## Version History

- **v1.0** (April 19, 2026) - Initial branding guidelines
  - Logo specifications
  - Color palette definition
  - Usage guidelines
  - Implementation examples

---

**Custom PC Republic - IT Synergy Energy for the Republic** 🛡️

*Securing infrastructure, one hardened image at a time*

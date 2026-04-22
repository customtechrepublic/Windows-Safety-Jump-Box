# Windows Factory: Project Milestones & Timeline

**Status:** Community Alpha Release  
**Organization:** Custom PC Republic  
**Vision:** Clean-Source Cloud Migrations via Sanctified Windows Deployments  

---

## 📊 Milestone Overview

This document outlines the development timeline, difficulty assessments, and resource allocation for the Windows Factory initiative. All milestones are graded by a Solutions Architect perspective using CIS/NIST/SOC2 compliance frameworks.

---

## 🎯 Core Milestones (Phase 1: Foundation)

### M1: Language of the Land (LotL) Core Pipeline
**Difficulty:** 4/10 | **Est. Hours:** 20 | **Status:** Foundation  

**Description:**  
Re-engineer the existing hardening scripts to use only native Windows tools (PowerShell, DISM, Registry APIs). Remove Packer dependency entirely.

**Deliverables:**
- [ ] Refactored `Build-Hardened-Image-Full.ps1` (LotL edition)
- [ ] Native WIM mount/inject/compress orchestration
- [ ] Component removal engine (AppxPackages, Windows Features)
- [ ] Registry injection for bloatware removal
- [ ] Support for local ISO input or skip to direct WIM manipulation

**Why This Matters:**  
Zero external dependencies = Zero friction for adoption. Users can run this on any Windows machine without installing frameworks. This is the "Gateway Drug" to the paid Factory.

---

### M2: Quick Start Templates System
**Difficulty:** 6/10 | **Est. Hours:** 35 | **Status:** Foundation  

**Description:**  
Design and implement the "Anointing" template system. Templates are PowerShell configuration files (.ps1config format) that define component removal, service disabling, AppLocker policies, and CIS hardening profiles.

**Deliverables:**
- [ ] Template format specification (PS hashtable)
- [ ] GitHub-hosted template registry
- [ ] 5 base templates:
  - Secure Jump Box
  - App-Dedicated (Quickbooks/POS)
  - Kiosk/Family
  - Dev-Hardened
  - Forensic/Recovery PE
- [ ] Template inheritance system (allow community extensions)
- [ ] CLI template selector

**Templates Explained:**

| Template | Target User | What Gets Removed | Security Level |
| :--- | :--- | :--- | :---: |
| **Secure Jump Box** | Network Admin | OneDrive, Cortana, Xbox, Widgets | CIS L2 |
| **App-Dedicated** | Small Business | Everything except .NET runtime + target app | CIS L2 |
| **Kiosk/Family** | Home User | All network components except browser, all apps except File Explorer | Custom |
| **Dev-Hardened** | Developer | Telemetry, Games, OneDrive (keep Git, VSCode, WSL2) | CIS L1 |
| **Forensic/Recovery PE** | IT/Security | Full WinPE with Sysinternals, SARA, malware scanners | N/A (PE) |

**Why This Matters:**  
Shifts the paradigm from "one-size-fits-all" hardening to functional specialization. A Quickbooks server doesn't need 80% of Windows; neither does a kiosk.

---

### M3: PowerShell Manifest Engine (Serverless)
**Difficulty:** 5/10 | **Est. Hours:** 25 | **Status:** Foundation  

**Description:**  
Design a serverless manifest system where PowerShell scripts fetch configuration from GitHub without requiring users to manually edit JSON/XML files.

**Deliverables:**
- [ ] `Invoke-FactoryBuild.ps1` - Main orchestrator
- [ ] GitHub Raw URL loader (safe HTTPS only)
- [ ] Template parser (converts .ps1config to runtime variables)
- [ ] Interactive CLI menu for template selection
- [ ] Manifest validation and error handling
- [ ] Pre-flight checks (PowerShell version, admin rights, disk space)

**Architecture:**
```
User runs: Build-Factory.ps1
    ↓
Script checks prerequisites
    ↓
Script fetches template list from GitHub
    ↓
User selects template interactively
    ↓
Script downloads template config from GitHub
    ↓
Script applies configuration to live system or ISO
    ↓
Output: Clean ISO + Audit Report
```

**Why This Matters:**  
No JSON confusion. No browser mishaps. Pure PowerShell. Modern, serverless, zero-installation required.

---

### M4: Kiosk Mode & App-Dedicated Profiles
**Difficulty:** 8/10 | **Est. Hours:** 40 | **Status:** Foundation  

**Description:**  
Implement granular component removal and restrictive AppLocker policies for specialized deployments.

**Deliverables:**
- [ ] Component granularity engine (registry-level feature toggles)
- [ ] AppLocker policy generation
- [ ] Shell replacement system (Task Bar / Start Menu customization)
- [ ] Network isolation profiles (e.g., "browsing only, no SMB")
- [ ] Kiosk Mode template (shell=explorer.exe limited to File Browser)

**Component Removal Examples:**
- Remove: Print Spooler, Fax, Remote Desktop, File Sharing
- Keep: Network stack, Edge browser, File Explorer
- Result: Locked box for Netflix/Google Docs on mom's machine

**Why This Matters:**  
Addresses the real-world use case: A Quickbooks server that runs accounting software and nothing else. Every removed component = fewer patches, fewer vulnerabilities, fewer points of compromise.

---

### M5: "Vulnerability Lockdown" (Experimental)
**Difficulty:** 7/10 | **Est. Hours:** 25 | **Status:** Foundation  

**Description:**  
Pre-boot registry injection that disables vulnerable protocols (SMBv1, NetBIOS, LLMNR) before the first Windows logon.

**Deliverables:**
- [ ] Offline registry mount/modify/unmount logic
- [ ] Registry hive backup (rollback capability)
- [ ] Disable: SMBv1, NetBIOS, LLMNR, WNB, Remote Registry
- [ ] Inject audit policies pre-boot
- [ ] Toggle flag (Experimental - warn user)

**Why This Matters:**  
Users can't accidentally re-enable vulnerable services. The machine is hardened at the silicon level before the OS even boots. This is the "zero-trust by default" approach.

---

### M6: Non-VSS Backup & Immutable Snapshots
**Difficulty:** 8/10 | **Est. Hours:** 50 | **Status:** Medium Priority  

**Description:**  
Replace Volume Shadow Service (VSS) with WIM-based snapshots. Creates immutable, block-level capture of the clean system state.

**Deliverables:**
- [ ] Rust utility: `wfactory-snapshot` (command-line tool)
- [ ] WIM multi-index snapshotter (creates versioned backups)
- [ ] Rollback script (restore from WIM snapshot)
- [ ] Integration with main build pipeline

**Why This Matters:**  
VSS is a known ransomware target. By avoiding it entirely, you eliminate a significant attack vector. The snapshots are cryptographically signed and immutable.

---

### M7: Compliance & Audit Report Generator
**Difficulty:** 4/10 | **Est. Hours:** 20 | **Status:** Foundation  

**Description:**  
Auto-generate PDF/HTML audit reports mapping CIS controls to NIST 800-53 and SOC2 requirements.

**Deliverables:**
- [ ] Control mapping database (CIS -> NIST -> SOC2)
- [ ] PDF report generation (via Pandoc/Markdown)
- [ ] SHA-256 component hash verification
- [ ] Deployment timeline tracking
- [ ] Compliance score calculation
- [ ] "Build Certificate" generation (GPG-signed proof of provenance)

**Report Includes:**
- ✅ All CIS controls applied
- ✅ All components removed (and why)
- ✅ NIST 800-53 Family mapping
- ✅ SOC2 Trust Service Criteria met
- ✅ GDPR data processing notes
- ✅ Audit trail (what was changed, when)

**Why This Matters:**  
Transforms the tool output into an enterprise artifact. Auditors see a clear, professional report that proves compliance from day one.

---

### M8: Enterprise UI (React/Cloudflare Workers) - **Paid Tier**
**Difficulty:** 5/10 | **Est. Hours:** 40 | **Status:** Future  

**Description:**  
Build the premium "Fancy Factory" UI. Hosted on Cloudflare Pages with a REST API backend on Cloudflare Workers.

**Deliverables:**
- [ ] React dashboard (Mission Profile selection)
- [ ] Real-time progress visualization (glowing energy bar)
- [ ] Live terminal log streaming
- [ ] One-click ISO download
- [ ] Build history & versioning
- [ ] Integration with Azure/AWS for direct deployment

**Why This Matters:**  
For organizations that want speed and polish. The LotL version is free and trusted; this is the premium, managed experience.

---

## 📅 Development Timeline

```
Phase 1 (Weeks 1-4): Foundation & Community Alpha
├─ M1: LotL Core Pipeline
├─ M2: Quick Start Templates
├─ M3: PowerShell Manifest Engine
└─ M4: Kiosk Mode & App-Dedicated

Phase 2 (Weeks 5-8): Hardening & Enterprise Features
├─ M5: Vulnerability Lockdown (toggle)
├─ M6: Non-VSS Backup (if time permits)
├─ M7: Compliance & Audit Reports
└─ Community feedback & refinement

Phase 3 (Weeks 9-12): Paid Tier (Factory Enhanced)
├─ M8: Enterprise UI (React/Cloudflare)
├─ REST API for manifest parsing
└─ Terraform for cloud deployments
```

---

## 🔐 Compliance Mapping

Each milestone is tested against:
- **CIS Benchmarks v2.0** (Windows 11 & Server 2022)
- **NIST SP 800-53** (Security controls)
- **SOC2 Trust Service Criteria** (Availability, Processing Integrity, Confidentiality, Security)
- **GDPR** (Data processing & privacy)

---

## 💰 Resource Allocation

| Phase | Total Hours | Priority | Team Size |
| :--- | :---: | :--- | :--- |
| Phase 1 (Foundation) | 145 | Critical | 2-3 |
| Phase 2 (Enterprise) | 95 | High | 1-2 |
| Phase 3 (Paid Tier) | 120 | Medium | 2-3 |
| **Total** | **360** | **--** | **--** |

---

## 🎓 Success Criteria

**Milestone Success = Completion + Testing + Community Validation**

- [ ] All deliverables completed per specification
- [ ] PowerShell PSScriptAnalyzer compliance (no warnings)
- [ ] Integration tests passing (80%+ coverage)
- [ ] Community feedback incorporated
- [ ] Documentation complete
- [ ] Security review passed (no CVEs introduced)

---

## 📞 Support & Questions

For questions about milestones:
- **GitHub Issues:** Use `milestone-inquiry` label
- **GitHub Discussions:** Post in "Roadmap & Vision"
- **Email:** security@custompcrepublic.com

**Custom PC Republic - Sanctified Windows Deployments**  
*IT Synergy Energy for the Republic* 🛡️

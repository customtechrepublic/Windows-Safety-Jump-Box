# Windows Factory Community Alpha - TODO List

**Last Updated:** April 21, 2026  
**Branch:** `alpha-prerelease-community-edition`  
**Status:** Active Development  

---

## 🚨 Critical Path (Must Complete for Alpha Release)

### Foundation Engine
- [ ] **M1.1** Refactor `Build-Hardened-Image-Full.ps1` to remove Packer dependency
- [ ] **M1.2** Implement native WIM mount/inject/compress in PowerShell
- [ ] **M1.3** Build AppxPackages removal engine (registry + DISM)
- [ ] **M1.4** Implement bloatware removal profiles (Services, Scheduled Tasks)
- [ ] **M1.5** Test on clean Windows 11 Pro/Enterprise/LTSC

### Quick Start Templates
- [ ] **M2.1** Design `.ps1config` template format specification
- [ ] **M2.2** Create template registry structure on GitHub
- [ ] **M2.3** Build "Secure Jump Box" template
- [ ] **M2.4** Build "App-Dedicated" template (Quickbooks profile)
- [ ] **M2.5** Build "Kiosk/Family" template
- [ ] **M2.6** Build "Dev-Hardened" template
- [ ] **M2.7** Build "Forensic/Recovery PE" template
- [ ] **M2.8** Implement template inheritance system

### PowerShell Manifest Engine
- [ ] **M3.1** Create `Build-Factory.ps1` main orchestrator
- [ ] **M3.2** Implement GitHub Raw URL loader (with signature verification)
- [ ] **M3.3** Build template parser (PS hashtable to runtime variables)
- [ ] **M3.4** Create interactive CLI menu system
- [ ] **M3.5** Implement pre-flight diagnostic checks
- [ ] **M3.6** Add comprehensive error handling & logging
- [ ] **M3.7** Test on Windows 10/11/Server 2019/2022

### Kiosk & App-Dedicated
- [ ] **M4.1** Build component granularity engine (feature-by-feature toggles)
- [ ] **M4.2** Implement AppLocker policy generator
- [ ] **M4.3** Create Kiosk shell replacement (Explorer locked mode)
- [ ] **M4.4** Build network isolation profiles (disable SMB, enable Edge only)
- [ ] **M4.5** Test end-to-end on mom's laptop (Netflix + Docs only)
- [ ] **M4.6** Test Quickbooks server profile (accounting software only)

---

## ⚠️ High Priority (Phase 1, Target: Week 4)

### Vulnerability Lockdown (Experimental)
- [ ] **M5.1** Design offline registry injection pipeline
- [ ] **M5.2** Implement registry hive mount/modify/unmount
- [ ] **M5.3** Disable SMBv1, NetBIOS, LLMNR, WNB pre-boot
- [ ] **M5.4** Inject audit policies before first logon
- [ ] **M5.5** Create rollback mechanism (registry backup)
- [ ] **M5.6** Add "Experimental" toggle with prominent warning
- [ ] **M5.7** Test registry injection validation

### Documentation & Community
- [ ] **DOC.1** Write `MILESTONES.md` (architecture & timeline)
- [ ] **DOC.2** Write `PHILOSOPHY.md` (why components matter)
- [ ] **DOC.3** Draft 3x GitHub Discussion posts
- [ ] **DOC.4** Create "Quick Start Templates" guide
- [ ] **DOC.5** Document template format (.ps1config) specification
- [ ] **DOC.6** Write troubleshooting FAQ

---

## 🔧 Medium Priority (Phase 2, Target: Week 8)

### Compliance & Audit
- [ ] **M7.1** Build CIS -> NIST control mapping database
- [ ] **M7.2** Create PDF report generator (Pandoc integration)
- [ ] **M7.3** Implement component hash verification (SHA-256)
- [ ] **M7.4** Build compliance score calculator
- [ ] **M7.5** Generate "Build Certificate" (GPG-signed)
- [ ] **M7.6** Add audit trail logging (what changed, when)
- [ ] **M7.7** Test report generation for all templates

### Non-VSS Backup (Experimental, if time permits)
- [ ] **M6.1** Design Rust CLI utility (`wfactory-snapshot`)
- [ ] **M6.2** Implement WIM multi-index snapshot logic
- [ ] **M6.3** Build rollback script from WIM snapshot
- [ ] **M6.4** Integrate with main build pipeline
- [ ] **M6.5** Test snapshot/rollback cycle

### Testing & Validation
- [ ] **TEST.1** Create integration test suite (all templates)
- [ ] **TEST.2** Build end-to-end deployment tests
- [ ] **TEST.3** Security regression testing (CIS compliance verification)
- [ ] **TEST.4** Performance benchmarking (build time, ISO size)
- [ ] **TEST.5** Compatibility testing (Windows versions)
- [ ] **TEST.6** Community beta testing (5-10 volunteers)

---

## 🌟 Lower Priority (Phase 3, Future)

### Hardware Attestation Validator
- [ ] **HW.1** Build TPM 2.0 pre-flight check
- [ ] **HW.2** Implement Secure Boot validation
- [ ] **HW.3** Create UEFI detection
- [ ] **HW.4** Generate "Hardware Readiness Report"

### Intune Readiness Checker
- [ ] **INTUNE.1** Build Hybrid Azure AD compatibility check
- [ ] **INTUNE.2** Implement MDE (Microsoft Defender for Endpoint) readiness validation
- [ ] **INTUNE.3** Create "Green Light" pre-deployment report
- [ ] **INTUNE.4** Add identity migration simulator

### Community Template Registry
- [ ] **REGISTRY.1** Create GitHub Pages template index
- [ ] **REGISTRY.2** Implement community rating system
- [ ] **REGISTRY.3** Build template submission process
- [ ] **REGISTRY.4** Track usage statistics (opt-in)

### Transparent Telemetry
- [ ] **TELEMETRY.1** Design opt-in data collection schema
- [ ] **TELEMETRY.2** Build anonymous metrics aggregation
- [ ] **TELEMETRY.3** Create telemetry dashboard (GitHub private)
- [ ] **TELEMETRY.4** Implement privacy-first retention policy (30-day purge)

### Build Artifact Signing
- [ ] **SIGNING.1** Implement GPG key generation/management
- [ ] **SIGNING.2** Create ISO signing pipeline
- [ ] **SIGNING.3** Build verification script for users
- [ ] **SIGNING.4** Generate "Build Certificate" PDF

### Network Isolation Simulator
- [ ] **SIM.1** Build test user account provisioning
- [ ] **SIM.2** Implement AppLocker simulation environment
- [ ] **SIM.3** Create "What-If" scenario explorer
- [ ] **SIM.4** Generate impact report (before/after)

### Enterprise UI (Paid Tier)
- [ ] **UI.1** Design React dashboard (Figma mockups)
- [ ] **UI.2** Implement Mission Profile selection UI
- [ ] **UI.3** Build real-time progress bar component
- [ ] **UI.4** Create live terminal log viewer
- [ ] **UI.5** Implement build history & versioning
- [ ] **UI.6** Deploy to Cloudflare Pages
- [ ] **UI.7** Build REST API on Cloudflare Workers

---

## 📋 Blocked/Pending Tasks

- [ ] **BLOCKED: M6** (Non-VSS Backup) - Waiting for Rust environment setup
- [ ] **PENDING: HW Attestation** - Awaiting hardware lab for TPM testing
- [ ] **PENDING: Intune Integration** - Requires test Azure tenant

---

## 🎯 Definition of Done (Per Task)

Each task is marked complete when:
1. ✅ Code written & tested locally
2. ✅ Passes PowerShell PSScriptAnalyzer (if PS code)
3. ✅ Documentation updated (README, comments)
4. ✅ Peer reviewed (1 approval minimum)
5. ✅ Integrated into main pipeline
6. ✅ Community tested (alpha users validated)

---

## 📊 Sprint Breakdown

**Sprint 1 (Week 1-2): Foundation**
- [ ] M1.1 - M1.5 (LotL Core)
- [ ] M2.1 - M2.3 (Templates)
- [ ] M3.1 - M3.3 (Manifest Engine)

**Sprint 2 (Week 3-4): Completion**
- [ ] M2.4 - M2.8 (All Templates)
- [ ] M3.4 - M3.7 (Manifest finalization)
- [ ] M4.1 - M4.6 (Kiosk/App-Dedicated)
- [ ] M5.1 - M5.7 (Vulnerability Lockdown)

**Sprint 3 (Week 5-8): Polish & Enterprise**
- [ ] M7.1 - M7.7 (Compliance & Auditing)
- [ ] M6.1 - M6.5 (Non-VSS, if time permits)
- [ ] TEST.1 - TEST.6 (Full validation)

---

## 🔗 Related Files

- **MILESTONES.md** - Detailed milestone breakdown & timeline
- **PHILOSOPHY.md** - The "why" behind each template
- **templates/** - Quick Start Template definitions
- **Build-Factory.ps1** - Main orchestrator script
- **.github/discussions/** - Community posts & feedback

---

## 📞 Contributing

To claim a task:
1. Comment on the GitHub issue with your GitHub handle
2. Assign yourself
3. Move to "In Progress" on the project board
4. Submit a PR when complete

---

**Windows Factory Community Alpha Release**  
*Building the clean room for cloud migrations*  
Custom PC Republic 🛡️

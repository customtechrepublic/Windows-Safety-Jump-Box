# Windows Factory: Community Alpha Release

**Version:** 1.0-alpha  
**Release Status:** Community Alpha (Pre-release)  
**Branch:** `alpha-prerelease-community-edition`  
**Organization:** Custom PC Republic  
**License:** MIT  

---

## 🏭 What is the Windows Factory?

The **Windows Factory** is a **Language of the Land (LotL)** approach to building "Sanctified" Windows images—clean, hardened, and optimized for specific functional purposes.

Instead of the traditional "one-size-fits-all" Windows deployment, the Factory allows you to anoint your Windows with a specific purpose:

- **Secure Jump Box:** Network administration workstation.
- **App-Dedicated:** Lock-down for single business applications (Quickbooks, POS).
- **Kiosk/Family:** Safe browsing and document editing only.
- **Dev-Hardened:** Secure development environment with tooling.
- **Forensic/Recovery PE:** Boot media for incident response and malware cleanup.

---

## 🎯 The Problem We Solve

**"Virus-Native Cloud Migrations"**

Most organizations follow this pattern:

```
Old Infected System → Lift & Shift → Migrate to Azure → Cloud Now Infected
```

The Factory inverts this:

```
Old Infected System → Audit & Plan → Deploy Clean Image → Sanctified Cloud Foundation
```

By starting with a clean, hardened baseline, you prevent inherited security debt before it enters your cloud environment.

---

## 🚀 Quick Start

### Prerequisites

- Windows 10 / Windows 11 / Windows Server 2019 / Server 2022
- Administrator PowerShell prompt
- 15GB free disk space
- A Windows ISO file (or UUP download capability)

### One-Minute Launch

```powershell
# 1. Download the script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/custompcrepublic/Windows-Safety-Jump-Box/alpha-prerelease-community-edition/Build-Factory.ps1" `
  -OutFile "$env:TEMP\Build-Factory.ps1"

# 2. Run it
powershell -ExecutionPolicy Bypass -File "$env:TEMP\Build-Factory.ps1"

# 3. Select your template interactively
# 4. Wait for the factory to build your image
# 5. Deploy the resulting ISO
```

---

## 📋 Available Quick Start Templates

| Template | Use Case | OS Support | Hardening Level |
| :--- | :--- | :--- | :---: |
| **Secure Jump Box** | Network administration | Pro, Enterprise | CIS L2 |
| **App-Dedicated** | Single business app (Quickbooks, POS) | Pro, Enterprise, Server | CIS L2 |
| **Kiosk/Family** | Safe browsing + docs | Home, Pro | Custom |
| **Dev-Hardened** | Developer workstation | Pro, Enterprise | CIS L1 |
| **Forensic/Recovery PE** | Incident response, malware cleanup | WinPE | N/A |

---

## 🔑 Key Features

### ✅ Language of the Land (LotL)
- **Zero external dependencies.** No frameworks to install.
- **Native tools only:** PowerShell, DISM, Registry APIs.
- **Serverless:** Scripts fetch templates from GitHub at runtime.
- **Modern:** Optimized for PowerShell 5.1+.

### ✅ Component Granularity
- Remove bloatware at component level (AppxPackages, Windows Features, Services).
- Choose exactly what stays and what goes.
- Transparent logging of every change.

### ✅ CIS Benchmark Compliance
- Automatic application of CIS Level 1 & 2 controls.
- NIST 800-53 mapping included.
- SOC2 compliance checks built-in.

### ✅ Compliance Reporting
- Auto-generated PDF audit reports.
- SHA-256 hash verification of all components.
- Build certificates (cryptographic proof of provenance).
- GDPR-aware data processing notes.

### ✅ Community-Driven
- Templates are open-source and modifiable.
- GitHub-hosted registry for easy discovery.
- Community contributions welcome.

---

## 📁 Repository Structure

```
windows-safety-jump-box/
├─ README.md                      # Main project README
├─ PHILOSOPHY.md                  # Why this approach matters
├─ MILESTONES.md                  # Development timeline & resource grading
├─ TODO.md                         # Task breakdown & sprint planning
├─ TEMPLATE_SPECIFICATION.md       # How to create templates
│
├─ Build-Factory.ps1              # Main orchestrator script
├─ templates/                      # Quick Start Templates
│  ├─ JumpBox.ps1config
│  ├─ AppDedicated.ps1config
│  ├─ Kiosk.ps1config
│  ├─ DevHardened.ps1config
│  └─ ForensicPE.ps1config
│
├─ lib/                           # Shared PowerShell modules (LotL)
│  ├─ ImageManagement.ps1
│  ├─ ComponentRemoval.ps1
│  ├─ CISHardening.ps1
│  └─ ComplianceReporting.ps1
│
├─ hardening/                     # CIS hardening scripts (existing)
├─ deployment/                    # Deployment utilities
├─ tests/                         # PowerShell integration tests
│
└─ .github/
   ├─ DISCUSSIONS.md              # Community discussion starters
   ├─ ISSUE_TEMPLATE/
   └─ workflows/
```

---

## 🎓 Understanding the "Anointing"

When you select a **Quick Start Template**, you are "anointing" your Windows with a specific purpose.

Each anointing represents:
1. **A functional commitment:** The machine does ONE thing, well.
2. **A security posture:** Hardened specifically for that use case.
3. **A compliance baseline:** CIS/NIST controls pre-applied.
4. **A maintainability promise:** Fewer components = fewer patches, fewer issues.

---

## 📊 Compliance Mapping

All templates include mappings to:
- **CIS Benchmarks v2.0** (Windows 11 & Server 2022)
- **NIST SP 800-53** (Security controls)
- **SOC2 Trust Service Criteria** (Security, Availability, Processing Integrity, Confidentiality)
- **GDPR** (Data protection & privacy)

Every generated image includes a **Compliance Audit Report** detailing which controls are applied.

---

## 🔧 Advanced Usage

### Use a Local ISO (Skip UUP Download)

```powershell
.\Build-Factory.ps1 -LocalISO "C:\ISO\Windows11.iso" -Mode Interactive
```

### Non-Interactive Mode (Preset Template)

```powershell
.\Build-Factory.ps1 -LocalISO "C:\ISO\Windows11.iso" -TemplatePreset "JumpBox"
```

### Custom Output Directory

```powershell
.\Build-Factory.ps1 -LocalISO "C:\ISO\Windows11.iso" -OutputDirectory "D:\Factory\Output"
```

### Skip Compliance Reports (Not Recommended)

```powershell
.\Build-Factory.ps1 -LocalISO "C:\ISO\Windows11.iso" -SkipCompliance $true
```

---

## 🎯 What's NOT Included (Yet)

This is an **alpha release**. The following are planned for Phase 2-3:

- [ ] UUP-Dump integration (multi-platform ISO download)
- [ ] Non-VSS backup strategy (block-level snapshot)
- [ ] Experimental "Vulnerability Lockdown" (pre-boot hardening)
- [ ] Enterprise UI (React/Cloudflare Workers)
- [ ] Cloud deployment (Terraform for Azure/AWS)
- [ ] Intune readiness checker
- [ ] Hardware attestation validator

See [MILESTONES.md](../MILESTONES.md) for the full development timeline.

---

## 📖 Documentation

- **[PHILOSOPHY.md](../PHILOSOPHY.md)** - The "why" behind each template
- **[MILESTONES.md](../MILESTONES.md)** - Development timeline & resource allocation
- **[TODO.md](../TODO.md)** - Task breakdown & sprint planning
- **[TEMPLATE_SPECIFICATION.md](../TEMPLATE_SPECIFICATION.md)** - How to create custom templates

---

## 🤝 Community Engagement

We welcome community input! Here's how to contribute:

### Report Issues
Use GitHub Issues with the appropriate label:
- `bug` - Something is broken
- `enhancement` - Feature request
- `documentation` - Docs improvement
- `template-request` - Request a new template

### Suggest Templates
Create a GitHub Discussion post suggesting a new template (e.g., "Gaming Light," "Medical Records Server").

### Contribute Code
Fork the repo, create a branch, and submit a PR with:
- [ ] Code changes
- [ ] Corresponding tests
- [ ] Documentation updates
- [ ] 1 peer review approval

### Vote on Priorities
Use 👍 reactions on GitHub Issues to vote for features you want next.

---

## 🛡️ Security Considerations

### This is NOT a Complete Security Solution
The Factory provides:
- ✅ Baseline hardening (CIS controls)
- ✅ Component minimization (reduced attack surface)
- ✅ Compliance scaffolding (audit trails)

It does NOT provide:
- ❌ Network segmentation (configure your firewall)
- ❌ Identity provider integration (configure Entra ID/Active Directory)
- ❌ Endpoint detection (integrate with Microsoft Defender for Endpoint)
- ❌ Patch management (establish a patching cadence)

### Responsible Disclosure
If you discover a security vulnerability, please report it to **security@custompcrepublic.com** instead of posting publicly. See [SECURITY.md](../SECURITY.md) for details.

---

## 📈 Roadmap Preview

**Phase 1 (Current - Alpha):**
- Quick Start Templates
- LotL PowerShell engine
- CIS hardening

**Phase 2 (Q3 2026):**
- UUP-Dump integration
- Vulnerability Lockdown (experimental)
- Compliance audit reports

**Phase 3 (Q4 2026):**
- Enterprise UI (React/Cloudflare)
- Cloud deployments (Terraform)
- Multi-platform support (Linux)

**Phase 4 (2027):**
- AI-driven hardening recommendations
- Anomaly detection
- Predictive compliance analytics

See [MILESTONES.md](../MILESTONES.md) for detailed timeline.

---

## 💬 Support & Questions

- **GitHub Issues:** Bug reports and feature requests
- **GitHub Discussions:** General questions and ideas
- **Email:** security@custompcrepublic.com (for enterprise inquiries)

---

## 📜 License

This project is licensed under the **MIT License**. See [LICENSE](../LICENSE) for details.

---

## 🙏 Acknowledgments

- **CIS:** For the invaluable CIS Benchmarks
- **Microsoft:** For NIST/SOC2 guidance and hardening research
- **Community:** For testing, feedback, and template contributions

---

## 🚀 Ready to Build?

1. **Download:** `Build-Factory.ps1`
2. **Run:** `powershell -ExecutionPolicy Bypass -File Build-Factory.ps1`
3. **Select:** Choose your anointing (Quick Start Template)
4. **Wait:** The factory builds your image
5. **Deploy:** Use the resulting ISO

---

**Windows Factory: Sanctified Deployments**  
*Clean IT for the Republic* 🛡️

**Custom PC Republic**  
*IT Synergy Energy for the Republic*

---

**Questions?** Start a discussion on GitHub or reach out to **security@custompcrepublic.com**

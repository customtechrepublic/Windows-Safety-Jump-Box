```
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║                    FREQUENTLY ASKED QUESTIONS                            ║
║         Windows Safety Jump Box - Common Questions & Answers             ║
║                                                                           ║
║              🛡️  CUSTOM PC REPUBLIC  🛡️                                 ║
║         IT Synergy Energy for the Republic                              ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

# Frequently Asked Questions (FAQ)

This document contains answers to common questions about the Windows Safety Jump Box project.

---

## Table of Contents

- [General Questions](#general-questions)
- [Technical Questions](#technical-questions)
- [Hardening Questions](#hardening-questions)
- [Deployment Questions](#deployment-questions)
- [Security Questions](#security-questions)
- [Support & Licensing Questions](#support--licensing-questions)

---

## General Questions

### What is Windows Safety Jump Box?

**A:** Windows Safety Jump Box is an enterprise-grade solution for creating CIS Level 2 hardened Windows installations. It provides:

- ✅ Automated CIS benchmark hardening
- ✅ Multiple hardening profiles (Mandatory, Level 1, Level 1+2)
- ✅ Multiple deployment formats (WIM, VHDX, ISO)
- ✅ Compliance verification and auditing
- ✅ Incident response capabilities
- ✅ Rollback functionality

It's designed for organizations that need:
- Secure, standardized Windows images
- CIS compliance verification
- Quick incident response (reimage) capabilities
- Enterprise-grade automation

### What are the key features?

**Security Hardening:**
- CIS Benchmarks for Windows 11 and Server 2022
- User Account Control hardening
- Windows Defender and exploit protection
- Credential Guard and Device Guard
- SMB hardening
- BitLocker integration
- AppLocker policies
- Attack Surface Reduction rules

**Image Management:**
- Create WIM (Windows Imaging Format) files
- Convert to VHDX (Hyper-V format)
- Generate ISO files (bootable media)
- Create Windows PE boot media
- Support for multiple formats

**Deployment:**
- USB media deployment
- Network PXE deployment
- VM direct deployment
- Cloud storage integration
- Automated forensics logging

**Compliance:**
- Verification of CIS control application
- Compliance reporting
- Detailed audit logs
- Historical tracking

### Who should use this project?

**Ideal Users:**
- ✅ IT security teams
- ✅ System administrators
- ✅ Enterprise organizations
- ✅ MSPs (Managed Service Providers)
- ✅ Government agencies
- ✅ Healthcare organizations
- ✅ Financial institutions
- ✅ Anyone needing CIS-hardened Windows

**Not Ideal For:**
- ❌ Home users (may be overkill)
- ❌ Systems needing maximum compatibility (some controls restrict functionality)
- ❌ Very specialized workstations with unique requirements
- ❌ Systems running legacy Windows versions (7, 8, 10)

### Is this open source?

**A:** Yes! Windows Safety Jump Box is released under the MIT License, which means:

- ✅ Free to use commercially
- ✅ Free to use privately
- ✅ Free to modify
- ✅ Free to distribute
- ✅ Community can contribute improvements

See the `LICENSE` file for complete terms.

### Can I use this in production?

**A:** Yes, but with caution:

- ✅ Designed for production use
- ✅ Implements industry-standard CIS benchmarks
- ✅ Used by enterprises and government agencies
- ✅ Includes rollback capability

**Best practices:**
1. Always test in non-production environment first
2. Have full system backups before hardening
3. Test your applications for compatibility
4. Have a rollback plan ready
5. Start with "Mandatory" profile, then increase
6. Monitor system performance after hardening

### What operating systems are supported?

**Fully Supported:**
- Windows 11 Pro
- Windows 11 Enterprise
- Windows Server 2022

**Partially Supported:**
- Windows 10 Enterprise (some controls, not recommended for new deployments)

**Not Supported:**
- Windows 7, 8, 8.1
- Server 2019 and earlier
- Home editions
- Non-Windows operating systems

### What is CIS Benchmark?

**A:** CIS (Center for Internet Security) Benchmarks are:

- **Community-driven** security best practices
- **Consensus-based** configurations
- **Globally recognized** standards
- **Free to implement** but proprietary documentation

**Why CIS?**
- Industry standard (recognized by NIST, DISA, etc.)
- Based on real-world security research
- Regularly updated (typically annually)
- Applicable to most environments

**CIS Levels:**
- **Level 1:** Essential security baseline for all systems
- **Level 2:** Enhanced security for high-value systems
- **NG (Next Generation):** Advanced controls for specialized environments

This project implements:
- ✅ Windows 11 v2.0 CIS Benchmark
- ✅ Windows Server 2022 v1.0 CIS Benchmark
- ✅ Both Level 1 and Level 2 controls

---

## Technical Questions

### What are the system requirements?

**Minimum:**
- OS: Windows 11 Pro/Enterprise or Server 2022
- RAM: 16 GB
- Storage: 100 GB free
- CPU: 4+ cores
- PowerShell: 5.1+

**Recommended:**
- RAM: 32 GB
- Storage: 200 GB free
- SSD for faster operations
- Dedicated VM for image building

### What hardware is supported?

**For Hardening:**
- ✅ Physical computers (laptops, desktops, servers)
- ✅ Virtual machines (Hyper-V, VMware, Proxmox)
- ✅ Cloud instances (Azure VMs, AWS instances)

**Special Hardware:**
- TPM 2.0: Required for BitLocker (optional feature)
- UEFI firmware: Required for Secure Boot
- Legacy BIOS: Supported but less secure

### Can I run this in a virtual machine?

**A:** Yes! In fact, it's recommended for testing:

**Hyper-V:**
```powershell
New-VM -Name "HardenedTest" `
  -MemoryStartupBytes 16GB `
  -Generation 2
```

**VMware:**
- Create VM with Windows 11 Enterprise
- Allocate 16 GB RAM
- 50+ GB storage
- Generation 2 recommended

**Cloud:**
- Azure VMs: Standard_D4s_v3 or larger
- AWS EC2: t3.xlarge or larger

### Do I need administrator access?

**A:** Yes, always:

- ✅ Local administrator on the system being hardened
- ✅ Admin access to run deployment scripts
- ✅ UAC (User Account Control) prompts will appear
- ✅ Some registry modifications require admin

**Note:** Scripts will fail with clear errors if admin rights insufficient.

### What PowerShell version do I need?

**A:** PowerShell 5.1 or later

Check version:
```powershell
$PSVersionTable.PSVersion
```

**Note:** PowerShell 7+ (Core) not required, but works fine.

### What about Windows Sandbox or Docker?

**A:** 

**Windows Sandbox:**
- ✅ Can run hardening scripts
- ✅ Good for testing
- ❌ Cannot capture images (limited file system)
- ❌ Cannot deploy (read-only OS)

**Docker/Containers:**
- ❌ Not supported (Windows containers, but doesn't apply to image building)
- ❌ Would need Windows container host
- ⚠️ Use VMs instead (Hyper-V, VMware)

### How much internet bandwidth does this use?

**A:** Relatively little:

- **Windows installation:** ~3-5 GB (ISO file)
- **Updates:** ~1-2 GB (if installing updates)
- **Project download:** ~50-100 MB
- **ADK tools:** ~2-3 GB (one-time)

**Total:** ~5-10 GB for initial setup

### Can I run this offline?

**A:** Mostly yes:

- ✅ Hardening scripts work offline
- ✅ Image capture works offline
- ✅ Can run tests offline
- ❌ Windows updates require internet
- ❌ Cloud sync requires internet
- ❌ Compliance reporting may need internet for reference data

---

## Hardening Questions

### What CIS controls are applied?

**Mandatory Profile (~25 controls):**
- User Account Control hardening
- Firewall configuration
- Windows Defender real-time monitoring
- Audit policy
- Service hardening (DiagTrack, RemoteRegistry disabled)
- Registry hardening
- System service policies

**Level 1 Profile (~40+ controls):**
- All mandatory controls
- SMB hardening
- Network security
- Credential Guard
- Device Guard
- Exploit Protection
- BitLocker prerequisites
- Audit logging

**Level 2 Complete Profile (~60+ controls):**
- All Level 1 controls
- Advanced audit policies
- AppLocker policies
- ASR (Attack Surface Reduction) rules
- Restricted PowerShell execution
- Advanced network isolation
- Additional security policies

**Reference:** See `hardening/configs/` for detailed control mappings

### Which hardening profile should I use?

**Choose by your needs:**

| Profile | Best For | Controls | Performance Impact |
|---------|----------|----------|-------------------|
| **Mandatory** | Quick security boost | ~25 | Minimal (< 5%) |
| **Level 1** | General enterprise use | ~40 | Minor (5-10%) |
| **Level 2** | High-security environments | ~60+ | Moderate (10-20%) |

**Recommendation:**
- Start with **Mandatory** for initial deployment
- Move to **Level 1** after testing
- Use **Level 2** for critical systems only

### Will hardening break my applications?

**A:** Possibly, depends on the application:

**Generally Safe:**
- ✅ Modern business software (Office, Chrome, Firefox)
- ✅ System applications
- ✅ Standard enterprise applications

**Potentially Problematic:**
- ⚠️ Old/legacy applications (pre-2015)
- ⚠️ Custom LOB (Line of Business) applications
- ⚠️ Specialized software (CAD, video editing)
- ⚠️ Applications that require admin privileges
- ⚠️ Peer-to-peer or file-sharing applications

**How to Mitigate:**
1. Test with your applications in a VM first
2. Start with Mandatory profile
3. Document any incompatibilities
4. Use rollback if major issues
5. Work with application vendors for compatibility
6. Disable specific controls if needed

### Can I disable specific controls?

**A:** Yes! Edit the configuration:

```powershell
# Edit: hardening/configs/cis-baseline.json

{
  "controls": {
    "uac": { "enabled": true },           # Set to false to disable
    "firewall": { "enabled": true },
    "bitlocker": { "enabled": false }     # Example: BitLocker disabled
  }
}
```

Then run hardening with the config:
```powershell
.\Apply-CIS-Automated.ps1 -ConfigFile "hardening/configs/custom.json"
```

### What is AppLocker?

**A:** AppLocker is application whitelisting:

- **What it does:** Only allows approved applications to run
- **How it works:** Creates allow rules for applications
- **Why use it:** Prevents malware and unapproved software

**Drawbacks:**
- ⚠️ Requires maintenance (adding approved applications)
- ⚠️ Can be restrictive
- ⚠️ Performance overhead

**Is it enabled by default?**
- No, AppLocker is optional
- Requires manual policy configuration
- Good for high-security environments
- Not recommended for general users

### What are ASR (Attack Surface Reduction) rules?

**A:** ASR rules block common attack techniques:

- **Office macro attacks:** Blocks office process execution
- **JavaScript/VBScript:** Prevents script-based attacks
- **Win32 API calls:** Prevents exploitation
- **Credential theft:** Blocks credential dumping
- **Email execution:** Prevents email attachment attacks

**Default status:** Audit mode (logs but doesn't block)

**To enable blocking:**
```powershell
Set-MpPreference -AttackSurfaceReductionRules_Ids @("01cf1201-3e4f-4f94-9fa7-ffffffff") -AttackSurfaceReductionRules_Actions @("1")
```

### What is Credential Guard?

**A:** Credential Guard protects credentials using hypervisor:

- **What it does:** Isolates credentials in secure enclave
- **Requirements:** Hyper-V capable CPU, Secure Boot
- **Protection:** Prevents credential theft (Pass-the-Hash attacks)
- **Performance:** Minimal impact

**Limitations:**
- Requires modern hardware (2011+)
- Doesn't work on older systems
- May affect older applications

### What is Device Guard?

**A:** Device Guard enforces code integrity using UEFI:

- **What it does:** Only signed code can execute
- **Requirements:** UEFI firmware, Secure Boot
- **Protection:** Prevents unsigned malware execution
- **Performance:** Minimal impact

**Note:** Device Guard != AppLocker (Device Guard is lower-level)

### Can I use BitLocker?

**A:** Yes, if you have TPM 2.0:

**Requirements:**
- TPM 2.0 (trusted platform module)
- Secure Boot enabled
- UEFI firmware

**Implementation:**
```powershell
.\deployment\Enable-BitLocker.ps1 -MountPoint "C:"
```

**Recovery Key:** Must save recovery key (16-digit code)
- Store in safe location
- Recommended: Password manager, Azure Key Vault
- Essential for access if BitLocker key lost

---

## Deployment Questions

### What image formats are supported?

**WIM (Windows Imaging Format):**
- ✅ Primary format (smallest file size)
- ✅ Used by DISM
- ✅ Native Windows format
- ✅ Compressed, ~2-3 GB

**VHDX (Hyper-V Virtual Disk):**
- ✅ For Hyper-V VMs
- ✅ Can be mounted directly
- ✅ ~10-12 GB (uncompressed)
- ✅ Dynamic or fixed size

**ISO (Bootable Disc):**
- ✅ Bootable media
- ✅ Can burn to DVD or USB
- ✅ ~5-6 GB
- ✅ For physical system deployment

**Boot.wim:**
- ✅ Windows PE (minimal OS)
- ✅ For deployment and recovery
- ✅ ~200-300 MB
- ✅ For creating recovery USB

### How do I deploy to a USB drive?

**A:** Using Windows PE:

```powershell
# Step 1: Create Windows PE ISO
.\deployment\Create-Windows-PE.ps1 -OutputPath "C:\boot.iso"

# Step 2: Create USB
.\deployment\Create-Deployment-USB.ps1 `
  -ISOPath "C:\boot.iso" `
  -USBDrive "E:"

# Step 3: Boot system from USB
# (Insert USB, restart, select USB as boot device)

# Step 4: Deploy image from PE
X:\> Deploy-Image -ImagePath "\\networkshare\install.wim" -TargetDisk "C:"
```

**Tools:**
- Rufus (GUI tool, easiest)
- Windows PE tools (command-line, most compatible)
- PowerShell script (included in project)

### How do I deploy to Hyper-V?

**A:** Convert to VHDX format:

```powershell
# Step 1: Convert WIM to VHDX
.\capture\Convert-Image-Formats.ps1 `
  -SourceWIM "C:\install.wim" `
  -OutputDir "C:\output"

# Step 2: Create VM with VHDX
New-VM -Name "HardenedVM" `
  -VHDPath "C:\output\install.vhdx" `
  -Generation 2

# Step 3: Start VM
Start-VM -Name "HardenedVM"
```

### Can I deploy to Azure?

**A:** Yes, using Azure VMs:

```powershell
# Step 1: Upload VHDX to Azure Storage
az storage blob upload `
  --account-name mystorageaccount `
  --container-name vhds `
  --name install.vhdx `
  --file C:\output\install.vhdx

# Step 2: Create image from VHDX
az image create `
  --resource-group myResourceGroup `
  --name HardenedImage `
  --os-type Windows `
  --source https://mystorageaccount.blob.core.windows.net/vhds/install.vhdx

# Step 3: Create VM from image
az vm create `
  --resource-group myResourceGroup `
  --name HardenedVM `
  --image HardenedImage
```

### Can I deploy to AWS?

**A:** Yes, but requires conversion:

```powershell
# Step 1: Convert VHDX to RAW format
# Use: qemu-img convert -f vhdx -O raw install.vhdx install.raw

# Step 2: Create AMI (Amazon Machine Image)
aws ec2 import-image `
  --description "Hardened Windows" `
  --disk-containers "file://containers.json"

# Step 3: Create EC2 instance from AMI
aws ec2 run-instances `
  --image-id ami-xxxxxxxxx `
  --instance-type m5.xlarge
```

### How long does deployment take?

**A:** Depends on method:

| Method | Time | Notes |
|--------|------|-------|
| **Direct copy** | 5-10 min | Fastest, local storage |
| **Network deploy** | 10-20 min | Depends on network speed |
| **USB media** | 15-25 min | Depends on USB speed |
| **Cloud upload** | 20-60 min | Depends on internet/cloud |

**Image capture time:** 20-40 minutes

### Can I deploy to Linux or Mac?

**A:** No.

- ❌ Only Windows compatible
- ❌ WIM format is Windows-specific
- ❌ Scripts are PowerShell (Windows-only)
- ❌ Hardening is Windows-specific

**Alternatives:**
- Use Docker on Linux
- Use KVM/QEMU for VM
- Use native Linux hardening tools

---

## Security Questions

### How secure is this compared to default Windows?

**A:** Significantly more secure:

**Vulnerabilities Addressed:**
- ✅ ~60+ CIS benchmark vulnerabilities fixed
- ✅ Common attack vectors eliminated
- ✅ Exploitation made significantly harder
- ✅ Malware persistence methods blocked

**Not Protected Against:**
- ❌ Zero-day exploits (unknown vulnerabilities)
- ❌ CPU/chipset vulnerabilities (Spectre, Meltdown)
- ❌ Human error (users installing malware)
- ❌ Hardware theft (physical access)

**Reality:**
- Hardening is a "defense in depth" approach
- No single tool makes system 100% secure
- Combines multiple security layers
- Significantly raises the bar for attackers

### Does this protect against ransomware?

**A:** Partially:

**Protection Mechanisms:**
- ✅ ASR rules block many ransomware behaviors
- ✅ Controlled Folder Access prevents encryption of user files
- ✅ BitLocker prevents offline attacks
- ✅ AppLocker prevents unapproved software

**Not Protected Against:**
- ❌ Sophisticated, targeted ransomware
- ❌ Supply chain attacks
- ❌ Zero-day ransomware
- ❌ Advanced persistent threats (APTs)

**Best Practice:**
- Hardening + backups = protection
- Regular backups are ESSENTIAL
- Air-gapped backups recommended
- Test restore procedures

### Does this protect against malware?

**A:** Partially:

**Strong Against:**
- ✅ Script-based malware (PowerShell, VBScript, JavaScript)
- ✅ Office macro attacks
- ✅ File-less malware
- ✅ Persistence techniques
- ✅ Credential theft

**Weaker Against:**
- ⚠️ Sophisticated, signed malware
- ⚠️ Kernel-level rootkits
- ⚠️ BIOS/firmware malware
- ⚠️ Zero-day exploits

**Recommended Additional Steps:**
- Use antivirus (Windows Defender is included)
- Enable real-time protection (enabled by default)
- Keep Windows updated
- Use endpoint detection and response (EDR)
- Implement network segmentation

### What about supply chain attacks?

**A:** Hardening reduces impact but doesn't prevent:

- ⚠️ Compromised software supply chain
- ⚠️ Trojanized updates
- ⚠️ Compromised build systems

**Mitigation:**
- ✅ Code signing verification (enabled)
- ✅ Signed driver enforcement
- ✅ Secure Boot prevents unsigned boot code
- ✅ Limited write access (prevents tampering)

**Additional Actions:**
- Verify software sources
- Use software from trusted vendors
- Implement procurement security
- Monitor for indicators of compromise

### Is this compliant with NIST or other standards?

**A:** Yes, with qualifications:

**Compliance:**
- ✅ CIS Benchmarks (Windows 11 v2.0, Server 2022 v1.0)
- ✅ Aligns with NIST SP 800-53 (selected controls)
- ✅ Aligns with NIST CSF (Cybersecurity Framework)
- ✅ Supports HIPAA, PCI-DSS, SOC 2 compliance efforts

**Not a Complete Solution:**
- ❌ Not standalone HIPAA/PCI-DSS compliant
- ❌ Compliance requires additional controls
- ❌ Organization policies may add requirements
- ❌ Compliance is ongoing (not one-time)

**Reference:**
- See `docs/NIST-800-53-COMPLIANCE.md` for mapping
- See `docs/CIS-BENCHMARK-v2.0-MAPPING.md` for CIS mapping

### What about GDPR or data privacy?

**A:** Hardening supports privacy:

**Privacy Benefits:**
- ✅ Encrypted storage (BitLocker)
- ✅ Access controls prevent unauthorized access
- ✅ Audit logging for compliance
- ✅ Credential protection prevents theft

**Not Sufficient Alone:**
- Needs organizational policies
- Requires proper data handling procedures
- Requires privacy impact assessments
- Needs additional privacy controls

### Can attackers still bypass this?

**A:** Yes, with effort and resources:

**Realistic Threat Model:**
- ✅ Protected against: Opportunistic attacks, script kiddies
- ✅ Protected against: Common malware, persistence methods
- ⚠️ Harder to exploit: But possible for determined attackers
- ❌ Protected against: Nation-state actors with unlimited resources

**Multi-Layer Defense:**
- Hardening is one layer
- Add: Antivirus, EDR, network security, user training
- Result: Strong security posture

---

## Support & Licensing Questions

### How do I get support?

**A:** Multiple support options:

**Documentation:**
- README.md - Comprehensive guide
- docs/GETTING-STARTED.md - Quick start
- docs/FAQ.md - This file
- docs/SECURITY-NOTES.md - Security details

**Community Support:**
- GitHub Issues - Report bugs
- GitHub Discussions - Ask questions
- Pull Requests - Contribute improvements

**Commercial Support:**
- Contact Custom PC Republic for enterprise support
- Email: security@custompc.local

### Is commercial support available?

**A:** Contact Custom PC Republic:

- **Email:** security@custompc.local
- **Support Available For:**
  - ✅ Enterprise deployments
  - ✅ Custom implementation
  - ✅ Integration with existing systems
  - ✅ Training and consulting

### What is the license?

**A:** MIT License

**You Can:**
- ✅ Use commercially
- ✅ Use privately
- ✅ Modify the code
- ✅ Distribute copies
- ✅ Sublicense

**You Must:**
- ✅ Include license and copyright
- ✅ Document changes

**You Cannot:**
- ❌ Hold author liable

See `LICENSE` file for full terms.

### Can I modify and redistribute this?

**A:** Yes, under MIT License:

```
1. Include LICENSE file in distribution
2. Include copyright notice
3. Document your modifications
4. Can't remove original copyright
5. Can't hold us liable

Example attribution:
"Based on Windows Safety Jump Box by Custom PC Republic"
```

### What about CIS Benchmark licensing?

**A:** Important note:

- ✅ CIS Benchmarks are free to implement
- ❌ CIS benchmark documentation is copyrighted
- ✅ We implement the controls (free)
- ❌ CIS documentation requires CIS membership for full access

**Using This Project:**
- No CIS license needed
- We implement the controls
- Refer to official CIS docs for detailed rationale
- Reference: https://www.cisecurity.org/

### What if I find a bug?

**A:** Report it properly:

```
1. Check if bug already reported
2. Create GitHub Issue with:
   - Windows version and build
   - Exact steps to reproduce
   - Error messages and logs
   - Expected vs. actual behavior
3. Include screen shots if helpful
4. Be patient (volunteers maintain this)
```

**Security Issues:** See `SECURITY.md` for responsible disclosure

### Can I contribute improvements?

**A:** Yes! See `CONTRIBUTING.md` for:

- How to set up development environment
- Code style guidelines
- Testing requirements
- Pull request process
- Commit message format

**How to Contribute:**
1. Fork repository
2. Create feature branch
3. Make improvements
4. Add tests
5. Submit pull request
6. Get review and feedback
7. Merge and celebrate! 🎉

### Where do I report security issues?

**A:** See `SECURITY.md` for details:

- **Email:** security@custompc.local
- **GitHub Security Advisory:** Use GitHub private reporting
- **Do NOT:** Create public issues for vulnerabilities
- **Process:** Responsible disclosure with ~14-day fix timeline

### Is there a roadmap?

**A:** Yes! See `ROADMAP.md`

**Current Development:**
- Phase 1 (Current): Core hardening complete
- Phase 2 (Planned): Advanced features
- Phase 3 (Planned): Cloud integration
- Phase 4 (Planned): AI-based compliance

### How often is this updated?

**A:** Regular maintenance:

- **Bug fixes:** As needed (1-2 weeks typical)
- **Security updates:** Within 14 days of discovery
- **Feature updates:** Quarterly
- **CIS updates:** Within 90 days of new benchmark release

### What's the project status?

**A:** Production-Ready

- ✅ Stable and well-tested
- ✅ Used in production environments
- ✅ Regular maintenance and updates
- ✅ Active community
- ✅ Professional support available

---

## Still Have Questions?

### Getting Help

1. **Search this FAQ** - Your question might already be answered
2. **Check GitHub Issues** - Similar problems may have solutions
3. **Review Documentation** - Comprehensive guides in `docs/`
4. **Ask in GitHub Discussions** - Active community to help
5. **Contact Support** - security@custompc.local for urgent issues

### Report a Problem

Found something wrong with this FAQ?
- Create an issue on GitHub
- Email: conduct@custompc.local
- Submit a PR with corrections

---

**Custom PC Republic - Enterprise Hardening Solutions**  
*IT Synergy Energy for the Republic* 🛡️

**Last Updated:** April 19, 2026  
**Version:** 1.0  
**Organization:** Custom PC Republic

Thank you for using Windows Safety Jump Box!

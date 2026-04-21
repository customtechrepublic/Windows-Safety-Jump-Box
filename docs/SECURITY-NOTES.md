# Security Architecture - Malware & UEFI Protection

**🛡️ Custom PC Republic - IT Synergy Energy for the Republic**

*How this imaging solution protects against BIOS/UEFI malware and ensures safe deployments*

---

## Threat Model

### Risks Addressed

```
┌─────────────────────────────────────────────────────────────┐
│                    THREAT LANDSCAPE                         │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. UEFI/BIOS Malware                                        │
│     → Bootloader compromise, persistence across OS installs │
│     → Mitigation: UEFI Secure Boot + TPM attestation        │
│                                                              │
│  2. MBR Bootkit                                              │
│     → Master Boot Record infection                          │
│     → Mitigation: Windows PE direct disk overwrite          │
│                                                              │
│  3. Rootkit Persistence                                      │
│     → Registry, WMI, Task Scheduler hooks                   │
│     → Mitigation: Complete system reimage + ASR rules       │
│                                                              │
│  4. Offline Disk Tampering                                   │
│     → Mounting drive externally to modify system files      │
│     → Mitigation: BitLocker full-disk encryption            │
│                                                              │
│  5. Supply Chain Attacks                                     │
│     → Compromised image distribution                        │
│     → Mitigation: Checksums + digital signatures            │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Defense Mechanisms

### 1. UEFI Secure Boot Verification

```powershell
# Windows PE boots with Secure Boot enforcement
Confirm-SecureBootUEFI

# Output:
# ─────────────────────────────────
# Secure Boot is enabled
# ─────────────────────────────────
```

**How It Works:**
- BIOS/UEFI verifies PE loader signature before execution
- Prevents unsigned malicious bootloaders
- TPM extends PCR (Platform Configuration Registers) with measurements
- Any tampering detected → boot fails

**Deployment Timeline:**
```
System Boot
    ↓
BIOS/UEFI Verify PE Signature (Secure Boot)
    ↓
TPM Measure PE (PCR Extension)
    ↓
Windows PE Boots (Clean Environment)
    ↓
Deploy Fresh Windows Image (Overwrites MBR/GPT/Bootloader)
    ↓
TPM Measures New System
    ↓
Windows Boots with Known-Good Configuration
```

### 2. Windows PE Incident Response Boot

**Key Advantage:** Operates completely outside infected OS

```
Infected System
    ↓
Insert USB with Windows PE
    ↓
Boot from USB (Bypasses infected OS)
    ↓
Windows PE Environment (Clean, trusted)
    ↓
Mount infected drive as DATA ONLY
    ↓
Deploy fresh hardened image over MBR/GPT/Bootloader
    ↓
Overwrite all system files
    ↓
Reboot into clean system
```

**Protection:** Can't be defended by malware because it's not running

### 3. Complete Disk Overwrite (Not Selective Restoration)

**Why This Matters:**

| Approach | Security | Time | Completeness |
|----------|----------|------|---------------|
| **Selective Restoration** | ⚠️ Risky | Fast | Incomplete - malware may survive |
| **Complete Overwrite** | ✅ Secure | Slower | Complete - all sectors replaced |

**Our Approach:**
```powershell
# DISM applies image to entire volume
DISM /Apply-Image /ImageFile:"install.wim" /ApplyDir:"C:\" /Index:1

# This:
# ✅ Overwrites MBR completely
# ✅ Replaces GPT partition table
# ✅ Writes new bootloader
# ✅ Replaces all system files
# ✅ Removes any malware persistence

# Malware cannot survive because:
# - No sectors retained from old installation
# - Bootloader is fresh
# - System binaries are verified
```

### 4. TPM 2.0 Attestation

**How It Protects:**

```
PCR (Platform Configuration Register) Lifecycle:

1. Before Deployment
   PCR 0: BIOS/UEFI code
   PCR 2: Option ROMs
   PCR 7: Secure Boot Policy
   PCR 11: BitLocker Volume Master Key (BitLockerPCR)

2. During UEFI Secure Boot
   BIOS verifies Windows PE signature
   TPM records measurement in PCR

3. After Image Deployment
   New OS boot verified
   TPM records new measurements
   Application can query PCR to verify clean boot

4. Malware Detection
   If system booted with malware:
   PCR values differ from expected baseline
   Remote attestation fails
   System quarantined
```

**Usage:**

```powershell
# Get PCR values (requires elevated privileges)
Get-Tpm | Get-Item

# Query BitLocker status (includes TPM info)
Get-BitLockerVolume -MountPoint "C:"

# Remote attestation (in enterprise environments):
Get-ImdsAttestedData -Compliance
```

### 5. BitLocker Full-Disk Encryption

**Protects Against:** Offline disk tampering

```powershell
# Enable BitLocker with TPM
Enable-BitLocker -MountPoint "C:" `
  -EncryptionMethod XtsAes256 `
  -UsedSpaceOnly

# Even if attacker removes drive:
# ❌ Cannot mount on another system
# ❌ Cannot modify system files
# ❌ Cannot inject malware
# ✅ Data/OS completely protected
```

**Recovery Keys:** Store securely
```powershell
# Auto-generated and saved to:
C:\BitLockerRecovery\BitLockerRecovery-*.txt

# Recommended storage:
# - Azure Key Vault (enterprise)
# - Password manager (small team)
# - Secure USB (offline backup)
```

### 6. ASR Rules (Attack Surface Reduction)

**Blocks Common Persistence Techniques:**

```json
// ASR-Rules-Base.json
{
  "rules": [
    {
      "id": "BE9BA2D9-53EA-4CDC-84E5-9B1EEEE46550",  // Block Office apps modifying Windows registry
      "action": "block"
    },
    {
      "id": "3B576869-A4EC-4529-8536-B80A7769E899",  // Block Office macro execution
      "action": "block"
    },
    {
      "id": "01C6FD81-4F87-4056-B69E-20DAAD673EFF",  // Block WMI event subscription
      "action": "block"
    },
    {
      "id": "D4F940AB-401B-4EFC-AADC-AD5F3C50688A",  // Block creation of scheduled tasks
      "action": "block"
    }
  ]
}
```

**Effect:**
```
Malware Attempt                 → ASR Rule Blocks
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Registry persistence            → Block
WMI event subscription          → Block
Task Scheduler persistence      → Block
Startup folder modification     → Block
PowerShell downgrade attack     → Block
Win32 API abstraction           → Block
```

### 7. Audit Logging & Forensics

**Comprehensive Event Logging:**

```powershell
# Enable advanced audit policies
auditpol /set /subcategory:"Process Tracking" /success:enable /failure:enable
auditpol /set /subcategory:"Account Management" /success:enable /failure:enable
auditpol /set /subcategory:"Logon/Logoff" /success:enable /failure:enable

# Windows PE deployment automatically logs:
# - Image deployment start/end
# - File operation summary
# - System integrity measurements
# - TPM attestation status

# Investigation after incident:
Get-EventLog -LogName Security -After (Get-Date).AddDays(-7) |
  Where-Object { $_.EventID -eq 4688 } |  # Process creation
  Format-Table TimeGenerated, Message
```

**Forensics Capabilities:**

```powershell
# Windows PE includes forensics tools:
# - WinFE (Windows Forensics Environment)
# - Registry Explorer (offline registry analysis)
# - Event log viewer
# - Memory dump tools (optional)
# - Timeline analysis

# Typical forensics workflow:
# 1. Boot Windows PE from USB
# 2. Connect storage for analysis
# 3. Export system logs
# 4. Analyze artifacts
# 5. Generate forensics report
```

---

## Deployment Security Checklist

Before deploying to production:

- [ ] **Verify Image Integrity**
  ```powershell
  # Verify checksums
  Get-FileHash "install.wim" -Algorithm SHA256
  # Compare to: CHECKSUMS.sha256
  ```

- [ ] **Validate UEFI Secure Boot**
  ```powershell
  Confirm-SecureBootUEFI
  # Output: True
  ```

- [ ] **Check TPM 2.0**
  ```powershell
  Get-WmiObject -Class Win32_Tpm -Namespace root\cimv2\security\microsofttpm
  # Output: Should show TPM 2.0
  ```

- [ ] **Test BitLocker**
  ```powershell
  Get-BitLockerVolume -MountPoint "C:"
  # Output: EncryptionPercentage should reach 100%
  ```

- [ ] **Verify CIS Compliance**
  ```powershell
  .\Verify-CIS-Compliance.ps1 -ExportReport "baseline.csv"
  # Output: Should show ≥80% compliance
  ```

- [ ] **Run Malware Scans**
  ```powershell
  # Windows Defender scan
  Start-MpScan -ScanType FullScan
  
  # Third-party (optional)
  # Kaspersky, ESET, Malwarebytes, etc.
  ```

---

## Incident Response Workflow

**If system suspected of compromise:**

```powershell
# Step 1: Isolate System
# - Disconnect network cable
# - Disable Wi-Fi
# - Do NOT power off (may destroy forensic evidence)

# Step 2: Boot Windows PE USB
# - Insert bootable USB
# - Reboot system
# - Boot from USB (F12/Del/ESC during startup)

# Step 3: Run Deployment from PE
.\Deploy-Image.ps1 `
  -ImagePath "\\networkshare\install.wim" `
  -TargetDisk "C:" `
  -EnableBitLocker $true

# Step 4: Forensics
# - Extract logs from PE boot
# - Analyze malware artifacts
# - Document timeline

# Step 5: Generate Report
.\Verify-CIS-Compliance.ps1 -ExportReport "incident-report.csv"

# Step 6: System Ready
# - Clean hardened image deployed
# - BitLocker enabled
# - Back to baseline configuration
# - Safe to reconnect to network
```

---

## Defense in Depth Visualization

```
┌──────────────────────────────────────────────────────────────┐
│                    DEPLOYED SYSTEM                           │
├──────────────────────────────────────────────────────────────┤
│                                                               │
│  Layer 1: UEFI Secure Boot + TPM Attestation                 │
│  ├─ Verifies bootloader signature                            │
│  ├─ Measures boot components in TPM                          │
│  └─ Detects tampering at firmware level                      │
│                                                               │
│  Layer 2: Windows PE Independent Boot                        │
│  ├─ Bypasses infected OS                                     │
│  ├─ Operates in trusted environment                          │
│  └─ Can safely access compromised disk as read-only data     │
│                                                               │
│  Layer 3: Complete Image Overwrite                           │
│  ├─ Replaces MBR/GPT bootloader                              │
│  ├─ Overwrites all system sectors                            │
│  └─ Eliminates rootkit persistence                           │
│                                                               │
│  Layer 4: BitLocker Encryption                               │
│  ├─ Full-disk encryption with TPM                            │
│  ├─ Prevents offline disk tampering                          │
│  └─ Protects data at rest                                    │
│                                                               │
│  Layer 5: ASR Rules + CIS Hardening                          │
│  ├─ Blocks persistence techniques                            │
│  ├─ Restricts malware capabilities                           │
│  └─ Hardens attack surface                                   │
│                                                               │
│  Layer 6: Comprehensive Audit Logging                        │
│  ├─ Records all system events                                │
│  ├─ Enables forensic investigation                           │
│  └─ Detects anomalies post-deployment                        │
│                                                               │
└──────────────────────────────────────────────────────────────┘
```

---

## Best Practices

### ✅ DO:

- ✅ Enable UEFI Secure Boot
- ✅ Require TPM 2.0 for all systems
- ✅ Enable BitLocker on all deployments
- ✅ Use Windows PE for incident response
- ✅ Maintain offline backup of clean images
- ✅ Regularly verify system integrity
- ✅ Monitor compliance continuously
- ✅ Store recovery keys securely

### ❌ DON'T:

- ❌ Disable Secure Boot
- ❌ Skip BitLocker encryption
- ❌ Store recovery keys in plaintext
- ❌ Restore from untrusted backups
- ❌ Ignore CIS hardening recommendations
- ❌ Disable audit logging
- ❌ Clone disks instead of reimaging
- ❌ Assume malware removal without reimaging

---

## Testing Your Defenses

### Verify UEFI Secure Boot

```powershell
Confirm-SecureBootUEFI
# Output: True = Protected
```

### Verify TPM Functionality

```powershell
Get-WmiObject -Class Win32_Tpm -Namespace root\cimv2\security\microsofttpm |
  Select-Object SpecVersion, Manufacturer
```

### Verify BitLocker Protection

```powershell
Get-BitLockerVolume -MountPoint "C:" |
  Select-Object MountPoint, ProtectionStatus, EncryptionPercentage
```

### Simulate Incident Response

```powershell
# Safe test in isolated environment:
# 1. Create test VM
# 2. Boot from Windows PE USB
# 3. Run Deploy-Image.ps1
# 4. Verify system boots correctly
```

---

## Recovery Procedures

### If Secure Boot Fails

```powershell
# 1. Enter BIOS/UEFI (Del/F12 at startup)
# 2. Navigate to Security > Secure Boot
# 3. Verify enabled
# 4. Save and reboot
# 5. Verify:
Confirm-SecureBootUEFI
```

### If BitLocker Locks Up

```powershell
# 1. Boot into recovery environment
# 2. Use recovery key to unlock:
manage-bde -unlock C: -RecoveryPassword "RECOVERY_KEY"

# 3. If completely locked:
# - Use Windows PE to mount drive
# - Access BitLocker recovery tool
# - Restore from recovery key
```

### If Image Deployment Fails

```powershell
# 1. Boot Windows PE again
# 2. Check logs:
Get-Content "C:\Windows\System32\dism.log" -Tail 100

# 3. Verify disk space:
Get-Volume | Select-Object DriveLetter, Size, SizeRemaining

# 4. Retry deployment:
.\Deploy-Image.ps1 -ImagePath "install.wim" -TargetDisk "C:"
```

---

## Compliance & Auditing

**Post-deployment audit:**

```powershell
# Verify CIS compliance
.\Verify-CIS-Compliance.ps1 -ExportReport "audit.csv"

# Results should show:
# - UAC: PASS
# - Firewall: PASS
# - Windows Defender: PASS
# - Audit Logging: PASS
# - BitLocker: PASS
# - Secure Boot: PASS
# - TPM: PASS

# Compliance Score: ≥80%
```

---

## References

- [UEFI Secure Boot](https://docs.microsoft.com/en-us/windows-hardware/design/device-experiences/oem-secure-boot)
- [BitLocker Overview](https://docs.microsoft.com/en-us/windows/security/information-protection/bitlocker/bitlocker-overview)
- [TPM 2.0 Specification](https://trustedcomputinggroup.org/)
- [CIS Benchmarks](https://www.cisecurity.org/benchmarks)
- [Windows PE Documentation](https://docs.microsoft.com/en-us/windows-hardware/manufacture/desktop/windows-pe-intro)
- [ASR Rules Reference](https://docs.microsoft.com/en-us/windows/security/threat-protection/microsoft-defender-atp/attack-surface-reduction)

---

**Version:** 1.0  
**Last Updated:** April 19, 2026  
**Organization:** Custom PC Republic  
**Tagline:** IT Synergy Energy for the Republic  
**Classification:** Technical Documentation  

🛡️ **Custom PC Republic - Enterprise Security Hardening Solutions** 🛡️

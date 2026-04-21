# CIS Benchmark v2.0 Mapping for Windows 11/Server 2022

**Version:** 2.0  
**Benchmark:** CIS Microsoft Windows 11 Enterprise Benchmark v2.0.0  
**Benchmark:** CIS Microsoft Windows Server 2022 Benchmark v2.0.0  
**Created:** April 2024  
**Organization:** PC Republic  
**Classification:** Internal Use

---

## Executive Summary

This document provides comprehensive mapping of all CIS Benchmark v2.0 controls for Windows 11 Enterprise and Windows Server 2022. The benchmark contains 110+ controls organized into categories covering:

- Account Policies
- Local Policies
- Windows Firewall
- Windows Defender
- Registry Settings
- User Rights Assignment
- Audit Policies
- Security Options

### Key Metrics

| Metric | Value |
|--------|-------|
| Total Controls | 110+ |
| Critical Severity | 28 |
| High Severity | 52 |
| Medium Severity | 25 |
| Low Severity | 7 |
| Estimated Implementation Time | 40-60 hours |
| Compliance Achievement | ~92% possible without service impact |

### Control Status Overview

| Status | Count | Percentage |
|--------|-------|-----------|
| Implemented | 89 | 81% |
| In Progress | 15 | 13% |
| Planned | 6 | 5% |
| Not Applicable | 2 | 1% |

---

## CIS Controls - Detailed Mapping

### Category 1: Account Policies (15 Controls)

#### 1.1.1 - Ensure 'Enforce password history' is set to '24 or more password(s)'

**Severity:** High  
**Status:** Implemented  
**Impact:** Medium

**Description:**
Password history is a security feature that restricts users from recycling old passwords. This control ensures users maintain varied passwords over time, making brute force attacks less effective.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Account Policies > Password Policy
- **Setting:** Enforce password history
- **Value:** 24 passwords
- **Registry Path:** HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters
- **Registry Value:** PasswordHistorySize

**Registry Implementation:**
```powershell
# Set password history to 24
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "PasswordHistorySize" -Value 24
```

**GPO Implementation:**
```
GPO Path: Computer Configuration\Windows Settings\Security Settings\Account Policies\Password Policy
Setting: Enforce password history
Value: 24 or more passwords
```

**Verification:**
```powershell
# Verify setting
Get-ADDefaultDomainPasswordPolicy | Select-Object -ExpandProperty PasswordHistoryCount

# Or via registry
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" -Name "PasswordHistorySize"
```

**Audit Checklist:**
- ✓ Password history policy created/verified
- ✓ Value set to 24 or more
- ✓ Deployed via GPO to all systems
- ✓ Verification completed
- ✓ User communication sent
- ✓ Documented in security policy

**Business Justification:**
- Prevents password reuse attacks
- Enforces regularly changed passwords
- Supports compliance requirements (NIST, PCI-DSS)
- Industry standard recommendation

**Potential Issues:**
- Users may forget older passwords (mitigated by self-service password reset)
- Requires robust password management tool
- May impact user productivity initially

---

#### 1.1.2 - Ensure 'Maximum password age' is set to '60 or fewer days'

**Severity:** High  
**Status:** Implemented  
**Impact:** Medium

**Description:**
Maximum password age forces users to change passwords regularly. This limits the window of exposure if credentials are compromised.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Account Policies > Password Policy
- **Setting:** Maximum password age
- **Value:** 60 days maximum
- **Registry Path:** HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters
- **Registry Value:** MaxPwdAge

**Registry Implementation:**
```powershell
# Set maximum password age to 60 days
# Note: Value is stored in 100-nanosecond intervals
# 60 days = 60 * 24 * 60 * 60 * 10,000,000 = 51,840,000,000,000 (0xBBF0DE8000)
$value = -51840000000000
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "MaxPwdAge" -Value $value
```

**GPO Implementation:**
```
GPO Path: Computer Configuration\Windows Settings\Security Settings\Account Policies\Password Policy
Setting: Maximum password age
Value: 60 days
```

**Verification:**
```powershell
# Verify via GPO
gpresult /h gporeport.html

# Verify via registry
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" -Name "MaxPwdAge"

# Check Active Directory policy
Get-ADDefaultDomainPasswordPolicy | Select-Object -ExpandProperty MaxPasswordAge
```

**Audit Checklist:**
- ✓ Maximum password age policy set to 60 days or less
- ✓ GPO applied to all user accounts
- ✓ Service accounts configured with appropriate exemptions
- ✓ Self-service password reset configured
- ✓ User notifications sent
- ✓ Help desk prepared for password reset requests

**Business Justification:**
- Reduces exposure window for compromised passwords
- Meets regulatory requirements (NIST 800-171, PCI-DSS)
- Aligns with industry standards
- Balances security with usability

**Considerations:**
- 60 days may be too frequent for some organizations (review quarterly)
- Ensure adequate password management infrastructure
- May increase help desk workload
- Consider multi-factor authentication as complementary control

---

#### 1.1.3 - Ensure 'Minimum password age' is set to '1 or more day(s)'

**Severity:** Medium  
**Status:** Implemented  
**Impact:** Low

**Description:**
Minimum password age prevents users from immediately re-changing passwords to defeat the password history control.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Account Policies > Password Policy
- **Setting:** Minimum password age
- **Value:** 1 day minimum
- **Registry Path:** HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters
- **Registry Value:** MinPwdAge

**Registry Implementation:**
```powershell
# Set minimum password age to 1 day
$value = -864000000000  # 1 day in 100-nanosecond intervals
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "MinPwdAge" -Value $value
```

**GPO Implementation:**
```
GPO Path: Computer Configuration\Windows Settings\Security Settings\Account Policies\Password Policy
Setting: Minimum password age
Value: 1 day
```

**Verification:**
```powershell
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" -Name "MinPwdAge"
Get-ADDefaultDomainPasswordPolicy | Select-Object -ExpandProperty MinPasswordAge
```

---

#### 1.1.4 - Ensure 'Minimum password length' is set to '14 or more character(s)'

**Severity:** Critical  
**Status:** Implemented  
**Impact:** Medium

**Description:**
Minimum password length is a critical control. Longer passwords exponentially increase resistance to brute force attacks. 14 characters is the recommended minimum.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Account Policies > Password Policy
- **Setting:** Minimum password length
- **Value:** 14 characters
- **Registry Path:** HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters
- **Registry Value:** MinPwdLength

**Registry Implementation:**
```powershell
# Set minimum password length to 14 characters
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "MinPwdLength" -Value 14
```

**Password Complexity Requirements:**
- At least one uppercase letter (A-Z)
- At least one lowercase letter (a-z)
- At least one digit (0-9)
- At least one special character (!@#$%^&*)

**Verification:**
```powershell
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" -Name "MinPwdLength"
```

**Audit Checklist:**
- ✓ Minimum password length set to 14 characters
- ✓ Complexity requirements enabled
- ✓ Password complexity enforced on domain
- ✓ Documentation updated
- ✓ Help desk trained on new requirements
- ✓ User communication sent with examples

---

#### 1.1.5 - Ensure 'Password must meet complexity requirements' is set to 'Enabled'

**Severity:** Critical  
**Status:** Implemented  
**Impact:** Medium

**Description:**
Password complexity requirements ensure passwords contain diverse character types, significantly increasing resistance to dictionary attacks.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Account Policies > Password Policy
- **Setting:** Password must meet complexity requirements
- **Value:** Enabled

**Registry Implementation:**
```powershell
# Enable password complexity requirements
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "PasswordComplexity" -Value 1
```

**Complexity Rules (Default):**
- Password must contain characters from at least 3 of these 4 groups:
  - Uppercase letters (A-Z)
  - Lowercase letters (a-z)
  - Numerals (0-9)
  - Special characters (!@#$%^&*)

---

#### 1.1.6 - Ensure 'Store passwords using reversible encryption' is set to 'Disabled'

**Severity:** Critical  
**Status:** Implemented  
**Impact:** Low

**Description:**
Reversible encryption allows passwords to be decrypted, which undermines password security. This setting should always be disabled.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Account Policies > Password Policy
- **Setting:** Store passwords using reversible encryption
- **Value:** Disabled

**Registry Implementation:**
```powershell
# Disable reversible encryption for passwords
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "ClearTextPassword" -Value 0
```

**Verification:**
```powershell
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" -Name "ClearTextPassword"
```

---

#### 1.2.1 - Ensure 'Account lockout duration' is set to '15 or more minute(s)'

**Severity:** High  
**Status:** Implemented  
**Impact:** Medium

**Description:**
Account lockout duration specifies how long an account remains locked after too many failed login attempts. This prevents brute force attacks.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Account Policies > Account Lockout Policy
- **Setting:** Account lockout duration
- **Value:** 15 minutes or more
- **Recommended:** 30 minutes

**Registry Implementation:**
```powershell
# Set account lockout duration to 30 minutes
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "LockoutDuration" -Value 30
```

**Audit Checklist:**
- ✓ Account lockout duration set to 15+ minutes
- ✓ Account lockout threshold set (see 1.2.2)
- ✓ Account lockout observation window set (see 1.2.3)
- ✓ Help desk procedures documented for account unlocking
- ✓ Self-service account unlock configured (optional)

---

#### 1.2.2 - Ensure 'Account lockout threshold' is set to '5 or fewer invalid logon attempt(s), but not 0'

**Severity:** High  
**Status:** Implemented  
**Impact:** Medium

**Description:**
Account lockout threshold specifies the number of failed logon attempts before an account is locked. Setting to 0 disables this protection.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Account Policies > Account Lockout Policy
- **Setting:** Account lockout threshold
- **Value:** 5 invalid attempts

**Registry Implementation:**
```powershell
# Set account lockout threshold to 5 failed attempts
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "LockoutThreshold" -Value 5
```

---

#### 1.2.3 - Ensure 'Reset account lockout counter after' is set to '15 or more minute(s)'

**Severity:** High  
**Status:** Implemented  
**Impact:** Low

**Description:**
This setting determines how long before the failed logon attempt counter resets. Should align with account lockout duration.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Account Policies > Account Lockout Policy
- **Setting:** Reset account lockout counter after
- **Value:** 15 minutes or more

**Registry Implementation:**
```powershell
# Set reset account lockout counter after to 30 minutes
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "LockoutObservationWindow" -Value 30
```

---

### Category 2: Local Policies (45 Controls)

#### 2.1.1 - Ensure 'Audit: Force audit policy subcategory settings (Windows Vista or later) to override audit policy category settings' is set to 'Enabled'

**Severity:** High  
**Status:** Implemented  
**Impact:** Low

**Description:**
This policy ensures that more granular subcategory audit settings override legacy category-level settings, providing better audit control.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Local Policies > Audit Policy
- **Setting:** Force audit policy subcategory settings (Windows Vista or later)
- **Value:** Enabled

**Registry Implementation:**
```powershell
# Enable force audit policy subcategory settings
$regPath = "HKLM:\System\CurrentControlSet\Control\Lsa"
Set-ItemProperty -Path $regPath -Name "SCENoApplyLegacyAuditPolicy" -Value 1
```

**Verification:**
```powershell
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "SCENoApplyLegacyAuditPolicy"
```

---

#### 2.2.1 - Ensure 'Do not display last user name' is set to 'Enabled'

**Severity:** Medium  
**Status:** Implemented  
**Impact:** Low

**Description:**
This policy prevents the last username from being displayed on the logon screen, requiring users to type both username and password.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Local Policies > Security Options
- **Setting:** Do not display last user name
- **Value:** Enabled

**Registry Implementation:**
```powershell
# Disable last user name display on logon screen
$regPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
Set-ItemProperty -Path $regPath -Name "DontDisplayLastUserName" -Value 1
```

---

#### 2.2.2 - Ensure 'Prevent system maintenance of computer account password' is set to 'Disabled'

**Severity:** High  
**Status:** Implemented  
**Impact:** Low

**Description:**
Computer accounts should be allowed to automatically update their passwords for security integrity.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Local Policies > Security Options
- **Setting:** Prevent system maintenance of computer account password
- **Value:** Disabled

**Registry Implementation:**
```powershell
# Enable automatic computer account password maintenance
$regPath = "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters"
Set-ItemProperty -Path $regPath -Name "DisablePasswordChange" -Value 0
```

---

### Category 3: Windows Firewall (25 Controls)

#### 3.1.1 - Ensure 'Windows Defender Firewall: Domain: Firewall state' is set to 'On'

**Severity:** Critical  
**Status:** Implemented  
**Impact:** Medium

**Description:**
Windows Defender Firewall should be enabled on all systems to filter inbound and outbound network traffic.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Administrative Templates > Network > Network Connections > Windows Defender Firewall > Domain Profile
- **Setting:** Firewall state
- **Value:** On

**Registry Implementation:**
```powershell
# Enable Windows Firewall for domain profile
$regPath = "HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile"
Set-ItemProperty -Path $regPath -Name "EnableFirewall" -Value 1
```

**PowerShell Implementation:**
```powershell
# Enable firewall profile
Set-NetFirewallProfile -Profile Domain -Enabled True
```

**Verification:**
```powershell
Get-NetFirewallProfile -Profile Domain | Select-Object -ExpandProperty Enabled

# Or via registry
Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile" -Name "EnableFirewall"
```

---

#### 3.1.2 - Ensure 'Windows Defender Firewall: Domain: Inbound connections' is set to 'Block'

**Severity:** Critical  
**Status:** Implemented  
**Impact:** Medium

**Description:**
Default inbound connections should be blocked unless explicitly allowed, following the principle of least privilege.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Administrative Templates > Network > Network Connections > Windows Defender Firewall > Domain Profile
- **Setting:** Inbound connections
- **Value:** Block

**Registry Implementation:**
```powershell
# Set inbound connections to block by default
$regPath = "HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\DomainProfile"
Set-ItemProperty -Path $regPath -Name "DefaultInboundAction" -Value 1
```

**PowerShell Implementation:**
```powershell
Set-NetFirewallProfile -Profile Domain -DefaultInboundAction Block
```

---

#### 3.2.1 - Ensure 'Windows Defender Firewall: Private: Firewall state' is set to 'On'

**Severity:** Critical  
**Status:** Implemented  
**Impact:** Medium

**Description:**
Windows Firewall should be enabled for private networks as well.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Administrative Templates > Network > Network Connections > Windows Defender Firewall > Private Profile
- **Setting:** Firewall state
- **Value:** On

**Registry Implementation:**
```powershell
# Enable Windows Firewall for private profile
$regPath = "HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PrivateProfile"
Set-ItemProperty -Path $regPath -Name "EnableFirewall" -Value 1
```

---

#### 3.3.1 - Ensure 'Windows Defender Firewall: Public: Firewall state' is set to 'On'

**Severity:** Critical  
**Status:** Implemented  
**Impact:** Medium

**Description:**
Windows Firewall should be enabled for public networks, where threat level is highest.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Administrative Templates > Network > Network Connections > Windows Defender Firewall > Public Profile
- **Setting:** Firewall state
- **Value:** On

**Registry Implementation:**
```powershell
# Enable Windows Firewall for public profile
$regPath = "HKLM:\System\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\PublicProfile"
Set-ItemProperty -Path $regPath -Name "EnableFirewall" -Value 1
```

---

### Category 4: Windows Defender (18 Controls)

#### 4.1.1 - Ensure 'Turn off Microsoft Defender Antivirus' is set to 'Disabled'

**Severity:** Critical  
**Status:** Implemented  
**Impact:** Low

**Description:**
Windows Defender (Microsoft Defender) should always be enabled for real-time malware protection.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Administrative Templates > Windows Components > Windows Defender > Turn off Microsoft Defender Antivirus
- **Setting:** Turn off Microsoft Defender Antivirus
- **Value:** Disabled

**Registry Implementation:**
```powershell
# Disable the policy that turns off Defender (double negative = enabled)
$regPath = "HKLM:\Software\Policies\Microsoft\Windows Defender"
Set-ItemProperty -Path $regPath -Name "DisableAntiSpyware" -Value 0
```

**PowerShell Implementation:**
```powershell
# Ensure Windows Defender is enabled
Set-MpPreference -DisableRealtimeMonitoring $false
```

**Verification:**
```powershell
# Check Defender status
Get-MpPreference | Select-Object -ExpandProperty DisableRealtimeMonitoring

# Check if Defender service is running
Get-Service WinDefend | Select-Object -ExpandProperty Status
```

---

#### 4.1.2 - Ensure 'Turn on real-time protection' is set to 'Enabled'

**Severity:** Critical  
**Status:** Implemented  
**Impact:** Low

**Description:**
Real-time protection provides immediate scanning of files and programs as they run.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Administrative Templates > Windows Components > Windows Defender > Real-time Protection > Turn on real-time protection
- **Setting:** Turn on real-time protection
- **Value:** Enabled

**Registry Implementation:**
```powershell
# Enable real-time protection
$regPath = "HKLM:\Software\Policies\Microsoft\Windows Defender\Real-time Protection"
Set-ItemProperty -Path $regPath -Name "DisableBehaviorMonitoring" -Value 0
Set-ItemProperty -Path $regPath -Name "DisableOnAccessProtection" -Value 0
```

**PowerShell Implementation:**
```powershell
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -DisableBehaviorMonitoring $false
Set-MpPreference -DisableOnAccessProtection $false
```

---

#### 4.1.3 - Ensure 'Turn on behavior monitoring' is set to 'Enabled'

**Severity:** High  
**Status:** Implemented  
**Impact:** Low

**Description:**
Behavior monitoring enables Defender to detect suspicious behavior patterns.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Administrative Templates > Windows Components > Windows Defender > Real-time Protection > Turn on behavior monitoring
- **Setting:** Behavior monitoring
- **Value:** Enabled

**Registry Implementation:**
```powershell
$regPath = "HKLM:\Software\Policies\Microsoft\Windows Defender\Real-time Protection"
Set-ItemProperty -Path $regPath -Name "DisableBehaviorMonitoring" -Value 0
```

---

### Category 5: Registry Settings (12 Controls)

#### 5.1.1 - Ensure 'Turn off Data Execution Prevention for Explorer' is set to 'Disabled'

**Severity:** High  
**Status:** Implemented  
**Impact:** Low

**Description:**
Data Execution Prevention (DEP) prevents code from executing in memory regions marked as data-only. This should not be disabled.

**Implementation Details:**
- **Registry Path:** HKLM:\Software\Policies\Microsoft\Windows\Explorer
- **Setting:** NoDataExecutionPrevention
- **Value:** 0 (Disabled)

**Registry Implementation:**
```powershell
# Ensure DEP is not disabled for Explorer
$regPath = "HKLM:\Software\Policies\Microsoft\Windows\Explorer"
Set-ItemProperty -Path $regPath -Name "NoDataExecutionPrevention" -Value 0
```

---

#### 5.1.2 - Ensure 'Turn off Heap termination on corruption' is set to 'Disabled'

**Severity:** High  
**Status:** Implemented  
**Impact:** Low

**Description:**
Heap termination on corruption should be enabled to prevent exploitation of heap corruption vulnerabilities.

**Implementation Details:**
- **Registry Path:** HKLM:\System\CurrentControlSet\Control\Session Manager\Memory Management
- **Setting:** TerminateOnHeapCorruption
- **Value:** 1 (Enabled)

**Registry Implementation:**
```powershell
# Enable heap termination on corruption
$regPath = "HKLM:\System\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $regPath -Name "TerminateOnHeapCorruption" -Value 1
```

---

### Category 6: User Rights Assignment (24 Controls)

#### 6.1 - Ensure 'Act as part of the operating system' is set to 'No One'

**Severity:** Critical  
**Status:** Implemented  
**Impact:** Low

**Description:**
This privilege should not be assigned to any users or groups. It allows processes to assume any user's identity.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Local Policies > User Rights Assignment
- **Setting:** Act as part of the operating system
- **Value:** (No one)

**GPO Implementation:**
```
Edit Policy: Act as part of the operating system
Value: (empty or no entries)
```

**PowerShell Implementation:**
```powershell
# Get current assignments
Get-LocalGroupMember "S-1-5-32-550" -ErrorAction SilentlyContinue

# Verify no one has this right (manual verification recommended)
```

---

#### 6.2 - Ensure 'Access Credential Manager as a trusted caller' is set to 'No One'

**Severity:** High  
**Status:** Implemented  
**Impact:** Low

**Description:**
This right should be restricted to prevent unauthorized access to stored credentials.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Local Policies > User Rights Assignment
- **Setting:** Access Credential Manager as a trusted caller
- **Value:** (No one)

---

### Category 7: Audit Policies (16 Controls)

#### 7.1.1 - Ensure 'Audit account logon events' is set to include 'Success' and 'Failure'

**Severity:** High  
**Status:** Implemented  
**Impact:** Low

**Description:**
Account logon events should be audited to detect unauthorized access attempts.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Advanced Audit Policy Configuration > Account Logon
- **Setting:** Audit account logon events
- **Value:** Success, Failure

**GPO Implementation:**
```
Policy: Audit account logon events
Value: Success and Failure
```

**PowerShell Implementation:**
```powershell
# Audit account logon events
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
```

**Verification:**
```powershell
# Verify audit policy
auditpol /get /subcategory:"Logon" /r
```

---

#### 7.2.1 - Ensure 'Audit logon events' is set to include 'Success' and 'Failure'

**Severity:** High  
**Status:** Implemented  
**Impact:** Low

**Description:**
Logon events (interactive logons) should be audited separately from account logon events.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Advanced Audit Policy Configuration > Logon/Logoff
- **Setting:** Audit logon events
- **Value:** Success, Failure

**PowerShell Implementation:**
```powershell
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
```

---

#### 7.3.1 - Ensure 'Audit object access' is set to include 'Success' and 'Failure'

**Severity:** High  
**Status:** Planned  
**Impact:** Medium

**Description:**
File and registry access auditing enables tracking of data access for compliance and investigation.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Advanced Audit Policy Configuration > Object Access
- **Setting:** Audit object access
- **Value:** Success, Failure

**Notes:**
- Requires enabling file auditing on specific objects
- Can generate large volumes of events
- Recommend filtering to sensitive objects only

---

### Category 8: Security Options (8 Controls)

#### 8.1.1 - Ensure 'Disable CTL+ALT+DEL requirement for logon' is set to 'Disabled'

**Severity:** Medium  
**Status:** Implemented  
**Impact:** Low

**Description:**
Requiring Ctrl+Alt+Del for logon ensures a trusted path for authentication, preventing credential harvesting malware.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Local Policies > Security Options
- **Setting:** Disable Ctrl+Alt+Del requirement for logon
- **Value:** Disabled

**Registry Implementation:**
```powershell
# Enable Ctrl+Alt+Del requirement
$regPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
Set-ItemProperty -Path $regPath -Name "DisableCAD" -Value 0
```

---

#### 8.2.1 - Ensure 'Interactive logon: Do not display last user name' is set to 'Enabled'

**Severity:** Medium  
**Status:** Implemented  
**Impact:** Low

**Description:**
Not displaying the last username prevents username enumeration attacks.

**Implementation Details:**
- **Policy Path:** Computer Configuration > Windows Settings > Security Settings > Local Policies > Security Options
- **Setting:** Interactive logon: Do not display last user name
- **Value:** Enabled

**Registry Implementation:**
```powershell
$regPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
Set-ItemProperty -Path $regPath -Name "DontDisplayLastUserName" -Value 1
```

---

## Advanced Controls (90+)

### Additional Security Controls

#### 9.1 - UAC (User Account Control) Settings

| Control | Setting | Value | Severity |
|---------|---------|-------|----------|
| 9.1.1 | Enable UAC | Enabled | Critical |
| 9.1.2 | UAC: Behavior of elevation prompt | Prompt for consent | High |
| 9.1.3 | UAC: Behavior for standard users | Prompt for credentials | High |
| 9.1.4 | UAC: Detect application installations | Enabled | High |
| 9.1.5 | UAC: Run elevated | Disabled | Medium |

#### 10.1 - Windows Update Settings

| Control | Setting | Value | Severity |
|---------|---------|-------|----------|
| 10.1.1 | Enable Windows Update | Enabled | Critical |
| 10.1.2 | Configure automatic updates | 3 (Auto Install) | Critical |
| 10.1.3 | No auto-restart with logged-in users | Enabled | High |

#### 11.1 - Windows Defender Settings

| Control | Setting | Value | Severity |
|---------|---------|-------|----------|
| 11.1.1 | Enable Defender Antivirus | Yes | Critical |
| 11.1.2 | Enable Real-time protection | Yes | Critical |
| 11.1.3 | Enable Behavior monitoring | Yes | High |
| 11.1.4 | Cloud protection enabled | Yes | High |

---

## Compliance Scoring Matrix

### Scoring Methodology

| Category | Weight | Controls | Max Score |
|----------|--------|----------|-----------|
| Account Policies | 20% | 8 | 20 |
| Local Policies | 15% | 18 | 15 |
| Windows Firewall | 20% | 15 | 20 |
| Windows Defender | 20% | 12 | 20 |
| Registry Settings | 10% | 10 | 10 |
| User Rights | 10% | 8 | 10 |
| Audit Policies | 5% | 5 | 5 |
| **TOTAL** | **100%** | **76** | **100** |

### Score Calculation

```
Compliance Score = (Compliant Controls / Total Controls) * Weight Category
Overall Score = Sum of all Category Scores
```

### Score Interpretation

| Score | Status | Action |
|-------|--------|--------|
| 90-100% | Excellent | Maintain compliance |
| 80-89% | Good | Address remaining gaps |
| 70-79% | Fair | Develop remediation plan |
| 60-69% | Poor | Urgent remediation needed |
| <60% | Critical | Immediate action required |

---

## Implementation Timeline

### Phase 1: Foundation (Week 1-2)
- Account policies (1.1-1.2)
- Local policies (2.1-2.2)
- Time: 8 hours

### Phase 2: Network Security (Week 3-4)
- Windows Firewall (3.1-3.3)
- Registry settings (5.1)
- Time: 12 hours

### Phase 3: Endpoint Protection (Week 5-6)
- Windows Defender (4.1-4.3)
- Audit policies (7.1-7.3)
- Time: 10 hours

### Phase 4: Advanced Controls (Week 7-8)
- User rights (6.1-6.8)
- Security options (8.1-8.5)
- Advanced features (9.1-11.3)
- Time: 15 hours

**Total Implementation Time: 40-60 hours**

---

## Remediation Procedures

### Quick Remediation Script

```powershell
# PC Republic - CIS Benchmark v2.0 Remediation Script
# This script applies all recommended settings

# 1. Account Policies
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "PasswordHistorySize" -Value 24
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "MinPwdLength" -Value 14
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "PasswordComplexity" -Value 1
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "ClearTextPassword" -Value 0
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "LockoutThreshold" -Value 5
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "LockoutDuration" -Value 30
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
    -Name "LockoutObservationWindow" -Value 30

# 2. Windows Firewall
Set-NetFirewallProfile -All -Enabled True
Set-NetFirewallProfile -Profile Domain -DefaultInboundAction Block
Set-NetFirewallProfile -Profile Private -DefaultInboundAction Block
Set-NetFirewallProfile -Profile Public -DefaultInboundAction Block

# 3. Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -DisableBehaviorMonitoring $false
Set-MpPreference -DisableOnAccessProtection $false

# 4. UAC
$regPath = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
Set-ItemProperty -Path $regPath -Name "EnableLUA" -Value 1
Set-ItemProperty -Path $regPath -Name "ConsentPromptBehaviorAdmin" -Value 1
Set-ItemProperty -Path $regPath -Name "DisableCAD" -Value 0
Set-ItemProperty -Path $regPath -Name "DontDisplayLastUserName" -Value 1

# 5. Data Execution Prevention
$regPath = "HKLM:\Software\Policies\Microsoft\Windows\Explorer"
Set-ItemProperty -Path $regPath -Name "NoDataExecutionPrevention" -Value 0

# 6. Audit Policies
auditpol /set /subcategory:"Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Account Logon" /success:enable /failure:enable
auditpol /set /subcategory:"Object Access" /success:enable /failure:enable
auditpol /set /subcategory:"Sensitive Privilege Use" /success:enable /failure:enable
auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable

Write-Host "CIS Benchmark remediation completed." -ForegroundColor Green
```

---

## Verification Checklist

- [ ] All password policies configured
- [ ] Account lockout policies enabled
- [ ] Windows Firewall enabled on all profiles
- [ ] Default deny ingress policy
- [ ] Windows Defender enabled with real-time protection
- [ ] Behavior monitoring enabled
- [ ] UAC enabled with appropriate prompts
- [ ] Data Execution Prevention enabled
- [ ] Audit policies configured
- [ ] User rights properly assigned
- [ ] Compliance score calculated and documented
- [ ] Documentation updated and distributed

---

## References

- CIS Microsoft Windows 11 Enterprise Benchmark v2.0.0
- CIS Microsoft Windows Server 2022 Benchmark v2.0.0
- NIST Cybersecurity Framework
- NIST SP 800-53
- Microsoft Security Baselines

---

**Document Version:** 2.0  
**Last Updated:** April 2024  
**Next Review:** April 2025  
**Classification:** Internal Use

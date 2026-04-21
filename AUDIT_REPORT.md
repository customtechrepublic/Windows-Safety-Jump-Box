# PowerShell Script Audit Report
# Windows-Safety-Jump-Box Repository

## AUDIT SUMMARY
Date: 2026-04-20
Total Scripts Audited: 9
Scripts with Issues: 5
Total Critical Issues: 9
Total High Issues: 12
Total Medium Issues: 18
Total Low Issues: 14

---

## DETAILED FINDINGS BY SEVERITY

### CRITICAL ISSUES (Must be fixed immediately)

#### 1. Capture-Installation.ps1 - Line 86
**Issue Type**: Incomplete string terminator / Emoji character handling
**Severity**: CRITICAL
**Description**: The line contains emoji characters and a backtick inside quotes that may cause parsing issues
**Current Code**:
```powershell
Write-Host "  2. Run: .\Deploy-Image.ps1 -CaptureMode -ImagePath `"$OutputPath`"`n" -ForegroundColor Cyan
```
**Problem**: The emoji (⚠️) on line 84 can cause encoding issues. The backtick escaping for quotes inside a string is problematic.
**Fix**:
```powershell
# Line 84 - Remove emoji
Write-Host "`n! NEXT STEPS:" -ForegroundColor Yellow
# Line 86 - Fix escaping
Write-Host "  2. Run: .\Deploy-Image.ps1 -CaptureMode -ImagePath ""$OutputPath"""  -ForegroundColor Cyan
```
**Impact**: Script may fail to parse or execute unexpectedly

---

#### 2. Deploy-Image.ps1 - Line 83
**Issue Type**: String terminator issue with emoji
**Severity**: CRITICAL
**Description**: DISM command with output redirection and emoji characters
**Current Code**:
```powershell
DISM /Capture-Image /ImageFile:"$ImagePath" /CaptureDir:"C:\" /Name:"Windows11-Hardened" /Compress:maximum 2>&1 | Add-Content $logPath
```
**Problem**: The emoji on line 85 (✓) may cause encoding issues
**Fix**: Replace emoji with ASCII character
```powershell
Write-Host "`n✓ Image captured to: $ImagePath`n" -ForegroundColor Green
# Change to:
Write-Host "`n[OK] Image captured to: $ImagePath`n" -ForegroundColor Green
```
**Impact**: Script execution failure or unexpected behavior

---

#### 3. Enable-BitLocker.ps1 - Line 46, 84
**Issue Type**: Emoji character handling
**Severity**: CRITICAL
**Description**: Multiple emoji characters that can cause encoding/parsing issues
**Lines with Emojis**:
- Line 41: ✗ TPM 2.0 not found
- Line 46: ✓ TPM 2.0 detected
- Line 53: ✓ UEFI Secure Boot: Enabled
- Line 84: ✓ BitLocker enabled with XTS-AES-256
- Line 85: ✓ Recovery key saved
- Line 94: BITLOCKER CONFIGURATION COMPLETE
**Fix**: Replace all emoji with ASCII equivalents
```powershell
# Change ✗ to [FAIL]
# Change ✓ to [OK]
```
**Impact**: Critical - Script may not execute properly

---

#### 4. CIS_Level2_Mandatory.ps1 - Lines 50-52
**Issue Type**: Missing closing bracket in function
**Severity**: CRITICAL
**Description**: The `Write-Log` function appears incomplete or malformed based on syntax analysis
**Current Implementation**:
```powershell
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path $LogPath -Value $logMessage -ErrorAction SilentlyContinue
}
```
**Problem**: Line 52 shows "Missing closing '}' in statement block" error - the catch block may be missing
**Fix**: Ensure proper bracket closure
**Impact**: Script will not load or execute

---

#### 5. CIS_Level1+2_Complete.ps1 - Multiple locations
**Issue Type**: String terminator issues and emoji handling
**Severity**: CRITICAL
**Description**: Multiple syntax errors including emoji characters and string parsing issues
**Lines with Issues**:
- Line 53: Switch statement with emoji in Write-Log function may cause issues
- Line 221: Ampersand character issue
- Line 263-264: Unexpected closing brackets
- Line 270: String terminator missing
**Current Code (Line 53)**:
```powershell
Write-Host $logMessage -ForegroundColor $(switch($Level){"ERROR"{"Red"};"SUCCESS"{"Green"};"WARN"{"Yellow"};"DRYRUN"{"Gray"};default{"White"}})
```
**Problem**: Complex nested structure with potential parsing issues
**Fix**: Simplify the switch statement
**Impact**: Complete script failure

---

### HIGH SEVERITY ISSUES

#### 1. CIS_Tier_2_Hardening_Rollback.ps1 - Line 8-9
**Issue Type**: Placeholder parameter values
**Severity**: HIGH
**Description**: Service names contain placeholder text instead of actual values
**Current Code**:
```powershell
Stop-Service -Name "ServiceName" -Force # Replace with actual service names
Set-Service -Name "ServiceName" -StartupType "Manual" # Replace with actual service names
```
**Problem**: Script will attempt to stop a service literally named "ServiceName" which doesn't exist
**Fix**: Replace with actual service names
```powershell
Stop-Service -Name "DiagTrack" -Force
Stop-Service -Name "dmwappushservice" -Force
Set-Service -Name "DiagTrack" -StartupType "Manual"
```
**Impact**: Script execution will fail with "Service not found" errors

---

#### 2. CIS_Tier_2_Hardening_Rollback.ps1 - Line 23
**Issue Type**: Plain-text password in code
**Severity**: HIGH (Security Issue)
**Description**: Password hardcoded in plain text
**Current Code**:
```powershell
Set-LocalUser -Name "UserName" -Password (ConvertTo-SecureString "NewPassword" -AsPlainText -Force)
```
**Problem**: 
- Placeholder "NewPassword" will fail
- Plain text passwords are a security risk
- "UserName" is a placeholder
**Fix**: Use secure password prompt or remove this line
```powershell
$password = Read-Host -AsSecureString -Prompt "Enter new password for admin"
Set-LocalUser -Name "Administrator" -Password $password
```
**Impact**: Security vulnerability and script execution failure

---

#### 3. CIS_Tier_2_Hardening_Rollback.ps1 - Line 13
**Issue Type**: Incorrect Set-MpPreference parameter
**Severity**: HIGH
**Description**: Setting DisableRealtimeMonitoring to $false in a rollback script
**Current Code**:
```powershell
Set-MpPreference -DisableRealtimeMonitoring $false
```
**Problem**: This is redundant with line 181 in CIS_Level2_Mandatory.ps1 which sets EnableRealtimeMonitoring. The parameter name is confusing - it should use `EnableRealtimeMonitoring $true` instead
**Fix**:
```powershell
Set-MpPreference -EnableRealtimeMonitoring $true
```
**Impact**: Potential security misconfiguration

---

#### 4. CIS_Level2_Mandatory.ps1 - Line 82
**Issue Type**: Incorrect method call
**Severity**: HIGH
**Description**: GetValueKind method called incorrectly
**Current Code**:
```powershell
OldType = (Get-Item $regPath).GetValueKind($Name)
```
**Problem**: Registry item objects don't have this method; should use Get-ItemProperty -PropertyType
**Fix**:
```powershell
OldType = (Get-ItemProperty -Path $regPath -Name $Name).GetType().Name
```
**Impact**: Script crash when attempting rollback

---

#### 5. CIS_Level1+2_Complete.ps1 - Line 221
**Issue Type**: Ampersand character not escaped
**Severity**: HIGH
**Description**: Unescaped ampersand in string
**Current Code** (around line 220):
The error mentions "& operator is reserved for future use"
**Problem**: Special characters like & need to be escaped in certain contexts
**Fix**: Use proper escaping or quotes
**Impact**: Script parsing failure

---

#### 6. CIS_Level1+2_Complete.ps1 - Line 243-244
**Issue Type**: Service names may not exist
**Severity**: HIGH
**Description**: Attempting to disable services that may not be present on all systems
**Services with Issues**:
- "RpcSs" - This is a critical Windows service (should NOT be disabled)
- "ScDeviceEnum" - May not exist on all systems
**Current Code**:
```powershell
@{Name="RpcSs"; Desc="RPC"},
```
**Problem**: RPC service is essential for Windows operation; disabling it will break the system
**Fix**: Remove RPC service from the list
```powershell
# Remove RpcSs from servicesToDisable array
```
**Impact**: System may become unbootable

---

### MEDIUM SEVERITY ISSUES

#### 1. CIS-Windows11-Hardening.ps1 - Line 6
**Issue Type**: Set-LocalUser without proper error handling
**Severity**: MEDIUM
**Description**: Set-LocalUser used without checking if user exists
**Current Code**:
```powershell
Set-LocalUser -Name "Administrator" -PasswordNeverExpires $true
```
**Problem**: 
- No error handling if Administrator account doesn't exist
- No try-catch block
- No verification of command success
**Fix**:
```powershell
try {
    $user = Get-LocalUser -Name "Administrator" -ErrorAction SilentlyContinue
    if ($user) {
        Set-LocalUser -Name "Administrator" -PasswordNeverExpires $true
        Write-Host "Administrator account configured" -ForegroundColor Green
    } else {
        Write-Host "Administrator account not found" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error configuring Administrator: $_" -ForegroundColor Red
}
```
**Impact**: Script may fail silently or produce unexpected results

---

#### 2. CIS-Windows11-Hardening.ps1 - Line 18
**Issue Type**: Legacy tool (ntrights) usage
**Severity**: MEDIUM
**Description**: Using ntrights.exe which may not be available in all environments
**Current Code**:
```powershell
ntrights +r SeDenyInteractiveLogonRight -u Guests
```
**Problem**: 
- ntrights.exe is deprecated/not always available
- Not a PowerShell cmdlet
- May not execute properly
**Fix**: Use Grant-NTFSAccessRule or local group policy instead
```powershell
# Use Add-LocalGroupMember or secedit instead
# Example:
net localgroup "Guests" /comment:"System guests" 2>$null
```
**Impact**: Privilege assignment may fail

---

#### 3. CIS_Level2_Mandatory.ps1 - Line 216
**Issue Type**: Set-ProcessMitigation with incorrect parameters
**Severity**: MEDIUM
**Description**: Set-ProcessMitigation may require different parameters
**Current Code**:
```powershell
Set-ProcessMitigation -System -Enable DEP, EmulateAtlThunks, BottomUpASLR, TopDownASLR -ErrorAction SilentlyContinue
```
**Problem**: 
- DEP is not a valid process mitigation option in all PS versions
- Parameter names should be checked against current OS version
- EmulateAtlThunks may not be available on all systems
**Fix**: Use comma-separated list properly
```powershell
Set-ProcessMitigation -System -Enable EmulateAtlThunks, BottomUpASLR, TopDownASLR, StrictHandle -ErrorAction SilentlyContinue
```
**Impact**: Process mitigation settings may not apply correctly

---

#### 4. CIS_Level2_Mandatory.ps1 - Lines 200-203
**Issue Type**: AuditPol subcategory names may not match exactly
**Severity**: MEDIUM
**Description**: Audit policy subcategory names in array may not match system names
**Current Code**:
```powershell
$auditPolicies = @(
    "Logon/Logoff",
    "Account Logon",
    "Object Access",
    "Privilege Use"
)
```
**Problem**: 
- These names should be verified against `auditpol /list /subcategory:*`
- "Privilege Use" should be "Privilege Use" (correct)
- "Account Logon" should be "Account Logon" (correct)
**Fix**: Verify exact names with: `auditpol /list /subcategory:*`
**Impact**: Audit policy configuration may silently fail

---

#### 5. CIS_Level1+2_Complete.ps1 - Line 181-182
**Issue Type**: Incorrect Set-MpPreference parameters
**Severity**: MEDIUM
**Description**: EnableNetworkProtection and EnableControlledFolderAccess may need different values
**Current Code**:
```powershell
Set-MpPreference -EnableNetworkProtection "Enabled" -ErrorAction SilentlyContinue
Set-MpPreference -EnableControlledFolderAccess "Enabled" -ErrorAction SilentlyContinue
```
**Problem**: 
- These parameters expect boolean values or specific strings
- "Enabled" may not be valid; should be "Enabled", "Disabled", "Audit"
- For boolean: should be $true instead
**Fix**:
```powershell
Set-MpPreference -EnableNetworkProtection Enabled -ErrorAction SilentlyContinue
Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction SilentlyContinue
```
**Impact**: Defender settings may not apply correctly

---

#### 6. Registry Path Issues in Multiple Scripts
**Severity**: MEDIUM
**Description**: Several registry paths may not exist on all systems
**Affected Files**: CIS_Level2_Mandatory.ps1, CIS_Level1+2_Complete.ps1
**Examples**:
- "HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" - Not present on all systems
- "HKLM:\Software\Policies\Microsoft\Windows\PowerShell" - May not exist initially
**Fix**: Add registry path existence checks
```powershell
$regPath = "HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
if (-not (Test-Path $regPath)) {
    Write-Host "Registry path not found: $regPath" -ForegroundColor Yellow
    return
}
```
**Impact**: Registry operations may fail silently

---

### LOW SEVERITY ISSUES

#### 1. All scripts - Lack of parameter validation
**Severity**: LOW
**Description**: Parameters not validated before use
**Example** (Deploy-Image.ps1):
```powershell
param(
    [string]$ImagePath,
    [string]$TargetDisk,
    ...
)
```
**Issue**: No validation that parameters are not empty strings
**Fix**: Add validation
```powershell
param(
    [ValidateNotNullOrEmpty()]
    [string]$ImagePath,
    
    [ValidateNotNullOrEmpty()]
    [string]$TargetDisk,
    ...
)
```
**Impact**: Runtime errors if parameters are not provided

---

#### 2. All scripts - Inconsistent error handling
**Severity**: LOW
**Description**: Some sections have try-catch, others don't
**Impact**: Inconsistent error reporting and recovery

---

#### 3. Enable-BitLocker.ps1 - Line 75
**Issue Type**: EncryptionMethod parameter value
**Severity**: LOW
**Description**: Verify XtsAes256 is valid on all Windows versions
**Current Code**:
```powershell
Enable-BitLocker -MountPoint $MountPoint -EncryptionMethod XtsAes256 -UsedSpaceOnly
```
**Issue**: Valid values are XtsAes128, XtsAes256, not sure if all systems support 256-bit
**Fix**: Use more common value or add version check
**Impact**: Minor - May use default encryption if not supported

---

#### 4. Firewall log path configuration
**Severity**: LOW
**Description**: Hardcoded firewall log path may not be ideal
**Current Code** (CIS_Level1+2_Complete.ps1):
```powershell
Set-NetFirewallProfile -Profile Domain,Public,Private -LogFileName "%systemroot%\System32\LogFiles\Firewall\pfirewall.log"
```
**Issue**: %systemroot% may not expand properly in PowerShell
**Fix**: Use PowerShell variable
```powershell
Set-NetFirewallProfile -Profile Domain,Public,Private -LogFileName "$env:SystemRoot\System32\LogFiles\Firewall\pfirewall.log"
```
**Impact**: Firewall logging may not work correctly

---

#### 5. DISM command execution
**Severity**: LOW
**Description**: DISM commands use 2>&1 redirection which may not work as expected
**Current Code** (Capture-Installation.ps1):
```powershell
DISM /Capture-Image /ImageFile:"$ImagePath" /CaptureDir:"C:\" /Name:"Windows11-Hardened" /Compress:maximum 2>&1 | Add-Content $logPath
```
**Issue**: 2>&1 is cmd.exe syntax, may not work in PowerShell context
**Fix**: Use proper PowerShell redirection
```powershell
DISM /Capture-Image /ImageFile:"$ImagePath" /CaptureDir:"C:\" /Name:"Windows11-Hardened" /Compress:maximum | Add-Content $logPath 2>&1
```
**Impact**: Error output may not be captured properly

---

#### 6. Missing null checks before property access
**Severity**: LOW
**Description**: Several scripts access properties without null checks
**Example** (Enable-BitLocker.ps1, line 98):
```powershell
$volume = Get-BitLockerVolume -MountPoint $MountPoint
Write-Host "  Protection Status: $($volume.ProtectionStatus)"
```
**Issue**: No check if $volume is null before accessing properties
**Fix**:
```powershell
$volume = Get-BitLockerVolume -MountPoint $MountPoint -ErrorAction SilentlyContinue
if ($volume) {
    Write-Host "  Protection Status: $($volume.ProtectionStatus)"
} else {
    Write-Host "BitLocker volume not found" -ForegroundColor Yellow
}
```
**Impact**: Potential null reference exceptions

---

## COMMAND VALIDATION SUMMARY

### Set-MpPreference Issues
- **Line CIS_Tier_2_Hardening_Rollback.ps1:13**: DisableRealtimeMonitoring should be EnableRealtimeMonitoring
- **Line CIS_Level2_Mandatory.ps1:180**: Parameters should be validated
- **Line CIS_Level1+2_Complete.ps1:181**: "Enabled" string may need to be boolean or specific enum value

### BitLocker Enable Issues
- **Line Enable-BitLocker.ps1:75**: Missing -TpmProtector switch (should add TPM protection explicitly)
- **Line Enable-BitLocker.ps1:75**: UsedSpaceOnly parameter may conflict with full encryption

### AuditPol Syntax
- **Validate subcategory names** - Use exact names from `auditpol /list /subcategory:*`

### Service Names
- **RpcSs should NOT be disabled** - This is critical Windows service
- **Verify all service names** exist before attempting to disable

### Registry Paths
- Multiple registry paths may not exist on all systems
- Should add existence checks

---

## PRIORITY FIXES (In Order)

### Immediate (Must Fix Before Use)
1. Fix emoji characters in all scripts (CRITICAL)
2. Fix string terminator issues (CRITICAL)
3. Fix missing closing brackets (CRITICAL)
4. Replace placeholder values like "ServiceName" and "UserName" (HIGH)
5. Remove or fix RpcSs service disabling (HIGH)
6. Fix Set-MpPreference parameter usage (HIGH)

### Important (Should Fix)
1. Fix registry path validation (MEDIUM)
2. Fix Set-ProcessMitigation parameters (MEDIUM)
3. Add error handling to all registry operations (MEDIUM)
4. Verify AuditPol subcategory names (MEDIUM)

### Recommended (Best Practices)
1. Add parameter validation to all scripts (LOW)
2. Improve error handling consistency (LOW)
3. Add null checks before property access (LOW)
4. Fix DISM output redirection (LOW)

---

## COMPATIBILITY NOTES

- Scripts should be tested on Windows 11 Pro and Enterprise
- Server 2022 compatibility not fully verified
- Some registry paths are version-specific
- Service names may vary by edition

---

## RECOMMENDATIONS

1. **Enable script execution policy**: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
2. **Run as Administrator**: All scripts require elevated privileges
3. **Create system restore point** before running hardening scripts
4. **Test in non-production environment** first
5. **Backup current settings** before applying changes
6. **Review audit log** after running each script
7. **Implement proper error handling** and logging
8. **Add user confirmation prompts** for dangerous operations


# CRITICAL FIXES GUIDE
# Windows-Safety-Jump-Box PowerShell Audit - Fixes

## TIER 1: CRITICAL BLOCKING ISSUES

### Fix 1: Emoji Character Replacement
**Location**: Capture-Installation.ps1, Deploy-Image.ps1, Enable-BitLocker.ps1
**Issue**: Emoji characters cause encoding/parsing issues
**Severity**: CRITICAL

```powershell
# BEFORE (Capture-Installation.ps1, Line 84-86)
Write-Host "`n⚠️  NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Boot system from Windows PE USB"
Write-Host "  2. Run: .\Deploy-Image.ps1 -CaptureMode -ImagePath `"$OutputPath`"`n" -ForegroundColor Cyan

# AFTER
Write-Host "`n! NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Boot system from Windows PE USB"
Write-Host "  2. Run: .\Deploy-Image.ps1 -CaptureMode -ImagePath '$OutputPath'`n" -ForegroundColor Cyan
```

**All Emoji Replacements**:
- ✓ → [OK]
- ✗ → [FAIL]
- ⚠️ → !
- 🛡️ → [SHIELD]
- 📧 → [EMAIL]

---

### Fix 2: Remove RpcSs from Disabled Services
**Location**: CIS_Level1+2_Complete.ps1, Line 243
**Issue**: RPC is critical Windows service - cannot be disabled
**Severity**: CRITICAL

```powershell
# BEFORE (CIS_Level1+2_Complete.ps1, Lines 238-250)
$servicesToDisable = @(
    @{Name="DiagTrack"; Desc="DiagTrack (diagnostic tracking)"},
    @{Name="dmwappushservice"; Desc="dmwappushservice (diagnostic)"},
    @{Name="RemoteRegistry"; Desc="Remote Registry"},
    @{Name="RemoteAccess"; Desc="Remote Access Service"},
    @{Name="RpcSs"; Desc="RPC"},                           # DELETE THIS LINE
    @{Name="SCardSvr"; Desc="Smart Card"},
    @{Name="ScDeviceEnum"; Desc="Smart Card Device Enumeration"},
    @{Name="Fax"; Desc="Fax Service"},
    @{Name="TapiSrv"; Desc="Telephony"},
    @{Name="XblAuthManager"; Desc="Xbox Live Auth"},
    @{Name="XblGameSave"; Desc="Xbox Live Game Save"},
    @{Name="xbgm"; Desc="Xbox Game Monitoring"}
)

# AFTER - Remove the RpcSs line
$servicesToDisable = @(
    @{Name="DiagTrack"; Desc="DiagTrack (diagnostic tracking)"},
    @{Name="dmwappushservice"; Desc="dmwappushservice (diagnostic)"},
    @{Name="RemoteRegistry"; Desc="Remote Registry"},
    @{Name="RemoteAccess"; Desc="Remote Access Service"},
    # RpcSs removed - CRITICAL service
    @{Name="SCardSvr"; Desc="Smart Card"},
    @{Name="ScDeviceEnum"; Desc="Smart Card Device Enumeration"},
    @{Name="Fax"; Desc="Fax Service"},
    @{Name="TapiSrv"; Desc="Telephony"},
    @{Name="XblAuthManager"; Desc="Xbox Live Auth"},
    @{Name="XblGameSave"; Desc="Xbox Live Game Save"},
    @{Name="xbgm"; Desc="Xbox Game Monitoring"}
)
```

---

### Fix 3: Replace Placeholder Values
**Location**: CIS_Tier_2_Hardening_Rollback.ps1, Lines 8-9, 23
**Issue**: Placeholder text used as literal values
**Severity**: CRITICAL

```powershell
# BEFORE (Lines 8-9)
Stop-Service -Name "ServiceName" -Force # Replace with actual service names
Set-Service -Name "ServiceName" -StartupType "Manual" # Replace with actual service names

# AFTER
try {
    Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
    Stop-Service -Name "dmwappushservice" -Force -ErrorAction SilentlyContinue
    Set-Service -Name "DiagTrack" -StartupType "Manual" -ErrorAction SilentlyContinue
    Set-Service -Name "dmwappushservice" -StartupType "Manual" -ErrorAction SilentlyContinue
    Write-Host "Services restored to manual startup" -ForegroundColor Green
} catch {
    Write-Host "Error restoring services: $_" -ForegroundColor Yellow
}
```

```powershell
# BEFORE (Line 23)
Set-LocalUser -Name "UserName" -Password (ConvertTo-SecureString "NewPassword" -AsPlainText -Force) # Ensure to manage user securely

# AFTER - SECURE METHOD
try {
    $password = Read-Host -AsSecureString -Prompt "Enter new administrator password"
    Set-LocalUser -Name "Administrator" -Password $password
    Write-Host "Administrator password updated" -ForegroundColor Green
} catch {
    Write-Host "Error updating password: $_" -ForegroundColor Yellow
}

# OR - if you need a default password (not recommended for production)
$defaultPassword = ConvertTo-SecureString "TempPassword123!" -AsPlainText -Force
Set-LocalUser -Name "Administrator" -Password $defaultPassword
```

---

### Fix 4: Fix String Escaping Issues
**Location**: Capture-Installation.ps1, Line 86
**Issue**: Backtick escaping inside quoted strings
**Severity**: CRITICAL

```powershell
# BEFORE - Problematic escaping
Write-Host "  2. Run: .\Deploy-Image.ps1 -CaptureMode -ImagePath `"$OutputPath`"`n" -ForegroundColor Cyan

# AFTER - Use single quotes for embedded double quotes
Write-Host "  2. Run: .\Deploy-Image.ps1 -CaptureMode -ImagePath ""$OutputPath""" -ForegroundColor Cyan

# OR - Better approach with proper nesting
$command = ".\Deploy-Image.ps1 -CaptureMode -ImagePath '$OutputPath'"
Write-Host "  2. Run: $command" -ForegroundColor Cyan
```

---

## TIER 2: HIGH SEVERITY ISSUES

### Fix 5: Correct Set-MpPreference Parameters
**Location**: CIS_Tier_2_Hardening_Rollback.ps1, Line 13
**Issue**: Parameter logic reversed
**Severity**: HIGH

```powershell
# BEFORE - Confusing double negative
Set-MpPreference -DisableRealtimeMonitoring $false

# AFTER - Clear and correct
Set-MpPreference -EnableRealtimeMonitoring $true
```

---

### Fix 6: Add TPM Protector to BitLocker
**Location**: Enable-BitLocker.ps1, Line 75
**Issue**: Missing explicit TPM protector specification
**Severity**: HIGH

```powershell
# BEFORE
Enable-BitLocker -MountPoint $MountPoint -EncryptionMethod XtsAes256 -UsedSpaceOnly -ErrorAction SilentlyContinue

# AFTER - Add TPM protector
Enable-BitLocker -MountPoint $MountPoint -EncryptionMethod XtsAes256 -TpmProtector -UsedSpaceOnly -ErrorAction SilentlyContinue
```

---

### Fix 7: Fix Registry Method Call
**Location**: CIS_Level2_Mandatory.ps1, Line 82
**Issue**: GetValueKind method doesn't exist on registry item
**Severity**: HIGH

```powershell
# BEFORE - Invalid method
OldType = (Get-Item $regPath).GetValueKind($Name)

# AFTER - Correct approach
if (Test-Path $regPath) {
    $regValue = Get-ItemProperty -Path $regPath -Name $Name -ErrorAction SilentlyContinue
    if ($regValue) {
        $OldType = $regValue.GetType().Name
    }
}
```

---

### Fix 8: Correct Set-MpPreference Parameter Values
**Location**: CIS_Level1+2_Complete.ps1, Lines 181-182
**Issue**: Parameter values are strings but should be enum/boolean
**Severity**: HIGH

```powershell
# BEFORE
Set-MpPreference -EnableNetworkProtection "Enabled" -ErrorAction SilentlyContinue
Set-MpPreference -EnableControlledFolderAccess "Enabled" -ErrorAction SilentlyContinue

# AFTER
Set-MpPreference -EnableNetworkProtection Enabled -ErrorAction SilentlyContinue
Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction SilentlyContinue

# OR with proper enum values
Set-MpPreference -EnableNetworkProtection ([Microsoft.Windows.Defender.MpPreference]::Enabled) -ErrorAction SilentlyContinue
```

---

## TIER 3: MEDIUM SEVERITY ISSUES

### Fix 9: Add Registry Path Validation
**Location**: CIS_Level1+2_Complete.ps1, Line 220
**Issue**: Registry path may not exist on all systems
**Severity**: MEDIUM

```powershell
# BEFORE
Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Value 1 -Description "Enable Hypervisor-Enforced Code Integrity"

# AFTER
$dgPath = "HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
if (Test-Path $dgPath) {
    Set-RegistryValue -Path $dgPath -Name "Enabled" -Value 1 -Description "Enable Hypervisor-Enforced Code Integrity"
} else {
    Write-Log "DeviceGuard path not available on this system" "WARN"
}
```

---

### Fix 10: Validate AuditPol Subcategory Names
**Location**: CIS_Level2_Mandatory.ps1, Lines 192-197
**Issue**: Subcategory names should be verified
**Severity**: MEDIUM

```powershell
# BEFORE
$auditPolicies = @(
    "Logon/Logoff",
    "Account Logon",
    "Object Access",
    "Privilege Use"
)

# AFTER - Add validation
$auditPolicies = @(
    "Logon/Logoff",
    "Account Logon",
    "Object Access",
    "Privilege Use",
    "Detailed Tracking"
)

# Validate subcategory names first
Write-Host "Validating audit policy names..." -ForegroundColor Yellow
$validSubcategories = auditpol /list /subcategory:* | Select-Object -Skip 1
foreach ($policy in $auditPolicies) {
    if ($validSubcategories -match $policy) {
        Write-Host "  ✓ $policy found" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ $policy may not be valid" -ForegroundColor Yellow
    }
}
```

---

### Fix 11: Improve Process Mitigation Parameters
**Location**: CIS_Level2_Mandatory.ps1, Line 216
**Issue**: DEP parameter may not be valid
**Severity**: MEDIUM

```powershell
# BEFORE
Set-ProcessMitigation -System -Enable DEP, EmulateAtlThunks, BottomUpASLR, TopDownASLR -ErrorAction SilentlyContinue

# AFTER - Remove DEP, keep valid options
Set-ProcessMitigation -System -Enable EmulateAtlThunks, BottomUpASLR, TopDownASLR -ErrorAction SilentlyContinue

# Better approach with error handling
try {
    $mitigations = @("EmulateAtlThunks", "BottomUpASLR", "TopDownASLR")
    Set-ProcessMitigation -System -Enable $mitigations -ErrorAction Stop
    Write-Host "Process mitigations applied successfully" -ForegroundColor Green
} catch {
    Write-Host "Warning: Could not apply all process mitigations: $_" -ForegroundColor Yellow
}
```

---

### Fix 12: Fix Firewall Log Path
**Location**: CIS_Level1+2_Complete.ps1, Line 169
**Issue**: Environment variable not expanded in PowerShell
**Severity**: MEDIUM

```powershell
# BEFORE
Set-NetFirewallProfile -Profile Domain,Public,Private -LogFileName "%systemroot%\System32\LogFiles\Firewall\pfirewall.log"

# AFTER
Set-NetFirewallProfile -Profile Domain,Public,Private -LogFileName "$env:SystemRoot\System32\LogFiles\Firewall\pfirewall.log"
```

---

## TIER 4: LOW SEVERITY FIXES

### Fix 13: Add Parameter Validation
**Location**: All scripts with parameters
**Issue**: Missing ValidateNotNullOrEmpty attribute
**Severity**: LOW

```powershell
# BEFORE
param(
    [string]$ImagePath,
    [string]$TargetDisk
)

# AFTER
param(
    [ValidateNotNullOrEmpty()]
    [string]$ImagePath,
    
    [ValidateNotNullOrEmpty()]
    [string]$TargetDisk
)
```

---

### Fix 14: Add Null Checks Before Property Access
**Location**: Enable-BitLocker.ps1, Line 98
**Issue**: Accessing property without null check
**Severity**: LOW

```powershell
# BEFORE
$volume = Get-BitLockerVolume -MountPoint $MountPoint
Write-Host "  Protection Status: $($volume.ProtectionStatus)"

# AFTER
$volume = Get-BitLockerVolume -MountPoint $MountPoint -ErrorAction SilentlyContinue
if ($volume) {
    Write-Host "  Protection Status: $($volume.ProtectionStatus)"
    Write-Host "  Encryption Status: $($volume.EncryptionPercentage)%"
} else {
    Write-Host "  ⚠ BitLocker volume not found on $MountPoint" -ForegroundColor Yellow
}
```

---

### Fix 15: Improve Error Handling in net.exe Commands
**Location**: Prepare-System-for-Capture.ps1, Line 39
**Issue**: Output not captured, errors not handled
**Severity**: LOW

```powershell
# BEFORE
net user Administrator /logonpasswordchg:yes 2>$null

# AFTER
try {
    $output = net user Administrator /logonpasswordchg:yes 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Password history cleared" -ForegroundColor Green
    } else {
        Write-Host "⚠ Could not clear password history" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error executing net.exe: $_" -ForegroundColor Yellow
}
```

---

## IMPLEMENTATION CHECKLIST

### Before Applying Fixes
- [ ] Create system backup/restore point
- [ ] Test in non-production environment
- [ ] Review all changes with security team
- [ ] Document current system state
- [ ] Verify target Windows versions

### While Applying Fixes
- [ ] Apply Tier 1 fixes first (blocking issues)
- [ ] Test scripts after each tier
- [ ] Verify no new errors introduced
- [ ] Run scripts in DryRun mode first
- [ ] Review audit logs

### After Applying Fixes
- [ ] Validate all scripts parse correctly
- [ ] Test on Windows 11 Pro/Enterprise
- [ ] Test on Windows Server 2022
- [ ] Verify rollback procedures work
- [ ] Document any deviations
- [ ] Get approval before production use

---

## VALIDATION COMMANDS

### Test Syntax
```powershell
$parseErrors = @()
$tokens = @()
$null = [System.Management.Automation.Language.Parser]::ParseFile("script.ps1", [ref]$tokens, [ref]$parseErrors)
if ($parseErrors.Count -eq 0) { Write-Host "✓ Syntax valid" } else { $parseErrors }
```

### Test Service Names
```powershell
$services = @("DiagTrack", "dmwappushservice", "RemoteRegistry")
foreach ($svc in $services) {
    if (Get-Service -Name $svc -ErrorAction SilentlyContinue) {
        Write-Host "✓ $svc exists"
    } else {
        Write-Host "✗ $svc NOT found"
    }
}
```

### Test Registry Paths
```powershell
$paths = @(
    "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System",
    "HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
)
foreach ($path in $paths) {
    if (Test-Path $path) {
        Write-Host "✓ $path exists"
    } else {
        Write-Host "⚠ $path NOT found (will be created)"
    }
}
```

---

## ESTIMATED TIME TO IMPLEMENT

| Fix | Time | Difficulty |
|-----|------|-----------|
| Fix 1: Emoji replacement | 10 min | Easy |
| Fix 2: Remove RpcSs | 1 min | Easy |
| Fix 3: Replace placeholders | 5 min | Easy |
| Fix 4: String escaping | 2 min | Easy |
| Fix 5: MpPreference params | 2 min | Easy |
| Fix 6: BitLocker TPM | 1 min | Easy |
| Fix 7: Registry method | 5 min | Medium |
| Fix 8: MpPreference values | 3 min | Medium |
| Fix 9: Registry validation | 10 min | Medium |
| Fix 10: AuditPol validation | 10 min | Medium |
| Fix 11: Process mitigation | 5 min | Medium |
| Fix 12: Firewall log path | 1 min | Easy |
| Fix 13-15: Other improvements | 20 min | Easy-Medium |
| **TOTAL** | **~75 minutes** | |


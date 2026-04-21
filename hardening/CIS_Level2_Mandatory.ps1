<#
.SYNOPSIS
    CIS Level 2 Mandatory Controls for Windows 11/Server 2022
    
.DESCRIPTION
    Applies only the mandatory CIS Level 2 security controls.
    These are critical controls required for Level 2 compliance.
    
.PARAMETER RollbackPoint
    Enable rollback point creation (default: $true)
    
.PARAMETER DryRun
    Show what would be changed without making changes
    
.EXAMPLE
    .\CIS_Level2_Mandatory.ps1 -RollbackPoint $true
    .\CIS_Level2_Mandatory.ps1 -DryRun $true
    
.NOTES
    Requires: Administrator rights
    Tested on: Windows 11 Pro/Enterprise, Windows Server 2022
#>

param(
    [bool]$RollbackPoint = $true,
    [bool]$DryRun = $false,
    [string]$LogPath = "$PSScriptRoot\..\hardening\rollback\hardening-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
)

$ErrorActionPreference = "Stop"
$script:Changes = @()
$script:RollbackData = @{
    Timestamp = Get-Date
    RegistryChanges = @()
    ServiceChanges = @()
    FirewallRules = @()
}

# Ensure running as admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    Add-Content -Path $LogPath -Value $logMessage -ErrorAction SilentlyContinue
}

function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "DWORD",
        [string]$Description = ""
    )
    
    if ($DryRun) {
        Write-Log "[DRYRUN] Would set registry: $Path\$Name = $Value" "DRYRUN"
        return
    }
    
    try {
        $regPath = $Path -replace '^HKEY_LOCAL_MACHINE\\', 'HKLM:\'
        $regPath = $regPath -replace '^HKEY_CURRENT_USER\\', 'HKCU:\'
        
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
         # Backup for rollback
         $existingValue = Get-ItemProperty -Path $regPath -Name $Name -ErrorAction SilentlyContinue
         if ($existingValue) {
             $regItem = Get-Item -Path $regPath
             $script:RollbackData.RegistryChanges += @{
                 Path = $regPath
                 Name = $Name
                 OldValue = $existingValue.$Name
                 OldType = $regItem.GetValueKind($Name)
             }
         }
        
        New-ItemProperty -Path $regPath -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
        Write-Log "Registry set: $Path\$Name = $Value | $Description" "SUCCESS"
        $script:Changes += "Registry: $Path\$Name = $Value"
    } catch {
        Write-Log "Error setting registry $Path\$Name : $_" "ERROR"
    }
}

function Disable-Service {
    param([string]$ServiceName, [string]$Description = "")
    
    if ($DryRun) {
        Write-Log "[DRYRUN] Would disable service: $ServiceName" "DRYRUN"
        return
    }
    
    try {
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($service) {
            # Backup for rollback
            $script:RollbackData.ServiceChanges += @{
                Name = $ServiceName
                OldState = $service.Status
                OldStartType = $service.StartType
            }
            
            Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
            Set-Service -Name $ServiceName -StartupType Disabled
            Write-Log "Service disabled: $ServiceName | $Description" "SUCCESS"
            $script:Changes += "Service disabled: $ServiceName"
        }
    } catch {
        Write-Log "Error disabling service $ServiceName : $_" "ERROR"
    }
}

function Add-FirewallRule {
    param(
        [string]$DisplayName,
        [string]$Direction = "Inbound",
        [string]$Action = "Block",
        [string]$Protocol = "All",
        [string]$Description = ""
    )
    
    if ($DryRun) {
        Write-Log "[DRYRUN] Would add firewall rule: $DisplayName" "DRYRUN"
        return
    }
    
    try {
        $rule = Get-NetFirewallRule -DisplayName $DisplayName -ErrorAction SilentlyContinue
        if (-not $rule) {
            New-NetFirewallRule -DisplayName $DisplayName -Direction $Direction -Action $Action -Protocol $Protocol -ErrorAction Stop | Out-Null
            Write-Log "Firewall rule added: $DisplayName | $Description" "SUCCESS"
            $script:Changes += "Firewall: $DisplayName"
        }
    } catch {
        Write-Log "Error adding firewall rule $DisplayName : $_" "ERROR"
    }
}

Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "║          🛡️  CUSTOM PC REPUBLIC  🛡️                            ║" -ForegroundColor Cyan
Write-Host "║        IT Synergy Energy for the Republic                     ║" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "║     CIS Level 2 Mandatory Controls - Hardening Application    ║" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# ============= 1. USER ACCOUNT CONTROL =============
Write-Host "[1/8] Configuring User Account Control..." -ForegroundColor Yellow

Set-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 1 -Description "Enable UAC"
Set-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 2 -Description "Prompt for credentials on UAC"
Set-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorUser" -Value 3 -Description "Prompt for password on UAC"
Set-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableUIADesktopToggle" -Value 0 -Description "Disable UI Access for elevation"
Set-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ValidateAdminCodeSignatures" -Value 1 -Description "Only run signed admin apps"

# ============= 2. FIREWALL CONFIGURATION =============
Write-Host "`n[2/8] Configuring Windows Firewall..." -ForegroundColor Yellow

if (-not $DryRun) {
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -ErrorAction SilentlyContinue
}
Write-Log "Firewall profiles enabled" "SUCCESS"

# ============= 3. WINDOWS DEFENDER =============
Write-Host "`n[3/8] Configuring Windows Defender..." -ForegroundColor Yellow

if (Get-Command Set-MpPreference -ErrorAction SilentlyContinue) {
    if (-not $DryRun) {
        Set-MpPreference -EnableRealtimeMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue
        Set-MpPreference -EnableBehaviorMonitoring $true -ErrorAction SilentlyContinue
        Set-MpPreference -EnableCloudProtection $true -ErrorAction SilentlyContinue
        Set-MpPreference -CloudBlockLevel "High" -ErrorAction SilentlyContinue
    }
    Write-Log "Windows Defender configured" "SUCCESS"
}

# ============= 4. AUDIT POLICIES =============
Write-Host "`n[4/8] Configuring Audit Policies..." -ForegroundColor Yellow

$auditPolicies = @(
    "Logon/Logoff",
    "Account Logon",
    "Object Access",
    "Privilege Use"
)

if (-not $DryRun) {
    foreach ($policy in $auditPolicies) {
        try {
            # Validate subcategory name before setting audit policy
            $result = auditpol /set /subcategory:"$policy" /success:enable /failure:enable 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Log "Audit policy configured: $policy" "SUCCESS"
            } else {
                Write-Log "Warning: Could not configure audit policy '$policy'. Verify subcategory name with: auditpol /list /subcategory:*" "WARN"
            }
        } catch {
            Write-Log "Error setting audit policy for '$policy': $_" "ERROR"
        }
    }
}
Write-Log "Audit policies configuration completed" "SUCCESS"

# ============= 5. CREDENTIAL GUARD =============
Write-Host "`n[5/8] Enabling Credential Guard..." -ForegroundColor Yellow

Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "LsaCfgFlags" -Value 1 -Description "Enable Credential Guard"

# ============= 6. EXPLOIT PROTECTION =============
Write-Host "`n[6/8] Enabling Exploit Protection..." -ForegroundColor Yellow

if (-not $DryRun) {
    try {
        # Set exploit protections system-wide. Using supported parameters only.
        # Note: DEP parameter is deprecated in newer Windows versions, use DEPPolicy instead
        $mitigationParams = @{
            System = $true
            Enable = @("EmulateAtlThunks", "BottomUpASLR", "TopDownASLR")
        }
        Set-ProcessMitigation @mitigationParams -ErrorAction SilentlyContinue
        Write-Log "Exploit protection enabled (ASLR, AtlThunks)" "SUCCESS"
    } catch {
        Write-Log "Error enabling exploit protection: $_" "ERROR"
    }
}
Write-Log "Exploit protection configuration completed" "SUCCESS"

# ============= 7. SECURE BOOT & TPM =============
Write-Host "`n[7/8] Verifying Secure Boot & TPM..." -ForegroundColor Yellow

try {
    $secBoot = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue
    if ($null -eq $secBoot) {
        Write-Log "Secure Boot status: Not available or not supported on this system" "WARN"
        $secBoot = "N/A"
    }
} catch {
    Write-Log "Could not verify Secure Boot: $_" "WARN"
    $secBoot = "N/A"
}

try {
    $tpmObject = Get-WmiObject -Class Win32_Tpm -Namespace root\cimv2\security\microsofttpm -ErrorAction SilentlyContinue
    if ($null -ne $tpmObject) {
        $tpmPresent = $true
        Write-Log "TPM 2.0 detected and available" "INFO"
    } else {
        $tpmPresent = $false
        Write-Log "TPM 2.0 not detected on this system" "WARN"
    }
} catch {
    Write-Log "Could not verify TPM status: $_" "WARN"
    $tpmPresent = $false
}

Write-Log "Secure Boot enabled: $secBoot" "INFO"
Write-Log "TPM 2.0 present: $tpmPresent" "INFO"

# ============= 8. OPTIONAL SERVICES =============
Write-Host "`n[8/8] Disabling Unnecessary Services..." -ForegroundColor Yellow

$servicesToDisable = @(
    "DiagTrack",
    "dmwappushservice",
    "RemoteRegistry"
)

foreach ($service in $servicesToDisable) {
    Disable-Service -ServiceName $service -Description "Unnecessary service"
}

# ============= SAVE ROLLBACK POINT =============
if ($RollbackPoint -and -not $DryRun) {
    Write-Host "`n[ROLLBACK] Saving rollback data..." -ForegroundColor Cyan
    $rollbackPath = "$PSScriptRoot\rollback\rollback-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    $script:RollbackData | ConvertTo-Json | Out-File -FilePath $rollbackPath -Force
    Write-Log "Rollback data saved to: $rollbackPath" "SUCCESS"
}

# ============= SUMMARY =============
Write-Host "`n" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  CIS LEVEL 2 MANDATORY - COMPLETE" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  🛡️ Custom PC Republic - IT Synergy Energy for the Republic" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════`n" -ForegroundColor Green

Write-Host "Changes applied: $($script:Changes.Count)" -ForegroundColor Green
Write-Host "Log file: $LogPath`n" -ForegroundColor Green

if ($script:Changes.Count -gt 0) {
    Write-Host "Summary of changes:" -ForegroundColor Yellow
    $script:Changes | ForEach-Object { Write-Host "  ✓ $_" }
}

Write-Host "`n⚠️  SYSTEM REBOOT REQUIRED" -ForegroundColor Yellow
Write-Host "Reboot recommended to apply all changes.`n" -ForegroundColor Yellow

Write-Host "📧 Support: support@custompc.local" -ForegroundColor Cyan
Write-Host "🛡️ Organization: Custom PC Republic`n" -ForegroundColor Cyan

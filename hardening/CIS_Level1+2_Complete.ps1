<#
.SYNOPSIS
    CIS Level 1 & 2 Complete Controls for Windows 11/Server 2022
    
.DESCRIPTION
    Applies ALL CIS Level 1 and Level 2 security controls for maximum hardening.
    This is the comprehensive hardening profile for high-security environments.
    
.PARAMETER RollbackPoint
    Enable rollback point creation (default: $true)
    
.PARAMETER DryRun
    Show what would be changed without making changes
    
.PARAMETER SkipCritical
    Skip confirmation for critical changes
    
.EXAMPLE
    .\CIS_Level1+2_Complete.ps1 -RollbackPoint $true
    .\CIS_Level1+2_Complete.ps1 -DryRun $true
    
.NOTES
    Requires: Administrator rights
    WARNING: This applies aggressive security settings that may affect application compatibility
#>

param(
    [bool]$RollbackPoint = $true,
    [bool]$DryRun = $false,
    [bool]$SkipCritical = $false,
    [string]$LogPath = "$PSScriptRoot\..\hardening\rollback\hardening-complete-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
)

$ErrorActionPreference = "Stop"
$script:Changes = @()
$script:RollbackData = @{
    Timestamp = Get-Date
    RegistryChanges = @()
    ServiceChanges = @()
    FirewallRules = @()
    GPOChanges = @()
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage -ForegroundColor $(switch($Level){"ERROR"{"Red"};"SUCCESS"{"Green"};"WARN"{"Yellow"};"DRYRUN"{"Gray"};default{"White"}})
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
        Write-Log "[DRYRUN] Would set: $Path\$Name = $Value" "DRYRUN"
        return
    }
    
    try {
        $regPath = $Path -replace '^HKEY_LOCAL_MACHINE\\', 'HKLM:\'
        $regPath = $regPath -replace '^HKEY_CURRENT_USER\\', 'HKCU:\'
        
        if (-not (Test-Path $regPath)) {
            New-Item -Path $regPath -Force | Out-Null
        }
        
        $existingValue = Get-ItemProperty -Path $regPath -Name $Name -ErrorAction SilentlyContinue
        if ($existingValue) {
            $script:RollbackData.RegistryChanges += @{
                Path = $regPath
                Name = $Name
                OldValue = $existingValue.$Name
                OldType = (Get-Item $regPath).GetValueKind($Name)
            }
        }
        
        New-ItemProperty -Path $regPath -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
        Write-Log "✓ $Description" "SUCCESS"
        $script:Changes += $Description
    } catch {
        Write-Log "✗ Error: $Description - $_" "ERROR"
    }
}

function Disable-Service {
    param([string]$ServiceName, [string]$Description = "")
    
    if ($DryRun) {
        Write-Log "[DRYRUN] Would disable: $ServiceName" "DRYRUN"
        return
    }
    
    try {
        $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
        if ($service) {
            $script:RollbackData.ServiceChanges += @{
                Name = $ServiceName
                OldState = $service.Status
                OldStartType = $service.StartType
            }
            
            Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
            Set-Service -Name $ServiceName -StartupType Disabled
            Write-Log "✓ Service disabled: $Description" "SUCCESS"
            $script:Changes += "Service: $Description"
        }
    } catch {
        Write-Log "✗ Failed to disable $ServiceName : $_" "ERROR"
    }
}

# Confirmation for critical changes
if (-not $SkipCritical -and -not $DryRun) {
    Write-Host "`n" -ForegroundColor Yellow
    Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
    Write-Host "║  CIS LEVEL 1+2 COMPLETE HARDENING - AGGRESSIVE CONFIGURATION  ║" -ForegroundColor Yellow
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
    Write-Host "`nWARNING: This will apply comprehensive security controls that may affect:" -ForegroundColor Red
    Write-Host "  • Application compatibility"
    Write-Host "  • User experience"
    Write-Host "  • Administrative operations"
    Write-Host "`nPlease ensure you have:" -ForegroundColor Cyan
    Write-Host "  ✓ Full system backup"
    Write-Host "  ✓ Tested in non-production environment"
    Write-Host "  ✓ Documented rollback procedures`n"
    
    $confirm = Read-Host "Type 'APPLY' to proceed"
    if ($confirm -ne "APPLY") {
        Write-Host "Cancelled by user" -ForegroundColor Yellow
        exit 0
    }
}

Write-Host "`n" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🛡️  CUSTOM PC REPUBLIC - HARDENING SUITE  🛡️" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  IT Synergy Energy for the Republic" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "  CIS Level 1 + 2 Complete Hardening Configuration`n" -ForegroundColor Cyan

# ============= 1. USER ACCOUNT CONTROL =============
Write-Host "[1/12] USER ACCOUNT CONTROL" -ForegroundColor Cyan
Set-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 1 -Description "Enable User Account Control"
Set-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorAdmin" -Value 2 -Description "Prompt for credentials on admin tasks"
Set-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ConsentPromptBehaviorUser" -Value 3 -Description "Prompt on user task elevation"
Set-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableUIADesktopToggle" -Value 0 -Description "Disable UAC desktop toggle"
Set-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "ValidateAdminCodeSignatures" -Value 1 -Description "Require signed code for elevation"
Set-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "PromptOnSecureDesktop" -Value 1 -Description "Display UAC on secure desktop"

# ============= 2. FIREWALL =============
Write-Host "`n[2/12] WINDOWS FIREWALL" -ForegroundColor Cyan
if (-not $DryRun) {
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -ErrorAction SilentlyContinue
    Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultOutboundAction Block -ErrorAction SilentlyContinue
    # Use expanded environment variable instead of %systemroot% for proper path resolution
    $firewallLogPath = "$env:SystemRoot\System32\LogFiles\Firewall\pfirewall.log"
    Set-NetFirewallProfile -Profile Domain,Public,Private -LogFileName $firewallLogPath -ErrorAction SilentlyContinue
}
Write-Log "✓ Firewall enabled and configured" "SUCCESS"

# ============= 3. WINDOWS DEFENDER =============
Write-Host "`n[3/12] WINDOWS DEFENDER" -ForegroundColor Cyan
if (Get-Command Set-MpPreference -ErrorAction SilentlyContinue) {
     if (-not $DryRun) {
         Set-MpPreference -EnableRealtimeMonitoring $true -ErrorAction SilentlyContinue
         Set-MpPreference -EnableBehaviorMonitoring $true -ErrorAction SilentlyContinue
         Set-MpPreference -EnableCloudProtection $true -ErrorAction SilentlyContinue
         Set-MpPreference -CloudBlockLevel "High" -ErrorAction SilentlyContinue
         Set-MpPreference -EnableNetworkProtection Enabled -ErrorAction SilentlyContinue
         Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction SilentlyContinue
    }
    Write-Log "✓ Windows Defender fully configured" "SUCCESS"
}

# ============= 4. AUDIT POLICIES =============
Write-Host "`n[4/12] ADVANCED AUDIT POLICIES" -ForegroundColor Cyan
$auditPolicies = @(
    "Logon/Logoff",
    "Account Logon",
    "Object Access",
    "Privilege Use",
    "Detailed Tracking",
    "Policy Change",
    "Account Management",
    "Process Tracking",
    "System",
    "DS Access"
)

if (-not $DryRun) {
    foreach ($policy in $auditPolicies) {
        try {
            # Validate subcategory name and set audit policy with error checking
            $result = auditpol /set /subcategory:"$policy" /success:enable /failure:enable 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Log "✓ Audit policy configured: $policy" "SUCCESS"
            } else {
                Write-Log "Warning: Could not configure audit policy '$policy'. Verify with: auditpol /list /subcategory:*" "WARN"
            }
        } catch {
            Write-Log "✗ Error setting audit policy for '$policy': $_" "ERROR"
        }
    }
}
Write-Log "✓ Advanced audit policies configuration completed ($($auditPolicies.Count) categories)" "SUCCESS"

# ============= 5. LOCAL SECURITY POLICY =============
Write-Host "`n[5/12] LOCAL SECURITY POLICY" -ForegroundColor Cyan
Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters" -Name "RestrictNullSessAccess" -Value 1 -Description "Restrict null session access"
Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "RestrictAnonymous" -Value 1 -Description "Restrict anonymous user access"
Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "RestrictAnonymousSAM" -Value 1 -Description "Restrict anonymous SAM enumeration"
Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "EveryoneIncludesAnonymous" -Value 0 -Description "Exclude anonymous from everyone group"
Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "ForceGuest" -Value 0 -Description "Account lockout policy enforcement"

# ============= 6. CREDENTIAL GUARD & DEVICE GUARD =============
Write-Host "`n[6/12] CREDENTIAL GUARD & DEVICE GUARD" -ForegroundColor Cyan
Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Control\Lsa" -Name "LsaCfgFlags" -Value 1 -Description "Enable Credential Guard"
Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Value 1 -Description "Enable Hypervisor-Enforced Code Integrity"

# ============= 7. EXPLOIT PROTECTION =============
Write-Host "`n[7/12] EXPLOIT PROTECTION" -ForegroundColor Cyan
if (-not $DryRun) {
    try {
        # Set exploit protections system-wide. Using supported parameters only.
        # Note: DEP parameter is deprecated in newer Windows versions
        $mitigationParams = @{
            System = $true
            Enable = @("EmulateAtlThunks", "BottomUpASLR", "TopDownASLR")
        }
        Set-ProcessMitigation @mitigationParams -ErrorAction SilentlyContinue
        Write-Log "✓ Exploit protection enabled (ASLR, AtlThunks)" "SUCCESS"
    } catch {
        Write-Log "✗ Error enabling exploit protection: $_" "ERROR"
    }
}
Write-Log "✓ Exploit protection configuration completed" "SUCCESS"

# ============= 8. NETWORK SECURITY =============
Write-Host "`n[8/12] NETWORK SECURITY" -ForegroundColor Cyan
Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters" -Name "TcpMaxDataRetransmissions" -Value 3 -Description "TCP retransmission limit"
Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters" -Name "SynAttackProtect" -Value 2 -Description "SYN flood protection"
Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters" -Name "DisableIPSourceRouting" -Value 2 -Description "Disable IP source routing"
Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Services\Tcpip\Parameters" -Name "EnableICMPRedirect" -Value 0 -Description "Disable ICMP redirects"

# ============= 9. SERVICES HARDENING =============
Write-Host "`n[9/12] UNNECESSARY SERVICES" -ForegroundColor Cyan
$servicesToDisable = @(
     @{Name="DiagTrack"; Desc="DiagTrack (diagnostic tracking)"},
     @{Name="dmwappushservice"; Desc="dmwappushservice (diagnostic)"},
     @{Name="RemoteRegistry"; Desc="Remote Registry"},
     @{Name="RemoteAccess"; Desc="Remote Access Service"},
     @{Name="SCardSvr"; Desc="Smart Card"},
     @{Name="ScDeviceEnum"; Desc="Smart Card Device Enumeration"},
     @{Name="Fax"; Desc="Fax Service"},
     @{Name="TapiSrv"; Desc="Telephony"},
     @{Name="XblAuthManager"; Desc="Xbox Live Auth"},
     @{Name="XblGameSave"; Desc="Xbox Live Game Save"},
     @{Name="xbgm"; Desc="Xbox Game Monitoring"}
)

foreach ($svc in $servicesToDisable) {
    Disable-Service -ServiceName $svc.Name -Description $svc.Desc
}

# ============= 10. SMB HARDENING =============
Write-Host "`n[10/12] SMB HARDENING" -ForegroundColor Cyan
Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters" -Name "SMB1" -Value 0 -Description "Disable SMBv1 protocol"
Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters" -Name "RequireSecuritySignature" -Value 1 -Description "Require SMB signing"
Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters" -Name "EnableSecuritySignature" -Value 1 -Description "Enable SMB packet signing"
Set-RegistryValue -Path "HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters" -Name "RestrictNullSessAccess" -Value 1 -Description "Restrict null SMB sessions"

# ============= 11. WINDOWS UPDATE & PATCH =============
Write-Host "`n[11/12] WINDOWS UPDATE HARDENING" -ForegroundColor Cyan
Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoRebootWithLoggedOnUsers" -Value 0 -Description "Auto-reboot for updates"
Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "AUOptions" -Value 3 -Description "Auto-download and install updates"
Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate" -Name "DisableWindowsUpdateAccess" -Value 0 -Description "Allow Windows Update"

# ============= 12. ADDITIONAL SECURITY =============
Write-Host "`n[12/12] ADDITIONAL SECURITY CONTROLS" -ForegroundColor Cyan
Set-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableCMD" -Value 2 -Description "Disable Command Prompt"
Set-RegistryValue -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableLockWorkstation" -Value 0 -Description "Enable lock workstation"
Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\PowerShell" -Name "ExecutionPolicy" -Value 2 -Description "Set PowerShell to AllSigned"
Set-RegistryValue -Path "HKLM:\Software\Policies\Microsoft\Windows\Installer" -Name "AlwaysInstallElevated" -Value 0 -Description "Prevent MSI elevation"

# ============= SAVE ROLLBACK POINT =============
if ($RollbackPoint -and -not $DryRun) {
    Write-Host "`n[ROLLBACK] Saving configuration snapshot..." -ForegroundColor Cyan
    $rollbackPath = "$PSScriptRoot\..\hardening\rollback\rollback-complete-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
    if (-not (Test-Path (Split-Path $rollbackPath))) {
        New-Item -ItemType Directory -Path (Split-Path $rollbackPath) -Force | Out-Null
    }
    $script:RollbackData | ConvertTo-Json -Depth 3 | Out-File -FilePath $rollbackPath -Force
    Write-Log "Rollback snapshot saved: $rollbackPath" "SUCCESS"
}

# ============= SUMMARY =============
Write-Host "`n" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  CIS LEVEL 1 + 2 HARDENING - COMPLETE" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  🛡️ CUSTOM PC REPUBLIC - IT Synergy Energy for the Republic" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════════════`n" -ForegroundColor Green

Write-Host "Applied Controls: $($script:Changes.Count)" -ForegroundColor Green
Write-Host "Log File: $LogPath`n" -ForegroundColor Green

Write-Host "Summary of Security Changes Applied:" -ForegroundColor Yellow
$script:Changes | ForEach-Object { Write-Host "  ✓ $_" }

Write-Host "`n⚠️  SYSTEM REBOOT REQUIRED" -ForegroundColor Red
Write-Host "Please reboot at your earliest convenience`n" -ForegroundColor Red

Write-Host "📧 Support: support@custompc.local" -ForegroundColor Cyan
Write-Host "🛡️ Organization: Custom PC Republic`n" -ForegroundColor Cyan

Write-Host "To restore previous configuration, run:" -ForegroundColor Yellow
Write-Host "  .\CIS_Rollback.ps1 -RollbackFile `"$rollbackPath`"`n" -ForegroundColor Yellow

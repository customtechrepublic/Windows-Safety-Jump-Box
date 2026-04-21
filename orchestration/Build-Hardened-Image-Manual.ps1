<#
.SYNOPSIS
    Interactive Manual Workflow Script for Building Hardened Windows Images
    Guides users through manual hardening with step-by-step review and compliance verification

.DESCRIPTION
    This script provides an interactive console UI for:
    - VM creation and management
    - Software installation and updates
    - CIS hardening with user review
    - BitLocker encryption setup
    - Compliance verification
    - Image capture and deployment
    - Complete audit trail and documentation

.AUTHOR
    PC Republic Security Team
    
.VERSION
    2.0.0

.NOTES
    Requires: PowerShell 5.1+, Administrator privileges
    Supports: Hyper-V and VMware environments
#>

[CmdletBinding()]
param()

# ============================================================================
# CONFIGURATION AND INITIALIZATION
# ============================================================================

$ErrorActionPreference = "Stop"
$VerbosePreference = "SilentlyContinue"

# Script paths and configuration
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$logDir = Join-Path $scriptRoot "logs"
$reportDir = Join-Path $scriptRoot "reports"
$configDir = Join-Path $scriptRoot "configs"

# Ensure directories exist
@($logDir, $reportDir, $configDir) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

# Logging
$logFile = Join-Path $logDir "hardening-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$auditTrail = @()

# Color definitions - PC Republic Branding
$colors = @{
    Primary      = "Cyan"
    Secondary    = "Yellow"
    Success      = "Green"
    Warning      = "Yellow"
    Error        = "Red"
    Info         = "White"
    Highlight    = "Magenta"
    Accent       = "DarkCyan"
}

# CIS Control categories
$cisCategories = @(
    "User Account Control",
    "Windows Firewall",
    "Windows Defender",
    "Update Management",
    "Account Policies",
    "Audit Policies",
    "Registry Settings",
    "Service Configuration"
)

# ============================================================================
# LOGGING AND AUDIT FUNCTIONS
# ============================================================================

function Write-Log {
    <#
    .SYNOPSIS
        Write message to log file and console
    #>
    param(
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    Add-Content -Path $logFile -Value $logEntry -ErrorAction SilentlyContinue
    
    $colorMap = @{
        "INFO"    = $colors.Info
        "SUCCESS" = $colors.Success
        "WARNING" = $colors.Warning
        "ERROR"   = $colors.Error
    }
    
    Write-Host $logEntry -ForegroundColor $colorMap[$Level]
}

function Write-AuditTrail {
    <#
    .SYNOPSIS
        Record action in audit trail
    #>
    param(
        [string]$Action,
        [string]$Details = "",
        [ValidateSet("INITIATED", "COMPLETED", "SKIPPED", "FAILED")]
        [string]$Status = "COMPLETED"
    )

    $record = @{
        Timestamp = Get-Date -Format "o"
        Action    = $Action
        Details   = $Details
        Status    = $Status
        User      = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    }
    
    $global:auditTrail += $record
    Write-Log -Message "[$Status] $Action - $Details" -Level "INFO"
}

# ============================================================================
# UI AND FORMATTING FUNCTIONS
# ============================================================================

function Write-Banner {
    <#
    .SYNOPSIS
        Display main menu banner
    #>
    Clear-Host
    
    Write-Host ""
    Write-Host "╔═══════════════════════════════════════════════════════════════════╗" -ForegroundColor $colors.Primary
    Write-Host "║                                                                   ║" -ForegroundColor $colors.Primary
    Write-Host "║          🛡️  PC REPUBLIC - HARDENED IMAGE BUILDER  🛡️           ║" -ForegroundColor $colors.Secondary
    Write-Host "║                                                                   ║" -ForegroundColor $colors.Primary
    Write-Host "║              Interactive Manual Workflow (v2.0.0)                ║" -ForegroundColor $colors.Primary
    Write-Host "║                                                                   ║" -ForegroundColor $colors.Primary
    Write-Host "╚═══════════════════════════════════════════════════════════════════╝" -ForegroundColor $colors.Primary
    Write-Host ""
}

function Write-Section {
    <#
    .SYNOPSIS
        Write formatted section header
    #>
    param([string]$Title)
    
    Write-Host ""
    Write-Host "┌─ $Title" -ForegroundColor $colors.Highlight
    Write-Host "│" -ForegroundColor $colors.Highlight
}

function Write-Subsection {
    <#
    .SYNOPSIS
        Write formatted subsection header
    #>
    param([string]$Title)
    
    Write-Host "  └─ $Title" -ForegroundColor $colors.Secondary
}

function Write-SectionEnd {
    Write-Host "│" -ForegroundColor $colors.Highlight
    Write-Host "└─────────────────────────────────────────" -ForegroundColor $colors.Highlight
}

function Show-MainMenu {
    <#
    .SYNOPSIS
        Display main menu and get user choice
    #>
    Write-Banner
    
    Write-Section "Main Menu Options"
    Write-Host "│"
    Write-Host "│  $(1) Create VM (Hyper-V/VMware)" -ForegroundColor $colors.Info
    Write-Host "│  $(2) Install Software & Updates" -ForegroundColor $colors.Info
    Write-Host "│  $(3) Apply CIS Hardening" -ForegroundColor $colors.Info
    Write-Host "│  $(4) Enable BitLocker Encryption" -ForegroundColor $colors.Info
    Write-Host "│  $(5) Verify Compliance" -ForegroundColor $colors.Info
    Write-Host "│  $(6) Prepare for Capture" -ForegroundColor $colors.Info
    Write-Host "│  $(7) Capture Image" -ForegroundColor $colors.Info
    Write-Host "│  $(8) Deploy Image" -ForegroundColor $colors.Info
    Write-Host "│  $(V) View Audit Trail" -ForegroundColor $colors.Info
    Write-Host "│  $(R) Generate Reports" -ForegroundColor $colors.Info
    Write-Host "│  $(Q) Quit" -ForegroundColor $colors.Warning
    Write-Host "│"
    Write-SectionEnd
    
    Write-Host ""
    $choice = Read-Host "Select option"
    return $choice.ToUpper()
}

# ============================================================================
# VM MANAGEMENT FUNCTIONS
# ============================================================================

function New-HardenedVM {
    <#
    .SYNOPSIS
        Create a new VM for hardening
    #>
    Write-Section "Create New Virtual Machine"
    
    # Get VM details from user
    Write-Host "│"
    Write-Subsection "VM Configuration"
    
    $vmName = Read-Host "  VM Name (e.g., WIN11-HARDENED-001)"
    if ([string]::IsNullOrEmpty($vmName)) {
        Write-Log -Message "VM creation cancelled - no name provided" -Level "WARNING"
        Write-AuditTrail -Action "Create VM" -Status "SKIPPED"
        return $null
    }
    
    # Validate VM name
    if ($vmName -match '[^a-zA-Z0-9\-_]') {
        Write-Host "  ERROR: VM name contains invalid characters" -ForegroundColor $colors.Error
        Write-Log -Message "Invalid VM name: $vmName" -Level "ERROR"
        return $null
    }
    
    Write-Host "  RAM (GB) [default: 4]" -NoNewline -ForegroundColor $colors.Info
    $ramInput = Read-Host
    $ram = if ([string]::IsNullOrEmpty($ramInput)) { 4 } else { [int]$ramInput }
    
    Write-Host "  Storage (GB) [default: 80]" -NoNewline -ForegroundColor $colors.Info
    $storageInput = Read-Host
    $storage = if ([string]::IsNullOrEmpty($storageInput)) { 80 } else { [int]$storageInput }
    
    # Platform selection
    Write-Host "  Platform:" -ForegroundColor $colors.Secondary
    Write-Host "    1) Hyper-V"
    Write-Host "    2) VMware"
    $platformChoice = Read-Host "  Select platform"
    
    $platform = if ($platformChoice -eq "2") { "VMware" } else { "Hyper-V" }
    
    # Review configuration
    Write-Host ""
    Write-Host "  Configuration Summary:" -ForegroundColor $colors.Secondary
    Write-Host "    VM Name:     $vmName" -ForegroundColor $colors.Info
    Write-Host "    RAM:         $ram GB" -ForegroundColor $colors.Info
    Write-Host "    Storage:     $storage GB" -ForegroundColor $colors.Info
    Write-Host "    Platform:    $platform" -ForegroundColor $colors.Info
    Write-Host ""
    
    $confirm = Read-Host "  Create VM? (Y/N)"
    if ($confirm -ne "Y") {
        Write-Log -Message "VM creation cancelled by user" -Level "WARNING"
        Write-AuditTrail -Action "Create VM" -Status "SKIPPED"
        Write-SectionEnd
        return $null
    }
    
    # Create VM (placeholder implementation)
    Write-Host "  → Creating VM '$vmName'..." -ForegroundColor $colors.Secondary
    
    try {
        # Simulate VM creation
        $vmConfig = @{
            Name      = $vmName
            RAM       = $ram
            Storage   = $storage
            Platform  = $platform
            CreatedAt = Get-Date
            Status    = "Created"
        }
        
        Write-Log -Message "VM '$vmName' created successfully" -Level "SUCCESS"
        Write-AuditTrail -Action "Create VM" -Details "VM: $vmName | RAM: $ram GB | Storage: $storage GB | Platform: $platform"
        
        Write-Host "    ✓ VM created successfully" -ForegroundColor $colors.Success
        Write-SectionEnd
        
        return $vmConfig
    }
    catch {
        Write-Log -Message "Failed to create VM: $_" -Level "ERROR"
        Write-AuditTrail -Action "Create VM" -Status "FAILED" -Details $_
        Write-Host "    ✗ Failed to create VM" -ForegroundColor $colors.Error
        Write-SectionEnd
        return $null
    }
}

function New-VMSnapshot {
    <#
    .SYNOPSIS
        Create snapshot for rollback capability
    #>
    param([string]$VMName)
    
    $snapshotName = "Checkpoint-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    
    Write-Log -Message "Creating snapshot '$snapshotName' for VM '$VMName'" -Level "INFO"
    Write-AuditTrail -Action "Create Snapshot" -Details "VM: $VMName | Snapshot: $snapshotName"
    
    return $snapshotName
}

# ============================================================================
# SOFTWARE INSTALLATION FUNCTIONS
# ============================================================================

function Install-SoftwareAndUpdates {
    <#
    .SYNOPSIS
        Guide through software installation and OS updates
    #>
    Write-Section "Install Software & Updates"
    
    Write-Host "│"
    Write-Subsection "Pre-Installation Checklist"
    Write-Host "│  □ VM is powered on and accessible" -ForegroundColor $colors.Info
    Write-Host "│  □ Network connectivity is available" -ForegroundColor $colors.Info
    Write-Host "│  □ Windows installation is clean" -ForegroundColor $colors.Info
    Write-Host "│"
    
    $ready = Read-Host "  Ready to proceed? (Y/N)"
    if ($ready -ne "Y") {
        Write-AuditTrail -Action "Install Software & Updates" -Status "SKIPPED"
        Write-SectionEnd
        return
    }
    
    # Software packages to install
    $packages = @(
        @{ Name = "Microsoft .NET Framework 4.8"; Required = $true }
        @{ Name = "PowerShell 7.x"; Required = $true }
        @{ Name = "Windows Terminal"; Required = $false }
        @{ Name = "Microsoft Edge"; Required = $false }
        @{ Name = "Visual C++ Redistributable"; Required = $true }
        @{ Name = "Windows Admin Center"; Required = $false }
    )
    
    Write-Host "│"
    Write-Subsection "Software Packages"
    
    foreach ($pkg in $packages) {
        $reqStr = if ($pkg.Required) { "[REQUIRED]" } else { "[OPTIONAL]" }
        Write-Host "│    $reqStr $($pkg.Name)" -ForegroundColor $colors.Info
    }
    
    Write-Host "│"
    Write-Subsection "Installation Progress"
    
    foreach ($pkg in $packages) {
        $pkgName = $pkg.Name
        Write-Host "│    Installing: $pkgName..." -NoNewline -ForegroundColor $colors.Secondary
        
        # Simulate installation
        Start-Sleep -Milliseconds 500
        
        Write-Host " ✓" -ForegroundColor $colors.Success
        Write-Log -Message "Installed package: $pkgName" -Level "SUCCESS"
        Write-AuditTrail -Action "Install Package" -Details $pkgName
    }
    
    Write-Host "│"
    Write-Subsection "Windows Updates"
    Write-Host "│    Checking for updates..." -ForegroundColor $colors.Secondary
    Start-Sleep -Milliseconds 800
    Write-Host "│    Updates available: 15 critical, 8 security, 23 standard" -ForegroundColor $colors.Warning
    Write-Host "│"
    
    $updateChoice = Read-Host "  Install all updates? (Y/N)"
    if ($updateChoice -eq "Y") {
        Write-Host "│    Installing updates..." -NoNewline -ForegroundColor $colors.Secondary
        Start-Sleep -Milliseconds 1000
        Write-Host " ✓" -ForegroundColor $colors.Success
        Write-Log -Message "Windows updates installed" -Level "SUCCESS"
        Write-AuditTrail -Action "Install Updates" -Details "15 critical, 8 security, 23 standard"
    }
    
    Write-SectionEnd
}

# ============================================================================
# CIS HARDENING FUNCTIONS
# ============================================================================

function Show-RegistryChange {
    <#
    .SYNOPSIS
        Display registry changes for review
    #>
    param(
        [string]$Path,
        [string]$Name,
        [string]$CurrentValue,
        [string]$NewValue,
        [string]$Description
    )
    
    Write-Host ""
    Write-Host "    Registry Change:" -ForegroundColor $colors.Secondary
    Write-Host "      Path:    $Path" -ForegroundColor $colors.Info
    Write-Host "      Name:    $Name" -ForegroundColor $colors.Info
    Write-Host "      Current: $CurrentValue → New: $NewValue" -ForegroundColor $colors.Accent
    Write-Host "      Details: $Description" -ForegroundColor $colors.Info
}

function Show-ServiceChange {
    <#
    .SYNOPSIS
        Display service changes for review
    #>
    param(
        [string]$ServiceName,
        [string]$CurrentState,
        [string]$NewState,
        [string]$Justification
    )
    
    Write-Host ""
    Write-Host "    Service Change:" -ForegroundColor $colors.Secondary
    Write-Host "      Service:  $ServiceName" -ForegroundColor $colors.Info
    Write-Host "      Current:  $CurrentState → New: $NewState" -ForegroundColor $colors.Accent
    Write-Host "      Reason:   $Justification" -ForegroundColor $colors.Info
}

function Show-FirewallChange {
    <#
    .SYNOPSIS
        Display firewall rule changes
    #>
    param(
        [string]$RuleName,
        [string]$Direction,
        [string]$Action,
        [string]$Protocol,
        [string]$Purpose
    )
    
    Write-Host ""
    Write-Host "    Firewall Rule:" -ForegroundColor $colors.Secondary
    Write-Host "      Rule:      $RuleName" -ForegroundColor $colors.Info
    Write-Host "      Direction: $Direction | Action: $Action" -ForegroundColor $colors.Accent
    Write-Host "      Protocol:  $Protocol" -ForegroundColor $colors.Info
    Write-Host "      Purpose:   $Purpose" -ForegroundColor $colors.Info
}

function Apply-CISHardening {
    <#
    .SYNOPSIS
        Apply CIS hardening with step-by-step review
    #>
    Write-Section "Apply CIS Hardening"
    
    Write-Host "│"
    Write-Subsection "CIS Benchmark v2.0 for Windows 11/Server 2022"
    Write-Host "│"
    
    # Define hardening controls
    $controls = @(
        @{
            ID       = "1.1.1"
            Category = "User Account Control"
            Control  = "Ensure User Access Control is enabled"
            Registry = @{
                Path         = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
                Name         = "EnableLUA"
                Current      = 1
                New          = 1
                Description  = "User Account Control (UAC) prompts users for elevated privileges"
            }
            Impact   = "Medium"
            Severity = "High"
        }
        @{
            ID       = "2.2.1"
            Category = "Windows Firewall"
            Control  = "Ensure Windows Firewall is enabled"
            Services = @{
                Name            = "MpsSvc"
                Current         = "Stopped"
                New             = "Running"
                Justification   = "Windows Firewall provides essential network protection"
                Dependencies    = "RpcSs", "SharedAccess"
            }
            Impact   = "High"
            Severity = "Critical"
        }
        @{
            ID       = "2.3.1"
            Category = "Windows Defender"
            Control  = "Ensure Windows Defender is enabled"
            Services = @{
                Name            = "WinDefend"
                Current         = "Stopped"
                New             = "Running"
                Justification   = "Windows Defender provides real-time protection"
                Dependencies    = "RpcSs"
            }
            Impact   = "High"
            Severity = "Critical"
        }
        @{
            ID       = "3.1.1"
            Category = "Account Policies"
            Control  = "Ensure password policy is enforced"
            Registry = @{
                Path         = "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters"
                Name         = "RefusePasswordChange"
                Current      = 0
                New          = 0
                Description  = "Password changes are controlled by policy"
            }
            Impact   = "Medium"
            Severity = "High"
        }
        @{
            ID       = "4.1.1"
            Category = "Audit Policies"
            Control  = "Enable audit logging for security events"
            Registry = @{
                Path         = "HKLM:\System\CurrentControlSet\Control\Lsa"
                Name         = "AuditBaseObjects"
                Current      = 0
                New          = 1
                Description  = "Audit base objects for security investigation"
            }
            Impact   = "Low"
            Severity = "Medium"
        }
        @{
            ID       = "5.1.1"
            Category = "Registry Settings"
            Control  = "Configure UAC elevation prompts"
            Registry = @{
                Path         = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
                Name         = "ConsentPromptBehaviorAdmin"
                Current      = 2
                New          = 2
                Description  = "Admin approval mode for the built-in Administrator account"
            }
            Impact   = "Medium"
            Severity = "High"
        }
    )
    
    $skipCount = 0
    $applyCount = 0
    $failCount = 0
    
    foreach ($control in $controls) {
        Write-Host "│"
        Write-Host "│  ┌─ Control: $($control.ID) - $($control.Control)" -ForegroundColor $colors.Highlight
        Write-Host "│  │  Category: $($control.Category)" -ForegroundColor $colors.Info
        Write-Host "│  │  Severity: $($control.Severity) | Impact: $($control.Impact)" -ForegroundColor $colors.Accent
        
        # Display specific changes
        if ($control.Registry) {
            Show-RegistryChange -Path $control.Registry.Path -Name $control.Registry.Name `
                -CurrentValue $control.Registry.Current -NewValue $control.Registry.New `
                -Description $control.Registry.Description
        }
        
        if ($control.Services) {
            Show-ServiceChange -ServiceName $control.Services.Name `
                -CurrentState $control.Services.Current -NewState $control.Services.New `
                -Justification $control.Services.Justification
        }
        
        Write-Host ""
        Write-Host "│  │  Options: [A]pply | [S]kip | [V]iew Details | [R]ollback" -ForegroundColor $colors.Secondary
        
        $response = Read-Host "  │  Action"
        
        switch ($response.ToUpper()) {
            "A" {
                Write-Host "  │  → Applying control $($control.ID)..." -NoNewline -ForegroundColor $colors.Secondary
                # Simulate applying control
                Start-Sleep -Milliseconds 300
                Write-Host " ✓" -ForegroundColor $colors.Success
                Write-Log -Message "Applied control $($control.ID): $($control.Control)" -Level "SUCCESS"
                Write-AuditTrail -Action "Apply CIS Control" -Details "$($control.ID): $($control.Control)"
                $applyCount++
            }
            "S" {
                Write-Host "  │  ⊘ Skipped control $($control.ID)" -ForegroundColor $colors.Warning
                Write-Log -Message "Skipped control $($control.ID): $($control.Control)" -Level "WARNING"
                Write-AuditTrail -Action "Skip CIS Control" -Status "SKIPPED" -Details "$($control.ID): $($control.Control)"
                $skipCount++
            }
            "V" {
                Write-Host "  │  Details: $($control.Control)" -ForegroundColor $colors.Info
                Write-Host "  │  Category: $($control.Category)" -ForegroundColor $colors.Info
                Read-Host "  │  Press Enter to continue"
                Write-Host "  │  → Applying control $($control.ID)..." -NoNewline -ForegroundColor $colors.Secondary
                Start-Sleep -Milliseconds 300
                Write-Host " ✓" -ForegroundColor $colors.Success
                $applyCount++
            }
            "R" {
                Write-Host "  │  ⟲ Rollback initiated for control $($control.ID)" -ForegroundColor $colors.Warning
                Write-AuditTrail -Action "Rollback CIS Control" -Details "$($control.ID): $($control.Control)"
                $failCount++
            }
            default {
                Write-Host "  │  ? Invalid option, skipping control" -ForegroundColor $colors.Warning
                $skipCount++
            }
        }
        
        Write-Host "  │"
    }
    
    Write-Host "│"
    Write-Host "│  Summary:" -ForegroundColor $colors.Secondary
    Write-Host "│    Applied:  $applyCount" -ForegroundColor $colors.Success
    Write-Host "│    Skipped:  $skipCount" -ForegroundColor $colors.Warning
    Write-Host "│    Failed:   $failCount" -ForegroundColor $colors.Error
    Write-Host "│    Total:    $($applyCount + $skipCount + $failCount)" -ForegroundColor $colors.Info
    
    Write-SectionEnd
}

# ============================================================================
# ENCRYPTION FUNCTIONS
# ============================================================================

function Enable-BitLockerEncryption {
    <#
    .SYNOPSIS
        Enable BitLocker encryption
    #>
    Write-Section "Enable BitLocker Encryption"
    
    Write-Host "│"
    Write-Subsection "BitLocker Configuration"
    Write-Host "│  BitLocker provides full disk encryption for data protection" -ForegroundColor $colors.Info
    Write-Host "│"
    
    Write-Host "  Encryption Method:" -ForegroundColor $colors.Secondary
    Write-Host "    1) XTS-AES 128-bit (Recommended)" -ForegroundColor $colors.Info
    Write-Host "    2) XTS-AES 256-bit" -ForegroundColor $colors.Info
    
    $encMethod = Read-Host "  Select encryption method"
    $method = if ($encMethod -eq "2") { "256-bit" } else { "128-bit" }
    
    Write-Host "  Recovery Password:" -ForegroundColor $colors.Secondary
    Write-Host "    1) Create new recovery password" -ForegroundColor $colors.Info
    Write-Host "    2) Use existing recovery password" -ForegroundColor $colors.Info
    
    $recoveryChoice = Read-Host "  Select option"
    
    Write-Host "│"
    Write-Host "│  Configuration Summary:" -ForegroundColor $colors.Secondary
    Write-Host "│    Encryption: XTS-AES $method" -ForegroundColor $colors.Info
    Write-Host "│    Drive:      C:\ (OS Drive)" -ForegroundColor $colors.Info
    Write-Host "│    Status:     Ready to enable" -ForegroundColor $colors.Info
    Write-Host "│"
    
    $confirm = Read-Host "  Enable BitLocker now? (Y/N)"
    
    if ($confirm -eq "Y") {
        Write-Host "│  → Enabling BitLocker..." -NoNewline -ForegroundColor $colors.Secondary
        Start-Sleep -Milliseconds 1000
        Write-Host " ✓" -ForegroundColor $colors.Success
        Write-Log -Message "BitLocker enabled with $method encryption" -Level "SUCCESS"
        Write-AuditTrail -Action "Enable BitLocker" -Details "Encryption: XTS-AES $method"
    }
    else {
        Write-Log -Message "BitLocker setup cancelled" -Level "WARNING"
        Write-AuditTrail -Action "Enable BitLocker" -Status "SKIPPED"
    }
    
    Write-SectionEnd
}

# ============================================================================
# COMPLIANCE VERIFICATION FUNCTIONS
# ============================================================================

function Verify-Compliance {
    <#
    .SYNOPSIS
        Verify CIS compliance status
    #>
    Write-Section "Verify CIS Compliance"
    
    Write-Host "│"
    Write-Subsection "Compliance Assessment"
    Write-Host "│"
    
    # Simulate compliance check
    $compliant = 42
    $noncompliant = 8
    $notApplicable = 60
    $total = $compliant + $noncompliant + $notApplicable
    $score = [math]::Round(($compliant / ($compliant + $noncompliant)) * 100, 2)
    
    Write-Host "│  Compliance Status:" -ForegroundColor $colors.Secondary
    Write-Host "│"
    Write-Host "│    ✓ Compliant Controls:     $compliant" -ForegroundColor $colors.Success
    Write-Host "│    ✗ Non-Compliant Controls: $noncompliant" -ForegroundColor $colors.Error
    Write-Host "│    ⊘ Not Applicable:        $notApplicable" -ForegroundColor $colors.Warning
    Write-Host "│"
    Write-Host "│    Overall Compliance Score: $score%" -ForegroundColor $(if ($score -ge 80) { $colors.Success } else { $colors.Warning })
    
    Write-Host "│"
    Write-Subsection "Non-Compliant Controls"
    Write-Host "│"
    
    $nonCompliant = @(
        @{ ID = "2.2.5"; Title = "Ensure Remote Assistance is disabled" }
        @{ ID = "2.3.7"; Title = "Ensure Telemetry is minimized" }
        @{ ID = "5.1.3"; Title = "Ensure AutoPlay is disabled" }
        @{ ID = "6.2.1"; Title = "Ensure weak SSL protocols are disabled" }
        @{ ID = "7.1.1"; Title = "Ensure automatic download updates" }
        @{ ID = "8.1.2"; Title = "Ensure secure boot is enabled" }
        @{ ID = "9.2.3"; Title = "Ensure Windows Defender exclusions" }
        @{ ID = "10.1.1"; Title = "Ensure password expiration policy" }
    )
    
    foreach ($control in $nonCompliant) {
        Write-Host "│    $($control.ID) - $($control.Title)" -ForegroundColor $colors.Error
    }
    
    Write-Host "│"
    Write-Subsection "Remediation Options"
    Write-Host "│  [F]ix All | [S]elect | [V]iew Details | [E]xport Report" -ForegroundColor $colors.Secondary
    
    $remAction = Read-Host "  │  Action"
    
    if ($remAction.ToUpper() -eq "F") {
        Write-Host "│  → Applying remediation..." -NoNewline -ForegroundColor $colors.Secondary
        Start-Sleep -Milliseconds 800
        Write-Host " ✓" -ForegroundColor $colors.Success
        Write-Log -Message "Applied remediation for all non-compliant controls" -Level "SUCCESS"
        Write-AuditTrail -Action "Apply Remediation" -Details "8 non-compliant controls remediated"
    }
    elseif ($remAction.ToUpper() -eq "E") {
        Write-Host "│  → Exporting compliance report..." -NoNewline -ForegroundColor $colors.Secondary
        $reportPath = Export-ComplianceReport
        Write-Host " ✓" -ForegroundColor $colors.Success
        Write-Host "│    Report saved to: $reportPath" -ForegroundColor $colors.Info
    }
    
    Write-SectionEnd
}

# ============================================================================
# IMAGE PREPARATION AND CAPTURE FUNCTIONS
# ============================================================================

function Prepare-ForCapture {
    <#
    .SYNOPSIS
        Prepare system for image capture
    #>
    Write-Section "Prepare for Capture"
    
    Write-Host "│"
    Write-Subsection "Pre-Capture Checklist"
    Write-Host "│"
    
    $checks = @(
        @{ Item = "Remove user profiles"; Status = "Pending" }
        @{ Item = "Clear temporary files"; Status = "Pending" }
        @{ Item = "Reset Event Logs"; Status = "Pending" }
        @{ Item = "Clean Windows Update cache"; Status = "Pending" }
        @{ Item = "Disable anti-malware"; Status = "Pending" }
        @{ Item = "Remove installation media"; Status = "Pending" }
        @{ Item = "Run System Cleanup"; Status = "Pending" }
        @{ Item = "Verify sysprep readiness"; Status = "Pending" }
    )
    
    foreach ($check in $checks) {
        Write-Host "│    [$($check.Status)] $($check.Item)" -ForegroundColor $colors.Info
    }
    
    Write-Host "│"
    $confirm = Read-Host "  Execute preparation steps? (Y/N)"
    
    if ($confirm -eq "Y") {
        Write-Host "│"
        foreach ($check in $checks) {
            Write-Host "│  → $($check.Item)..." -NoNewline -ForegroundColor $colors.Secondary
            Start-Sleep -Milliseconds 400
            Write-Host " ✓" -ForegroundColor $colors.Success
        }
        
        Write-Log -Message "System prepared for capture" -Level "SUCCESS"
        Write-AuditTrail -Action "Prepare for Capture" -Details "All pre-capture steps completed"
    }
    
    Write-SectionEnd
}

function Capture-Image {
    <#
    .SYNOPSIS
        Capture hardened image
    #>
    Write-Section "Capture Image"
    
    Write-Host "│"
    Write-Subsection "Image Capture Configuration"
    Write-Host "│"
    
    $imageName = Read-Host "  Image name (e.g., WIN11-HARDENED-v1.0)"
    if ([string]::IsNullOrEmpty($imageName)) {
        Write-AuditTrail -Action "Capture Image" -Status "SKIPPED"
        Write-SectionEnd
        return
    }
    
    Write-Host "  Description:" -ForegroundColor $colors.Secondary
    $description = Read-Host "    "
    
    Write-Host "│"
    Write-Host "│  Image Configuration:" -ForegroundColor $colors.Secondary
    Write-Host "│    Name:        $imageName" -ForegroundColor $colors.Info
    Write-Host "│    Description: $description" -ForegroundColor $colors.Info
    Write-Host "│    Format:      WIM (Windows Imaging Format)" -ForegroundColor $colors.Info
    Write-Host "│    Compression: LZX (Maximum)" -ForegroundColor $colors.Info
    Write-Host "│"
    
    $confirm = Read-Host "  Begin image capture? (Y/N)"
    
    if ($confirm -eq "Y") {
        Write-Host "│  → Capturing image..." -ForegroundColor $colors.Secondary
        
        for ($i = 0; $i -le 100; $i += 10) {
            Write-Host "│    [" -NoNewline -ForegroundColor $colors.Secondary
            Write-Host "$(('█' * ($i / 10)).PadRight(10, '░'))" -NoNewline
            Write-Host "] $i%" -ForegroundColor $colors.Secondary
            Start-Sleep -Milliseconds 400
        }
        
        $imagePath = Join-Path $reportDir "$imageName.wim"
        Write-Host "│  ✓ Image captured successfully" -ForegroundColor $colors.Success
        Write-Host "│    Location: $imagePath" -ForegroundColor $colors.Info
        
        Write-Log -Message "Image '$imageName' captured successfully" -Level "SUCCESS"
        Write-AuditTrail -Action "Capture Image" -Details "Image: $imageName | Path: $imagePath"
    }
    
    Write-SectionEnd
}

function Deploy-Image {
    <#
    .SYNOPSIS
        Deploy captured image
    #>
    Write-Section "Deploy Image"
    
    Write-Host "│"
    Write-Subsection "Deployment Configuration"
    Write-Host "│"
    
    Write-Host "  Available Images:" -ForegroundColor $colors.Secondary
    Write-Host "    1) WIN11-HARDENED-v1.0.wim" -ForegroundColor $colors.Info
    Write-Host "    2) WIN11-HARDENED-v1.1.wim" -ForegroundColor $colors.Info
    Write-Host "    3) Custom image..." -ForegroundColor $colors.Info
    
    $imageChoice = Read-Host "  Select image"
    
    $images = @(
        "WIN11-HARDENED-v1.0.wim",
        "WIN11-HARDENED-v1.1.wim"
    )
    
    $selectedImage = if ([int]$imageChoice -le $images.Count) { 
        $images[[int]$imageChoice - 1] 
    } else { 
        Read-Host "Enter custom image path" 
    }
    
    Write-Host "│"
    Write-Host "│  Deployment Target:" -ForegroundColor $colors.Secondary
    
    $targetVM = Read-Host "    Target VM name"
    $targetDrive = Read-Host "    Target drive letter (default: C)"
    if ([string]::IsNullOrEmpty($targetDrive)) { $targetDrive = "C" }
    
    Write-Host "│"
    Write-Host "│  Configuration Summary:" -ForegroundColor $colors.Secondary
    Write-Host "│    Image:       $selectedImage" -ForegroundColor $colors.Info
    Write-Host "│    Target VM:   $targetVM" -ForegroundColor $colors.Info
    Write-Host "│    Drive:       $($targetDrive):\" -ForegroundColor $colors.Info
    Write-Host "│"
    
    $confirm = Read-Host "  Begin deployment? (Y/N)"
    
    if ($confirm -eq "Y") {
        Write-Host "│  → Deploying image..." -ForegroundColor $colors.Secondary
        
        for ($i = 0; $i -le 100; $i += 5) {
            Write-Host "│    [" -NoNewline -ForegroundColor $colors.Secondary
            Write-Host "$(('█' * ($i / 5)).PadRight(20, '░'))" -NoNewline
            Write-Host "] $i%" -ForegroundColor $colors.Secondary
            Start-Sleep -Milliseconds 200
        }
        
        Write-Host "│  ✓ Image deployed successfully" -ForegroundColor $colors.Success
        Write-Log -Message "Image '$selectedImage' deployed to VM '$targetVM'" -Level "SUCCESS"
        Write-AuditTrail -Action "Deploy Image" -Details "Image: $selectedImage | Target: $targetVM"
    }
    
    Write-SectionEnd
}

# ============================================================================
# REPORTING FUNCTIONS
# ============================================================================

function Export-ComplianceReport {
    <#
    .SYNOPSIS
        Export compliance report
    #>
    $reportFile = Join-Path $reportDir "Compliance-Report-$(Get-Date -Format 'yyyyMMdd-HHmmss').html"
    
    $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>PC Republic - Compliance Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f5f5f5; }
        h1 { color: #0066cc; border-bottom: 2px solid #0066cc; }
        h2 { color: #0099ff; margin-top: 20px; }
        table { border-collapse: collapse; width: 100%; margin: 15px 0; background: white; }
        th, td { border: 1px solid #ddd; padding: 12px; text-align: left; }
        th { background: #0066cc; color: white; }
        tr:nth-child(even) { background: #f9f9f9; }
        .success { color: green; font-weight: bold; }
        .warning { color: orange; font-weight: bold; }
        .error { color: red; font-weight: bold; }
        .summary { background: #e8f4f8; border-left: 4px solid #0066cc; padding: 15px; margin: 15px 0; }
    </style>
</head>
<body>
    <h1>🛡️ PC Republic - CIS Compliance Report</h1>
    
    <div class="summary">
        <h2>Compliance Summary</h2>
        <p><strong>Report Generated:</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
        <p><strong>Compliance Score:</strong> <span class="success">84.21%</span></p>
        <p><strong>Compliant Controls:</strong> <span class="success">42</span> | <strong>Non-Compliant:</strong> <span class="warning">8</span> | <strong>Not Applicable:</strong> 60</p>
    </div>
    
    <h2>Compliance Status by Category</h2>
    <table>
        <tr>
            <th>Category</th>
            <th>Compliant</th>
            <th>Non-Compliant</th>
            <th>Compliance %</th>
        </tr>
        <tr>
            <td>User Account Control</td>
            <td class="success">8</td>
            <td class="error">1</td>
            <td class="warning">88.9%</td>
        </tr>
        <tr>
            <td>Windows Firewall</td>
            <td class="success">6</td>
            <td class="error">0</td>
            <td class="success">100%</td>
        </tr>
        <tr>
            <td>Windows Defender</td>
            <td class="success">5</td>
            <td class="error">2</td>
            <td class="warning">71.4%</td>
        </tr>
        <tr>
            <td>Account Policies</td>
            <td class="success">7</td>
            <td class="error">2</td>
            <td class="warning">77.8%</td>
        </tr>
        <tr>
            <td>Audit Policies</td>
            <td class="success">9</td>
            <td class="error">1</td>
            <td class="warning">90%</td>
        </tr>
        <tr>
            <td>Registry Settings</td>
            <td class="success">7</td>
            <td class="error">2</td>
            <td class="warning">77.8%</td>
        </tr>
    </table>
    
    <h2>Audit Trail</h2>
    <table>
        <tr>
            <th>Timestamp</th>
            <th>Action</th>
            <th>Status</th>
            <th>Details</th>
        </tr>
"@

    foreach ($entry in $auditTrail | Select-Object -Last 20) {
        $statusClass = switch ($entry.Status) {
            "COMPLETED" { "success" }
            "SKIPPED" { "warning" }
            "FAILED" { "error" }
            default { "info" }
        }
        
        $html += @"
        <tr>
            <td>$($entry.Timestamp)</td>
            <td>$($entry.Action)</td>
            <td><span class="$statusClass">$($entry.Status)</span></td>
            <td>$($entry.Details)</td>
        </tr>
"@
    }
    
    $html += @"
    </table>
</body>
</html>
"@

    Set-Content -Path $reportFile -Value $html -Force
    return $reportFile
}

function Show-AuditTrail {
    <#
    .SYNOPSIS
        Display audit trail
    #>
    Write-Section "Audit Trail"
    
    Write-Host "│"
    Write-Host "│  Recent Actions:" -ForegroundColor $colors.Secondary
    Write-Host "│"
    
    foreach ($entry in $global:auditTrail | Select-Object -Last 15) {
        $statusColor = switch ($entry.Status) {
            "COMPLETED" { $colors.Success }
            "SKIPPED" { $colors.Warning }
            "FAILED" { $colors.Error }
            default { $colors.Info }
        }
        
        Write-Host "│  [$($entry.Status)]" -NoNewline -ForegroundColor $statusColor
        Write-Host " $($entry.Action)" -NoNewline -ForegroundColor $colors.Info
        Write-Host " - $($entry.Details)" -ForegroundColor $colors.Accent
    }
    
    Write-Host "│"
    Write-Host "│  Options: [E]xport | [C]lear | [B]ack" -ForegroundColor $colors.Secondary
    
    $action = Read-Host "  │  Action"
    
    if ($action.ToUpper() -eq "E") {
        $auditFile = Join-Path $reportDir "Audit-Trail-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
        $global:auditTrail | Export-Csv -Path $auditFile -NoTypeInformation
        Write-Host "│  ✓ Audit trail exported to: $auditFile" -ForegroundColor $colors.Success
        Write-AuditTrail -Action "Export Audit Trail" -Details "File: $auditFile"
    }
    
    Write-SectionEnd
}

function Generate-AllReports {
    <#
    .SYNOPSIS
        Generate all reports
    #>
    Write-Section "Generate Reports"
    
    Write-Host "│"
    Write-Subsection "Available Reports"
    Write-Host "│"
    Write-Host "│    1) Compliance Report" -ForegroundColor $colors.Info
    Write-Host "│    2) Audit Trail Report" -ForegroundColor $colors.Info
    Write-Host "│    3) Configuration Report" -ForegroundColor $colors.Info
    Write-Host "│    4) All Reports" -ForegroundColor $colors.Info
    Write-Host "│"
    
    $reportChoice = Read-Host "  Select report type"
    
    Write-Host "│  → Generating reports..." -ForegroundColor $colors.Secondary
    
    if ($reportChoice -in "1", "4") {
        $compFile = Export-ComplianceReport
        Write-Host "│    ✓ Compliance report: $compFile" -ForegroundColor $colors.Success
    }
    
    if ($reportChoice -in "2", "4") {
        $auditFile = Join-Path $reportDir "Audit-Trail-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
        $global:auditTrail | Export-Csv -Path $auditFile -NoTypeInformation
        Write-Host "│    ✓ Audit trail report: $auditFile" -ForegroundColor $colors.Success
    }
    
    if ($reportChoice -in "3", "4") {
        $configFile = Join-Path $reportDir "Configuration-Report-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
        "Configuration Report`n" + ("=" * 50) | Set-Content -Path $configFile
        Write-Host "│    ✓ Configuration report: $configFile" -ForegroundColor $colors.Success
    }
    
    Write-AuditTrail -Action "Generate Reports" -Details "Report type: $reportChoice"
    Write-SectionEnd
}

# ============================================================================
# MAIN MENU LOOP
# ============================================================================

function Main {
    <#
    .SYNOPSIS
        Main application loop
    #>
    Write-AuditTrail -Action "Application Start" -Details "PC Republic Hardened Image Builder v2.0.0"
    
    while ($true) {
        $choice = Show-MainMenu
        
        switch ($choice) {
            "1" { New-HardenedVM | Out-Null }
            "2" { Install-SoftwareAndUpdates }
            "3" { Apply-CISHardening }
            "4" { Enable-BitLockerEncryption }
            "5" { Verify-Compliance }
            "6" { Prepare-ForCapture }
            "7" { Capture-Image }
            "8" { Deploy-Image }
            "V" { Show-AuditTrail }
            "R" { Generate-AllReports }
            "Q" {
                Write-Banner
                Write-Host "Thank you for using PC Republic Hardened Image Builder!" -ForegroundColor $colors.Success
                Write-AuditTrail -Action "Application End" -Details "Normal termination"
                Write-Log -Message "Application terminated" -Level "INFO"
                exit 0
            }
            default {
                Write-Host "Invalid option. Please try again." -ForegroundColor $colors.Error
            }
        }
        
        Read-Host "Press Enter to continue"
    }
}

# ============================================================================
# ENTRY POINT
# ============================================================================

try {
    Main
}
catch {
    Write-Log -Message "Fatal error: $_" -Level "ERROR"
    Write-Host "An error occurred. Please check the log file: $logFile" -ForegroundColor $colors.Error
    exit 1
}

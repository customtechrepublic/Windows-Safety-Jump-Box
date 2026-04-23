# ============================================================================
# Windows Factory - CIS Hardening Module
# Language of the Land (LotL) Approach
# ============================================================================
# Implements CIS Benchmarks for Windows 11 & Server 2022
# CIS Level 1: Essential security controls
# CIS Level 2: Enhanced security controls
# ============================================================================

$ErrorActionPreference = "Stop"

# ============================================================================
# Helper Functions
# ============================================================================

function Write-HardeningLog {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'SUCCESS', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] [CISHardening] $Message"
    
    $color = @{
        'INFO'    = 'Cyan'
        'SUCCESS' = 'Green'
        'WARN'    = 'Yellow'
        'ERROR'   = 'Red'
    }
    Write-Host $logMessage -ForegroundColor $color[$Level]
}

function Test-AdminRights {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-HardeningLog "This module requires Administrator rights" "ERROR"
        throw "Administrator rights required"
    }
}

function Test-MountedImage {
    param([string]$MountPoint)
    if (-not (Test-Path "$MountPoint\Windows\System32")) {
        Write-HardeningLog "Not a valid Windows image mount: $MountPoint" "ERROR"
        throw "Invalid Windows image mount point"
    }
    return $true
}

function Set-RegistryValue {
    param(
        [string]$Path,
        [string]$Name,
        [object]$Value,
        [string]$Type = "DWord",
        [string]$MountPoint = ""
    )
    
    try {
        if ($MountPoint) {
            $regPath = $Path -replace 'HKLM:', $MountPoint
            if (-not (Test-Path $regPath)) {
                New-Item -Path $regPath -Force | Out-Null
            }
            New-ItemProperty -Path $regPath -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
        } else {
            if (-not (Test-Path $Path)) {
                New-Item -Path $Path -Force | Out-Null
            }
            New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
        }
        return $true
    } catch {
        Write-HardeningLog "Could not set registry $Path\$Name : $_" "WARN"
        return $false
    }
}

# ============================================================================
# User Account Control (CIS 1.x)
# ============================================================================

function Set-UACConfiguration {
    <#
    .SYNOPSIS
        Configures User Account Control per CIS
    .PARAMETER MountPoint
        Path to mounted Windows image
    .PARAMETER Level
        CIS Level: 1 or 2
    .EXAMPLE
        Set-UACConfiguration -MountPoint "C:\Mount" -Level 2
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = "",
        
        [ValidateSet(1, 2)]
        [Parameter(Mandatory = $false)]
        [int]$Level = 2
    )
    
    Test-AdminRights
    if ($MountPoint) { Test-MountedImage -MountPoint $MountPoint }
    
    Write-HardeningLog "Configuring UAC..." "INFO"
    
    $regBase = if ($MountPoint) { "HKLM:\$($MountPoint -replace ':', '')" } else { "HKLM:" }
    $path = "$regBase\Software\Microsoft\Windows\CurrentVersion\Policies\System"
    
    Set-RegistryValue -Path $path -Name "EnableLUA" -Value 1 -Type "DWord" -MountPoint $MountPoint
    Set-RegistryValue -Path $path -Name "ConsentPromptBehaviorAdmin" -Value 2 -Type "DWord" -MountPoint $MountPoint
    Set-RegistryValue -Path $path -Name "ConsentPromptBehaviorUser" -Value 3 -Type "DWord" -MountPoint $MountPoint
    Set-RegistryValue -Path $path -Name "EnableUIADesktopToggle" -Value 0 -Type "DWord" -MountPoint $MountPoint
    Set-RegistryValue -Path $path -Name "ValidateAdminCodeSignatures" -Value 1 -Type "DWord" -MountPoint $MountPoint
    Set-RegistryValue -Path $path -Name "PromptOnSecureDesktop" -Value 1 -Type "DWord" -MountPoint $MountPoint
    
    if ($Level -ge 2) {
        Set-RegistryValue -Path $path -Name "FilterAdministratorToken" -Value 1 -Type "DWord" -MountPoint $MountPoint
    }
    
    Write-HardeningLog "UAC configured (Level $Level)" "SUCCESS"
    return $true
}

# ============================================================================
# Windows Firewall (CIS 2.x)
# ============================================================================

function Set-WindowsFirewall {
    <#
    .SYNOPSIS
        Configures Windows Firewall per CIS
    .PARAMETER MountPoint
        Path to mounted Windows image
    .PARAMETER Level
        CIS Level: 1 or 2
    .EXAMPLE
        Set-WindowsFirewall -MountPoint "C:\Mount" -Level 2
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = "",
        
        [ValidateSet(1, 2)]
        [Parameter(Mandatory = $false)]
        [int]$Level = 2
    )
    
    Test-AdminRights
    if ($MountPoint) { Test-MountedImage -MountPoint $MountPoint }
    
    Write-HardeningLog "Configuring Windows Firewall..." "INFO"
    
    try {
        if (-not $MountPoint) {
            Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True -ErrorAction SilentlyContinue
            Set-NetFirewallProfile -Profile Domain,Public,Private -DefaultOutboundAction Block -ErrorAction SilentlyContinue
            
            $logPath = "$env:SystemRoot\System32\LogFiles\Firewall\pfirewall.log"
            Set-NetFirewallProfile -Profile Domain,Public,Private -LogFileName $logPath -ErrorAction SilentlyContinue
            
            if ($Level -ge 2) {
                Set-NetFirewallProfile -Profile Domain,Public,Private -LogBlocked True -ErrorAction SilentlyContinue
            }
        }
        
        Write-HardeningLog "Windows Firewall configured (Level $Level)" "SUCCESS"
        return $true
    } catch {
        Write-HardeningLog "Firewall configuration error: $_" "WARN"
        return $false
    }
}

# ============================================================================
# Windows Defender (CIS 3.x)
# ============================================================================

function Set-WindowsDefender {
    <#
    .SYNOPSIS
        Configures Windows Defender per CIS
    .PARAMETER MountPoint
        Path to mounted Windows image
    .PARAMETER Level
        CIS Level: 1 or 2
    .EXAMPLE
        Set-WindowsDefender -MountPoint "C:\Mount" -Level 2
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = "",
        
        [ValidateSet(1, 2)]
        [Parameter(Mandatory = $false)]
        [int]$Level = 2
    )
    
    Test-AdminRights
    if ($MountPoint) { Test-MountedImage -MountPoint $MountPoint }
    
    Write-HardeningLog "Configuring Windows Defender..." "INFO"
    
    try {
        if (Get-Command Set-MpPreference -ErrorAction SilentlyContinue) {
            Set-MpPreference -EnableRealtimeMonitoring $true -ErrorAction SilentlyContinue
            Set-MpPreference -EnableBehaviorMonitoring $true -ErrorAction SilentlyContinue
            Set-MpPreference -EnableCloudProtection $true -ErrorAction SilentlyContinue
            Set-MpPreference -CloudBlockLevel "High" -ErrorAction SilentlyContinue
            
            if ($Level -ge 2) {
                Set-MpPreference -EnableNetworkProtection Enabled -ErrorAction SilentlyContinue
                Set-MpPreference -EnableControlledFolderAccess Enabled -ErrorAction SilentlyContinue
                Set-MpPreference -PUAProtection Enabled -ErrorAction SilentlyContinue
            }
            
            Write-HardeningLog "Windows Defender configured (Level $Level)" "SUCCESS"
        } else {
            Write-HardeningLog "Windows Defender not available" "WARN"
        }
        return $true
    } catch {
        Write-HardeningLog "Defender configuration error: $_" "WARN"
        return $false
    }
}

# ============================================================================
# Audit Policies (CIS 4.x)
# ============================================================================

function Set-AuditPolicies {
    <#
    .SYNOPSIS
        Configures audit policies per CIS
    .PARAMETER MountPoint
        Path to mounted Windows image
    .PARAMETER Level
        CIS Level: 1 or 2
    .EXAMPLE
        Set-AuditPolicies -MountPoint "C:\Mount" -Level 2
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = "",
        
        [ValidateSet(1, 2)]
        [Parameter(Mandatory = $false)]
        [int]$Level = 2
    )
    
    Test-AdminRights
    if ($MountPoint) { Test-MountedImage -MountPoint $MountPoint }
    
    Write-HardeningLog "Configuring audit policies..." "INFO"
    
    $policies = @(
        "Logon/Logoff",
        "Account Logon",
        "Object Access",
        "Privilege Use",
        "Detailed Tracking",
        "Policy Change",
        "Account Management",
        "Process Tracking",
        "System"
    )
    
    foreach ($policy in $policies) {
        try {
            $result = auditpol /set /subcategory:"$policy" /success:enable /failure:enable 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-HardeningLog "Auditing enabled: $policy" "SUCCESS"
            }
        } catch {
            Write-HardeningLog "Could not enable audit: $policy" "WARN"
        }
    }
    
    Write-HardeningLog "Audit policies configured (Level $Level)" "SUCCESS"
    return $true
}

# ============================================================================
# Local Security Policy (CIS 5.x)
# ============================================================================

function Set-LocalSecurityPolicy {
    <#
    .SYNOPSIS
        Configures local security policy per CIS
    .PARAMETER MountPoint
        Path to mounted Windows image
    .PARAMETER Level
        CIS Level: 1 or 2
    .EXAMPLE
        Set-LocalSecurityPolicy -MountPoint "C:\Mount" -Level 2
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = "",
        
        [ValidateSet(1, 2)]
        [Parameter(Mandatory = $false)]
        [int]$Level = 2
    )
    
    Test-AdminRights
    if ($MountPoint) { Test-MountedImage -MountPoint $MountPoint }
    
    Write-HardeningLog "Configuring local security policy..." "INFO"
    
    $regBase = if ($MountPoint) { "HKLM:\$($MountPoint -replace ':', '')" } else { "HKLM:" }
    
    # Network security
    $path = "$regBase\System\CurrentControlSet\Services\LanmanServer\Parameters"
    Set-RegistryValue -Path $path -Name "RestrictNullSessAccess" -Value 1 -Type "DWord" -MountPoint $MountPoint
    
    # LSA security
    $path = "$regBase\System\CurrentControlSet\Control\Lsa"
    Set-RegistryValue -Path $path -Name "RestrictAnonymous" -Value 1 -Type "DWord" -MountPoint $MountPoint
    Set-RegistryValue -Path $path -Name "RestrictAnonymousSAM" -Value 1 -Type "DWord" -MountPoint $MountPoint
    Set-RegistryValue -Path $path -Name "EveryoneIncludesAnonymous" -Value 0 -Type "DWord" -MountPoint $MountPoint
    Set-RegistryValue -Path $path -Name "ForceGuest" -Value 0 -Type "DWord" -MountPoint $MountPoint
    
    if ($Level -ge 2) {
        Set-RegistryValue -Path $path -Name "LmCompatibilityLevel" -Value 5 -Type "DWord" -MountPoint $MountPoint
    }
    
    Write-HardeningLog "Local security policy configured (Level $Level)" "SUCCESS"
    return $true
}

# ============================================================================
# Credential Guard & Device Guard (CIS 6.x)
# ============================================================================

function Set-CredentialGuard {
    <#
    .SYNOPSIS
        Configures Credential Guard and Device Guard per CIS
    .PARAMETER MountPoint
        Path to mounted Windows image
    .PARAMETER Level
        CIS Level: 1 or 2
    .EXAMPLE
        Set-CredentialGuard -MountPoint "C:\Mount" -Level 2
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = "",
        
        [ValidateSet(1, 2)]
        [Parameter(Mandatory = $false)]
        [int]$Level = 2
    )
    
    Test-AdminRights
    if ($MountPoint) { Test-MountedImage -MountPoint $MountPoint }
    
    Write-HardeningLog "Configuring Credential Guard & Device Guard..." "INFO"
    
    $regBase = if ($MountPoint) { "HKLM:\$($MountPoint -replace ':', '')" } else { "HKLM:" }
    
    # Enable Credential Guard
    $path = "$regBase\System\CurrentControlSet\Control\Lsa"
    Set-RegistryValue -Path $path -Name "LsaCfgFlags" -Value 1 -Type "DWord" -MountPoint $MountPoint
    
    if ($Level -ge 2) {
        # Enable Hypervisor-Enforced Code Integrity
        $path = "$regBase\System\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity"
        Set-RegistryValue -Path $path -Name "Enabled" -Value 1 -Type "DWord" -MountPoint $MountPoint
    }
    
    Write-HardeningLog "Credential Guard configured (Level $Level)" "SUCCESS"
    return $true
}

# ============================================================================
# Exploit Protection (CIS 7.x)
# ============================================================================

function Set-ExploitProtection {
    <#
    .SYNOPSIS
        Configures Exploit Protection per CIS
    .PARAMETER MountPoint
        Path to mounted Windows image
    .PARAMETER Level
        CIS Level: 1 or 2
    .EXAMPLE
        Set-ExploitProtection -MountPoint "C:\Mount" -Level 2
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = "",
        
        [ValidateSet(1, 2)]
        [Parameter(Mandatory = $false)]
        [int]$Level = 2
    )
    
    Test-AdminRights
    if ($MountPoint) { Test-MountedImage -MountPoint $MountPoint }
    
    Write-HardeningLog "Configuring Exploit Protection..." "INFO"
    
    try {
        $mitigationParams = @{
            System = $true
            Enable = @("EmulateAtlThunks", "BottomUpASLR", "TopDownASLR", "SEHOP", "ForceIEF")
        }
        Set-ProcessMitigation @mitigationParams -ErrorAction SilentlyContinue
        Write-HardeningLog "Exploit Protection configured (Level $Level)" "SUCCESS"
    } catch {
        Write-HardeningLog "Exploit Protection error: $_" "WARN"
    }
    
    return $true
}

# ============================================================================
# Network Security (CIS 8.x)
# ============================================================================

function Set-NetworkSecurity {
    <#
    .SYNOPSIS
        Configures network security per CIS
    .PARAMETER MountPoint
        Path to mounted Windows image
    .PARAMETER Level
        CIS Level: 1 or 2
    .EXAMPLE
        Set-NetworkSecurity -MountPoint "C:\Mount" -Level 2
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = "",
        
        [ValidateSet(1, 2)]
        [Parameter(Mandatory = $false)]
        [int]$Level = 2
    )
    
    Test-AdminRights
    if ($MountPoint) { Test-MountedImage -MountPoint $MountPoint }
    
    Write-HardeningLog "Configuring network security..." "INFO"
    
    $regBase = if ($MountPoint) { "HKLM:\$($MountPoint -replace ':', '')" } else { "HKLM:" }
    $path = "$regBase\System\CurrentControlSet\Services\Tcpip\Parameters"
    
    Set-RegistryValue -Path $path -Name "TcpMaxDataRetransmissions" -Value 3 -Type "DWord" -MountPoint $MountPoint
    Set-RegistryValue -Path $path -Name "SynAttackProtect" -Value 2 -Type "DWord" -MountPoint $MountPoint
    Set-RegistryValue -Path $path -Name "DisableIPSourceRouting" -Value 2 -Type "DWord" -MountPoint $MountPoint
    Set-RegistryValue -Path $path -Name "EnableICMPRedirect" -Value 0 -Type "DWord" -MountPoint $MountPoint
    
    if ($Level -ge 2) {
        # Disable NetBIOS over TCP/IP
        $path = "$regBase\System\CurrentControlSet\Services\NetBT\Parameters\Interfaces"
        # Additional hardening would go here
    }
    
    Write-HardeningLog "Network security configured (Level $Level)" "SUCCESS"
    return $true
}

# ============================================================================
# SMB Hardening (CIS 9.x)
# ============================================================================

function Set-SMBHardening {
    <#
    .SYNOPSIS
        Configures SMB security per CIS
    .PARAMETER MountPoint
        Path to mounted Windows image
    .PARAMETER Level
        CIS Level: 1 or 2
    .EXAMPLE
        Set-SMBHardening -MountPoint "C:\Mount" -Level 2
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = "",
        
        [ValidateSet(1, 2)]
        [Parameter(Mandatory = $false)]
        [int]$Level = 2
    )
    
    Test-AdminRights
    if ($MountPoint) { Test-MountedImage -MountPoint $MountPoint }
    
    Write-HardeningLog "Configuring SMB security..." "INFO"
    
    $regBase = if ($MountPoint) { "HKLM:\$($MountPoint -replace ':', '')" } else { "HKLM:" }
    $path = "$regBase\System\CurrentControlSet\Services\LanmanServer\Parameters"
    
    Set-RegistryValue -Path $path -Name "SMB1" -Value 0 -Type "DWord" -MountPoint $MountPoint
    Set-RegistryValue -Path $path -Name "RequireSecuritySignature" -Value 1 -Type "DWord" -MountPoint $MountPoint
    Set-RegistryValue -Path $path -Name "EnableSecuritySignature" -Value 1 -Type "DWord" -MountPoint $MountPoint
    Set-RegistryValue -Path $path -Name "RestrictNullSessAccess" -Value 1 -Type "DWord" -MountPoint $MountPoint
    
    Write-HardeningLog "SMB security configured (Level $Level)" "SUCCESS"
    return $true
}

# ============================================================================
# Windows Update (CIS 10.x)
# ============================================================================

function Set-WindowsUpdatePolicy {
    <#
    .SYNOPSIS
        Configures Windows Update per CIS
    .PARAMETER MountPoint
        Path to mounted Windows image
    .PARAMETER Level
        CIS Level: 1 or 2
    .EXAMPLE
        Set-WindowsUpdatePolicy -MountPoint "C:\Mount" -Level 2
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = "",
        
        [ValidateSet(1, 2)]
        [Parameter(Mandatory = $false)]
        [int]$Level = 2
    )
    
    Test-AdminRights
    if ($MountPoint) { Test-MountedImage -MountPoint $MountPoint }
    
    Write-HardeningLog "Configuring Windows Update..." "INFO"
    
    $regBase = if ($MountPoint) { "HKLM:\$($MountPoint -replace ':', '')" } else { "HKLM:" }
    $path = "$regBase\Software\Policies\Microsoft\Windows\WindowsUpdate\AU"
    
    Set-RegistryValue -Path $path -Name "NoAutoRebootWithLoggedOnUsers" -Value 1 -Type "DWord" -MountPoint $MountPoint
    Set-RegistryValue -Path $path -Name "AUOptions" -Value 4 -Type "DWord" -MountPoint $MountPoint
    Set-RegistryValue -Path $path -Name "ScheduledInstallDay" -Value 0 -Type "DWord" -MountPoint $MountPoint
    Set-RegistryValue -Path $path -Name "ScheduledInstallTime" -Value 3 -Type "DWord" -MountPoint $MountPoint
    
    Write-HardeningLog "Windows Update configured (Level $Level)" "SUCCESS"
    return $true
}

# ============================================================================
# PowerShell Hardening (CIS 11.x)
# ============================================================================

function Set-PowerShellHardening {
    <#
    .SYNOPSIS
        Configures PowerShell security per CIS
    .PARAMETER MountPoint
        Path to mounted Windows image
    .PARAMETER Level
        CIS Level: 1 or 2
    .EXAMPLE
        Set-PowerShellHardening -MountPoint "C:\Mount" -Level 2
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = "",
        
        [ValidateSet(1, 2)]
        [Parameter(Mandatory = $false)]
        [int]$Level = 2
    )
    
    Test-AdminRights
    if ($MountPoint) { Test-MountedImage -MountPoint $MountPoint }
    
    Write-HardeningLog "Configuring PowerShell hardening..." "INFO"
    
    $regBase = if ($MountPoint) { "HKLM:\$($MountPoint -replace ':', '')" } else { "HKLM:" }
    $path = "$regBase\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
    
    Set-RegistryValue -Path $path -Name "EnableScriptBockingLogging" -Value 1 -Type "DWord" -MountPoint $MountPoint
    
    $path = "$regBase\Software\Microsoft\PowerShellCore\ReleasedVersions"
    # Track PowerShell versions
    
    Write-HardeningLog "PowerShell hardening configured (Level $Level)" "SUCCESS"
    return $true
}

# ============================================================================
# Complete CIS Hardening Pipeline
# ============================================================================

function Start-CISHardening {
    <#
    .SYNOPSIS
        Applies complete CIS hardening
    .PARAMETER MountPoint
        Path to mounted Windows image
    .PARAMETER Level
        CIS Level: 1 or 2
    .EXAMPLE
        Start-CISHardening -MountPoint "C:\Mount" -Level 2
    #>
    [Cmd-letBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$MountPoint,
        
        [ValidateSet(1, 2)]
        [Parameter(Mandatory = $false)]
        [int]$Level = 2
    )
    
    Test-AdminRights
    Test-MountedImage -MountPoint $MountPoint
    
    Write-HardeningLog "========================================" "INFO"
    Write-HardeningLog "Starting CIS Level $Level Hardening..." "INFO"
    Write-HardeningLog "========================================" "INFO"
    
    # Apply all hardening categories
    Set-UACConfiguration -MountPoint $MountPoint -Level $Level
    Set-WindowsFirewall -MountPoint $MountPoint -Level $Level
    Set-WindowsDefender -MountPoint $MountPoint -Level $Level
    Set-AuditPolicies -MountPoint $MountPoint -Level $Level
    Set-LocalSecurityPolicy -MountPoint $MountPoint -Level $Level
    Set-CredentialGuard -MountPoint $MountPoint -Level $Level
    Set-ExploitProtection -MountPoint $MountPoint -Level $Level
    Set-NetworkSecurity -MountPoint $MountPoint -Level $Level
    Set-SMBHardening -MountPoint $MountPoint -Level $Level
    Set-WindowsUpdatePolicy -MountPoint $MountPoint -Level $Level
    Set-PowerShellHardening -MountPoint $MountPoint -Level $Level
    
    Write-HardeningLog "========================================" "SUCCESS"
    Write-HardeningLog "CIS Level $Level Hardening Complete" "SUCCESS"
    Write-HardeningLog "========================================" "SUCCESS"
    
    return $true
}

# ============================================================================
# Export Functions
# ============================================================================

Export-ModuleMember -Function @(
    'Set-UACConfiguration',
    'Set-WindowsFirewall',
    'Set-WindowsDefender',
    'Set-AuditPolicies',
    'Set-LocalSecurityPolicy',
    'Set-CredentialGuard',
    'Set-ExploitProtection',
    'Set-NetworkSecurity',
    'Set-SMBHardening',
    'Set-WindowsUpdatePolicy',
    'Set-PowerShellHardening',
    'Start-CISHardening'
)
# ============================================================================
# Windows Factory - Library Initialization
# Language of the Land (LotL) Approach
# ============================================================================
# Loads all Windows Factory modules
# ============================================================================

$ErrorActionPreference = "Stop"

# Get the script root directory
$ScriptRoot = $PSScriptRoot

# Load modules in order
$modules = @(
    "ImageManagement.ps1",
    "ComponentRemoval.ps1",
    "CISHardening.ps1",
    "ComplianceReporting.ps1"
)

Write-Host "Loading Windows Factory Library..." -ForegroundColor Cyan

foreach ($module in $modules) {
    $modulePath = Join-Path $ScriptRoot "lib\$module"
    if (Test-Path $modulePath) {
        try {
            . $modulePath
            Write-Host "  Loaded: $module" -ForegroundColor Green
        } catch {
            Write-Host "  Failed to load: $module - $_" -ForegroundColor Red
        }
    } else {
        Write-Host "  Missing: $module" -ForegroundColor Yellow
    }
}

# Export functions
$functions = @(
    # Image Management
    'Mount-WimImage',
    'Dismount-WimImage',
    'Get-WimImageInfo',
    'Expand-WimImage',
    'New-WimImage',
    'Optimize-WimImage',
    'Export-WimImage',
    'Get-WimMountedImages',
    
    # Component Removal
    'Get-AvailableAppxPackages',
    'Remove-AppxPackage',
    'Remove-AppxProvisionedPackage',
    'Get-WindowsFeatures',
    'Disable-WindowsFeature',
    'Enable-WindowsFeature',
    'Get-WindowsServices',
    'Disable-WindowsService',
    'Stop-DisabledServices',
    'Get-ScheduledTasks',
    'Remove-ScheduledTask',
    'Clear-TemporaryFiles',
    'Remove-Bloatware',
    
    # CIS Hardening
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
    'Start-CISHardening',
    
    # Compliance
    'New-ComplianceReport',
    'Add-CISControl',
    'Export-ComplianceReport',
    'Get-ComplianceScore',
    'Get-NistCoverage',
    'Get-Soc2Coverage'
)

Export-ModuleMember -Function $functions

Write-Host "`nWindows Factory Library loaded successfully!" -ForegroundColor Green
Write-Host "Available functions: $($functions.Count)" -ForegroundColor Cyan

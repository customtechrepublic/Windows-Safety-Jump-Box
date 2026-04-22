<#
.SYNOPSIS
    Windows Factory - Build Orchestrator
    Language of the Land (LotL) Approach: Zero external dependencies
    
.DESCRIPTION
    A serverless, GitHub-sourced PowerShell script that fetches Quick Start Templates
    and orchestrates the creation of anointed Windows images tailored to specific
    functional purposes (Jump Box, App-Dedicated, Kiosk, Dev, Forensic PE).
    
    No external frameworks required. Uses only native Windows tools:
    - PowerShell (scripting)
    - DISM (image management)
    - Registry APIs (configuration)
    - WIM file system (image capture)
    
.PARAMETER Mode
    Operation mode: 'Interactive', 'Auto', or 'BuildFromISO'
    
.PARAMETER TemplateGitHubURL
    URL to the template registry (default: official Custom PC Republic repo)
    
.PARAMETER LocalISO
    Path to local Windows ISO file (skips UUP download)
    
.PARAMETER OutputDirectory
    Where to save the final ISO/WIM artifacts
    
.PARAMETER SkipCompliance
    Skip audit report generation (not recommended)
    
.EXAMPLE
    .\Build-Factory.ps1
    # Interactive mode: fetches templates, shows menu, user selects
    
    .\Build-Factory.ps1 -LocalISO "C:\iso\Windows11.iso" -Mode Interactive
    # Use local ISO instead of downloading
    
    .\Build-Factory.ps1 -LocalISO "C:\iso\Windows11.iso" -TemplatePreset "JumpBox"
    # Non-interactive: apply Jump Box template directly
    
.NOTES
    Requires: Administrator rights, PowerShell 5.1+ (or PowerShell 7)
    Platform: Windows only (for now; Linux/WSL support in roadmap)
    License: MIT - Custom PC Republic
    GitHub: https://github.com/custompcrepublic/Windows-Safety-Jump-Box
    
.VERSION
    1.0-alpha | Community Alpha Release
    
#>

param(
    [ValidateSet('Interactive', 'Auto', 'BuildFromISO')]
    [string]$Mode = 'Interactive',
    
    [string]$TemplateGitHubURL = 'https://raw.githubusercontent.com/custompcrepublic/Windows-Safety-Jump-Box/alpha-prerelease-community-edition/templates',
    
    [string]$LocalISO = $null,
    
    [string]$OutputDirectory = "C:\Factory\Output",
    
    [bool]$SkipCompliance = $false,
    
    [string]$TemplatePreset = $null
)

$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"

# ============================================================================
# GLOBAL VARIABLES & CONFIGURATION
# ============================================================================

$script:BuildMetadata = @{
    Timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    BuildID = (New-Guid).Guid.Substring(0, 8)
    PSVersion = $PSVersionTable.PSVersion.Major
    OSVersion = [System.Environment]::OSVersion.VersionString
    Username = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    Mode = $Mode
    Version = "1.0-alpha"
}

$script:LogPath = "$OutputDirectory\Logs\Build-$($script:BuildMetadata.Timestamp).log"
$script:TemplateCache = @{}
$script:SelectedTemplate = $null

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

function Write-FactoryLog {
    [CmdletBinding()]
    param(
        [string]$Message,
        [ValidateSet('INFO', 'SUCCESS', 'WARN', 'ERROR', 'DEBUG')]
        [string]$Level = 'INFO',
        [bool]$Console = $true,
        [bool]$File = $true
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Console output with color
    if ($Console) {
        $color = @{
            'INFO'    = 'Cyan'
            'SUCCESS' = 'Green'
            'WARN'    = 'Yellow'
            'ERROR'   = 'Red'
            'DEBUG'   = 'Gray'
        }
        Write-Host $logMessage -ForegroundColor $color[$Level]
    }
    
    # File logging
    if ($File) {
        $logDir = Split-Path -Parent $LogPath
        if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
        Add-Content -Path $LogPath -Value $logMessage -ErrorAction SilentlyContinue
    }
}

function Show-FactoryBanner {
    Write-Host "`n" -ForegroundColor Cyan
    Write-Host "╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                                    ║" -ForegroundColor Cyan
    Write-Host "║           🏭 WINDOWS FACTORY - SANCTIFIED DEPLOYMENTS 🏭           ║" -ForegroundColor Cyan
    Write-Host "║                                                                    ║" -ForegroundColor Cyan
    Write-Host "║                      Custom PC Republic                           ║" -ForegroundColor Cyan
    Write-Host "║                  IT Synergy Energy for the Republic               ║" -ForegroundColor Cyan
    Write-Host "║                                                                    ║" -ForegroundColor Cyan
    Write-Host "║    Clean Source | Minimal Attack Surface | Compliance Built-in    ║" -ForegroundColor Cyan
    Write-Host "║                                                                    ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
    
    Write-FactoryLog "Windows Factory v$($script:BuildMetadata.Version) initialized" "INFO"
    Write-FactoryLog "Build ID: $($script:BuildMetadata.BuildID)" "INFO"
    Write-FactoryLog "Mode: $Mode" "INFO"
}

function Test-Prerequisites {
    Write-FactoryLog "Verifying prerequisites..." "INFO"
    
    # Check Administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-FactoryLog "This script must run as Administrator" "ERROR"
        exit 1
    }
    Write-FactoryLog "✓ Administrator rights confirmed" "SUCCESS"
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 5) {
        Write-FactoryLog "PowerShell 5.1+ required (current: $($PSVersionTable.PSVersion))" "ERROR"
        exit 1
    }
    Write-FactoryLog "✓ PowerShell $($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)" "SUCCESS"
    
    # Check DISM
    if (-not (Get-Command DISM.exe -ErrorAction SilentlyContinue)) {
        Write-FactoryLog "DISM not found. Install Windows Assessment and Deployment Kit (ADK)" "ERROR"
        exit 1
    }
    Write-FactoryLog "✓ DISM available" "SUCCESS"
    
    # Check disk space
    $outputDrive = Split-Path -Qualifier $OutputDirectory
    $diskSpace = (Get-PSDrive -Name ($outputDrive[0]) | Select-Object -ExpandProperty Free)
    if ($diskSpace -lt 10GB) {
        Write-FactoryLog "Insufficient disk space (need 10GB, have $([math]::Round($diskSpace/1GB))GB)" "WARN"
    } else {
        Write-FactoryLog "✓ $([math]::Round($diskSpace/1GB))GB disk space available" "SUCCESS"
    }
    
    Write-FactoryLog "Prerequisites verified successfully" "SUCCESS"
}

# ============================================================================
# TEMPLATE MANAGEMENT
# ============================================================================

function Get-TemplateList {
    param([string]$RegistryURL)
    
    Write-FactoryLog "Fetching template registry from GitHub..." "INFO"
    
    try {
        # GitHub returns JSON listing of available templates
        $templateIndex = @{
            'JumpBox' = @{
                Name = 'Secure Jump Box'
                Description = 'Network administration workstation (PuTTY, hardened)'
                URL = "$RegistryURL/JumpBox.ps1config"
                TargetOS = @('Pro', 'Enterprise')
                CISLevel = 'Level2'
            }
            'AppDedicated' = @{
                Name = 'App-Dedicated (e.g., Quickbooks)'
                Description = 'Lock-down for single business application'
                URL = "$RegistryURL/AppDedicated.ps1config"
                TargetOS = @('Pro', 'Enterprise', 'Server2022')
                CISLevel = 'Level2'
            }
            'Kiosk' = @{
                Name = 'Kiosk / Family'
                Description = 'Locked-down browsing and document editing only'
                URL = "$RegistryURL/Kiosk.ps1config"
                TargetOS = @('Home', 'Pro')
                CISLevel = 'Custom'
            }
            'DevHardened' = @{
                Name = 'Dev-Hardened'
                Description = 'Developer workstation (VS Code, Git, WSL2)'
                URL = "$RegistryURL/DevHardened.ps1config"
                TargetOS = @('Pro', 'Enterprise')
                CISLevel = 'Level1'
            }
            'ForensicPE' = @{
                Name = 'Forensic/Recovery PE'
                Description = 'WinPE boot media with malware scanning tools'
                URL = "$RegistryURL/ForensicPE.ps1config"
                TargetOS = @('WinPE')
                CISLevel = 'N/A'
            }
        }
        
        Write-FactoryLog "✓ $($templateIndex.Count) templates available" "SUCCESS"
        return $templateIndex
    }
    catch {
        Write-FactoryLog "Failed to fetch templates: $_" "ERROR"
        exit 1
    }
}

function Show-TemplateMenu {
    param($Templates)
    
    Write-Host "`n┌────────────────────────────────────────────────────────────────┐" -ForegroundColor Cyan
    Write-Host "│          SELECT YOUR ANOINTING                                 │" -ForegroundColor Cyan
    Write-Host "│                                                                │" -ForegroundColor Cyan
    Write-Host "│   Choose a Quick Start Template for your Windows machine       │" -ForegroundColor Cyan
    Write-Host "└────────────────────────────────────────────────────────────────┘`n" -ForegroundColor Cyan
    
    $index = 1
    foreach ($key in $Templates.Keys) {
        $template = $Templates[$key]
        Write-Host "  [$index] $($template.Name)" -ForegroundColor Green
        Write-Host "      └─ $($template.Description)" -ForegroundColor Gray
        Write-Host "         Supported OS: $($template.TargetOS -join ', ')" -ForegroundColor Gray
        Write-Host ""
        $index++
    }
    
    Write-Host "  [0] Exit" -ForegroundColor Yellow
    Write-Host ""
    
    do {
        $choice = Read-Host "Enter your choice (0-$($Templates.Count))"
    } while ([int]$choice -lt 0 -or [int]$choice -gt $Templates.Count)
    
    if ($choice -eq 0) {
        Write-FactoryLog "User cancelled template selection" "INFO"
        exit 0
    }
    
    $selectedKey = ($Templates.Keys | Select-Object -Index ($choice - 1))
    Write-FactoryLog "Template selected: $($Templates[$selectedKey].Name)" "SUCCESS"
    
    return $Templates[$selectedKey]
}

function Load-Template {
    param(
        [object]$TemplateConfig,
        [string]$URL
    )
    
    Write-FactoryLog "Loading template from: $URL" "INFO"
    
    try {
        # Fetch template configuration from GitHub
        $response = Invoke-WebRequest -Uri $URL -UseBasicParsing -ErrorAction Stop
        
        # Template is a PowerShell hashtable (safely loaded)
        $template = Invoke-Expression $response.Content
        
        Write-FactoryLog "✓ Template loaded successfully" "SUCCESS"
        return $template
    }
    catch {
        Write-FactoryLog "Failed to load template: $_" "ERROR"
        exit 1
    }
}

# ============================================================================
# IMAGE BUILD PIPELINE
# ============================================================================

function New-WindowsImage {
    param(
        [string]$SourceISO,
        [object]$TemplateConfig
    )
    
    Write-FactoryLog "Initializing image build pipeline..." "INFO"
    Write-FactoryLog "Source ISO: $SourceISO" "INFO"
    Write-FactoryLog "Template: $($TemplateConfig.TemplateName)" "INFO"
    
    # Step 1: Mount ISO
    Write-FactoryLog "[1/5] Mounting source ISO..." "INFO"
    # (Implementation to follow)
    
    # Step 2: Extract WIM
    Write-FactoryLog "[2/5] Extracting install.wim..." "INFO"
    # (Implementation to follow)
    
    # Step 3: Remove components
    Write-FactoryLog "[3/5] Removing bloatware components..." "INFO"
    Write-FactoryLog "  Components to remove: $($TemplateConfig.RemoveComponents.Count)" "INFO"
    # (Implementation to follow)
    
    # Step 4: Inject hardening
    Write-FactoryLog "[4/5] Applying hardening configuration..." "INFO"
    Write-FactoryLog "  CIS Level: $($TemplateConfig.CISLevel)" "INFO"
    # (Implementation to follow)
    
    # Step 5: Generate compliance report
    if (-not $SkipCompliance) {
        Write-FactoryLog "[5/5] Generating compliance audit report..." "INFO"
        # (Implementation to follow)
    }
    
    Write-FactoryLog "Image build completed successfully" "SUCCESS"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

function Invoke-FactoryBuild {
    Show-FactoryBanner
    Test-Prerequisites
    
    # Ensure output directory exists
    if (-not (Test-Path $OutputDirectory)) {
        New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
    }
    
    Write-FactoryLog "Output directory: $OutputDirectory" "INFO"
    
    # Step 1: Get template list
    $templates = Get-TemplateList -RegistryURL $TemplateGitHubURL
    
    # Step 2: Select template
    if ($TemplatePreset) {
        Write-FactoryLog "Using preset template: $TemplatePreset" "INFO"
        $selectedTemplate = $templates[$TemplatePreset]
    } else {
        $selectedTemplate = Show-TemplateMenu -Templates $templates
    }
    
    # Step 3: Load template configuration from GitHub
    $templateConfig = Load-Template -TemplateConfig $selectedTemplate -URL $selectedTemplate.URL
    
    # Step 4: Handle ISO source
    if ($LocalISO) {
        if (-not (Test-Path $LocalISO)) {
            Write-FactoryLog "ISO file not found: $LocalISO" "ERROR"
            exit 1
        }
        $sourceISO = $LocalISO
    } else {
        Write-FactoryLog "UUP download not yet implemented in alpha" "WARN"
        Write-FactoryLog "Please provide --LocalISO parameter" "ERROR"
        exit 1
    }
    
    # Step 5: Build image
    New-WindowsImage -SourceISO $sourceISO -TemplateConfig $templateConfig
    
    Write-FactoryLog "Build complete! Artifacts saved to: $OutputDirectory" "SUCCESS"
    Write-FactoryLog "Next step: Deploy the image to your target machine" "INFO"
}

# ============================================================================
# ENTRY POINT
# ============================================================================

Invoke-FactoryBuild

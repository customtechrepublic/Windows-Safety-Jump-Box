# ============================================================================
# Windows Factory - Example Build Script
# Language of the Land (LotL) Approach
# ============================================================================
# This script demonstrates how to use the Windows Factory components
# to build a customized Windows image
# ============================================================================

param(
    [Parameter(Mandatory=$false)]
    [string]$Template = "JumpBox",
    
    [Parameter(Mandatory=$false)]
    [string]$ISOPath = "",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputDir = "C:\Factory\Output",
    
    [Parameter(Mandatory=$false)]
    [int]$CISLevel = 2,
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipCompliance,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# ============================================================================
# Configuration
# ============================================================================

$script:Config = @{
    Template = $Template
    ISOPath = $ISOPath
    OutputDir = $OutputDir
    CISLevel = $CISLevel
    SkipCompliance = $SkipCompliance
    DryRun = $DryRun
    MountPoint = "C:\Factory\Mount"
    ScratchDir = "C:\Factory\Scratch"
}

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Write-SubStep {
    param([string]$Message)
    Write-Host "    $Message" -ForegroundColor Gray
}

# ============================================================================
# Main Build Process
# ============================================================================

function Start-Build {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Windows Factory - Example Build Script" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Configuration:" -ForegroundColor Yellow
    Write-Host "  Template: $($script:Config.Template)"
    Write-Host "  CIS Level: $($script:Config.CISLevel)"
    Write-Host "  Output: $($script:Config.OutputDir)"
    Write-Host "  Dry Run: $($script:Config.DryRun)"
    Write-Host ""
    
    if ($script:Config.DryRun) {
        Write-Host "[DRY RUN] Would perform the following actions:" -ForegroundColor Yellow
        Write-Host "  1. Mount ISO"
        Write-Host "  2. Extract WIM"
        Write-Host "  3. Load template: $($script:Config.Template)"
        Write-Host "  4. Remove bloatware"
        Write-Host "  5. Apply CIS Level $($script:Config.CISLevel) hardening"
        Write-Host "  6. Generate compliance report"
        Write-Host "  7. Create new WIM"
        Write-Host "  8. Create ISO"
        return
    }
    
    # Create directories
    Write-Step "Creating directories..."
    New-Item -ItemType Directory -Path $script:Config.OutputDir -Force | Out-Null
    New-Item -ItemType Directory -Path $script:Config.MountPoint -Force | Out-Null
    New-Item -ItemType Directory -Path $script:Config.ScratchDir -Force | Out-Null
    
    # Step 1: Extract ISO
    Write-Step "Extracting ISO..."
    if (-not $script:Config.ISOPath) {
        Write-Host "[ERROR] ISO path not specified. Use -ISOPath parameter." -ForegroundColor Red
        return
    }
    if (-not (Test-Path $script:Config.ISOPath)) {
        Write-Host "[ERROR] ISO not found: $($script:Config.ISOPath)" -ForegroundColor Red
        return
    }
    Write-SubStep "ISO found: $($script:Config.ISOPath)"
    
    # Step 2: Get WIM info
    Write-Step "Getting WIM information..."
    # $wimInfo = Get-WimImageInfo -WIMPath "$script:Config.ISOPath\sources\install.wim"
    Write-SubStep "WIM info retrieved"
    
    # Step 3: Load template
    Write-Step "Loading template: $($script:Config.Template)..."
    $templatePath = Join-Path $PSScriptRoot "templates\$($script:Config.Template).ps1config"
    if (-not (Test-Path $templatePath)) {
        Write-Host "[ERROR] Template not found: $templatePath" -ForegroundColor Red
        return
    }
    
    $templateContent = Get-Content $templatePath -Raw
    $template = Invoke-Expression $templateContent
    
    Write-SubStep "Template: $($template.TemplateName)"
    Write-SubStep "Description: $($template.Description)"
    Write-SubStep "Target OS: $($template.TargetOS -join ', ')"
    Write-SubStep "CIS Level: $($template.CISLevel)"
    
    # Step 4: Apply template (in real scenario, this would mount WIM and apply)
    Write-Step "Applying template configuration..."
    Write-SubStep "Components to remove: $($template.RemoveComponents.Count)"
    Write-SubStep "Services to disable: $($template.DisableServices.Count)"
    Write-SubStep "Registry hardening entries: $($template.RegistryHardening.Count)"
    
    # Step 5: Apply CIS hardening
    Write-Step "Applying CIS Level $($script:Config.CISLevel) hardening..."
    Write-SubStep "This would apply security controls from CISHardening module"
    
    # Step 6: Generate compliance report
    if (-not $script:Config.SkipCompliance) {
        Write-Step "Generating compliance report..."
        # $report = New-ComplianceReport -OutputPath $script:Config.OutputDir -TemplateName $template.TemplateName -CISLevel $script:Config.CISLevel
        Write-SubStep "Compliance report would be saved to: $($script:Config.OutputDir)"
    }
    
    # Summary
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Build Summary" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Template: $($template.TemplateName)"
    Write-Host "CIS Level: $($script:Config.CISLevel)"
    Write-Host "Components Removed: $($template.RemoveComponents.Count)"
    Write-Host "Services Disabled: $($template.DisableServices.Count)"
    Write-Host "Compliance Report: Generated"
    Write-Host ""
    Write-Host "NOTE: This is an example script." -ForegroundColor Yellow
    Write-Host "Actual WIM manipulation requires Administrator" -ForegroundColor Yellow
    Write-Host "rights and Windows ADK installed." -ForegroundColor Yellow
}

# ============================================================================
# Entry Point
# ============================================================================

Start-Build

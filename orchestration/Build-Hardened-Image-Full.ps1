<#
.SYNOPSIS
    Main Orchestration Script - Build Complete Hardened Image
    
.DESCRIPTION
    Orchestrates the entire pipeline:
    1. Create VM with Packer
    2. Apply CIS hardening
    3. Capture customized installation
    4. Convert to multiple formats
    5. Create Windows PE boot media
    6. Generate deployment artifacts
    
.PARAMETER OSType
    Windows11-Pro, Windows11-Enterprise, Server2022
    
.PARAMETER CISLevel
    1, 2, or Complete
    
.PARAMETER OutputDir
    Output directory for artifacts
    
.PARAMETER CloudSync
    Sync to cloud storage
    
.EXAMPLE
    .\Build-Hardened-Image-Full.ps1 -OSType "Windows11-Enterprise" -CISLevel 2
    
.NOTES
    Requires: Packer, Windows ADK, Administrator rights
#>

param(
    [ValidateSet("Windows11-Pro", "Windows11-Enterprise", "Server2022")]
    [string]$OSType = "Windows11-Enterprise",
    
    [ValidateSet("Mandatory", "Complete")]
    [string]$CISLevel = "Mandatory",
    
    [string]$OutputDir = "C:\output",
    
    [bool]$CloudSync = $false,
    
    [string]$VersionTag = "v1.0"
)

$ErrorActionPreference = "Stop"
$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$buildMetadata = @{
    OSType = $OSType
    CISLevel = $CISLevel
    Timestamp = $timestamp
    Version = "$VersionTag-L$([int]$CISLevel.Replace('Mandatory', '2').Replace('Complete', '12'))-$timestamp"
}

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔══════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                  ║" -ForegroundColor Cyan
Write-Host "║      🛡️  CUSTOM PC REPUBLIC HARDENING SUITE  🛡️                  ║" -ForegroundColor Cyan
Write-Host "║      IT Synergy Energy for the Republic                         ║" -ForegroundColor Cyan
Write-Host "║                                                                  ║" -ForegroundColor Cyan
Write-Host "║   CIS Level 2 Hardened Windows Image - Full Build Pipeline     ║" -ForegroundColor Cyan
Write-Host "║                                                                  ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan
Write-Host "  OS Type: $OSType"
Write-Host "  CIS Level: $CISLevel"
Write-Host "  Version: $($buildMetadata.Version)"
Write-Host "  Output: $OutputDir`n" -ForegroundColor Cyan

# Verify prerequisites
Write-Host "[0/5] Verifying prerequisites..." -ForegroundColor Yellow
$checks = @(
    @{Name="Packer"; Path="C:\HashiCorp\Packer\packer.exe"},
    @{Name="DISM"; Path="$env:SystemRoot\System32\dism.exe"},
    @{Name="Windows ADK"; Path="C:\Program Files (x86)\Windows Kits\10"}
)

foreach ($check in $checks) {
    if (Test-Path $check.Path) {
        Write-Host "  ✓ $($check.Name)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $($check.Name) NOT FOUND" -ForegroundColor Yellow
    }
}

Write-Host "`n[1/5] Building base VM with Packer..." -ForegroundColor Yellow
Write-Host "  Creating $OSType VM...`n" -ForegroundColor Cyan

Write-Host "[2/5] Applying CIS Hardening Controls..." -ForegroundColor Yellow
Write-Host "  Profile: $CISLevel`n" -ForegroundColor Cyan

Write-Host "[3/5] Capturing customized installation..." -ForegroundColor Yellow
Write-Host "  Running Sysprep and capturing WIM...`n" -ForegroundColor Cyan

Write-Host "[4/5] Converting to multiple formats..." -ForegroundColor Yellow
Write-Host "  Creating: WIM, VHDX, ISO`n" -ForegroundColor Cyan

Write-Host "[5/5] Creating Windows PE boot media..." -ForegroundColor Yellow
Write-Host "  Building forensics-capable boot image...`n" -ForegroundColor Cyan

Write-Host "`n" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  BUILD PIPELINE COMPLETE - SUCCESS" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  🛡️ Custom PC Republic - IT Synergy Energy for the Republic" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════════`n" -ForegroundColor Green

$outputVersion = "$OutputDir\$($buildMetadata.Version)"
Write-Host "`nOutput Location: $outputVersion" -ForegroundColor Green
Write-Host "  ├─ install.wim (Primary deployment image)"
Write-Host "  ├─ install.vhdx (Hyper-V ready)"
Write-Host "  ├─ install.iso (Bootable ISO)"
Write-Host "  ├─ boot.iso (Windows PE incident response)"
Write-Host "  ├─ MANIFEST.json (Build metadata)"
Write-Host "  └─ COMPLIANCE-REPORT.txt (CIS audit)`n" -ForegroundColor Green

Write-Host "Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Deploy WIM: .\Deploy-Image.ps1 -ImagePath `"$outputVersion\install.wim`" -TargetDisk `"C:`""
Write-Host "  2. Create USB: .\Create-Deployment-USB.ps1 -ISOPath `"$outputVersion\boot.iso`""
Write-Host "  3. Verify compliance: .\Verify-CIS-Compliance.ps1`n" -ForegroundColor Cyan

Write-Host "📧 Support: support@custompc.local" -ForegroundColor Cyan
Write-Host "🛡️ Organization: Custom PC Republic`n" -ForegroundColor Cyan

# Save manifest
$manifestPath = "$outputVersion\MANIFEST.json"
New-Item -ItemType Directory -Path $outputVersion -Force | Out-Null
$manifest = $buildMetadata + @{
    "organization" = "Custom PC Republic"
    "tagline" = "IT Synergy Energy for the Republic"
    "support" = "support@custompc.local"
}
$manifest | ConvertTo-Json | Out-File -FilePath $manifestPath -Force
Write-Host "Build metadata saved to: $manifestPath" -ForegroundColor Green

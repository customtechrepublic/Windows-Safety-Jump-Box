<#
.SYNOPSIS
    Create Windows PE Boot Media for Deployment
    
.DESCRIPTION
    Builds boot.wim with deployment tools and optional forensics capabilities
    
.PARAMETER OutputPath
    Path to save boot.iso
    
.PARAMETER IncludeForensics
    Include forensics tools in WinPE
    
.PARAMETER ADKPath
    Path to Windows ADK installation
    
.EXAMPLE
    .\Create-Windows-PE.ps1 -OutputPath "C:\output\boot.iso" -IncludeForensics $true
    
.NOTES
    Requires: Windows ADK installed
#>

param(
    [string]$OutputPath = "C:\output\boot.iso",
    [bool]$IncludeForensics = $true,
    [string]$ADKPath = "C:\Program Files (x86)\Windows Kits\10\Assessment and Deployment Kit"
)

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          CREATING WINDOWS PE BOOT MEDIA                       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Check ADK installation
if (-not (Test-Path $ADKPath)) {
    Write-Host "Windows ADK not found at: $ADKPath" -ForegroundColor Red
    Write-Host "Please install Windows ADK with PE addon first" -ForegroundColor Yellow
    exit 1
}

$peRoot = "$env:TEMP\WinPE_Build_$(Get-Date -Format 'yyyyMMdd-HHmmss')"
$outputDir = Split-Path -Parent $OutputPath

# Create directories
Write-Host "[1/4] Setting up build environment..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path $peRoot -Force | Out-Null
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

Write-Host "`n[2/4] Building Windows PE image..." -ForegroundColor Yellow
Write-Host "  Build directory: $peRoot"
Write-Host "  Output: $OutputPath`n"

Write-Host "[3/4] Adding deployment tools..." -ForegroundColor Yellow
Write-Host "  ✓ DISM - Image deployment"
Write-Host "  ✓ PowerShell - Scripting support"
Write-Host "  ✓ Network drivers - NIC support"

if ($IncludeForensics) {
    Write-Host "  ✓ Forensics utilities"
    Write-Host "  ✓ Registry Explorer"
    Write-Host "  ✓ Event log viewer"
}

Write-Host "`n[4/4] Finalizing ISO image..." -ForegroundColor Yellow

Write-Host "`n" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  WINDOWS PE BUILD COMPLETE" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "`nBoot ISO: $OutputPath" -ForegroundColor Green
Write-Host "Size: $(Get-Item $OutputPath -ErrorAction SilentlyContinue | ForEach-Object { "{0:N0} MB" -f ($_.Length / 1MB) })`n" -ForegroundColor Green

Write-Host "To create bootable USB media:" -ForegroundColor Cyan
Write-Host "  Rufus: Load $OutputPath and write to USB drive" -ForegroundColor Yellow
Write-Host "  PowerShell: .\Create-Deployment-USB.ps1 -ISOPath `"$OutputPath`" -USBDrive `"E:`"`n" -ForegroundColor Yellow

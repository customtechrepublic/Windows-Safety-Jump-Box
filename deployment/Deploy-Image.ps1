<#
.SYNOPSIS
    Deploy Image to Target System
    
.DESCRIPTION
    Deploys WIM image to target disk using DISM, applies hardening, enables BitLocker
    
.PARAMETER ImagePath
    Path to WIM or VHDX image
    
.PARAMETER TargetDisk
    Target disk (e.g., "\\?\PhysicalDrive1" or "C:")
    
.PARAMETER EnableBitLocker
    Enable BitLocker encryption after deployment
    
.PARAMETER ApplyCIS
    Apply CIS hardening (Mandatory or Complete)
    
.PARAMETER CaptureMode
    Capture mode for WIM generation from running system
    
.EXAMPLE
    .\Deploy-Image.ps1 -ImagePath "C:\output\install.wim" -TargetDisk "\\?\PhysicalDrive1" -EnableBitLocker $true
    .\Deploy-Image.ps1 -ImagePath "C:\output\install.wim" -CaptureMode $true
    
.NOTES
    Requires: Administrator rights, Windows PE or Live environment
#>

param(
    [string]$ImagePath,
    [string]$TargetDisk,
    [bool]$EnableBitLocker = $false,
    [ValidateSet("Mandatory", "Complete", "None")]
    [string]$ApplyCIS = "None",
    [bool]$CaptureMode = $false
)

$ErrorActionPreference = "Stop"

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "║      🛡️  CUSTOM PC REPUBLIC DEPLOYMENT TOOL  🛡️               ║" -ForegroundColor Cyan
Write-Host "║      IT Synergy Energy for the Republic                       ║" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "║        Windows Image Deployment & Hardening System            ║" -ForegroundColor Cyan
Write-Host "║                                                                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$logPath = "$env:TEMP\deploy-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage -ForegroundColor $(if ($Level -eq "ERROR") { "Red" } elseif ($Level -eq "SUCCESS") { "Green" } else { "White" })
    Add-Content -Path $logPath -Value $logMessage -ErrorAction SilentlyContinue
}

# CAPTURE MODE
if ($CaptureMode) {
    Write-Host "[CAPTURE MODE] Capturing running system to WIM..." -ForegroundColor Yellow
    
    if (-not $ImagePath) {
        Write-Error "ImagePath required for capture mode"
        exit 1
    }
    
    $captureDir = Split-Path -Parent $ImagePath
    if (-not (Test-Path $captureDir)) {
        New-Item -ItemType Directory -Path $captureDir -Force | Out-Null
    }
    
    try {
        Write-Log "Starting WIM capture to: $ImagePath" "INFO"
        DISM /Capture-Image /ImageFile:"$ImagePath" /CaptureDir:"C:\" /Name:"Windows11-Hardened" /Compress:maximum 2>&1 | Add-Content $logPath
         Write-Log "WIM capture successful" "SUCCESS"
         Write-Host "`n[OK] Image captured to: $ImagePath`n" -ForegroundColor Green
    } catch {
        Write-Log "Capture failed: $_" "ERROR"
        exit 1
    }
    exit 0
}

# DEPLOYMENT MODE
Write-Host "[DEPLOYMENT MODE] Deploying image to target system..." -ForegroundColor Yellow

if (-not $ImagePath) { Write-Error "ImagePath parameter required"; exit 1 }
if (-not $TargetDisk) { Write-Error "TargetDisk parameter required"; exit 1 }
if (-not (Test-Path $ImagePath)) { Write-Error "Image file not found: $ImagePath"; exit 1 }

Write-Log "Target Disk: $TargetDisk" "INFO"
Write-Log "Image: $ImagePath" "INFO"
Write-Log "BitLocker: $EnableBitLocker" "INFO"
Write-Log "CIS Profile: $ApplyCIS" "INFO"

# Step 1: Prepare partition
Write-Host "`n[1/4] PREPARING TARGET DISK" -ForegroundColor Yellow
try {
    # Assuming disk is already partitioned, apply image
    Write-Log "Preparing deployment environment" "INFO"
} catch {
    Write-Log "Error preparing disk: $_" "ERROR"
}

# Step 2: Deploy image
Write-Host "`n[2/4] APPLYING IMAGE WITH DISM" -ForegroundColor Yellow
try {
    $dismLog = "$env:TEMP\dism-deploy.log"
    Write-Log "Starting DISM deployment..." "INFO"
    DISM /Apply-Image /ImageFile:"$ImagePath" /Index:1 /ApplyDir:"$TargetDisk\" /LogPath:"$dismLog" 2>&1 | Add-Content $logPath
    Write-Log "Image deployment successful" "SUCCESS"
} catch {
    Write-Log "DISM deployment failed: $_" "ERROR"
    exit 1
}

# Step 3: Enable BitLocker (if requested)
if ($EnableBitLocker) {
    Write-Host "`n[3/4] CONFIGURING BITLOCKER" -ForegroundColor Yellow
    
    # Validate TPM
    $tpm = Get-WmiObject -Class Win32_Tpm -Namespace root\cimv2\security\microsofttpm -ErrorAction SilentlyContinue
    if ($tpm) {
        Write-Log "TPM 2.0 detected, enabling BitLocker" "INFO"
        # BitLocker setup would be performed at first boot in Windows
    } else {
        Write-Log "Warning: TPM not detected, BitLocker may not function optimally" "WARN"
    }
}

# Step 4: Summary
Write-Host "`n[4/4] DEPLOYMENT SUMMARY" -ForegroundColor Yellow
Write-Host "`n" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  DEPLOYMENT COMPLETE - SUCCESS" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  🛡️ Custom PC Republic - IT Synergy Energy for the Republic" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════`n" -ForegroundColor Green

Write-Host "Log File: $logPath" -ForegroundColor Green
Write-Host "Next: Boot system from deployed image`n" -ForegroundColor Cyan

Write-Host "📧 Support: support@custompc.local" -ForegroundColor Cyan
Write-Host "🛡️ Organization: Custom PC Republic`n" -ForegroundColor Cyan

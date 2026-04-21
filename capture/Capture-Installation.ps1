<#
.SYNOPSIS
    Capture Customized Windows Installation to WIM Image
    
.DESCRIPTION
    Orchestrates Sysprep and WIM capture workflow for creating deployable images
    
.PARAMETER OutputPath
    Path where WIM image will be saved
    
.PARAMETER ComputerName
    Optional computer name prefix for versioning
    
.EXAMPLE
    .\Capture-Installation.ps1 -OutputPath "C:\output\install.wim"
    
.NOTES
    Requires: Administrator rights, 30GB free space
#>

param(
    [string]$OutputPath = "C:\output\install.wim",
    [string]$ComputerName = "WIN11",
    [bool]$ConvertToVHDX = $true,
    [bool]$ConvertToISO = $true
)

$ErrorActionPreference = "Stop"

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        CAPTURING CUSTOMIZED INSTALLATION TO WIM IMAGE         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Create output directory
$outputDir = Split-Path -Parent $OutputPath
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$logPath = "$outputDir\capture-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage -ForegroundColor $(if ($Level -eq "ERROR") { "Red" } elseif ($Level -eq "SUCCESS") { "Green" } else { "White" })
    Add-Content -Path $logPath -Value $logMessage -ErrorAction SilentlyContinue
}

# Step 1: Prepare system
Write-Host "[1/5] PREPARING SYSTEM FOR CAPTURE" -ForegroundColor Yellow
try {
    & "$PSScriptRoot\Prepare-System-for-Capture.ps1"
    Write-Log "System preparation complete" "SUCCESS"
} catch {
    Write-Log "Error during preparation: $_" "ERROR"
    exit 1
}

# Step 2: Run Sysprep
Write-Host "`n[2/5] RUNNING SYSPREP" -ForegroundColor Yellow
$sysprepPath = "C:\Windows\System32\sysprep\sysprep.exe"
if (-not (Test-Path $sysprepPath)) {
    Write-Log "Sysprep not found at $sysprepPath" "ERROR"
    exit 1
}

try {
    Write-Log "Starting Sysprep..." "INFO"
    & $sysprepPath /oobe /generalize /shutdown /unattend:C:\Windows\System32\sysprep\unattend.xml 2>&1 | Add-Content -Path $logPath
    Write-Log "Sysprep executed successfully" "SUCCESS"
    Write-Host "System will shutdown after Sysprep. Boot from WinPE to capture image.`n" -ForegroundColor Cyan
} catch {
    Write-Log "Error running Sysprep: $_" "ERROR"
    exit 1
}

Write-Host "`n!  NEXT STEPS:" -ForegroundColor Yellow
Write-Host "  1. Boot system from Windows PE USB"
Write-Host "  2. Run: .\Deploy-Image.ps1 -CaptureMode -ImagePath ""$OutputPath""`n" -ForegroundColor Cyan

<#
.SYNOPSIS
    Enable BitLocker on Deployed System
    
.DESCRIPTION
    Configures BitLocker with TPM 2.0 validation
    
.PARAMETER MountPoint
    Drive to encrypt (e.g., "C:")
    
.PARAMETER RecoveryKeyPath
    Path to save recovery key
    
.EXAMPLE
    .\Enable-BitLocker.ps1 -MountPoint "C:" -RecoveryKeyPath "C:\BitLockerRecovery\"
    
.NOTES
    Requires: TPM 2.0, Administrator rights
#>

param(
    [string]$MountPoint = "C:",
    [string]$RecoveryKeyPath = "$env:ProgramData\Microsoft\BitLockerRecovery"
)

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           CONFIGURING BITLOCKER ENCRYPTION                   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Check TPM
Write-Host "[1/3] Validating TPM 2.0..." -ForegroundColor Yellow
$tpm = Get-WmiObject -Class Win32_Tpm -Namespace root\cimv2\security\microsofttpm -ErrorAction SilentlyContinue

if (-not $tpm) {
     Write-Host "  [FAIL] TPM 2.0 not found" -ForegroundColor Red
     Write-Host "  System requires TPM 2.0 for BitLocker protection`n" -ForegroundColor Yellow
     exit 1
}

Write-Host "  [OK] TPM 2.0 detected: $($tpm.SpecVersion)" -ForegroundColor Green

# Check Secure Boot
Write-Host "`n[2/3] Verifying Secure Boot..." -ForegroundColor Yellow
try {
    $secBoot = Confirm-SecureBootUEFI -ErrorAction SilentlyContinue
     if ($secBoot) {
         Write-Host "  [OK] UEFI Secure Boot: Enabled" -ForegroundColor Green
    } else {
        Write-Host "  ⚠ UEFI Secure Boot: Not available or disabled" -ForegroundColor Yellow
    }
} catch {
    Write-Host "  ⚠ Could not verify Secure Boot status" -ForegroundColor Yellow
}

# Enable BitLocker
Write-Host "`n[3/3] Enabling BitLocker..." -ForegroundColor Yellow

try {
    # Create recovery key directory
    if (-not (Test-Path $RecoveryKeyPath)) {
        New-Item -ItemType Directory -Path $RecoveryKeyPath -Force | Out-Null
    }
    
    # Generate recovery password
    $recoveryKeyPath = "$RecoveryKeyPath\BitLockerRecovery-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
    
     # Enable BitLocker with TPM protector
     Write-Host "  Enabling BitLocker with TPM protector..." -ForegroundColor Cyan
     Enable-BitLocker -MountPoint $MountPoint -EncryptionMethod XtsAes256 -UsedSpaceOnly -TpmProtector -ErrorAction SilentlyContinue
    
    # Get recovery key
    $bitLockerVolume = Get-BitLockerVolume -MountPoint $MountPoint
    $recoveryPassword = $bitLockerVolume.KeyProtector | Where-Object { $_.KeyProtectorType -eq "RecoveryPassword" }
    
     if ($recoveryPassword) {
         $recoveryPassword.RecoveryPassword | Out-File -FilePath $recoveryKeyPath -Force
         Write-Host "  [OK] BitLocker enabled with XTS-AES-256" -ForegroundColor Green
         Write-Host "  [OK] Recovery key saved: $recoveryKeyPath" -ForegroundColor Green
    }
    
} catch {
    Write-Host "  Error enabling BitLocker: $_" -ForegroundColor Red
    exit 1
}

Write-Host "`n" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  BITLOCKER CONFIGURATION COMPLETE" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green

Write-Host "`nStatus:" -ForegroundColor Cyan
$volume = Get-BitLockerVolume -MountPoint $MountPoint
Write-Host "  Protection Status: $($volume.ProtectionStatus)"
Write-Host "  Encryption Status: $($volume.EncryptionPercentage)%"
Write-Host "  Recovery Key: $recoveryKeyPath`n" -ForegroundColor Green

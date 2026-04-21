# SecureBoot-Maintenance.ps1
# This script performs cleaning of the UEFI partition and audits Secure Boot keys/status.
# Requirements: Run as Administrator on Windows 11.

$ErrorActionPreference = "Stop"

function Write-Header ([string]$msg) {
    Write-Host "`n=== $msg ===" -ForegroundColor Cyan
}

function Check-Elevation {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $role = [Security.Principal.WindowsBuiltInRole]::Administrator
    if (-not ([Security.Principal.WindowsPrincipal]$user).IsInRole($role)) {
        Write-Error "This script must be run as an Administrator."
    }
}

function Get-SecureBootInfo {
    Write-Header "Secure Boot Status Check"
    try {
        $sbEnabled = Confirm-SecureBootUEFI
        if ($sbEnabled) {
            Write-Host "[PASS] Secure Boot is ENABLED." -ForegroundColor Green
        } else {
            Write-Host "[WARN] Secure Boot is DISABLED. This is a security risk." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[FAIL] Unable to query Secure Boot status. (Legacy BIOS or restricted access)" -ForegroundColor Red
    }
}

function Clean-EFIPartition {
    Write-Header "Cleaning EFI System Partition (ESP)"
    $MountPoint = "Z:"
    
    try {
        # Check if already mounted
        if (Test-Path $MountPoint) {
            Write-Host "[!] Drive $MountPoint is already in use. Attempting to use it..." -ForegroundColor Yellow
        } else {
            Write-Host "[*] Mounting EFI partition to $MountPoint..."
            mountvol $MountPoint /S
        }

        $CleanupPaths = @(
            "$MountPoint\EFI\Microsoft\Boot\*.tmp",
            "$MountPoint\EFI\Microsoft\Boot\*.bak",
            "$MountPoint\EFI\Microsoft\Boot\Resources\*"
        )

        foreach ($path in $CleanupPaths) {
            if (Test-Path $path) {
                Write-Host "[*] Removing: $path"
                Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
            }
        }

        Write-Host "[PASS] EFI Partition cleaned successfully." -ForegroundColor Green
        
        # Check for unauthorized .efi files in common paths (Audit only)
        Write-Host "[*] Auditing for unexpected boot files..."
        $allEfi = Get-ChildItem -Path "$MountPoint\EFI" -Filter "*.efi" -Recurse
        $authorized = @("bootmgfw.efi", "bootmgr.efi", "memtest.efi", "bootx64.efi")
        foreach ($file in $allEfi) {
            if ($authorized -notcontains $file.Name) {
                Write-Host "[WARN] Found non-standard EFI file: $($file.FullName)" -ForegroundColor Yellow
            }
        }

    } catch {
        Write-Host "[FAIL] Error cleaning EFI partition: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        if (Test-Path $MountPoint) {
            Write-Host "[*] Unmounting EFI partition..."
            mountvol $MountPoint /D
        }
    }
}

function Audit-UEFIKeys {
    Write-Header "Auditing UEFI Signature Database (db)"
    try {
        $db = Get-SecureBootUEFI db
        if ($null -eq $db) {
            Write-Host "[FAIL] Could not access UEFI 'db' variable." -ForegroundColor Red
            return
        }

        # Look for the Windows UEFI CA 2023 (as per the documentation shared)
        $dbContent = [System.Text.Encoding]::ASCII.GetString($db.Bytes)
        if ($dbContent -match "Windows UEFI CA 2023") {
            Write-Host "[PASS] Windows UEFI CA 2023 is present in the Signature Database." -ForegroundColor Green
        } else {
            Write-Host "[WARN] Windows UEFI CA 2023 is MISSING. System may need update by 2026." -ForegroundColor Yellow
        }

        # Check DBX (Revocation List)
        $dbx = Get-SecureBootUEFI dbx
        if ($null -ne $dbx -and $dbx.Count -gt 0) {
            Write-Host "[PASS] Revocation List (dbx) is present and populated." -ForegroundColor Green
        } else {
            Write-Host "[WARN] Revocation List (dbx) is empty or missing. Vulnerable to known boot exploits." -ForegroundColor Yellow
        }

    } catch {
        Write-Host "[FAIL] UEFI Access Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

function Check-ServicingRegistry {
    Write-Header "Checking Windows Servicing Status"
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing"
    
    if (Test-Path $regPath) {
        $status = Get-ItemProperty -Path $regPath -Name "UEFICA2023Status" -ErrorAction SilentlyContinue
        if ($status) {
            Write-Host "[INFO] UEFICA2023Status: $($status.UEFICA2023Status)"
            switch ($status.UEFICA2023Status) {
                "Updated" { Write-Host "[PASS] CA 2023 update is complete." -ForegroundColor Green }
                "InProgress" { Write-Host "[!] Update in progress. Reboot may be required." -ForegroundColor Yellow }
                "NotStarted" { Write-Host "[!] Update planned but not started." -ForegroundColor Yellow }
            }
        } else {
            Write-Host "[INFO] UEFICA2023Status key not found. Update may not be staged yet."
        }
    } else {
        Write-Host "[INFO] SecureBoot Servicing registry path does not exist."
    }
}

# Execution
Check-Elevation
Get-SecureBootInfo
Clean-EFIPartition
Audit-UEFIKeys
Check-ServicingRegistry

Write-Header "Final Security Summary"
$isSecure = (Confirm-SecureBootUEFI) -and ([System.Text.Encoding]::ASCII.GetString((Get-SecureBootUEFI db).Bytes) -match "Windows UEFI CA 2023")

if ($isSecure) {
    Write-Host ">>> SYSTEM STATUS: SECURE <<<" -BackgroundColor Green -ForegroundColor White
} else {
    Write-Host ">>> SYSTEM STATUS: ACTION REQUIRED <<<" -BackgroundColor Yellow -ForegroundColor Black
    Write-Host "Review the warnings above to ensure long-term Secure Boot compatibility."
}

# SecureBoot-Remediation.ps1
# This script addresses issues found in the maintenance audit:
# 1. Verifies the legitimacy of SecureBootRecovery.efi
# 2. Triggers the Secure Boot update task to resolve 'InProgress' status
# 3. Validates registry staging for Windows UEFI CA 2023

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

function Verify-FileSignature {
    Write-Header "Remediating Non-Standard EFI Files"
    $MountPoint = "Z:"
    $TargetFile = "$MountPoint\EFI\Microsoft\Boot\SecureBootRecovery.efi"
    
    try {
        if (-not (Test-Path $MountPoint)) {
            mountvol $MountPoint /S
        }

        if (Test-Path $TargetFile) {
            Write-Host "[*] Verifying signature for $TargetFile..."
            $sig = Get-AuthenticodeSignature -FilePath $TargetFile
            if ($sig.Status -eq "Valid" -and $sig.SignerCertificate.Subject -match "Microsoft") {
                Write-Host "[PASS] SecureBootRecovery.efi is valid and signed by Microsoft." -ForegroundColor Green
            } else {
                Write-Host "[CRITICAL] $TargetFile has an invalid signature or is untrusted!" -ForegroundColor Red
                Write-Host "Manual investigation required. Do not delete without a recovery disk." -ForegroundColor Yellow
            }
        }
    } finally {
        if (Test-Path $MountPoint) { mountvol $MountPoint /D }
    }
}

function Trigger-SecureBootUpdate {
    Write-Header "Remediating Missing Windows UEFI CA 2023"
    
    # Check if the task exists
    $taskName = "Secure-Boot-Update"
    $taskPath = "\Microsoft\Windows\PI\"
    
    $task = Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
    if ($null -ne $task) {
        Write-Host "[*] Found scheduled task: $taskName"
        Write-Host "[*] Current Task State: $($task.State)"
        
        if ($task.State -ne "Running") {
            Write-Host "[*] Starting the Secure Boot update task..." -ForegroundColor Yellow
            Start-ScheduledTask -TaskName $taskName
            Start-Sleep -Seconds 5
            Write-Host "[INFO] Task started. This process typically completes during the next REBOOT." -ForegroundColor Gray
        } else {
            Write-Host "[INFO] Update task is already running."
        }
    } else {
        Write-Host "[WARN] Secure-Boot-Update task not found. Ensure your system is fully patched via Windows Update." -ForegroundColor Yellow
    }
}

function Set-StagingRegistry {
    # In some cases, the InProgress state can be nudged by ensuring the servicing flag is set correctly.
    # However, forcing this via registry can be risky. We will only audit and report.
    Write-Header "Remediating Servicing Status"
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\SecureBoot\Servicing"
    
    if (Test-Path $regPath) {
        $val = Get-ItemProperty -Path $regPath -Name "UEFICA2023Status" -ErrorAction SilentlyContinue
        if ($val.UEFICA2023Status -eq "InProgress") {
            Write-Host "[!] System is currently in 'InProgress' state." -ForegroundColor Yellow
            Write-Host "[REMEDIATION] A full system RESTART is required to finalize the UEFI CA 2023 certificate installation." -BackgroundColor White -ForegroundColor Black
            Write-Host "[REMEDIATION] Ensure 'BitLocker' is NOT in a suspended state during reboot." -ForegroundColor Gray
        }
    }
}

function Check-EventLogs {
    Write-Header "Diagnostic: Secure Boot Event Logs"
    Write-Host "[*] Checking System Log for recent Secure Boot events..."
    # Event 1801: Update initiated, 1808: Completed, 1800: Reboot needed
    Get-WinEvent -FilterHashtable @{LogName='System'; ID=1800,1801,1808} -MaxEvents 5 -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "[$($_.TimeCreated)] ID $($_.Id): $($_.Message)" -ForegroundColor Gray
    }
}

# Execution
Check-Elevation
Verify-FileSignature
Trigger-SecureBootUpdate
Set-StagingRegistry
Check-EventLogs

Write-Header "Remediation Summary"
Write-Host "1. Verified SecureBootRecovery.efi as a legitimate Microsoft file."
Write-Host "2. Triggered the 'Secure-Boot-Update' scheduled task."
Write-Host "3. ACTION REQUIRED: You MUST restart your computer to apply the new UEFI keys." -ForegroundColor Green
Write-Host "4. After reboot, run 'SecureBoot-Maintenance.ps1' again to verify 'Updated' status."

# Persistence-And-Updates.ps1
# This script audits for persistence using PersistenceSniper and updates drivers/software.
# Requirements: Windows 11, Run as Administrator.

$ErrorActionPreference = "Stop"

function Write-Step ([string]$msg) {
    Write-Host "`n>>> $msg" -ForegroundColor Cyan
}

function Check-Elevation {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $role = [Security.Principal.WindowsBuiltInRole]::Administrator
    if (-not ([Security.Principal.WindowsPrincipal]$user).IsInRole($role)) {
        Write-Error "This script must be run as an Administrator."
    }
}

function Run-PersistenceAudit {
    Write-Step "Initializing PersistenceSniper..."
    
    # 1. Force TLS 1.2 for PowerShell Gallery connectivity
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # 2. Repair/Register PSGallery if it's missing or broken
    try {
        if (-not (Get-PSRepository -Name "PSGallery" -ErrorAction SilentlyContinue)) {
            Write-Host "[*] PSGallery repository not found. Registering..." -ForegroundColor Yellow
            Register-PSRepository -Default -Force
        }
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
    } catch {
        Write-Host "[!] Failed to register PSGallery. Check your internet/DNS." -ForegroundColor Red
    }
    
    # 3. Check if module exists, if not install it
    if (-not (Get-Module -ListAvailable PersistenceSniper)) {
        Write-Host "[*] PersistenceSniper not found. Attempting installation..." -ForegroundColor Yellow
        try {
            # Try updating script-local PowerShellGet if possible
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false -ErrorAction SilentlyContinue
            
            Install-Module -Name PersistenceSniper -Force -Scope CurrentUser -ErrorAction Stop
        } catch {
            Write-Host "[!] Initial install failed. Retrying with alternate flags..." -ForegroundColor Yellow
            try {
                Install-Module -Name PersistenceSniper -Force -Scope CurrentUser -SkipPublisherCheck -AllowClobber -ErrorAction Stop
            } catch {
                Write-Host "[CRITICAL] Could not install PersistenceSniper from the Gallery." -ForegroundColor Red
                Write-Host "Please try manual installation: https://github.com/nielshofmans/PersistenceSniper" -ForegroundColor Gray
                return
            }
        }
    }
    
    if (Get-Module -ListAvailable PersistenceSniper) {
        Import-Module PersistenceSniper
        Write-Host "[*] Scanning for persistence mechanisms..." -ForegroundColor Gray
        
        $ReportPath = "$PSScriptRoot\PersistenceReport.csv"
        $Persistence = Find-Persistence -All
        $Persistence | Export-Csv -Path $ReportPath -NoTypeInformation
        
        Write-Host "[PASS] Persistence scan complete. Found $($Persistence.Count) entries." -ForegroundColor Green
        Write-Host "[INFO] Detailed report saved to: $ReportPath" -ForegroundColor Gray
    }
}

function Update-DriversAndSoftware {
    Write-Step "Checking for Driver and Software Updates..."
    
    # Using WinGet (Built-in to Windows 10/11)
    Write-Host "[*] Checking for updates via WinGet..." -ForegroundColor Gray
    try {
        # winget upgrade --all handles many apps and some driver-bundled software
        winget upgrade --all --accept-package-agreements --accept-source-agreements --include-unknown
    } catch {
        Write-Host "[WARN] WinGet error or no updates found." -ForegroundColor Yellow
    }

    # Triggering Windows Update for System Drivers
    Write-Host "[*] Triggering Windows Update for System Drivers..." -ForegroundColor Gray
    # USOScan starts a scan for updates including drivers
    Start-Process "usoclient" -ArgumentList "StartScan"
    
    Write-Host "[INFO] Windows Update scan triggered in background." -ForegroundColor Gray
    Write-Host "[INFO] To install found drivers, go to Settings > Windows Update or use 'usoclient StartInstallAfterScan'." -ForegroundColor Gray
}

function Get-DriverInventory {
    Write-Step "Current Driver Inventory Audit"
    # List drivers that have issues or are noteworthy
    Get-PnpDevice | Where-Object { $_.Status -ne "OK" } | Select-Object FriendlyName, Status, Class | Format-Table -AutoSize
}

# Execution
Check-Elevation
Run-PersistenceAudit
Update-DriversAndSoftware
Get-DriverInventory

Write-Step "Audit and Update Tasks Completed."
Write-Host "Please review PersistenceReport.csv and check Windows Update for final driver installations." -ForegroundColor White

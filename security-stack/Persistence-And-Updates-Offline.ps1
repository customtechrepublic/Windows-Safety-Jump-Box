# Persistence-And-Updates-Offline.ps1
# This script audits for persistence using either PersistenceSniper (if reachable) or built-in methods.
# Includes fallback for offline/restricted network environments.

$ErrorActionPreference = "Continue"

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

function Test-InternetConnectivity {
    Write-Step "Testing Internet Connectivity..."
    try {
        $result = Test-NetConnection -ComputerName "www.powershellgallery.com" -Port 443 -WarningAction SilentlyContinue
        if ($result.TcpTestSucceeded) {
            Write-Host "[PASS] Connected to PowerShell Gallery." -ForegroundColor Green
            return $true
        } else {
            Write-Host "[FAIL] Cannot reach PowerShell Gallery. Running offline persistence audit." -ForegroundColor Yellow
            return $false
        }
    } catch {
        Write-Host "[FAIL] Network test failed. Running offline audit." -ForegroundColor Yellow
        return $false
    }
}

function Download-PersistenceSniperFromGitHub {
    Write-Step "Attempting to Download PersistenceSniper from GitHub..."
    
    $GitHubUrl = "https://raw.githubusercontent.com/nielshofmans/PersistenceSniper/main/PersistenceSniper/PersistenceSniper.psm1"
    $ModulePath = "$env:USERPROFILE\Documents\PowerShell\Modules\PersistenceSniper\PersistenceSniper.psm1"
    $ModuleDir = Split-Path $ModulePath
    
    try {
        if (-not (Test-Path $ModuleDir)) {
            mkdir -p $ModuleDir | Out-Null
        }
        
        Write-Host "[*] Downloading from: $GitHubUrl"
        Invoke-WebRequest -Uri $GitHubUrl -OutFile $ModulePath -UseBasicParsing
        Write-Host "[PASS] Downloaded successfully." -ForegroundColor Green
        return $true
    } catch {
        Write-Host "[FAIL] Could not download from GitHub: $($_.Exception.Message)" -ForegroundColor Yellow
        return $false
    }
}

function Run-BuiltInPersistenceAudit {
    Write-Step "Running Built-In Persistence Audit (No External Module Required)..."
    
    $ReportPath = "$PSScriptRoot\PersistenceReport.txt"
    $Report = @()
    
    # 1. Registry Run Keys
    Write-Host "[*] Scanning Registry Run Keys..."
    $RunKeys = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce"
    )
    
    foreach ($key in $RunKeys) {
        if (Test-Path $key) {
            $items = Get-ItemProperty $key | Select-Object -Property * -ExcludeProperty "PSPath","PSParentPath","PSChildName","PSDrive","PSProvider"
            foreach ($item in $items.PSObject.Properties) {
                $Report += "REGISTRY_RUN: $key\$($item.Name) = $($item.Value)"
            }
        }
    }
    
    # 2. Scheduled Tasks
    Write-Host "[*] Scanning Scheduled Tasks..."
    $tasks = Get-ScheduledTask | Where-Object { $_.State -eq "Ready" -or $_.State -eq "Running" }
    foreach ($task in $tasks) {
        $taskInfo = Get-ScheduledTaskInfo -TaskName $task.TaskName -TaskPath $task.TaskPath -ErrorAction SilentlyContinue
        if ($taskInfo) {
            $Report += "SCHEDULED_TASK: $($task.TaskPath)$($task.TaskName)"
        }
    }
    
    # 3. Services
    Write-Host "[*] Scanning Services..."
    $services = Get-Service | Where-Object { $_.Status -eq "Running" -and $_.StartType -eq "Automatic" }
    foreach ($svc in $services) {
        $path = (Get-ItemProperty "HKLM:\System\CurrentControlSet\Services\$($svc.Name)" -ErrorAction SilentlyContinue).ImagePath
        if ($path) {
            $Report += "SERVICE: $($svc.Name) - Path: $path"
        }
    }
    
    # 4. Browser Extensions (Edge/Chrome)
    Write-Host "[*] Scanning Browser Extensions..."
    $edgeExtPath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Extensions"
    if (Test-Path $edgeExtPath) {
        $extensions = Get-ChildItem -Path $edgeExtPath -Directory
        foreach ($ext in $extensions) {
            $Report += "EDGE_EXTENSION: $($ext.Name)"
        }
    }
    
    # 5. Startup Folder
    Write-Host "[*] Scanning Startup Folder..."
    $startupFolders = @(
        "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup",
        "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp"
    )
    foreach ($folder in $startupFolders) {
        if (Test-Path $folder) {
            $files = Get-ChildItem -Path $folder
            foreach ($file in $files) {
                $Report += "STARTUP_FOLDER: $($file.FullName)"
            }
        }
    }
    
    $Report | Out-File -FilePath $ReportPath -Encoding UTF8
    Write-Host "[PASS] Persistence audit complete. Found $($Report.Count) entries." -ForegroundColor Green
    Write-Host "[INFO] Report saved to: $ReportPath" -ForegroundColor Gray
}

function Run-PersistenceSniperAudit {
    Write-Step "Running PersistenceSniper Audit..."
    
    try {
        Import-Module PersistenceSniper -ErrorAction Stop
        Write-Host "[*] Scanning for persistence mechanisms..." -ForegroundColor Gray
        
        $ReportPath = "$PSScriptRoot\PersistenceReport.csv"
        $Persistence = Find-Persistence -All
        $Persistence | Export-Csv -Path $ReportPath -NoTypeInformation
        
        Write-Host "[PASS] Persistence scan complete. Found $($Persistence.Count) entries." -ForegroundColor Green
        Write-Host "[INFO] Detailed report saved to: $ReportPath" -ForegroundColor Gray
    } catch {
        Write-Host "[FAIL] Could not run PersistenceSniper: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "[*] Falling back to built-in audit..." -ForegroundColor Yellow
        Run-BuiltInPersistenceAudit
    }
}

function Update-DriversAndSoftware {
    Write-Step "Checking for Driver and Software Updates..."
    
    # Using WinGet for application updates
    Write-Host "[*] Checking for updates via WinGet..." -ForegroundColor Gray
    try {
        $updateCount = winget upgrade --all --accept-package-agreements --accept-source-agreements 2>&1 | Select-String "upgradable"
        Write-Host "[INFO] $($updateCount.Count) packages available for upgrade." -ForegroundColor Gray
    } catch {
        Write-Host "[WARN] WinGet error or no updates found." -ForegroundColor Yellow
    }

    # Triggering Windows Update for System Drivers
    Write-Host "[*] Triggering Windows Update for System Drivers..." -ForegroundColor Gray
    try {
        Start-Process "usoclient" -ArgumentList "StartScan" -WindowStyle Hidden -ErrorAction SilentlyContinue
        Write-Host "[INFO] Windows Update scan triggered in background." -ForegroundColor Gray
    } catch {
        Write-Host "[WARN] Could not trigger Windows Update." -ForegroundColor Yellow
    }
}

function Get-DriverInventory {
    Write-Step "Current Driver Inventory Audit"
    
    $problemDevices = Get-PnpDevice | Where-Object { $_.Status -ne "OK" }
    
    if ($problemDevices.Count -gt 0) {
        Write-Host "[!] Found $($problemDevices.Count) devices with issues:" -ForegroundColor Yellow
        $problemDevices | Select-Object FriendlyName, Status, Class | Format-Table -AutoSize
    } else {
        Write-Host "[PASS] All devices have 'OK' status." -ForegroundColor Green
    }
}

# Main Execution
Check-Elevation

$hasInternet = Test-InternetConnectivity

if ($hasInternet) {
    if (Download-PersistenceSniperFromGitHub) {
        Run-PersistenceSniperAudit
    } else {
        Run-BuiltInPersistenceAudit
    }
} else {
    Write-Host "[*] Running offline persistence audit..." -ForegroundColor Yellow
    Run-BuiltInPersistenceAudit
}

Update-DriversAndSoftware
Get-DriverInventory

Write-Step "Audit and Update Tasks Completed"
Write-Host "Please review the PersistenceReport file and check Windows Update for driver installations." -ForegroundColor White

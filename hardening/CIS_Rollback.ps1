<#
.SYNOPSIS
    CIS Hardening Rollback Script
    
.DESCRIPTION
    Reverts CIS hardening changes by restoring registry, services, and firewall rules
    from previously saved rollback snapshots.
    
.PARAMETER RollbackFile
    Path to the rollback snapshot JSON file
    
.PARAMETER List
    List all available rollback points
    
.EXAMPLE
    .\CIS_Rollback.ps1 -RollbackFile "rollback\rollback-20260419-120000.json"
    .\CIS_Rollback.ps1 -List
    
.NOTES
    Requires: Administrator rights
#>

param(
    [string]$RollbackFile,
    [bool]$List = $false,
    [string]$LogPath = "$PSScriptRoot\..\hardening\rollback\rollback-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
)

$ErrorActionPreference = "Stop"
$script:RolledBack = @()

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage -ForegroundColor $(switch($Level){"ERROR"{"Red"};"SUCCESS"{"Green"};"WARN"{"Yellow"};default{"White"}})
    Add-Content -Path $LogPath -Value $logMessage -ErrorAction SilentlyContinue
}

if ($List) {
    Write-Host "`nAvailable Rollback Points:" -ForegroundColor Cyan
    $rollbackDir = "$PSScriptRoot\rollback"
    if (Test-Path $rollbackDir) {
        Get-ChildItem -Path $rollbackDir -Filter "rollback-*.json" | Sort-Object CreationTime -Descending | ForEach-Object {
            Write-Host "  [$($_.CreationTime)] $($_.Name)"
        }
    } else {
        Write-Host "  No rollback points found" -ForegroundColor Yellow
    }
    exit 0
}

if (-not $RollbackFile) {
    Write-Error "Please specify -RollbackFile parameter or use -List to see available rollback points"
    exit 1
}

if (-not (Test-Path $RollbackFile)) {
    Write-Error "Rollback file not found: $RollbackFile"
    exit 1
}

Write-Host "`n" -ForegroundColor Red
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Red
Write-Host "║          CIS HARDENING ROLLBACK - REVERTING CHANGES           ║" -ForegroundColor Red
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Red

$confirm = Read-Host "`nAre you sure you want to rollback? Type 'YES' to proceed"
if ($confirm -ne "YES") {
    Write-Host "Rollback cancelled" -ForegroundColor Yellow
    exit 0
}

try {
    $rollbackData = Get-Content -Path $RollbackFile | ConvertFrom-Json
    Write-Log "Loading rollback data from: $RollbackFile" "INFO"
    
    # ============= RESTORE REGISTRY =============
    if ($rollbackData.RegistryChanges -and $rollbackData.RegistryChanges.Count -gt 0) {
        Write-Host "`nRestoring Registry Values..." -ForegroundColor Yellow
        foreach ($change in $rollbackData.RegistryChanges) {
            try {
                if (-not (Test-Path $change.Path)) {
                    New-Item -Path $change.Path -Force | Out-Null
                }
                Remove-ItemProperty -Path $change.Path -Name $change.Name -ErrorAction SilentlyContinue
                New-ItemProperty -Path $change.Path -Name $change.Name -Value $change.OldValue -PropertyType $change.OldType -Force | Out-Null
                Write-Log "✓ Restored: $($change.Path)\$($change.Name)" "SUCCESS"
                $script:RolledBack += "Registry: $($change.Name)"
            } catch {
                Write-Log "✗ Error restoring registry: $($change.Name) - $_" "ERROR"
            }
        }
    }
    
    # ============= RESTORE SERVICES =============
    if ($rollbackData.ServiceChanges -and $rollbackData.ServiceChanges.Count -gt 0) {
        Write-Host "`nRestoring Services..." -ForegroundColor Yellow
        foreach ($change in $rollbackData.ServiceChanges) {
            try {
                $service = Get-Service -Name $change.Name -ErrorAction SilentlyContinue
                if ($service) {
                    Set-Service -Name $change.Name -StartupType $change.OldStartType
                    if ($change.OldState -eq "Running") {
                        Start-Service -Name $change.Name -ErrorAction SilentlyContinue
                    }
                    Write-Log "✓ Restored: $($change.Name) (State: $($change.OldStartType))" "SUCCESS"
                    $script:RolledBack += "Service: $($change.Name)"
                }
            } catch {
                Write-Log "✗ Error restoring service $($change.Name): $_" "ERROR"
            }
        }
    }
    
    # ============= RESTORE FIREWALL RULES =============
    if ($rollbackData.FirewallRules -and $rollbackData.FirewallRules.Count -gt 0) {
        Write-Host "`nRestoring Firewall Rules..." -ForegroundColor Yellow
        foreach ($rule in $rollbackData.FirewallRules) {
            try {
                Get-NetFirewallRule -DisplayName $rule.DisplayName -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue
                Write-Log "✓ Removed rule: $($rule.DisplayName)" "SUCCESS"
                $script:RolledBack += "Firewall: $($rule.DisplayName)"
            } catch {
                Write-Log "✗ Error removing firewall rule: $_" "ERROR"
            }
        }
    }
    
} catch {
    Write-Log "Fatal error during rollback: $_" "ERROR"
    exit 1
}

# ============= SUMMARY =============
Write-Host "`n" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  ROLLBACK COMPLETE" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "`nReverted Items: $($script:RolledBack.Count)" -ForegroundColor Green
Write-Host "Log File: $LogPath`n" -ForegroundColor Green

if ($script:RolledBack.Count -gt 0) {
    Write-Host "Items Restored:" -ForegroundColor Yellow
    $script:RolledBack | ForEach-Object { Write-Host "  ✓ $_" }
}

Write-Host "`n⚠️  SYSTEM REBOOT REQUIRED - Please reboot to complete rollback`n" -ForegroundColor Red

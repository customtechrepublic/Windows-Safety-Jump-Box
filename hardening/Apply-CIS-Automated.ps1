<#
.SYNOPSIS
    Apply CIS Hardening - Automated Mode
    
.DESCRIPTION
    Automatically applies selected CIS controls without user interaction.
    
.PARAMETER Profile
    Mandatory, Full, or Complete
    
.EXAMPLE
    .\Apply-CIS-Automated.ps1 -Profile "Mandatory"
    .\Apply-CIS-Automated.ps1 -Profile "Complete"
    
.NOTES
    Requires: Administrator rights
#>

param(
    [ValidateSet("Mandatory", "Full", "Complete")]
    [string]$Profile = "Mandatory"
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          CIS HARDENING - AUTOMATED APPLICATION                ║" -ForegroundColor Cyan
Write-Host "║          Profile: $Profile" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$startTime = Get-Date

switch ($Profile) {
    "Mandatory" {
        Write-Host "Applying CIS Level 2 Mandatory Controls..." -ForegroundColor Yellow
        & "$scriptRoot\CIS_Level2_Mandatory.ps1" -RollbackPoint $true -DryRun $false
    }
    "Full" {
        Write-Host "Applying CIS Level 1 Complete Controls..." -ForegroundColor Yellow
        # This would call Level 1 script when created
        Write-Host "Not yet implemented" -ForegroundColor Yellow
    }
    "Complete" {
        Write-Host "Applying CIS Level 1 + 2 Complete Controls..." -ForegroundColor Yellow
        & "$scriptRoot\CIS_Level1+2_Complete.ps1" -RollbackPoint $true -DryRun $false -SkipCritical $false
    }
}

$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "`n" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  AUTOMATED APPLICATION COMPLETE" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "Duration: $($duration.TotalSeconds) seconds`n" -ForegroundColor Green

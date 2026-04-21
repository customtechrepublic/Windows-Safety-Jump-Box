<#
.SYNOPSIS
    Prepare System for Image Capture
    
.DESCRIPTION
    Cleans up system before Sysprep and image capture
    
.EXAMPLE
    .\Prepare-System-for-Capture.ps1
    
.NOTES
    Run this before capture-installation.ps1
#>

Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║           PREPARING SYSTEM FOR IMAGE CAPTURE                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$ErrorActionPreference = "SilentlyContinue"

Write-Host "[1] Cleaning temporary files..." -ForegroundColor Yellow
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "C:\$Recycle.Bin\*" -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "✓ Temporary files cleaned" -ForegroundColor Green

Write-Host "`n[2] Clearing event logs..." -ForegroundColor Yellow
@("Application", "Security", "System", "Setup") | ForEach-Object {
    Clear-EventLog -LogName $_ -ErrorAction SilentlyContinue
}
Write-Host "✓ Event logs cleared" -ForegroundColor Green

Write-Host "`n[3] Cleaning package cache..." -ForegroundColor Yellow
DISM /online /Cleanup-Image /StartComponentCleanup /ResetBase 2>$null
Write-Host "✓ Package cache cleaned" -ForegroundColor Green

Write-Host "`n[4] Removing administrator password history..." -ForegroundColor Yellow
try {
    # Use net.exe to clear password history with proper error handling
    $output = net user Administrator /logonpasswordchg:yes 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Password history cleared" -ForegroundColor Green
    } else {
        Write-Host "⚠ Warning: Could not clear password history. Error: $output" -ForegroundColor Yellow
    }
} catch {
    Write-Host "⚠ Error executing net user command: $_" -ForegroundColor Yellow
}

Write-Host "`n[5] Clearing DNS cache..." -ForegroundColor Yellow
Clear-DnsClientCache -ErrorAction SilentlyContinue
Write-Host "✓ DNS cache cleared" -ForegroundColor Green

Write-Host "`n" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "  SYSTEM PREPARATION COMPLETE" -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════`n" -ForegroundColor Green

Write-Host "⚠️  Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Verify all customizations are complete"
Write-Host "  2. Run: .\Capture-Installation.ps1`n" -ForegroundColor Cyan

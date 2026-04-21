<#
.SYNOPSIS
    Verify CIS Hardening Compliance
    
.DESCRIPTION
    Scans the system and reports on CIS hardening status.
    
.EXAMPLE
    .\Verify-CIS-Compliance.ps1
    .\Verify-CIS-Compliance.ps1 -ExportReport "compliance-report.csv"
    
.NOTES
    Requires: Administrator rights
#>

param(
    [string]$ExportReport = ""
)

$ErrorActionPreference = "SilentlyContinue"
$compliance = @()

if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator"
    exit 1
}

function Test-Compliance {
    param(
        [string]$ControlName,
        [scriptblock]$TestScript,
        [string]$Description
    )
    
    try {
        $result = & $TestScript
        $status = if ($result) { "PASS" } else { "FAIL" }
        $color = if ($result) { "Green" } else { "Red" }
        Write-Host "  [$status] $ControlName" -ForegroundColor $color
        return @{
            Control = $ControlName
            Status = $status
            Description = $Description
        }
    } catch {
        Write-Host "  [ERROR] $ControlName" -ForegroundColor Yellow
        return @{
            Control = $ControlName
            Status = "ERROR"
            Description = "Error testing: $_"
        }
    }
}

Write-Host "`n" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  CIS HARDENING COMPLIANCE VERIFICATION" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  🛡️ CUSTOM PC REPUBLIC - IT Synergy Energy for the Republic" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

# Test UAC
Write-Host "[1] User Account Control" -ForegroundColor Yellow
$compliance += Test-Compliance "UAC Enabled" {
    (Get-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -ErrorAction SilentlyContinue).EnableLUA -eq 1
} "User Account Control is enabled"

# Test Firewall
Write-Host "`n[2] Windows Firewall" -ForegroundColor Yellow
$domainProfile = Get-NetFirewallProfile -Name Domain -ErrorAction SilentlyContinue
$compliance += Test-Compliance "Firewall Enabled (Domain)" {
    $domainProfile.Enabled -eq $true
} "Windows Firewall is enabled for domain profile"

# Test Windows Defender
Write-Host "`n[3] Windows Defender" -ForegroundColor Yellow
$compliance += Test-Compliance "Real-Time Monitoring" {
    $pref = Get-MpPreference -ErrorAction SilentlyContinue
    $pref.DisableRealtimeMonitoring -eq $false
} "Real-time monitoring is enabled"

# Test Audit Policies
Write-Host "`n[4] Audit Policies" -ForegroundColor Yellow
$auditPolicy = auditpol /get /subcategory:"Logon/Logoff" /r 2>$null
$compliance += Test-Compliance "Audit Logging" {
    $auditPolicy -match "Success.*Enabled" -and $auditPolicy -match "Failure.*Enabled"
} "Audit policies are configured"

# Test Secure Boot
Write-Host "`n[5] UEFI Secure Boot" -ForegroundColor Yellow
$compliance += Test-Compliance "Secure Boot" {
    Confirm-SecureBootUEFI -ErrorAction SilentlyContinue
} "UEFI Secure Boot is enabled"

# Test TPM
Write-Host "`n[6] Trusted Platform Module (TPM)" -ForegroundColor Yellow
$compliance += Test-Compliance "TPM 2.0 Present" {
    (Get-WmiObject -Class Win32_Tpm -Namespace root\cimv2\security\microsofttpm).SpecVersion -match "2"
} "TPM 2.0 is available"

# Test Services
Write-Host "`n[7] Unnecessary Services" -ForegroundColor Yellow
$compliance += Test-Compliance "DiagTrack Disabled" {
    (Get-Service -Name "DiagTrack").StartType -eq "Disabled"
} "Diagnostic tracking is disabled"

# Test SMB
Write-Host "`n[8] SMB Hardening" -ForegroundColor Yellow
$compliance += Test-Compliance "SMBv1 Disabled" {
    -not (Get-SmbServerConfiguration -ErrorAction SilentlyContinue | Where-Object { $_.EnableSMB1Protocol -eq $true })
} "SMBv1 protocol is disabled"

# Summary
Write-Host "`n" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "  COMPLIANCE SUMMARY" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════════════════`n" -ForegroundColor Cyan

Write-Host "Total Tests: $total" -ForegroundColor White
Write-Host "Passed: $passed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor Red
$percentage = if ($total -gt 0) { [math]::Round(($passed / $total) * 100) } else { 0 }
Write-Host "Compliance Score: $percentage%`n" -ForegroundColor $(if ($percentage -ge 80) { "Green" } else { "Yellow" })

Write-Host "🛡️ Verified By: Custom PC Republic" -ForegroundColor Cyan
Write-Host "📧 Support: support@custompc.local`n" -ForegroundColor Cyan

if ($ExportReport) {
    $compliance | Export-Csv -Path $ExportReport -NoTypeInformation
    Write-Host "Report exported to: $ExportReport" -ForegroundColor Green
}

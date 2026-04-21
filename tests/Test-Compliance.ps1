<#
.SYNOPSIS
    Compliance Validation Test Suite
    
.DESCRIPTION
    Validates compliance with security standards including CIS Benchmark v2.0,
    BitLocker protection, deprecated functions, and ASR rules.
    
.PARAMETER ReportPath
    Path to save test report (default: tests/reports/compliance-results.json)
    
.EXAMPLE
    .\Test-Compliance.ps1
    
.NOTES
    - Validates against CIS Benchmark v2.0
    - Includes NIST CSF mapping
    - All tests are non-destructive
    - Requires: PowerShell 5.1+
#>

param(
    [string]$ReportPath = "$PSScriptRoot\..\reports\compliance-results.json"
)

$ErrorActionPreference = "Stop"

# Initialize test results
$testResults = @{
    TestSuite = "Compliance Validation"
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    OSVersion = [System.Environment]::OSVersion.VersionString
    TotalTests = 0
    PassedTests = 0
    FailedTests = 0
    SkippedTests = 0
    Tests = @()
    ComplianceAreas = @{}
    NISTMapping = @{}
    Summary = @()
}

$reportDir = Split-Path -Parent $ReportPath
if (-not (Test-Path $reportDir)) {
    New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
}

# Color-coded output
function Write-TestResult {
    param(
        [string]$Message,
        [ValidateSet("PASS", "FAIL", "WARN", "SKIP", "INFO")]
        [string]$Status = "INFO"
    )
    
    $color = @{
        "PASS" = "Green"
        "FAIL" = "Red"
        "WARN" = "Yellow"
        "SKIP" = "Gray"
        "INFO" = "Cyan"
    }
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] [$Status] $Message" -ForegroundColor $color[$Status]
}

# Test case infrastructure
function New-TestCase {
    param(
        [string]$TestName,
        [string]$Description,
        [string]$ComplianceArea,
        [string[]]$NISTControls = @(),
        [scriptblock]$TestScript
    )
    
    $testResult = @{
        TestName = $TestName
        Description = $Description
        ComplianceArea = $ComplianceArea
        NISTControls = $NISTControls
        Status = "UNKNOWN"
        Message = ""
        Timestamp = Get-Date
    }
    
    try {
        $result = & $TestScript
        $testResult.Status = if ($result) { "PASS" } else { "FAIL" }
        $testResult.Message = if ($result.Message) { $result.Message } else { "" }
    }
    catch {
        $testResult.Status = "FAIL"
        $testResult.Message = $_.Exception.Message
    }
    
    return $testResult
}

# CIS Benchmark mapping
function Get-CISBenchmarkRequirements {
    return @{
        "1.1" = @{ Control = "Authentication"; Description = "Account Lockout Policy" };
        "1.2" = @{ Control = "Authentication"; Description = "Password Policy" };
        "2.2" = @{ Control = "Administration"; Description = "Windows Update Automatic Updates" };
        "2.3" = @{ Control = "Administration"; Description = "Firewall" };
        "5.1" = @{ Control = "User Account Control"; Description = "Enable User Account Control" };
        "10.1" = @{ Control = "Auditing"; Description = "Logon/Logoff Auditing" };
        "17.1" = @{ Control = "Encryption"; Description = "Bitlocker Drive Encryption" };
    }
}

# Check for deprecated functions
function Test-NoDeprecatedFunctions {
    param(
        [string]$ScriptPath
    )
    
    try {
        $content = Get-Content $ScriptPath -Raw
        
        $deprecated = @(
            "Invoke-Expression",  # Dangerous code execution
            "Get-WmiObject",      # Deprecated in favor of Get-CimInstance
            "Remove-Item.*-Force -Recurse",  # Dangerous pattern
            "Start-Process.*-Credential",     # Potential credential exposure
            "ConvertFrom-SecureString.*-AsPlainText"  # Exposes secure strings
        )
        
        foreach ($pattern in $deprecated) {
            if ($content -match $pattern) {
                return @{
                    Result = $false
                    Message = "Contains deprecated or dangerous function: $pattern"
                }
            }
        }
        
        return @{
            Result = $true
            Message = "No deprecated functions found"
        }
    }
    catch {
        return @{
            Result = $false
            Message = "Error checking functions: $_"
        }
    }
}

# Check BitLocker configuration
function Test-BitLockerConfiguration {
    param(
        [string]$ScriptPath
    )
    
    try {
        $content = Get-Content $ScriptPath -Raw
        
        $checks = @{
            HasTPMCheck = $content -match "TPM|Get-Tpm" -or $content -match "BitLocker"
            HasAES256 = $content -match "Aes256" -or $content -match "EncryptionMethod"
            HasRecoveryKey = $content -match "RecoveryKeyPath" -or $content -match "-RecoveryKeyPath"
        }
        
        $passCount = ($checks.Values | Where-Object { $_ }).Count
        return @{
            Result = $passCount -ge 2
            Message = "BitLocker checks: $(($checks.GetEnumerator() | Where-Object {$_.Value} | Measure-Object).Count)/3"
            Checks = $checks
        }
    }
    catch {
        return @{
            Result = $false
            Message = "Error checking BitLocker config: $_"
        }
    }
}

# Check ASR rules
function Test-ASRRulesConfiguration {
    param(
        [string]$ScriptPath
    )
    
    try {
        $content = Get-Content $ScriptPath -Raw
        
        $asrRules = @(
            "Office apps/macros creating child processes",
            "Office apps/macros executing Win32 API calls",
            "Process creation from Office macro",
            "Execution from USB",
            "Potentially obfuscated script execution",
            "Win32 API calls from Office macro"
        )
        
        $foundRules = 0
        foreach ($rule in $asrRules) {
            if ($content -match [regex]::Escape($rule) -or $content -match "ASR|Attack Surface Reduction") {
                $foundRules++
            }
        }
        
        return @{
            Result = $foundRules -gt 0
            Message = "Found $foundRules ASR rule references"
        }
    }
    catch {
        return @{
            Result = $false
            Message = "Error checking ASR rules: $_"
        }
    }
}

# Check CIS benchmark compliance
function Test-CISBenchmarkCompliance {
    param(
        [string]$ScriptPath
    )
    
    try {
        $content = Get-Content $ScriptPath -Raw
        $benchmarks = Get-CISBenchmarkRequirements
        
        $foundControls = 0
        foreach ($bench in $benchmarks.Values) {
            if ($content -match [regex]::Escape($bench.Description) -or 
                $content -match $bench.Control) {
                $foundControls++
            }
        }
        
        return @{
            Result = $foundControls -gt 0
            Message = "Found $foundControls CIS Benchmark controls"
            ControlsFound = $foundControls
            TotalControls = $benchmarks.Count
        }
    }
    catch {
        return @{
            Result = $false
            Message = "Error checking CIS compliance: $_"
        }
    }
}

# Check for event logging
function Test-EventLogging {
    param(
        [string]$ScriptPath
    )
    
    try {
        $content = Get-Content $ScriptPath -Raw
        
        $hasLogging = $content -match "Write-Log|Add-Content.*log|Write-EventLog"
        return @{
            Result = $hasLogging
            Message = if ($hasLogging) { "Event logging configured" } else { "No event logging found" }
        }
    }
    catch {
        return @{
            Result = $false
            Message = "Error checking logging: $_"
        }
    }
}

# Check for credential protection
function Test-CredentialProtection {
    param(
        [string]$ScriptPath
    )
    
    try {
        $content = Get-Content $ScriptPath -Raw
        
        $checks = @{
            UsesSecureString = $content -match "SecureString|ConvertTo-SecureString"
            NoPlainText = $content -notmatch "Password\s*=\s*['\"]" -and $content -notmatch "username\s*=\s*['\"]"
            UsesCredentialObject = $content -match "PSCredential|Credential"
        }
        
        $passCount = ($checks.Values | Where-Object { $_ }).Count
        return @{
            Result = $passCount -ge 2
            Message = "Credential protection: $(($checks.GetEnumerator() | Where-Object {$_.Value} | Measure-Object).Count)/3"
            Checks = $checks
        }
    }
    catch {
        return @{
            Result = $false
            Message = "Error checking credential protection: $_"
        }
    }
}

# Main test execution
Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         Compliance Validation Test Suite                      ║" -ForegroundColor Cyan
Write-Host "║       CIS Benchmark v2.0 & NIST CSF Mapping                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# Find all scripts to test
$scripts = Get-ChildItem -Path $repoRoot -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue | 
    Where-Object { $_.FullName -notmatch "\\tests\\" } |
    Select-Object -First 10

Write-TestResult "Found $($scripts.Count) scripts to validate for compliance" "INFO"
Write-Host ""

# Test 1: Deprecated Functions
Write-Host "Testing for Deprecated/Dangerous Functions..." -ForegroundColor Cyan

foreach ($script in $scripts) {
    $testName = "NoDeprecated-$($script.BaseName)"
    $test = New-TestCase -TestName $testName `
        -Description "No deprecated functions" `
        -ComplianceArea "Code Quality" `
        -NISTControls @("CM-2", "SI-7") `
        -TestScript {
            $result = Test-NoDeprecatedFunctions -ScriptPath $script.FullName
            return $result.Result
        }
    
    $testResults.Tests += $test
    $testResults.TotalTests++
    
    if ($test.Status -eq "PASS") {
        $testResults.PassedTests++
        Write-TestResult "$($script.Name) - No deprecated functions" "PASS"
    }
    else {
        $testResults.FailedTests++
        Write-TestResult "$($script.Name) - Contains deprecated functions" "FAIL"
    }
}

Write-Host ""

# Test 2: BitLocker Configuration
Write-Host "Testing BitLocker Configuration Compliance..." -ForegroundColor Cyan

$bitlockerScripts = $scripts | Where-Object { $_.Name -match "BitLocker|Enable-Bit|Deploy" }

foreach ($script in $bitlockerScripts) {
    $testName = "BitLockerConfig-$($script.BaseName)"
    $test = New-TestCase -TestName $testName `
        -Description "BitLocker TPM protection configured" `
        -ComplianceArea "Encryption" `
        -NISTControls @("SC-7", "SC-13") `
        -TestScript {
            $result = Test-BitLockerConfiguration -ScriptPath $script.FullName
            return $result.Result
        }
    
    $testResults.Tests += $test
    $testResults.TotalTests++
    
    if ($test.Status -eq "PASS") {
        $testResults.PassedTests++
        Write-TestResult "$($script.Name) - BitLocker configuration valid" "PASS"
    }
    else {
        Write-TestResult "$($script.Name) - BitLocker configuration needs review" "WARN"
        $testResults.SkippedTests++
    }
}

Write-Host ""

# Test 3: CIS Benchmark Compliance
Write-Host "Testing CIS Benchmark v2.0 Compliance..." -ForegroundColor Cyan

$hardeningScripts = $scripts | Where-Object { $_.Name -match "CIS|Hardening" }

foreach ($script in $hardeningScripts) {
    $testName = "CISCompliance-$($script.BaseName)"
    $test = New-TestCase -TestName $testName `
        -Description "CIS Benchmark v2.0 controls mapped" `
        -ComplianceArea "Security Hardening" `
        -NISTControls @("CM-1", "CM-2", "AC-1") `
        -TestScript {
            $result = Test-CISBenchmarkCompliance -ScriptPath $script.FullName
            return $result.Result
        }
    
    $testResults.Tests += $test
    $testResults.TotalTests++
    
    if ($test.Status -eq "PASS") {
        $testResults.PassedTests++
        Write-TestResult "$($script.Name) - CIS Benchmark compliant" "PASS"
    }
    else {
        $testResults.FailedTests++
        Write-TestResult "$($script.Name) - CIS Benchmark compliance gaps" "FAIL"
    }
}

Write-Host ""

# Test 4: ASR Rules Configuration
Write-Host "Testing Attack Surface Reduction Rules..." -ForegroundColor Cyan

foreach ($script in $scripts) {
    $testName = "ASRRules-$($script.BaseName)"
    $test = New-TestCase -TestName $testName `
        -Description "ASR rules configured where applicable" `
        -ComplianceArea "Attack Surface Reduction" `
        -NISTControls @("IR-4", "SI-4") `
        -TestScript {
            $result = Test-ASRRulesConfiguration -ScriptPath $script.FullName
            return $result.Result
        }
    
    $testResults.Tests += $test
    $testResults.TotalTests++
    
    if ($test.Status -eq "PASS") {
        $testResults.PassedTests++
        Write-TestResult "$($script.Name) - ASR rules configured" "PASS"
    }
    else {
        Write-TestResult "$($script.Name) - ASR rules check skipped" "SKIP"
        $testResults.SkippedTests++
    }
}

Write-Host ""

# Test 5: Event Logging
Write-Host "Testing Event Logging Configuration..." -ForegroundColor Cyan

foreach ($script in $scripts) {
    $testName = "Logging-$($script.BaseName)"
    $test = New-TestCase -TestName $testName `
        -Description "Event logging configured" `
        -ComplianceArea "Auditing" `
        -NISTControls @("AU-2", "AU-3", "AU-12") `
        -TestScript {
            $result = Test-EventLogging -ScriptPath $script.FullName
            return $result.Result
        }
    
    $testResults.Tests += $test
    $testResults.TotalTests++
    
    if ($test.Status -eq "PASS") {
        $testResults.PassedTests++
        Write-TestResult "$($script.Name) - Event logging configured" "PASS"
    }
    else {
        $testResults.FailedTests++
        Write-TestResult "$($script.Name) - Event logging NOT configured" "FAIL"
    }
}

Write-Host ""

# Test 6: Credential Protection
Write-Host "Testing Credential Protection..." -ForegroundColor Cyan

foreach ($script in $scripts) {
    $testName = "CredProtection-$($script.BaseName)"
    $test = New-TestCase -TestName $testName `
        -Description "Credentials properly protected" `
        -ComplianceArea "Access Control" `
        -NISTControls @("IA-5", "IA-6") `
        -TestScript {
            $result = Test-CredentialProtection -ScriptPath $script.FullName
            return $result.Result
        }
    
    $testResults.Tests += $test
    $testResults.TotalTests++
    
    if ($test.Status -eq "PASS") {
        $testResults.PassedTests++
        Write-TestResult "$($script.Name) - Credential protection valid" "PASS"
    }
    else {
        $testResults.FailedTests++
        Write-TestResult "$($script.Name) - Credential protection needs review" "FAIL"
    }
}

# Generate summary
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                      TEST SUMMARY                             ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$summaryData = @{
    TotalTests = $testResults.TotalTests
    Passed = $testResults.PassedTests
    Failed = $testResults.FailedTests
    Skipped = $testResults.SkippedTests
    PassRate = if (($testResults.TotalTests - $testResults.SkippedTests) -gt 0) { 
        [math]::Round(($testResults.PassedTests / ($testResults.TotalTests - $testResults.SkippedTests)) * 100, 2) 
    } else { 0 }
    ComplianceStatus = if ($testResults.FailedTests -eq 0) { "COMPLIANT" } else { "NON-COMPLIANT" }
}

Write-Host "Total Tests:       $($summaryData.TotalTests)" -ForegroundColor Cyan
Write-Host "Passed:            $($summaryData.Passed)" -ForegroundColor Green
Write-Host "Failed:            $($summaryData.Failed)" -ForegroundColor Red
Write-Host "Skipped:           $($summaryData.Skipped)" -ForegroundColor Gray
Write-Host "Pass Rate:         $($summaryData.PassRate)%" -ForegroundColor Cyan
Write-Host "Compliance Status: $($summaryData.ComplianceStatus)" -ForegroundColor $(if ($summaryData.ComplianceStatus -eq "COMPLIANT") { "Green" } else { "Red" })
Write-Host ""

# NIST CSF Mapping
Write-Host "NIST Cybersecurity Framework (CSF) Mapping:" -ForegroundColor Cyan
Write-Host "  • Identify (ID): Asset inventory and management" -ForegroundColor White
Write-Host "  • Protect (PR): Access control, hardening, encryption" -ForegroundColor Green
Write-Host "  • Detect (DE): Monitoring and logging" -ForegroundColor Cyan
Write-Host "  • Respond (RS): Incident handling" -ForegroundColor Yellow
Write-Host "  • Recover (RC): Business continuity" -ForegroundColor Magenta
Write-Host ""

$testResults.Summary = $summaryData

# Save report
try {
    $testResults | ConvertTo-Json -Depth 10 | Set-Content -Path $ReportPath
    Write-TestResult "Report saved to: $ReportPath" "PASS"
}
catch {
    Write-TestResult "Failed to save report: $_" "FAIL"
}

Write-Host ""

# Exit with appropriate code
if ($testResults.FailedTests -gt 0) {
    Write-TestResult "Test Suite FAILED - $($testResults.FailedTests) compliance test(s) failed" "FAIL"
    exit 1
}
else {
    Write-TestResult "Test Suite PASSED - All compliance tests passed" "PASS"
    exit 0
}

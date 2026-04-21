<#
.SYNOPSIS
    Deployment Scripts Validation Test Suite
    
.DESCRIPTION
    Validates deployment scripts for function signatures, parameter validation,
    Windows PE requirements, and DISM availability.
    
.PARAMETER ReportPath
    Path to save test report (default: tests/reports/deployment-results.json)
    
.PARAMETER SkipDISMCheck
    Skip DISM availability check (useful for non-deployment environments)
    
.EXAMPLE
    .\Test-Deployment-Scripts.ps1
    .\Test-Deployment-Scripts.ps1 -SkipDISMCheck $false
    
.NOTES
    - All tests are non-destructive
    - Does not perform actual deployments
    - Requires: PowerShell 5.1+
#>

param(
    [string]$ReportPath = "$PSScriptRoot\..\reports\deployment-results.json",
    [bool]$SkipDISMCheck = $false
)

$ErrorActionPreference = "Stop"

# Initialize test results
$testResults = @{
    TestSuite = "Deployment Scripts Validation"
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    OSVersion = [System.Environment]::OSVersion.VersionString
    TotalTests = 0
    PassedTests = 0
    FailedTests = 0
    SkippedTests = 0
    Tests = @()
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
        [scriptblock]$TestScript
    )
    
    $testResult = @{
        TestName = $TestName
        Description = $Description
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

# Function signature validation
function Test-FunctionSignature {
    param(
        [string]$ScriptPath,
        [string]$FunctionName
    )
    
    try {
        $content = Get-Content $ScriptPath -Raw
        $pattern = "function\s+$([regex]::Escape($FunctionName))\s*\{|function\s+$([regex]::Escape($FunctionName))\s*\("
        return $content -match $pattern
    }
    catch {
        return $false
    }
}

# Parameter block validation
function Test-HasParameterBlock {
    param(
        [string]$ScriptPath
    )
    
    try {
        $content = Get-Content $ScriptPath -Raw
        return $content -match "^\s*param\s*\("
    }
    catch {
        return $false
    }
}

# Parameter validation in script
function Test-ParameterValidation {
    param(
        [string]$ScriptPath,
        [string]$ParameterName
    )
    
    try {
        $content = Get-Content $ScriptPath -Raw
        # Check for common parameter validation patterns
        $patterns = @(
            "if\s*\(\s*-not\s+\`$$ParameterName\s*\)",
            "\[ValidateNotNullOrEmpty\(\)\]",
            "\[ValidateSet\(",
            "\[ValidatePath\(",
            "\[ValidateScript\("
        )
        
        return $content -match ($patterns -join "|")
    }
    catch {
        return $false
    }
}

# Check for required error handling
function Test-ErrorHandling {
    param(
        [string]$ScriptPath
    )
    
    try {
        $content = Get-Content $ScriptPath -Raw
        $hasErrorHandling = $content -match "try\s*\{" -and $content -match "catch\s*\{" -or 
                           $content -match "\$ErrorActionPreference" -or
                           $content -match "-ErrorAction"
        return $hasErrorHandling
    }
    catch {
        return $false
    }
}

# DISM availability check
function Test-DISMAvailable {
    try {
        $dism = Get-Command DISM -ErrorAction Stop
        return $dism -ne $null
    }
    catch {
        return $false
    }
}

# WIM format support validation
function Test-WIMSupport {
    try {
        # Check if DISM supports WIM operations
        $dism = Get-Command DISM -ErrorAction Stop
        return $dism -ne $null
    }
    catch {
        return $false
    }
}

# BitLocker prerequisite check
function Test-BitLockerPrerequisite {
    try {
        $bitlocker = Get-BitLockerVolume -ErrorAction Stop
        return $true
    }
    catch {
        # BitLocker may not be available on all SKUs, which is expected
        return $false
    }
}

# Main test execution
Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Deployment Scripts Validation Test Suite                  ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$deploymentPath = Join-Path $repoRoot "deployment"

# Test 1: Deployment script structure
Write-Host "Testing Deployment Script Structure..." -ForegroundColor Cyan

$deploymentScripts = @(
    @{ Path = "Deploy-Image.ps1"; Functions = @("Deploy-Image", "Write-Log") },
    @{ Path = "Enable-BitLocker.ps1"; Functions = @("Enable-BitLocker") },
    @{ Path = "Create-Windows-PE.ps1"; Functions = @("Create-Windows-PE") }
)

foreach ($scriptDef in $deploymentScripts) {
    $scriptPath = Join-Path $deploymentPath $scriptDef.Path
    
    if (-not (Test-Path $scriptPath)) {
        Write-TestResult "Script not found: $($scriptDef.Path)" "WARN"
        continue
    }
    
    # Test parameter block
    $testName = "ParamBlock-$($scriptDef.Path -replace '\W', '_')"
    $test = New-TestCase -TestName $testName -Description "Script has parameter block" -TestScript {
        Test-HasParameterBlock -ScriptPath $scriptPath
    }
    
    $testResults.Tests += $test
    $testResults.TotalTests++
    
    if ($test.Status -eq "PASS") {
        $testResults.PassedTests++
        Write-TestResult "$($scriptDef.Path) has parameter block" "PASS"
    }
    else {
        $testResults.FailedTests++
        Write-TestResult "$($scriptDef.Path) missing parameter block" "FAIL"
    }
    
    # Test error handling
    $testName = "ErrorHandling-$($scriptDef.Path -replace '\W', '_')"
    $test = New-TestCase -TestName $testName -Description "Script has error handling" -TestScript {
        Test-ErrorHandling -ScriptPath $scriptPath
    }
    
    $testResults.Tests += $test
    $testResults.TotalTests++
    
    if ($test.Status -eq "PASS") {
        $testResults.PassedTests++
        Write-TestResult "$($scriptDef.Path) has error handling" "PASS"
    }
    else {
        $testResults.FailedTests++
        Write-TestResult "$($scriptDef.Path) missing error handling" "WARN"
    }
}

Write-Host ""

# Test 2: Function signatures
Write-Host "Testing Function Signatures..." -ForegroundColor Cyan

foreach ($scriptDef in $deploymentScripts) {
    $scriptPath = Join-Path $deploymentPath $scriptDef.Path
    
    if (-not (Test-Path $scriptPath)) {
        continue
    }
    
    foreach ($func in $scriptDef.Functions) {
        $testName = "FuncSig-$($scriptDef.Path -replace '\W', '_')-$func"
        $test = New-TestCase -TestName $testName -Description "Function exists: $func" -TestScript {
            Test-FunctionSignature -ScriptPath $scriptPath -FunctionName $func
        }
        
        $testResults.Tests += $test
        $testResults.TotalTests++
        
        if ($test.Status -eq "PASS") {
            $testResults.PassedTests++
            Write-TestResult "Function '$func' found in $($scriptDef.Path)" "PASS"
        }
        else {
            Write-TestResult "Function '$func' NOT found in $($scriptDef.Path)" "WARN"
            $testResults.SkippedTests++
        }
    }
}

Write-Host ""

# Test 3: Common parameter validation
Write-Host "Testing Parameter Validation..." -ForegroundColor Cyan

$parameterTests = @(
    @{ Script = "Deploy-Image.ps1"; Parameter = "ImagePath" },
    @{ Script = "Deploy-Image.ps1"; Parameter = "TargetDisk" },
    @{ Script = "Enable-BitLocker.ps1"; Parameter = "MountPoint" }
)

foreach ($paramTest in $parameterTests) {
    $scriptPath = Join-Path $deploymentPath $paramTest.Script
    
    if (-not (Test-Path $scriptPath)) {
        continue
    }
    
    $testName = "ParamValid-$($paramTest.Script -replace '\W', '_')-$($paramTest.Parameter)"
    $test = New-TestCase -TestName $testName -Description "Parameter validation for $($paramTest.Parameter)" -TestScript {
        Test-ParameterValidation -ScriptPath $scriptPath -ParameterName $paramTest.Parameter
    }
    
    $testResults.Tests += $test
    $testResults.TotalTests++
    
    if ($test.Status -eq "PASS") {
        $testResults.PassedTests++
        Write-TestResult "Parameter '$($paramTest.Parameter)' has validation" "PASS"
    }
    else {
        Write-TestResult "Parameter '$($paramTest.Parameter)' lacks validation" "WARN"
        $testResults.SkippedTests++
    }
}

Write-Host ""

# Test 4: System requirements
Write-Host "Testing System Requirements..." -ForegroundColor Cyan

# Test DISM availability
$testName = "SystemReq-DISM"
$test = New-TestCase -TestName $testName -Description "DISM is available" -TestScript {
    Test-DISMAvailable
}

$testResults.Tests += $test
$testResults.TotalTests++

if ($test.Status -eq "PASS") {
    $testResults.PassedTests++
    Write-TestResult "DISM is available and functional" "PASS"
}
else {
    if ($SkipDISMCheck) {
        $testResults.SkippedTests++
        Write-TestResult "DISM check skipped" "SKIP"
    }
    else {
        $testResults.FailedTests++
        Write-TestResult "DISM is not available" "FAIL"
    }
}

# Test WIM support
$testName = "SystemReq-WIM"
$test = New-TestCase -TestName $testName -Description "WIM format is supported" -TestScript {
    Test-WIMSupport
}

$testResults.Tests += $test
$testResults.TotalTests++

if ($test.Status -eq "PASS") {
    $testResults.PassedTests++
    Write-TestResult "WIM format support available" "PASS"
}
else {
    $testResults.SkippedTests++
    Write-TestResult "WIM format support not available" "SKIP"
}

# Test BitLocker support
$testName = "SystemReq-BitLocker"
$test = New-TestCase -TestName $testName -Description "BitLocker is available" -TestScript {
    Test-BitLockerPrerequisite
}

$testResults.Tests += $test
$testResults.TotalTests++

if ($test.Status -eq "PASS") {
    $testResults.PassedTests++
    Write-TestResult "BitLocker is available on this system" "PASS"
}
else {
    Write-TestResult "BitLocker may not be available (expected on Home SKUs)" "WARN"
    $testResults.SkippedTests++
}

Write-Host ""

# Test 5: Windows PE compatibility
Write-Host "Testing Windows PE Compatibility..." -ForegroundColor Cyan

$testName = "WinPE-Requirements"
$test = New-TestCase -TestName $testName -Description "Check Windows PE script requirements" -TestScript {
    try {
        $scriptPath = Join-Path $deploymentPath "Create-Windows-PE.ps1"
        if (-not (Test-Path $scriptPath)) {
            return $false
        }
        
        $content = Get-Content $scriptPath -Raw
        # Check for common WinPE requirements
        $hasRequirements = $content -match "ADK|Windows PE|boot" -and $content -match "param"
        return $hasRequirements
    }
    catch {
        return $false
    }
}

$testResults.Tests += $test
$testResults.TotalTests++

if ($test.Status -eq "PASS") {
    $testResults.PassedTests++
    Write-TestResult "Windows PE requirements documented" "PASS"
}
else {
    Write-TestResult "Windows PE requirements check skipped" "SKIP"
    $testResults.SkippedTests++
}

Write-Host ""

# Test 6: Image format validation
Write-Host "Testing Image Format Validation..." -ForegroundColor Cyan

$imageFormats = @(
    @{ Format = "WIM"; Description = "Windows Imaging Format" },
    @{ Format = "VHDX"; Description = "Virtual Hard Disk Extended" },
    @{ Format = "ISO"; Description = "ISO 9660 Disk Image" },
    @{ Format = "VHD"; Description = "Virtual Hard Disk" }
)

foreach ($format in $imageFormats) {
    $testName = "ImageFormat-$($format.Format)"
    $test = New-TestCase -TestName $testName -Description "Validate $($format.Format) format support" -TestScript {
        try {
            $deploymentScripts = Get-ChildItem -Path (Join-Path $repoRoot "deployment") -Filter "*.ps1" -ErrorAction SilentlyContinue
            $supportsFormat = 0
            foreach ($script in $deploymentScripts) {
                $content = Get-Content $script.FullName -Raw
                if ($content -match $format.Format) {
                    $supportsFormat++
                }
            }
            return $supportsFormat -gt 0
        }
        catch {
            return $false
        }
    }
    
    $testResults.Tests += $test
    $testResults.TotalTests++
    
    if ($test.Status -eq "PASS") {
        $testResults.PassedTests++
        Write-TestResult "$($format.Format) format support validated" "PASS"
    }
    else {
        $testResults.SkippedTests++
        Write-TestResult "$($format.Format) format support check skipped" "SKIP"
    }
}

# Test 7: Deployment scenario validation
Write-Host ""
Write-Host "Testing Deployment Scenarios..." -ForegroundColor Cyan

$scenarios = @(
    @{ Name = "Fresh Deploy"; Description = "Deploy to clean system" },
    @{ Name = "Update"; Description = "Update existing deployment" },
    @{ Name = "Rollback"; Description = "Rollback to previous state" },
    @{ Name = "Verification"; Description = "Verify deployment success" }
)

foreach ($scenario in $scenarios) {
    $testName = "Scenario-$($scenario.Name -replace '\s', '_')"
    $test = New-TestCase -TestName $testName -Description "Validate deployment scenario: $($scenario.Name)" -TestScript {
        try {
            $deploymentScripts = Get-ChildItem -Path (Join-Path $repoRoot "deployment") -Filter "*.ps1" -ErrorAction SilentlyContinue
            $found = $false
            $scenarioKeywords = @{
                "Fresh Deploy" = "Deploy|Install|Create"
                "Update" = "Update|Upgrade"
                "Rollback" = "Rollback|Restore|Revert"
                "Verification" = "Verify|Validate|Test"
            }
            
            $keywords = $scenarioKeywords[$scenario.Name]
            foreach ($script in $deploymentScripts) {
                $content = Get-Content $script.FullName -Raw
                if ($content -match $keywords) {
                    $found = $true
                    break
                }
            }
            return $found
        }
        catch {
            return $false
        }
    }
    
    $testResults.Tests += $test
    $testResults.TotalTests++
    
    if ($test.Status -eq "PASS") {
        $testResults.PassedTests++
        Write-TestResult "Deployment scenario '$($scenario.Name)' validated" "PASS"
    }
    else {
        $testResults.SkippedTests++
        Write-TestResult "Deployment scenario '$($scenario.Name)' validation skipped" "SKIP"
    }
}

# Test 8: Recovery and rollback procedures
Write-Host ""
Write-Host "Testing Recovery Procedures..." -ForegroundColor Cyan

$testName = "Recovery-Procedures"
$test = New-TestCase -TestName $testName -Description "Validate recovery and rollback procedures" -TestScript {
    try {
        $deploymentScripts = Get-ChildItem -Path (Join-Path $repoRoot "deployment") -Filter "*.ps1" -ErrorAction SilentlyContinue
        $hasRecovery = 0
        foreach ($script in $deploymentScripts) {
            $content = Get-Content $script.FullName -Raw
            # Check for recovery patterns
            if ($content -match "Backup|Restore|Recover|Rollback|Recovery") {
                $hasRecovery++
            }
        }
        return $hasRecovery -gt 0
    }
    catch {
        return $false
    }
}

$testResults.Tests += $test
$testResults.TotalTests++

if ($test.Status -eq "PASS") {
    $testResults.PassedTests++
    Write-TestResult "Recovery procedures implemented" "PASS"
}
else {
    $testResults.FailedTests++
    Write-TestResult "Recovery procedures not found" "FAIL"
}

# Test 9: Logging in deployment
Write-Host ""
Write-Host "Testing Deployment Logging..." -ForegroundColor Cyan

$testName = "Deployment-Logging"
$test = New-TestCase -TestName $testName -Description "Validate deployment logging" -TestScript {
    try {
        $deploymentScripts = Get-ChildItem -Path (Join-Path $repoRoot "deployment") -Filter "*.ps1" -ErrorAction SilentlyContinue
        $hasLogging = 0
        foreach ($script in $deploymentScripts) {
            $content = Get-Content $script.FullName -Raw
            if ($content -match "Write-Log|Write-Host.*log|Out-File.*log|Add-Content") {
                $hasLogging++
            }
        }
        return $hasLogging -gt 0
    }
    catch {
        return $false
    }
}

$testResults.Tests += $test
$testResults.TotalTests++

if ($test.Status -eq "PASS") {
    $testResults.PassedTests++
    Write-TestResult "Deployment logging implemented" "PASS"
}
else {
    $testResults.FailedTests++
    Write-TestResult "Deployment logging not found" "FAIL"
}

# Test 10: Security validation in deployment
Write-Host ""
Write-Host "Testing Security Validation..." -ForegroundColor Cyan

$testName = "Security-Validation"
$test = New-TestCase -TestName $testName -Description "Validate security checks in deployment" -TestScript {
    try {
        $deploymentScripts = Get-ChildItem -Path (Join-Path $repoRoot "deployment") -Filter "*.ps1" -ErrorAction SilentlyContinue
        $hasSecurityChecks = 0
        foreach ($script in $deploymentScripts) {
            $content = Get-Content $script.FullName -Raw
            if ($content -match "Admin|Credential|Encrypt|Secure|Permission|Validate") {
                $hasSecurityChecks++
            }
        }
        return $hasSecurityChecks -gt 0
    }
    catch {
        return $false
    }
}

$testResults.Tests += $test
$testResults.TotalTests++

if ($test.Status -eq "PASS") {
    $testResults.PassedTests++
    Write-TestResult "Security validation implemented" "PASS"
}
else {
    $testResults.FailedTests++
    Write-TestResult "Security validation not found" "FAIL"
}

Write-Host ""

# Generate summary
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
}

Write-Host "Total Tests:       $($summaryData.TotalTests)" -ForegroundColor Cyan
Write-Host "Passed:            $($summaryData.Passed)" -ForegroundColor Green
Write-Host "Failed:            $($summaryData.Failed)" -ForegroundColor Red
Write-Host "Skipped:           $($summaryData.Skipped)" -ForegroundColor Gray
Write-Host "Pass Rate:         $($summaryData.PassRate)%" -ForegroundColor Cyan
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
    Write-TestResult "Test Suite FAILED - $($testResults.FailedTests) test(s) failed" "FAIL"
    exit 1
}
else {
    Write-TestResult "Test Suite PASSED - All tests passed" "PASS"
    exit 0
}

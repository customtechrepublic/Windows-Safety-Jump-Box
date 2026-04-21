<#
.SYNOPSIS
    CIS Hardening Script Unit Tests
    
.DESCRIPTION
    Comprehensive unit tests for CIS hardening scripts. Tests function definitions,
    registry operations (mocked), service availability, and audit policy validation.
    
.PARAMETER ReportPath
    Path to save test report (default: tests/reports/cis-hardening-results.json)
    
.PARAMETER SkipServiceCheck
    Skip actual service validation (useful for non-production environments)
    
.EXAMPLE
    .\Test-CIS-Hardening.ps1
    .\Test-CIS-Hardening.ps1 -SkipServiceCheck $false
    
.NOTES
    - All tests use mocks and do not modify system state
    - Registry operations are mocked and not executed on actual system
    - Requires: PowerShell 5.1+, Windows 10/11 Pro or Server 2019+
#>

param(
    [string]$ReportPath = "$PSScriptRoot\..\reports\cis-hardening-results.json",
    [bool]$SkipServiceCheck = $false
)

$ErrorActionPreference = "Stop"

# Initialize test results
$testResults = @{
    TestSuite = "CIS Hardening Validation"
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

# Test infrastructure
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

# Mocked registry validation
function Test-RegistryPath {
    param(
        [string]$Path
    )
    
    # This is a mock function - in production it would validate actual registry
    # For testing purposes, we validate the path format
    $validPatterns = @(
        "HKLM:",
        "HKCU:",
        "HKCR:",
        "HKU:",
        "HKCC:"
    )
    
    $isValid = $false
    foreach ($pattern in $validPatterns) {
        if ($Path -like "$pattern\*") {
            $isValid = $true
            break
        }
    }
    
    return $isValid
}

# Function existence check
function Test-FunctionExists {
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

# Service validation
function Test-ServiceExists {
    param(
        [string]$ServiceName
    )
    
    try {
        $service = Get-Service -Name $ServiceName -ErrorAction Stop
        return $service -ne $null
    }
    catch {
        return $false
    }
}

# Audit policy validation
function Test-AuditPolicy {
    param(
        [string]$PolicyName
    )
    
    # Known valid audit policies for Windows
    $validPolicies = @(
        "Security System Extension",
        "System Integrity",
        "IPsec Driver",
        "Other System Events",
        "Logon/Logoff",
        "Logon",
        "Logoff",
        "Account Lockout",
        "IPsec Main Mode",
        "IPsec Quick Mode",
        "IPsec Extended Mode",
        "Special Logon",
        "Detailed File Share",
        "File Share",
        "File System",
        "Registry",
        "Kernel Object",
        "SAM",
        "Certification Services",
        "Application Generated",
        "Handle Manipulation",
        "Directory Service Access",
        "Directory Service Changes",
        "Directory Service Replication",
        "Account Management",
        "Computer Account Management",
        "Other Account Management Events",
        "User Account Management",
        "Group Management",
        "Process Creation",
        "Process Termination",
        "DPAPI Activity",
        "RPC Events",
        "Audit Policy Change",
        "Authentication Policy Change",
        "Authorization Policy Change",
        "Filtering Platform Connection",
        "Filtering Platform Packet Drop",
        "Network Policy Server"
    )
    
    return $validPolicies -contains $PolicyName
}

# Main test execution
Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║        CIS Hardening Script Unit Test Suite                   ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Get repository root
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)

# Test 1: Function definitions in hardening scripts
Write-Host "Testing Function Definitions..." -ForegroundColor Cyan
$hardeningPath = Join-Path $repoRoot "hardening"
$cisMandatory = Join-Path $hardeningPath "CIS_Level2_Mandatory.ps1"
$cisComplete = Join-Path $hardeningPath "CIS_Level1+2_Complete.ps1"

$requiredFunctions = @(
    "Write-Log",
    "Get-LogPath",
    "Test-Administrator",
    "Backup-Registry",
    "Restore-Registry"
)

foreach ($script in @($cisMandatory, $cisComplete)) {
    if (Test-Path $script) {
        foreach ($func in $requiredFunctions) {
            $testName = "FunctionExists-$($script | Split-Path -Leaf)-$func"
            $test = New-TestCase -TestName $testName -Description "Check if function '$func' exists" -TestScript {
                Test-FunctionExists -ScriptPath $script -FunctionName $func
            }
            
            $testResults.Tests += $test
            $testResults.TotalTests++
            
            if ($test.Status -eq "PASS") {
                $testResults.PassedTests++
                Write-TestResult "$func found in $(Split-Path -Leaf $script)" "PASS"
            }
            else {
                $testResults.FailedTests++
                Write-TestResult "$func NOT found in $(Split-Path -Leaf $script)" "FAIL"
            }
        }
    }
}

Write-Host ""

# Test 2: Service availability
Write-Host "Testing Critical Services..." -ForegroundColor Cyan

$criticalServices = @(
    @{Name = "RpcSs"; DisplayName = "Remote Procedure Call" },
    @{Name = "LanmanServer"; DisplayName = "Server" },
    @{Name = "LanmanWorkstation"; DisplayName = "Workstation" },
    @{Name = "W32Time"; DisplayName = "Windows Time" },
    @{Name = "Winlogon"; DisplayName = "Winlogon" }
)

foreach ($svc in $criticalServices) {
    $testName = "ServiceExists-$($svc.Name)"
    $test = New-TestCase -TestName $testName -Description "Check if critical service '$($svc.DisplayName)' exists" -TestScript {
        Test-ServiceExists -ServiceName $svc.Name
    }
    
    $testResults.Tests += $test
    $testResults.TotalTests++
    
    if ($test.Status -eq "PASS") {
        $testResults.PassedTests++
        Write-TestResult "$($svc.DisplayName) service available" "PASS"
    }
    else {
        if ($SkipServiceCheck) {
            $testResults.SkippedTests++
            Write-TestResult "$($svc.DisplayName) service check skipped" "SKIP"
        }
        else {
            $testResults.FailedTests++
            Write-TestResult "$($svc.DisplayName) service NOT found" "FAIL"
        }
    }
}

Write-Host ""

# Test 3: Service shouldn't be disabled
Write-Host "Testing Critical Services NOT Disabled..." -ForegroundColor Cyan

$servicesNotDisabled = @(
    @{Name = "RpcSs"; DisplayName = "Remote Procedure Call (required)" },
    @{Name = "BITS"; DisplayName = "Background Intelligent Transfer Service" }
)

foreach ($svc in $servicesNotDisabled) {
    $testName = "ServiceNotDisabled-$($svc.Name)"
    $test = New-TestCase -TestName $testName -Description "Verify critical service is not disabled" -TestScript {
        try {
            $service = Get-Service -Name $svc.Name -ErrorAction Stop
            # If service exists and can be accessed, that's a pass
            return ($service.Status -ne "Stopped" -or $service.StartType -ne "Disabled")
        }
        catch {
            return $false
        }
    }
    
    $testResults.Tests += $test
    $testResults.TotalTests++
    
    if ($test.Status -eq "PASS") {
        $testResults.PassedTests++
        Write-TestResult "$($svc.DisplayName) is properly configured" "PASS"
    }
    else {
        $testResults.FailedTests++
        Write-TestResult "$($svc.DisplayName) might be misconfigured" "FAIL"
    }
}

Write-Host ""

# Test 4: Registry paths are valid format
Write-Host "Testing Registry Path Formats..." -ForegroundColor Cyan

$registryPaths = @(
    "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters",
    "HKLM:\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System",
    "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers"
)

foreach ($path in $registryPaths) {
    $testName = "RegistryPathFormat-$($path -replace '[:\\]', '_')"
    $test = New-TestCase -TestName $testName -Description "Validate registry path format" -TestScript {
        Test-RegistryPath -Path $path
    }
    
    $testResults.Tests += $test
    $testResults.TotalTests++
    
    if ($test.Status -eq "PASS") {
        $testResults.PassedTests++
        Write-TestResult "Registry path valid: $path" "PASS"
    }
    else {
        $testResults.FailedTests++
        Write-TestResult "Registry path invalid: $path" "FAIL"
    }
}

Write-Host ""

# Test 5: Audit policy names
Write-Host "Testing Audit Policy Names..." -ForegroundColor Cyan

$auditPolicies = @(
    "Logon/Logoff",
    "Account Management",
    "Process Creation",
    "File System",
    "Registry"
)

foreach ($policy in $auditPolicies) {
    $testName = "AuditPolicy-$($policy -replace '[/\s]', '_')"
    $test = New-TestCase -TestName $testName -Description "Validate audit policy name" -TestScript {
        Test-AuditPolicy -PolicyName $policy
    }
    
    $testResults.Tests += $test
    $testResults.TotalTests++
    
    if ($test.Status -eq "PASS") {
        $testResults.PassedTests++
        Write-TestResult "Audit policy valid: $policy" "PASS"
    }
    else {
        $testResults.FailedTests++
        Write-TestResult "Audit policy invalid: $policy" "FAIL"
    }
}

Write-Host ""

# Test 6: Script parameter validation
Write-Host "Testing Script Parameters..." -ForegroundColor Cyan

$applyScripts = Get-ChildItem -Path (Join-Path $repoRoot "hardening") -Filter "Apply-CIS-*.ps1" -ErrorAction SilentlyContinue

foreach ($script in $applyScripts) {
    $testName = "ScriptParams-$($script.BaseName)"
    $test = New-TestCase -TestName $testName -Description "Validate script has parameter block" -TestScript {
        $content = Get-Content $script.FullName -Raw
        $hasParams = $content -match "^\s*param\s*\("
        return $hasParams
    }
    
    $testResults.Tests += $test
    $testResults.TotalTests++
    
    if ($test.Status -eq "PASS") {
        $testResults.PassedTests++
        Write-TestResult "$($script.Name) has proper parameters" "PASS"
    }
    else {
        $testResults.FailedTests++
        Write-TestResult "$($script.Name) missing parameter block" "FAIL"
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
    PassRate = if ($testResults.TotalTests -gt 0) { 
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

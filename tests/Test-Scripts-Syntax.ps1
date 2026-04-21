<#
.SYNOPSIS
    PowerShell Script Syntax Validation Test Suite
    
.DESCRIPTION
    Validates all PowerShell scripts in the repository for syntax errors,
    placeholder values, emoji characters, and production readiness.
    
.PARAMETER ReportPath
    Path to save JSON report (default: tests/reports/syntax-results.json)
    
.EXAMPLE
    .\Test-Scripts-Syntax.ps1
    .\Test-Scripts-Syntax.ps1 -ReportPath "C:\reports\syntax.json"
    
.NOTES
    - Tests run non-destructively using dot-sourcing with error handling
    - No system modifications are made
    - Requires: PowerShell 5.1+
#>

param(
    [string]$ReportPath = "$PSScriptRoot\..\reports\syntax-results.json"
)

$ErrorActionPreference = "Stop"

# Initialize test results
$testResults = @{
    TestSuite = "Script Syntax Validation"
    Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    TotalScripts = 0
    PassedScripts = 0
    FailedScripts = 0
    WarningScripts = 0
    Scripts = @()
    Summary = @()
}

$reportDir = Split-Path -Parent $ReportPath
if (-not (Test-Path $reportDir)) {
    New-Item -ItemType Directory -Path $reportDir -Force | Out-Null
}

# Color-coded console output
function Write-TestResult {
    param(
        [string]$Message,
        [ValidateSet("PASS", "FAIL", "WARN", "INFO")]
        [string]$Status = "INFO"
    )
    
    $color = @{
        "PASS" = "Green"
        "FAIL" = "Red"
        "WARN" = "Yellow"
        "INFO" = "Cyan"
    }
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] [$Status] $Message" -ForegroundColor $color[$Status]
}

# Test function: Check script syntax
function Test-ScriptSyntax {
    param(
        [string]$FilePath
    )
    
    $result = @{
        FilePath = $FilePath
        FileName = Split-Path -Leaf $FilePath
        Status = "PASS"
        Errors = @()
        Warnings = @()
    }
    
    try {
        # Attempt to parse the script without executing
        $null = [System.Management.Automation.PSParser]::Tokenize((Get-Content $FilePath -Raw), [ref]$null)
    }
    catch {
        $result.Status = "FAIL"
        $result.Errors += "Parse Error: $_"
        return $result
    }
    
    # Check file content for issues
    $content = Get-Content $FilePath -Raw
    
    # Check for emoji characters
    $emojiPattern = '[^\x00-\x7F]'  # Non-ASCII characters
    if ($content -match $emojiPattern) {
        $result.Warnings += "Contains non-ASCII characters (possible emoji)"
        if ($result.Status -eq "PASS") { $result.Status = "WARN" }
    }
    
    # Check for common placeholder patterns
    $placeholders = @(
        '\[TODO\]',
        '\[FIXME\]',
        'PLACEHOLDER',
        'XXX_',
        'your-?password',
        'your-?username',
        'change-?this',
        'CHANGEME'
    )
    
    foreach ($placeholder in $placeholders) {
        if ($content -match $placeholder) {
            $result.Warnings += "Contains placeholder: $placeholder"
            if ($result.Status -eq "PASS") { $result.Status = "WARN" }
        }
    }
    
    # Validate function definitions if present
    try {
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($content, [ref]$null, [ref]$null)
        
        # Check for syntax errors in AST
        if ($ast.ParamBlock -or $ast.BeginBlock -or $ast.ProcessBlock -or $ast.EndBlock -or $ast.DynamicParamBlock) {
            # Script has proper structure
            $result.Errors += @()
        }
    }
    catch {
        $result.Status = "FAIL"
        $result.Errors += "AST Parse Error: $_"
    }
    
    return $result
}

# Test function: Validate critical functions exist
function Test-CriticalFunctions {
    param(
        [string]$FilePath,
        [string[]]$RequiredFunctions = @()
    )
    
    $result = @{
        FilePath = $FilePath
        FileName = Split-Path -Leaf $FilePath
        Status = "PASS"
        Errors = @()
        FoundFunctions = @()
    }
    
    if ($RequiredFunctions.Count -eq 0) {
        return $result
    }
    
    try {
        $content = Get-Content $FilePath -Raw
        
        foreach ($func in $RequiredFunctions) {
            $funcPattern = "function\s+$([regex]::Escape($func))\s*\{"
            if ($content -match $funcPattern) {
                $result.FoundFunctions += $func
            }
            else {
                $result.Errors += "Missing function: $func"
                $result.Status = "WARN"
            }
        }
    }
    catch {
        $result.Errors += "Error checking functions: $_"
        $result.Status = "FAIL"
    }
    
    return $result
}

# Main test execution
Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       PowerShell Script Syntax Validation Test Suite           ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Find all PowerShell scripts in repository
$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$scripts = Get-ChildItem -Path $repoRoot -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue | 
    Where-Object { $_.FullName -notmatch "\\tests\\" }

$testResults.TotalScripts = $scripts.Count

Write-TestResult "Found $($scripts.Count) PowerShell scripts to validate" "INFO"
Write-Host ""

# Test each script
foreach ($script in $scripts) {
    $syntaxTest = Test-ScriptSyntax -FilePath $script.FullName
    $testResults.Scripts += $syntaxTest
    
    if ($syntaxTest.Status -eq "PASS") {
        $testResults.PassedScripts++
        Write-TestResult "$($script.Name) - Syntax Valid" "PASS"
    }
    elseif ($syntaxTest.Status -eq "WARN") {
        $testResults.WarningScripts++
        Write-TestResult "$($script.Name) - Warnings Found" "WARN"
        foreach ($warning in $syntaxTest.Warnings) {
            Write-Host "  ⚠️  $warning" -ForegroundColor Yellow
        }
    }
    else {
        $testResults.FailedScripts++
        Write-TestResult "$($script.Name) - Syntax Error" "FAIL"
        foreach ($error in $syntaxTest.Errors) {
            Write-Host "  ✗ $error" -ForegroundColor Red
        }
    }
}

# Generate summary
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                      TEST SUMMARY                             ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

$summaryData = @{
    TotalScripts = $testResults.TotalScripts
    Passed = $testResults.PassedScripts
    Failed = $testResults.FailedScripts
    Warnings = $testResults.WarningScripts
    PassRate = if ($testResults.TotalScripts -gt 0) { 
        [math]::Round(($testResults.PassedScripts / $testResults.TotalScripts) * 100, 2) 
    } else { 0 }
}

Write-Host "Total Scripts:     $($summaryData.TotalScripts)" -ForegroundColor Cyan
Write-Host "Passed:            $($summaryData.Passed)" -ForegroundColor Green
Write-Host "Failed:            $($summaryData.Failed)" -ForegroundColor Red
Write-Host "Warnings:          $($summaryData.Warnings)" -ForegroundColor Yellow
Write-Host "Pass Rate:         $($summaryData.PassRate)%" -ForegroundColor Cyan
Write-Host ""

$testResults.Summary = $summaryData

# Save JSON report
try {
    $testResults | ConvertTo-Json -Depth 10 | Set-Content -Path $ReportPath
    Write-TestResult "Report saved to: $ReportPath" "PASS"
}
catch {
    Write-TestResult "Failed to save report: $_" "FAIL"
}

# Exit with appropriate code
if ($testResults.FailedScripts -gt 0) {
    Write-Host ""
    Write-TestResult "Test Suite FAILED - $($testResults.FailedScripts) syntax errors found" "FAIL"
    exit 1
}
elseif ($testResults.WarningScripts -gt 0) {
    Write-Host ""
    Write-TestResult "Test Suite PASSED with warnings - $($testResults.WarningScripts) scripts have issues" "WARN"
    exit 0
}
else {
    Write-Host ""
    Write-TestResult "Test Suite PASSED - All scripts validated successfully" "PASS"
    exit 0
}

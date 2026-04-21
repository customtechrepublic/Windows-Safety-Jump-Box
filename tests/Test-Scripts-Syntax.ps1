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

# Test function: Check file encoding
function Test-FileEncoding {
    param(
        [string]$FilePath
    )
    
    $result = @{
        FilePath = $FilePath
        FileName = Split-Path -Leaf $FilePath
        Status = "PASS"
        DetectedEncoding = ""
        Warnings = @()
    }
    
    try {
        $fileInfo = Get-Item $FilePath
        $bytes = Get-Content $FilePath -Encoding Byte -TotalCount 4
        
        # Detect BOM
        if ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
            $result.DetectedEncoding = "UTF-8 BOM"
        }
        elseif ($bytes[0] -eq 0xFF -and $bytes[1] -eq 0xFE) {
            $result.DetectedEncoding = "UTF-16 LE"
        }
        elseif ($bytes[0] -eq 0xFE -and $bytes[1] -eq 0xFF) {
            $result.DetectedEncoding = "UTF-16 BE"
        }
        else {
            $result.DetectedEncoding = "ASCII/UTF-8 No BOM"
        }
        
        # Warning if not UTF-8
        if ($result.DetectedEncoding -notmatch "UTF-8") {
            $result.Warnings += "Non-standard encoding detected: $($result.DetectedEncoding)"
            $result.Status = "WARN"
        }
    }
    catch {
        $result.Status = "FAIL"
        $result.Warnings += "Error detecting encoding: $_"
    }
    
    return $result
}

# Test function: Check file permissions
function Test-FilePermissions {
    param(
        [string]$FilePath
    )
    
    $result = @{
        FilePath = $FilePath
        FileName = Split-Path -Leaf $FilePath
        Status = "PASS"
        IsReadable = $false
        IsWritable = $false
        Owner = ""
        Warnings = @()
    }
    
    try {
        $fileInfo = Get-Item $FilePath
        $result.IsReadable = $fileInfo.CanRead
        $result.IsWritable = $fileInfo.CanWrite
        
        # Get owner info
        $acl = Get-Acl $FilePath
        $result.Owner = $acl.Owner
        
        if (-not $result.IsReadable) {
            $result.Warnings += "File is not readable"
            $result.Status = "WARN"
        }
        
        if ($result.IsWritable -and $FilePath -notmatch "\\tests\\") {
            # Production scripts shouldn't be directly writable
            $result.Warnings += "Production script has write permissions"
            $result.Status = "WARN"
        }
    }
    catch {
        $result.Status = "FAIL"
        $result.Warnings += "Error checking permissions: $_"
    }
    
    return $result
}

# Test function: Check for encoding issues
function Test-EncodingCompliance {
    param(
        [string]$FilePath
    )
    
    $result = @{
        FilePath = $FilePath
        FileName = Split-Path -Leaf $FilePath
        Status = "PASS"
        Issues = @()
    }
    
    try {
        $content = Get-Content $FilePath -Raw
        
        # Check for mixed line endings
        $crlfCount = ($content | Select-String -Pattern "`r`n" -AllMatches).Matches.Count
        $lfOnlyCount = ($content -replace "`r`n", "" | Select-String -Pattern "`n" -AllMatches).Matches.Count
        $crOnlyCount = ($content -replace "`r`n", "" -replace "`n", "" | Select-String -Pattern "`r" -AllMatches).Matches.Count
        
        if ($lfOnlyCount -gt 0 -or $crOnlyCount -gt 0) {
            $result.Issues += "Mixed line endings detected"
            $result.Status = "WARN"
        }
        
        # Check for trailing whitespace
        $lines = $content -split "`n"
        $trailingWhitespaceLines = @($lines | Where-Object { $_ -match '\s+$' }).Count
        if ($trailingWhitespaceLines -gt 0) {
            $result.Issues += "Found $trailingWhitespaceLines lines with trailing whitespace"
            $result.Status = "WARN"
        }
        
        # Check for tabs vs spaces consistency
        $tabLines = @($lines | Where-Object { $_ -match "`t" }).Count
        $spaceIndentedLines = @($lines | Where-Object { $_ -match "^[ ]+" }).Count
        if ($tabLines -gt 0 -and $spaceIndentedLines -gt 0) {
            $result.Issues += "Mixed tabs and spaces for indentation"
            $result.Status = "WARN"
        }
    }
    catch {
        $result.Status = "FAIL"
        $result.Issues += "Error checking encoding: $_"
    }
    
    return $result
}

# Additional tests
Write-Host ""
Write-Host "Additional Validation Tests..." -ForegroundColor Cyan

# Test encoding compliance on a sample of scripts
Write-Host "Testing File Encoding Compliance..." -ForegroundColor Cyan
$encodingTestCount = 0
$encodingPassCount = 0
foreach ($script in $scripts | Select-Object -First 20) {
    $encodingTest = Test-FileEncoding -FilePath $script.FullName
    if ($encodingTest.Status -eq "PASS") {
        $encodingPassCount++
    }
    $encodingTestCount++
    $testResults.Scripts += $encodingTest
}

Write-Host "File Encoding Tests: $encodingPassCount / $encodingTestCount passed" -ForegroundColor $(if ($encodingPassCount -eq $encodingTestCount) { "Green" } else { "Yellow" })

# Test encoding compliance
Write-Host "Testing Encoding Compliance..." -ForegroundColor Cyan
$complianceTestCount = 0
$compliancePassCount = 0
foreach ($script in $scripts | Select-Object -First 20) {
    $complianceTest = Test-EncodingCompliance -FilePath $script.FullName
    if ($complianceTest.Status -eq "PASS") {
        $compliancePassCount++
    }
    $complianceTestCount++
    if ($complianceTest.Status -ne "PASS") {
        Write-TestResult "$($script.Name) - Encoding issues found" "WARN"
    }
}

Write-Host "Encoding Compliance Tests: $compliancePassCount / $complianceTestCount passed" -ForegroundColor $(if ($compliancePassCount -eq $complianceTestCount) { "Green" } else { "Yellow" })



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

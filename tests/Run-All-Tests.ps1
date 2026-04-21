<#
.SYNOPSIS
    Master Test Suite Runner
    
.DESCRIPTION
    Executes all test suites and generates comprehensive consolidated reports
    with HTML formatting and detailed metrics.
    
.PARAMETER TestFilter
    Run only specific tests (Syntax, CIS, Deployment, Compliance, Integration, All)
    
.PARAMETER ReportPath
    Base path for reports (default: tests/reports)
    
.PARAMETER GenerateHTML
    Generate HTML report (default: $true)
    
.EXAMPLE
    .\Run-All-Tests.ps1
    .\Run-All-Tests.ps1 -TestFilter "Syntax,CIS"
    .\Run-All-Tests.ps1 -GenerateHTML $false
    
.NOTES
    - Exit code 0 = all tests passed
    - Exit code 1+ = number of test suites failed
    - Generates JSON and HTML reports
#>

param(
    [ValidateSet("Syntax", "CIS", "Deployment", "Compliance", "Integration", "All")]
    [string[]]$TestFilter = @("All"),
    [string]$ReportPath = "$PSScriptRoot\..\reports",
    [bool]$GenerateHTML = $true
)

$ErrorActionPreference = "Stop"

# Ensure reports directory exists
if (-not (Test-Path $ReportPath)) {
    New-Item -ItemType Directory -Path $ReportPath -Force | Out-Null
}

# Initialize consolidated results
$consolidatedResults = @{
    ExecutionStarted = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    ExecutionEnded = $null
    TotalSuites = 0
    PassedSuites = 0
    FailedSuites = 0
    SkippedSuites = 0
    TestSuites = @()
    OverallStatus = "UNKNOWN"
    ConsolidatedMetrics = @{
        TotalTests = 0
        TotalPassed = 0
        TotalFailed = 0
        TotalSkipped = 0
        OverallPassRate = 0
    }
}

# Color-coded output
function Write-TestResult {
    param(
        [string]$Message,
        [ValidateSet("PASS", "FAIL", "WARN", "SKIP", "INFO", "START", "DONE")]
        [string]$Status = "INFO"
    )
    
    $color = @{
        "PASS" = "Green"
        "FAIL" = "Red"
        "WARN" = "Yellow"
        "SKIP" = "Gray"
        "INFO" = "Cyan"
        "START" = "Magenta"
        "DONE" = "Green"
    }
    
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] [$Status] $Message" -ForegroundColor $color[$Status]
}

# Execute a test script and capture results
function Invoke-TestSuite {
    param(
        [string]$ScriptName,
        [string]$DisplayName,
        [string]$ReportFile
    )
    
    $scriptPath = Join-Path $PSScriptRoot $ScriptName
    
    if (-not (Test-Path $scriptPath)) {
        Write-TestResult "$DisplayName script not found: $ScriptName" "WARN"
        return $null
    }
    
    Write-TestResult "Starting $DisplayName test suite..." "START"
    
    try {
        $output = & $scriptPath -ReportPath (Join-Path $ReportPath $ReportFile) 2>&1
        
        # Read the generated report
        $reportFullPath = Join-Path $ReportPath $ReportFile
        if (Test-Path $reportFullPath) {
            try {
                $report = Get-Content $reportFullPath -Raw | ConvertFrom-Json
                Write-TestResult "$DisplayName test suite completed" "DONE"
                return $report
            }
            catch {
                Write-TestResult "Failed to parse $DisplayName report: $_" "WARN"
                return $null
            }
        }
    }
    catch {
        Write-TestResult "$DisplayName test suite failed: $_" "FAIL"
        return $null
    }
}

# Generate HTML report
function New-HTMLReport {
    param(
        [object]$ConsolidatedResults,
        [string]$OutputPath
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $overallStatus = if ($ConsolidatedResults.ConsolidatedMetrics.TotalFailed -eq 0) { "PASSED" } else { "FAILED" }
    $statusColor = if ($overallStatus -eq "PASSED") { "#22c55e" } else { "#ef4444" }
    
    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Test Results Report</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f3f4f6;
            color: #1f2937;
            line-height: 1.6;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 30px;
            border-radius: 8px;
            margin-bottom: 30px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        
        .header h1 {
            font-size: 2.5em;
            margin-bottom: 10px;
        }
        
        .header p {
            font-size: 1.1em;
            opacity: 0.9;
        }
        
        .status-badge {
            display: inline-block;
            padding: 10px 20px;
            border-radius: 4px;
            font-weight: bold;
            margin-bottom: 20px;
            background-color: $statusColor;
            color: white;
            font-size: 1.2em;
        }
        
        .metrics {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .metric-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            border-left: 4px solid #667eea;
        }
        
        .metric-card.success {
            border-left-color: #22c55e;
        }
        
        .metric-card.failure {
            border-left-color: #ef4444;
        }
        
        .metric-card.warning {
            border-left-color: #f59e0b;
        }
        
        .metric-card.skip {
            border-left-color: #9ca3af;
        }
        
        .metric-value {
            font-size: 2em;
            font-weight: bold;
            color: #667eea;
        }
        
        .metric-card.success .metric-value {
            color: #22c55e;
        }
        
        .metric-card.failure .metric-value {
            color: #ef4444;
        }
        
        .metric-card.warning .metric-value {
            color: #f59e0b;
        }
        
        .metric-card.skip .metric-value {
            color: #9ca3af;
        }
        
        .metric-label {
            font-size: 0.9em;
            color: #6b7280;
            margin-top: 10px;
        }
        
        .section {
            background: white;
            padding: 25px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        
        .section h2 {
            color: #667eea;
            margin-bottom: 15px;
            padding-bottom: 10px;
            border-bottom: 2px solid #e5e7eb;
        }
        
        .test-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        
        .test-table th {
            background-color: #f3f4f6;
            padding: 12px;
            text-align: left;
            font-weight: 600;
            border-bottom: 2px solid #e5e7eb;
        }
        
        .test-table td {
            padding: 12px;
            border-bottom: 1px solid #e5e7eb;
        }
        
        .test-table tr:hover {
            background-color: #f9fafb;
        }
        
        .status-badge-sm {
            display: inline-block;
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 0.85em;
            font-weight: 600;
        }
        
        .status-badge-sm.pass {
            background-color: #dcfce7;
            color: #166534;
        }
        
        .status-badge-sm.fail {
            background-color: #fee2e2;
            color: #991b1b;
        }
        
        .status-badge-sm.skip {
            background-color: #f3f4f6;
            color: #6b7280;
        }
        
        .footer {
            background: #f3f4f6;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            color: #6b7280;
            margin-top: 30px;
            font-size: 0.9em;
        }
        
        .progress-bar {
            width: 100%;
            height: 20px;
            background-color: #e5e7eb;
            border-radius: 4px;
            overflow: hidden;
            margin-top: 10px;
        }
        
        .progress-fill {
            height: 100%;
            background-color: #22c55e;
            transition: width 0.3s ease;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 0.85em;
            font-weight: 600;
        }
        
        .highlight {
            background-color: #fef3c7;
            padding: 2px 6px;
            border-radius: 3px;
            font-weight: 500;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Test Results Report</h1>
            <p>Windows Safety Jump Box - Comprehensive Test Suite</p>
            <div class="status-badge">
                Overall Status: <span style="text-transform: uppercase;">$overallStatus</span>
            </div>
            <p style="margin-top: 15px;">Generated: $timestamp</p>
        </div>
        
        <div class="metrics">
            <div class="metric-card success">
                <div class="metric-value">${$($ConsolidatedResults.ConsolidatedMetrics.TotalPassed)}</div>
                <div class="metric-label">Tests Passed</div>
            </div>
            <div class="metric-card failure">
                <div class="metric-value">${$($ConsolidatedResults.ConsolidatedMetrics.TotalFailed)}</div>
                <div class="metric-label">Tests Failed</div>
            </div>
            <div class="metric-card skip">
                <div class="metric-value">${$($ConsolidatedResults.ConsolidatedMetrics.TotalSkipped)}</div>
                <div class="metric-label">Tests Skipped</div>
            </div>
            <div class="metric-card">
                <div class="metric-value">${$($ConsolidatedResults.ConsolidatedMetrics.OverallPassRate)}%</div>
                <div class="metric-label">Pass Rate</div>
            </div>
        </div>
        
        <div class="section">
            <h2>Overall Progress</h2>
            <div class="progress-bar">
                <div class="progress-fill" style="width: $($ConsolidatedResults.ConsolidatedMetrics.OverallPassRate)%">
                    $($ConsolidatedResults.ConsolidatedMetrics.OverallPassRate)%
                </div>
            </div>
        </div>
"@
    
    # Add test suite results
    foreach ($suite in $ConsolidatedResults.TestSuites) {
        if ($suite -ne $null) {
            $suitePassRate = if ($suite.Summary.TotalTests -gt 0) {
                [math]::Round(($suite.Summary.Passed / $suite.Summary.TotalTests) * 100, 2)
            } else { 0 }
            
            $suiteStatus = if ($suite.Summary.Failed -eq 0) { "PASSED" } else { "FAILED" }
            $suiteStatusBadge = if ($suiteStatus -eq "PASSED") { "pass" } else { "fail" }
            
            $html += @"
        <div class="section">
            <h2>${$($suite.TestSuite)}</h2>
            <div class="test-table">
                <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px;">
                    <div>
                        <strong>Total:</strong> $($suite.Summary.TotalTests)
                    </div>
                    <div>
                        <strong>Passed:</strong> <span class="highlight">$($suite.Summary.Passed)</span>
                    </div>
                    <div>
                        <strong>Failed:</strong> <span class="highlight">$($suite.Summary.Failed)</span>
                    </div>
                </div>
            </div>
            <div class="progress-bar" style="margin-top: 15px;">
                <div class="progress-fill" style="width: $suitePassRate%">
                    $suitePassRate%
                </div>
            </div>
        </div>
"@
        }
    }
    
    $html += @"
        <div class="footer">
            <p>Report generated by Windows Safety Jump Box Test Suite</p>
            <p>For more information, see: <code>tests/reports/</code></p>
        </div>
    </div>
</body>
</html>
"@
    
    $html | Set-Content -Path $OutputPath -Encoding UTF8
}

# Main execution
Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║       Windows Safety Jump Box - Master Test Suite Runner       ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

$testSuites = @(
    @{
        Name = "Syntax"
        DisplayName = "Script Syntax Validation"
        Script = "Test-Scripts-Syntax.ps1"
        Report = "syntax-results.json"
        Enabled = $TestFilter -contains "All" -or $TestFilter -contains "Syntax"
    },
    @{
        Name = "CIS"
        DisplayName = "CIS Hardening Validation"
        Script = "Test-CIS-Hardening.ps1"
        Report = "cis-hardening-results.json"
        Enabled = $TestFilter -contains "All" -or $TestFilter -contains "CIS"
    },
    @{
        Name = "Deployment"
        DisplayName = "Deployment Scripts Validation"
        Script = "Test-Deployment-Scripts.ps1"
        Report = "deployment-results.json"
        Enabled = $TestFilter -contains "All" -or $TestFilter -contains "Deployment"
    },
    @{
        Name = "Compliance"
        DisplayName = "Compliance Validation"
        Script = "Test-Compliance.ps1"
        Report = "compliance-results.json"
        Enabled = $TestFilter -contains "All" -or $TestFilter -contains "Compliance"
    },
    @{
        Name = "Integration"
        DisplayName = "Integration Testing"
        Script = "Test-Integration.ps1"
        Report = "integration-results.json"
        Enabled = $TestFilter -contains "All" -or $TestFilter -contains "Integration"
    }
)

$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

foreach ($suite in $testSuites) {
    if ($suite.Enabled) {
        $result = Invoke-TestSuite -ScriptName $suite.Script -DisplayName $suite.DisplayName -ReportFile $suite.Report
        
        if ($result) {
            $consolidatedResults.TestSuites += $result
            $consolidatedResults.TotalSuites++
            
            $consolidatedResults.ConsolidatedMetrics.TotalTests += $result.Summary.TotalTests
            $consolidatedResults.ConsolidatedMetrics.TotalPassed += $result.Summary.Passed
            $consolidatedResults.ConsolidatedMetrics.TotalFailed += $result.Summary.Failed
            $consolidatedResults.ConsolidatedMetrics.TotalSkipped += $result.Summary.Skipped
            
            if ($result.Summary.Failed -eq 0) {
                $consolidatedResults.PassedSuites++
            }
            else {
                $consolidatedResults.FailedSuites++
            }
        }
        else {
            $consolidatedResults.SkippedSuites++
        }
    }
}

$stopwatch.Stop()

# Calculate overall metrics
if ($consolidatedResults.ConsolidatedMetrics.TotalTests -gt 0) {
    $consolidatedResults.ConsolidatedMetrics.OverallPassRate = [math]::Round(
        ($consolidatedResults.ConsolidatedMetrics.TotalPassed / 
         ($consolidatedResults.ConsolidatedMetrics.TotalTests - $consolidatedResults.ConsolidatedMetrics.TotalSkipped)) * 100, 2
    )
}

$consolidatedResults.ExecutionEnded = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$consolidatedResults.OverallStatus = if ($consolidatedResults.FailedSuites -eq 0) { "PASSED" } else { "FAILED" }

# Save consolidated report
$consolidatedReportPath = Join-Path $ReportPath "test-results.json"
try {
    $consolidatedResults | ConvertTo-Json -Depth 10 | Set-Content -Path $consolidatedReportPath
    Write-TestResult "Consolidated report saved to: $consolidatedReportPath" "PASS"
}
catch {
    Write-TestResult "Failed to save consolidated report: $_" "FAIL"
}

# Generate HTML report
if ($GenerateHTML) {
    $htmlPath = Join-Path $ReportPath "test-results.html"
    try {
        New-HTMLReport -ConsolidatedResults $consolidatedResults -OutputPath $htmlPath
        Write-TestResult "HTML report generated: $htmlPath" "PASS"
    }
    catch {
        Write-TestResult "Failed to generate HTML report: $_" "FAIL"
    }
}

# Display summary
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                   MASTER TEST SUMMARY                         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "Test Suites Executed:  $($consolidatedResults.TotalSuites)" -ForegroundColor Cyan
Write-Host "Passed:                $($consolidatedResults.PassedSuites)" -ForegroundColor Green
Write-Host "Failed:                $($consolidatedResults.FailedSuites)" -ForegroundColor Red
Write-Host "Skipped:               $($consolidatedResults.SkippedSuites)" -ForegroundColor Gray
Write-Host ""

Write-Host "Consolidated Metrics:" -ForegroundColor Cyan
Write-Host "  Total Tests:         $($consolidatedResults.ConsolidatedMetrics.TotalTests)" -ForegroundColor Cyan
Write-Host "  Passed:              $($consolidatedResults.ConsolidatedMetrics.TotalPassed)" -ForegroundColor Green
Write-Host "  Failed:              $($consolidatedResults.ConsolidatedMetrics.TotalFailed)" -ForegroundColor Red
Write-Host "  Skipped:             $($consolidatedResults.ConsolidatedMetrics.TotalSkipped)" -ForegroundColor Gray
Write-Host "  Overall Pass Rate:   $($consolidatedResults.ConsolidatedMetrics.OverallPassRate)%" -ForegroundColor Cyan
Write-Host ""

Write-Host "Execution Time:        $($stopwatch.ElapsedMilliseconds)ms" -ForegroundColor Cyan
Write-Host "Overall Status:        $($consolidatedResults.OverallStatus)" -ForegroundColor $(if ($consolidatedResults.OverallStatus -eq "PASSED") { "Green" } else { "Red" })
Write-Host ""

Write-Host "Report Locations:" -ForegroundColor Cyan
Write-Host "  JSON:                $consolidatedReportPath" -ForegroundColor White
if ($GenerateHTML) {
    Write-Host "  HTML:                $(Join-Path $ReportPath 'test-results.html')" -ForegroundColor White
}
Write-Host ""

# Exit with appropriate code
$exitCode = $consolidatedResults.FailedSuites
Write-TestResult "Master test suite execution completed with exit code: $exitCode" $(if ($exitCode -eq 0) { "PASS" } else { "FAIL" })

Write-Host ""
exit $exitCode

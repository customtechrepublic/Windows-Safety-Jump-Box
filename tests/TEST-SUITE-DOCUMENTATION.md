# Windows Safety Jump Box - Test Suite Documentation

## Overview

This document provides comprehensive documentation for the Windows Safety Jump Box test suite, a production-grade PowerShell testing framework designed to validate security hardening scripts, deployment automation, and compliance standards.

## Test Suite Architecture

```
tests/
├── Run-All-Tests.ps1                    # Master test runner
├── Test-Scripts-Syntax.ps1              # PowerShell syntax validation
├── Test-CIS-Hardening.ps1               # CIS hardening unit tests
├── Test-Deployment-Scripts.ps1          # Deployment script validation
├── Test-Compliance.ps1                  # Compliance & security standards
├── Test-Integration.ps1                 # Full pipeline integration tests
├── data/                                # Test data & mock files
└── reports/                             # Test results & reports
    ├── test-results.json                # Consolidated JSON report
    ├── test-results.html                # HTML report
    ├── syntax-results.json              # Syntax test results
    ├── cis-hardening-results.json       # CIS hardening test results
    ├── deployment-results.json          # Deployment test results
    ├── compliance-results.json          # Compliance test results
    └── integration-results.json         # Integration test results
```

## Test Files Description

### 1. Test-Scripts-Syntax.ps1

**Purpose**: Validates all PowerShell scripts for syntax correctness and production readiness.

**Key Features**:
- Syntax parsing validation using PowerShell Parser
- Detects non-ASCII characters (emoji) in scripts
- Identifies placeholder values and TODO comments
- Validates function definitions
- Generates JSON report with detailed results

**Test Coverage**:
- PowerShell syntax correctness
- Non-ASCII character detection
- Placeholder/TODO identification
- Function definition validation
- AST (Abstract Syntax Tree) analysis

**Usage**:
```powershell
# Run syntax validation
.\Test-Scripts-Syntax.ps1

# Run with custom report path
.\Test-Scripts-Syntax.ps1 -ReportPath "C:\reports\syntax.json"
```

**Sample Output**:
```
[HH:mm:ss] [INFO] Found 47 PowerShell scripts to validate
[HH:mm:ss] [PASS] Deploy-Image.ps1 - Syntax Valid
[HH:mm:ss] [WARN] audit-scripts.ps1 - Warnings Found
  ⚠️  Contains non-ASCII characters (possible emoji)
```

### 2. Test-CIS-Hardening.ps1

**Purpose**: Unit tests for CIS hardening scripts including function validation, service checks, and audit policies.

**Key Features**:
- Function definition validation
- Critical service availability checks
- Service startup type verification
- Registry path format validation
- Audit policy name validation
- Parameter block validation

**Test Coverage**:
- Write-Log, Get-LogPath, Test-Administrator functions
- RpcSs, LanmanServer, LanmanWorkstation services
- Critical services NOT disabled checks
- Registry paths for hardening
- Valid audit policy names
- Script parameter definitions

**Usage**:
```powershell
# Run CIS hardening tests
.\Test-CIS-Hardening.ps1

# Skip service validation (for non-production environments)
.\Test-CIS-Hardening.ps1 -SkipServiceCheck $true

# Custom report path
.\Test-CIS-Hardening.ps1 -ReportPath "C:\reports\cis.json"
```

**Sample Output**:
```
[HH:mm:ss] [PASS] Write-Log found in CIS_Level2_Mandatory.ps1
[HH:mm:ss] [PASS] Remote Procedure Call service available
[HH:mm:ss] [FAIL] Remote Procedure Call service NOT found
[HH:mm:ss] [PASS] Registry path valid: HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer
```

### 3. Test-Deployment-Scripts.ps1

**Purpose**: Validates deployment scripts for correct function signatures, parameter validation, and system requirements.

**Key Features**:
- Function signature validation
- Parameter block verification
- Error handling detection
- Parameter validation checks
- DISM availability verification
- WIM format support validation
- BitLocker prerequisite checks
- Windows PE compatibility

**Test Coverage**:
- Deploy-Image, Enable-BitLocker, Create-Windows-PE functions
- Script parameters (ImagePath, TargetDisk, etc.)
- Try-catch error handling
- Parameter validation patterns
- System requirement validation

**Usage**:
```powershell
# Run deployment validation
.\Test-Deployment-Scripts.ps1

# Skip DISM availability check
.\Test-Deployment-Scripts.ps1 -SkipDISMCheck $true
```

**Sample Output**:
```
[HH:mm:ss] [PASS] Deploy-Image.ps1 has parameter block
[HH:mm:ss] [PASS] Deploy-Image.ps1 has error handling
[HH:mm:ss] [PASS] Function 'Deploy-Image' found in Deploy-Image.ps1
[HH:mm:ss] [PASS] DISM is available and functional
```

### 4. Test-Compliance.ps1

**Purpose**: Validates compliance with security standards including CIS Benchmark v2.0 and NIST CSF mapping.

**Key Features**:
- CIS Benchmark v2.0 compliance checking
- BitLocker configuration validation
- Deprecated/dangerous function detection
- ASR (Attack Surface Reduction) rules validation
- Event logging verification
- Credential protection checks
- NIST CSF mapping

**Test Coverage**:
- No deprecated functions (Invoke-Expression, Get-WmiObject)
- BitLocker TPM protection configuration
- CIS control mapping
- ASR rules configuration
- Audit logging implementation
- Secure credential handling

**Usage**:
```powershell
# Run compliance validation
.\Test-Compliance.ps1

# Custom report path
.\Test-Compliance.ps1 -ReportPath "C:\reports\compliance.json"
```

**Sample Output**:
```
[HH:mm:ss] [PASS] Deploy-Image.ps1 - No deprecated functions
[HH:mm:ss] [PASS] Enable-BitLocker.ps1 - BitLocker configuration valid
[HH:mm:ss] [PASS] CIS_Tier_2_Hardening.ps1 - CIS Benchmark compliant
[HH:mm:ss] [PASS] CIS_Tier_2_Hardening.ps1 - ASR rules configured
```

### 5. Test-Integration.ps1

**Purpose**: Full pipeline integration tests validating complete deployment scenarios.

**Key Features**:
- Image capture and validation
- Full deployment pipeline testing
- Rollback procedure validation
- Image format conversion testing (WIM, VHDX, ISO)
- Forensics boot media creation validation
- Image versioning validation
- Pipeline consistency checking

**Test Scenarios**:
1. **Image Validation**: Capture and validation process
2. **Deployment Pipeline**: Full Prepare → Capture → Deploy → Hardening
3. **Rollback Procedure**: Registry backup and restore
4. **Format Conversions**: WIM ↔ VHDX, WIM → ISO
5. **Forensics Boot Media**: PE + forensics tools ISO creation
6. **Image Versioning**: Metadata and build tracking
7. **Pipeline Consistency**: Cross-component artifact integrity

**Usage**:
```powershell
# Run integration tests
.\Test-Integration.ps1

# Custom report path
.\Test-Integration.ps1 -ReportPath "C:\reports\integration.json"
```

**Sample Output**:
```
[HH:mm:ss] [START] Starting Integration Tests...
[HH:mm:ss] [PASS] Image validation passed (245ms)
[HH:mm:ss] [PASS] Deployment pipeline validated (1023ms)
[HH:mm:ss] [PASS] Rollback procedure validated (456ms)
[HH:mm:ss] [PASS] WIM → VHDX conversion validated
[HH:mm:ss] [PASS] Forensics boot media creation validated (892ms)
```

### 6. Run-All-Tests.ps1

**Purpose**: Master test runner that executes all test suites and generates consolidated reports.

**Features**:
- Execute selective test suites or all tests
- Consolidate results from all test suites
- Generate JSON and HTML reports
- Calculate overall metrics and pass rates
- Color-coded console output
- Exit codes based on test results

**Test Filtering**:
```powershell
# Run all tests
.\Run-All-Tests.ps1

# Run specific tests
.\Run-All-Tests.ps1 -TestFilter "Syntax", "CIS"

# Skip HTML report generation
.\Run-All-Tests.ps1 -GenerateHTML $false
```

**Exit Codes**:
- `0` = All test suites passed
- `1+` = Number of failed test suites

**Sample Output**:
```
Test Suites Executed:  5
Passed:                4
Failed:                1
Skipped:               0

Consolidated Metrics:
  Total Tests:         124
  Passed:              117
  Failed:              7
  Skipped:             0
  Overall Pass Rate:   94.36%
```

## Report Formats

### JSON Report Structure

```json
{
  "TestSuite": "Script Syntax Validation",
  "Timestamp": "2024-04-20 14:30:45",
  "TotalScripts": 47,
  "PassedScripts": 45,
  "FailedScripts": 2,
  "WarningScripts": 3,
  "Scripts": [
    {
      "FilePath": "/path/to/script.ps1",
      "FileName": "script.ps1",
      "Status": "PASS",
      "Errors": [],
      "Warnings": []
    }
  ],
  "Summary": {
    "TotalScripts": 47,
    "Passed": 45,
    "Failed": 2,
    "Warnings": 3,
    "PassRate": 97.87
  }
}
```

### HTML Report Features

- Executive summary with overall status
- Consolidated metrics dashboard
- Pass rate visualization
- Per-test-suite detailed results
- Progress bars and status indicators
- Responsive design for all devices
- Color-coded status badges

## Running Tests

### Basic Usage

```powershell
# Navigate to tests directory
cd C:\path\to\Windows-Safety-Jump-Box\tests

# Run all tests
.\Run-All-Tests.ps1

# View consolidated report
.\Run-All-Tests.ps1 | Out-Host

# Open HTML report in browser
Invoke-Item .\reports\test-results.html
```

### Running Individual Tests

```powershell
# Syntax validation only
.\Test-Scripts-Syntax.ps1

# CIS hardening validation only
.\Test-CIS-Hardening.ps1

# Deployment validation only
.\Test-Deployment-Scripts.ps1

# Compliance validation only
.\Test-Compliance.ps1

# Integration tests only
.\Test-Integration.ps1
```

### Advanced Usage

```powershell
# Run with detailed output and custom report path
$reportPath = "C:\custom\reports"
.\Run-All-Tests.ps1 -ReportPath $reportPath -GenerateHTML $true

# Run specific test suites only
.\Run-All-Tests.ps1 -TestFilter "Syntax", "CIS", "Deployment"

# Run and check exit code
.\Run-All-Tests.ps1
if ($LASTEXITCODE -eq 0) {
    Write-Host "All tests passed!"
} else {
    Write-Host "Tests failed: $LASTEXITCODE suite(s) failed"
}
```

## Test Data & Mock Files

Test data is located in `tests/data/`:

```
data/
├── mock-registry/           # Mock registry snapshots
├── mock-images/             # Sample image metadata
├── mock-deployments/        # Deployment scenario data
└── mock-services/           # Service state snapshots
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Test Suite

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-2022
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: .\tests\Run-All-Tests.ps1
      - name: Upload reports
        if: always()
        uses: actions/upload-artifact@v2
        with:
          name: test-reports
          path: tests/reports/
      - name: Check exit code
        run: exit $LASTEXITCODE
```

### Azure Pipelines Example

```yaml
trigger:
  - main

pool:
  vmImage: 'windows-2022'

steps:
- task: PowerShell@2
  inputs:
    targetType: 'filePath'
    filePath: '$(Build.SourcesDirectory)\tests\Run-All-Tests.ps1'
    workingDirectory: '$(Build.SourcesDirectory)\tests'

- task: PublishBuildArtifacts@1
  inputs:
    PathtoPublish: '$(Build.SourcesDirectory)\tests\reports'
    ArtifactName: 'test-reports'
```

## Best Practices

### Test Development

1. **Non-Destructive Tests**: All tests must use mocks and not modify system state
2. **Clear Naming**: Use pattern `Test-<Component>-<Scenario>`
3. **Error Handling**: Always use try-catch blocks
4. **Logging**: Log all test steps for debugging
5. **Documentation**: Include inline comments explaining test logic

### Test Execution

1. **Run Before Deployment**: Execute full test suite before production deployment
2. **Monitor Results**: Check both JSON and HTML reports
3. **Review Failures**: Investigate and fix failures before proceeding
4. **Track Metrics**: Monitor pass rates over time for trend analysis
5. **CI/CD Integration**: Automate test execution in deployment pipeline

### Maintenance

1. **Update Tests**: Keep tests synchronized with script changes
2. **Add Coverage**: Create tests for new features
3. **Mock Data**: Maintain mock data and test fixtures
4. **Documentation**: Update documentation with test changes
5. **Versioning**: Track test suite versions alongside scripts

## Troubleshooting

### Common Issues

**Issue**: Script execution policy prevents running tests
```powershell
# Solution: Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Issue**: Missing DISM or system requirements
```powershell
# Solution: Skip system requirement checks
.\Test-Deployment-Scripts.ps1 -SkipDISMCheck $true
```

**Issue**: Non-ASCII character warnings
```powershell
# Solution: Check and remove emoji from scripts
Get-Content script.ps1 | Select-String '[^\x00-\x7F]'
```

**Issue**: Registry access denied in tests
```powershell
# Solution: Run tests as Administrator
# Right-click PowerShell and select "Run as Administrator"
```

## Performance Metrics

Expected test execution times:

- **Syntax Tests**: ~2-5 seconds (47 scripts)
- **CIS Tests**: ~5-10 seconds (20+ unit tests)
- **Deployment Tests**: ~3-8 seconds (15+ tests)
- **Compliance Tests**: ~5-15 seconds (30+ tests)
- **Integration Tests**: ~10-20 seconds (7 scenarios)
- **Full Suite**: ~30-60 seconds total

## Support & Resources

- **CIS Benchmark**: https://www.cisecurity.org/cis-benchmarks/
- **NIST CSF**: https://www.nist.gov/cyberframework
- **PowerShell Documentation**: https://docs.microsoft.com/powershell/
- **GitHub Issues**: Report issues with test suite

## Version History

### Version 1.0 (Current)
- Initial test suite release
- 5 comprehensive test suites
- JSON and HTML reporting
- CIS Benchmark v2.0 mapping
- NIST CSF compliance checking

## Contributing

To contribute improvements to the test suite:

1. Create a new branch
2. Add or modify test cases
3. Update documentation
4. Run full test suite locally
5. Submit pull request with description

---

**Last Updated**: April 20, 2024  
**Version**: 1.0  
**Maintainer**: Windows Safety Jump Box Team

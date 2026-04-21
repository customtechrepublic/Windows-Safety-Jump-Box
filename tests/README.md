# Windows Safety Jump Box - Test Suite

Comprehensive PowerShell test suite for validating security hardening scripts, deployment automation, and compliance standards.

## 📋 Test Suite Overview

This test suite provides production-grade testing for:

- **Syntax Validation**: All PowerShell scripts validated for correctness
- **CIS Hardening**: Unit tests for CIS Benchmark compliance controls
- **Deployment Scripts**: Function signatures, parameters, and system requirements
- **Compliance**: Security standards including CIS Benchmark v2.0 and NIST CSF
- **Integration**: Full pipeline scenarios including capture, deploy, and rollback

## 🚀 Quick Start

```powershell
# Navigate to tests directory
cd tests

# Run all tests
.\Run-All-Tests.ps1

# View HTML report
Invoke-Item .\reports\test-results.html
```

## 📁 Directory Structure

```
tests/
├── Run-All-Tests.ps1                 # Master test runner
├── Test-Scripts-Syntax.ps1           # Syntax validation (47 scripts)
├── Test-CIS-Hardening.ps1            # CIS hardening unit tests
├── Test-Deployment-Scripts.ps1       # Deployment validation
├── Test-Compliance.ps1               # Compliance & security standards
├── Test-Integration.ps1              # Full pipeline integration tests
├── QUICK-START.md                    # 5-minute quick start guide
├── TEST-SUITE-DOCUMENTATION.md       # Complete reference documentation
├── data/                             # Test data & mock files
└── reports/                          # Generated test reports
    ├── test-results.json             # Consolidated results
    ├── test-results.html             # Visual dashboard
    ├── syntax-results.json
    ├── cis-hardening-results.json
    ├── deployment-results.json
    ├── compliance-results.json
    └── integration-results.json
```

## 📊 Test Suites

### 1. **Test-Scripts-Syntax.ps1**
Validates all PowerShell scripts in the repository.

**Tests**:
- PowerShell syntax parsing
- Non-ASCII character detection
- Placeholder value identification
- Function definition validation

**Run**:
```powershell
.\Test-Scripts-Syntax.ps1
```

### 2. **Test-CIS-Hardening.ps1**
Unit tests for CIS hardening implementation.

**Tests**:
- Required function definitions
- Critical service availability
- Registry path formats
- Audit policy names

**Run**:
```powershell
.\Test-CIS-Hardening.ps1
```

### 3. **Test-Deployment-Scripts.ps1**
Validates deployment script readiness.

**Tests**:
- Function signatures
- Parameter validation
- Error handling
- DISM and BitLocker availability

**Run**:
```powershell
.\Test-Deployment-Scripts.ps1
```

### 4. **Test-Compliance.ps1**
Security compliance validation.

**Tests**:
- CIS Benchmark v2.0 compliance
- BitLocker configuration
- Deprecated function detection
- ASR rules configuration
- Event logging implementation
- Credential protection

**Run**:
```powershell
.\Test-Compliance.ps1
```

### 5. **Test-Integration.ps1**
Full pipeline integration scenarios.

**Tests**:
- Image capture & validation
- Complete deployment pipeline
- Rollback procedures
- Image format conversions
- Forensics boot media creation
- Pipeline consistency

**Run**:
```powershell
.\Test-Integration.ps1
```

### 6. **Run-All-Tests.ps1**
Master test runner executing all suites.

**Features**:
- Execute all or selected test suites
- Consolidate results from all tests
- Generate JSON and HTML reports
- Calculate overall metrics
- Exit code based on results (0=pass, 1+=failures)

**Run**:
```powershell
# All tests
.\Run-All-Tests.ps1

# Specific tests
.\Run-All-Tests.ps1 -TestFilter "Syntax", "CIS"

# Skip HTML report
.\Run-All-Tests.ps1 -GenerateHTML $false
```

## 📈 Test Coverage

| Component | Tests | Status |
|-----------|-------|--------|
| Syntax Validation | 47+ | Comprehensive |
| CIS Hardening | 20+ | Comprehensive |
| Deployment Scripts | 15+ | Comprehensive |
| Compliance | 30+ | Comprehensive |
| Integration | 7 | Comprehensive |
| **Total** | **120+** | **Comprehensive** |

## 📊 Reports

### JSON Report Format
```json
{
  "TestSuite": "Script Syntax Validation",
  "Timestamp": "2024-04-20 14:30:45",
  "TotalTests": 47,
  "PassedTests": 45,
  "FailedTests": 0,
  "Summary": {
    "PassRate": 100.0
  }
}
```

### HTML Report Features
- Executive summary with overall status
- Metrics dashboard with KPIs
- Per-test-suite detailed results
- Progress bars and visualizations
- Color-coded status badges
- Responsive design

## ✅ Test Requirements

- Windows 10/11 Pro or Server 2019/2022
- PowerShell 5.1 or later
- Administrator access (recommended)
- No system modifications during testing
- Uses mocks and snapshots only

## 🎯 Test Execution Options

### Run All Tests
```powershell
.\Run-All-Tests.ps1
```
Exit code: 0 (pass) or 1+ (failures)

### Run Individual Test Suite
```powershell
# Syntax only
.\Test-Scripts-Syntax.ps1

# CIS only
.\Test-CIS-Hardening.ps1

# Deployment only
.\Test-Deployment-Scripts.ps1

# Compliance only
.\Test-Compliance.ps1

# Integration only
.\Test-Integration.ps1
```

### Custom Report Path
```powershell
.\Run-All-Tests.ps1 -ReportPath "C:\custom\reports"
```

### Selective Test Execution
```powershell
# Run Syntax and CIS tests only
.\Run-All-Tests.ps1 -TestFilter "Syntax", "CIS"

# Run Compliance only
.\Run-All-Tests.ps1 -TestFilter "Compliance"
```

## 📋 Status Output

### Console Output Color Codes
```
[HH:mm:ss] [PASS] Test passed successfully      ✓ Green
[HH:mm:ss] [FAIL] Test failed                    ✗ Red
[HH:mm:ss] [WARN] Test passed with warnings      ⚠ Yellow
[HH:mm:ss] [SKIP] Test skipped                   - Gray
[HH:mm:ss] [INFO] Information message            ℹ Cyan
```

### Exit Codes
- **0**: All tests passed
- **1**: One test suite failed
- **2+**: Multiple test suites failed

## 🔍 Sample Test Output

```
╔════════════════════════════════════════════════════════════════╗
║       Windows Safety Jump Box - Master Test Suite Runner       ║
╚════════════════════════════════════════════════════════════════╝

[14:30:45] [START] Starting Syntax Validation test suite...
[14:30:46] [PASS] Found 47 PowerShell scripts to validate
[14:30:47] [PASS] Deploy-Image.ps1 - Syntax Valid
[14:30:48] [DONE] Syntax Validation test suite completed

Test Suites Executed:  5
Passed:                5
Failed:                0

Consolidated Metrics:
  Total Tests:         124
  Passed:              124
  Failed:              0
  Overall Pass Rate:   100%

Overall Status: PASSED ✓
```

## 🔧 Common Usage Scenarios

### Pre-Deployment Validation
```powershell
# Validate all scripts before deployment
.\Run-All-Tests.ps1
if ($LASTEXITCODE -eq 0) {
    Write-Host "Ready for deployment"
} else {
    Write-Host "Fix issues before deploying"
}
```

### CI/CD Pipeline
```powershell
# Run in build pipeline
& ".\Run-All-Tests.ps1" -GenerateHTML $true
$report = Get-Content .\reports\test-results.json | ConvertFrom-Json

if ($report.ConsolidatedMetrics.TotalFailed -gt 0) {
    exit 1
}
exit 0
```

### Continuous Monitoring
```powershell
# Scheduled test execution
$trigger = New-ScheduledTaskTrigger -Daily -At 3:00AM
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-File tests\Run-All-Tests.ps1"
Register-ScheduledTask -TaskName "SJB-Tests" -Trigger $trigger -Action $action
```

## 📚 Documentation

- **QUICK-START.md** - 5-minute quick start guide
- **TEST-SUITE-DOCUMENTATION.md** - Complete reference documentation
- **README.md** - Main repository documentation

## 🐛 Troubleshooting

### Script Execution Policy Error
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### DISM Not Found
```powershell
.\Test-Deployment-Scripts.ps1 -SkipDISMCheck $true
```

### Permission Denied
```powershell
# Run PowerShell as Administrator
# Right-click → Run as Administrator
```

### Report Generation Failed
```powershell
# Check reports directory exists and is writable
New-Item -ItemType Directory -Path "tests\reports" -Force
```

## 📈 Performance

Expected execution times:
- **Syntax Tests**: 2-5 seconds
- **CIS Tests**: 5-10 seconds
- **Deployment Tests**: 3-8 seconds
- **Compliance Tests**: 5-15 seconds
- **Integration Tests**: 10-20 seconds
- **Full Suite**: 30-60 seconds total

## 🔐 Security & Non-Destructive Testing

✓ All tests are **non-destructive**  
✓ No system modifications  
✓ Uses mocks and snapshots only  
✓ Safe to run on production systems  
✓ No credentials or sensitive data in reports  

## 🤝 Contributing

To improve the test suite:

1. Create a new branch
2. Add or modify test cases
3. Update documentation
4. Run full test suite locally
5. Submit pull request

## 📞 Support

- Check test output for specific errors
- Review test files for implementation details
- See troubleshooting section above
- Consult full documentation for advanced usage

## 📝 Version

**Test Suite Version**: 1.0  
**Last Updated**: April 20, 2024  
**Status**: Production Ready

---

**Ready to test?**
```powershell
cd tests
.\Run-All-Tests.ps1
```

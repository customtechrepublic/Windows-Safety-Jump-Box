# Test Suite Quick Start Guide

## 5-Minute Setup

### Prerequisites
- Windows 10/11 Pro or Windows Server 2019/2022
- PowerShell 5.1 or later
- Administrator access (recommended for full testing)

### Quick Start

```powershell
# 1. Navigate to tests directory
cd "C:\path\to\Windows-Safety-Jump-Box\tests"

# 2. Allow script execution (if needed)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 3. Run all tests
.\Run-All-Tests.ps1

# 4. View HTML report
Invoke-Item .\reports\test-results.html
```

## Command Reference

### Run All Tests
```powershell
.\Run-All-Tests.ps1
```
Executes all test suites and generates consolidated reports. Exit code 0 = pass, 1+ = failures.

### Run Specific Tests
```powershell
# Syntax tests only
.\Test-Scripts-Syntax.ps1

# CIS hardening tests only
.\Test-CIS-Hardening.ps1

# Deployment tests only
.\Test-Deployment-Scripts.ps1

# Compliance tests only
.\Test-Compliance.ps1

# Integration tests only
.\Test-Integration.ps1
```

### Custom Report Location
```powershell
.\Run-All-Tests.ps1 -ReportPath "C:\custom\path"
```

### Selective Test Execution
```powershell
# Run only syntax and CIS tests
.\Run-All-Tests.ps1 -TestFilter "Syntax", "CIS"

# Run only compliance tests
.\Run-All-Tests.ps1 -TestFilter "Compliance"
```

### Skip HTML Report
```powershell
.\Run-All-Tests.ps1 -GenerateHTML $false
```

## Understanding Test Results

### Exit Codes
- **0**: All tests passed ✓
- **1**: One test suite failed
- **2+**: Multiple test suites failed

### Console Output
```
[HH:mm:ss] [PASS] Test passed successfully
[HH:mm:ss] [FAIL] Test failed with error
[HH:mm:ss] [WARN] Test passed with warnings
[HH:mm:ss] [SKIP] Test skipped (not applicable)
[HH:mm:ss] [INFO] Informational message
```

### JSON Reports
Located in `tests/reports/`:
- `test-results.json` - Consolidated results
- `syntax-results.json` - Syntax validation results
- `cis-hardening-results.json` - CIS tests results
- `deployment-results.json` - Deployment tests results
- `compliance-results.json` - Compliance tests results
- `integration-results.json` - Integration tests results

### HTML Report
Open `tests/reports/test-results.html` in a web browser for visual dashboard.

## What Gets Tested

### Syntax Validation (Test-Scripts-Syntax.ps1)
✓ PowerShell syntax correctness  
✓ Non-ASCII character detection  
✓ Placeholder value identification  
✓ Function definition validation  

### CIS Hardening (Test-CIS-Hardening.ps1)
✓ Function existence (Write-Log, Get-LogPath, etc.)  
✓ Critical services availability  
✓ Registry path formats  
✓ Audit policy names  

### Deployment Scripts (Test-Deployment-Scripts.ps1)
✓ Function signatures  
✓ Parameter blocks  
✓ Error handling  
✓ DISM availability  
✓ BitLocker support  

### Compliance (Test-Compliance.ps1)
✓ CIS Benchmark v2.0 mapping  
✓ BitLocker configuration  
✓ No deprecated functions  
✓ ASR rules configuration  
✓ Event logging  
✓ Credential protection  

### Integration (Test-Integration.ps1)
✓ Image capture & validation  
✓ Deployment pipeline  
✓ Rollback procedures  
✓ Format conversions  
✓ Forensics boot media  
✓ Pipeline consistency  

## Common Scenarios

### Before Deployment
```powershell
# Run full test suite to ensure readiness
.\Run-All-Tests.ps1

# Check if all tests passed
if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ System ready for deployment"
} else {
    Write-Host "✗ Fix failed tests before deploying"
}
```

### Continuous Testing
```powershell
# Schedule periodic test runs (PowerShell Schedule)
$trigger = New-ScheduledTaskTrigger -Daily -At 03:00AM
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File C:\tests\Run-All-Tests.ps1"
Register-ScheduledTask -TaskName "SJB-Tests" -Trigger $trigger -Action $action
```

### Troubleshooting Failed Tests
```powershell
# Run verbose test output
.\Run-All-Tests.ps1 | Tee-Object -FilePath "debug.log"

# Check specific test details
Get-Content .\reports\test-results.json | ConvertFrom-Json | 
    Select-Object -ExpandProperty TestSuites | 
    Where-Object { $_.Summary.Failed -gt 0 }
```

## Interpreting Results

### Perfect Results
```
All Suites Passed: 5/5
Total Tests Passed: 124/124
Overall Pass Rate: 100%
Status: ✓ PASSED
```
→ **Action**: Ready for production deployment

### Some Warnings
```
All Suites Passed: 5/5
Total Tests Passed: 117/124
Warnings Found: 7
Overall Pass Rate: 94.36%
Status: ⚠ PASSED WITH WARNINGS
```
→ **Action**: Review warnings, may proceed with caution

### Test Failures
```
Suites Failed: 1/5
Total Tests Failed: 7/124
Overall Pass Rate: 94.36%
Status: ✗ FAILED
```
→ **Action**: Fix failures before deployment. Check `test-results.html` for details.

## Performance Notes

- Full test suite typically completes in 30-60 seconds
- No system modifications are made during testing
- Safe to run on production systems
- Tests use mocks and snapshots only

## Next Steps

1. **Review Results**: Check HTML report for any issues
2. **Fix Failures**: Address any failed tests
3. **Validate Changes**: Re-run tests after fixes
4. **Document Issues**: Log any systematic problems
5. **Deploy**: Proceed with deployment once all tests pass

## More Information

For detailed documentation, see:
- `TEST-SUITE-DOCUMENTATION.md` - Complete reference
- `tests/reports/test-results.html` - Visual dashboard
- Individual test files for implementation details

---

**Need Help?**
- Check README.md for general information
- Review test output for specific errors
- Check individual test files for test logic
- See troubleshooting section in full documentation

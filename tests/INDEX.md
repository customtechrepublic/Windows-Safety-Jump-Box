# Test Suite Index & Navigation Guide

## 🎯 Where to Start?

### For First-Time Users
1. **Start here**: [`00-START-HERE.md`](00-START-HERE.md) - Complete overview (5 min read)
2. **Quick setup**: [`QUICK-START.md`](QUICK-START.md) - Get running in 5 minutes
3. **Run tests**: `.\Run-All-Tests.ps1` in PowerShell
4. **View results**: Open `reports/test-results.html` in browser

### For Developers & Integration
1. **Technical details**: [`TEST-SUITE-DOCUMENTATION.md`](TEST-SUITE-DOCUMENTATION.md)
2. **Implementation guide**: [`TEST-SUITE-IMPLEMENTATION-SUMMARY.md`](TEST-SUITE-IMPLEMENTATION-SUMMARY.md)
3. **Review tests**: Check individual test scripts
4. **Configuration**: Edit `test-suite.config.ps1` as needed

---

## 📁 File Organization

### Documentation Files

| File | Purpose | Audience | Read Time |
|------|---------|----------|-----------|
| [`00-START-HERE.md`](00-START-HERE.md) | Complete overview & quick start | Everyone | 10 min |
| [`QUICK-START.md`](QUICK-START.md) | 5-minute quick reference | Quick setup | 5 min |
| [`README.md`](README.md) | Test suite overview & usage | Operators | 10 min |
| [`TEST-SUITE-DOCUMENTATION.md`](TEST-SUITE-DOCUMENTATION.md) | Complete technical reference | Developers | 20 min |
| [`TEST-SUITE-IMPLEMENTATION-SUMMARY.md`](TEST-SUITE-IMPLEMENTATION-SUMMARY.md) | Implementation details | Architects | 15 min |

### Test Scripts

| Script | Purpose | Tests | Run Time |
|--------|---------|-------|----------|
| [`Run-All-Tests.ps1`](Run-All-Tests.ps1) | Master test runner | All | 30-60 sec |
| [`Test-Scripts-Syntax.ps1`](Test-Scripts-Syntax.ps1) | Syntax validation | 47+ | 2-5 sec |
| [`Test-CIS-Hardening.ps1`](Test-CIS-Hardening.ps1) | CIS hardening tests | 20+ | 5-10 sec |
| [`Test-Deployment-Scripts.ps1`](Test-Deployment-Scripts.ps1) | Deployment validation | 15+ | 3-8 sec |
| [`Test-Compliance.ps1`](Test-Compliance.ps1) | Compliance validation | 30+ | 5-15 sec |
| [`Test-Integration.ps1`](Test-Integration.ps1) | Integration scenarios | 7 | 10-20 sec |

### Support Files

| File | Purpose |
|------|---------|
| [`test-suite.config.ps1`](test-suite.config.ps1) | Global configuration & settings |
| [`data/mock-test-data.ps1`](data/mock-test-data.ps1) | Mock data definitions |

---

## 🚀 Common Tasks

### Run All Tests
```powershell
.\Run-All-Tests.ps1
```
**Result**: Consolidated JSON and HTML reports

### Run Specific Test Suite
```powershell
# Syntax only
.\Test-Scripts-Syntax.ps1

# CIS hardening only
.\Test-CIS-Hardening.ps1

# Compliance only
.\Test-Compliance.ps1
```

### View Results
```powershell
# Open HTML dashboard
Invoke-Item .\reports\test-results.html

# Check JSON results
Get-Content .\reports\test-results.json | ConvertFrom-Json
```

### Custom Configuration
```powershell
# Edit configuration
notepad test-suite.config.ps1

# Apply custom settings before running tests
$Script:Config.DefaultTimeoutSeconds = 60
```

### Troubleshooting
```powershell
# Run with verbose output
$VerbosePreference = "Continue"
.\Run-All-Tests.ps1

# Check execution policy
Get-ExecutionPolicy -Scope CurrentUser

# Set if needed
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 📊 Reports & Output

### Generated Files

**JSON Reports** (in `reports/`)
```
test-results.json                 # Consolidated all suites
syntax-results.json               # Syntax tests only
cis-hardening-results.json        # CIS tests only
deployment-results.json           # Deployment tests only
compliance-results.json           # Compliance tests only
integration-results.json          # Integration tests only
```

**HTML Reports** (in `reports/`)
```
test-results.html                 # Visual dashboard with metrics
```

### Report Features
- ✓ Consolidated metrics
- ✓ Per-test details
- ✓ Status indicators
- ✓ Performance metrics
- ✓ Pass rate calculations
- ✓ Compliance mappings

---

## 📚 Documentation Map

### Quick References
- **5-minute setup**: [`QUICK-START.md`](QUICK-START.md)
- **Command reference**: [`QUICK-START.md` - Command Reference](QUICK-START.md#command-reference)
- **Troubleshooting**: [`QUICK-START.md` - Troubleshooting](QUICK-START.md#troubleshooting)

### Detailed Guides
- **Test descriptions**: [`TEST-SUITE-DOCUMENTATION.md` - Test Files Description](TEST-SUITE-DOCUMENTATION.md#test-files-description)
- **Running tests**: [`TEST-SUITE-DOCUMENTATION.md` - Running Tests](TEST-SUITE-DOCUMENTATION.md#running-tests)
- **CI/CD integration**: [`TEST-SUITE-DOCUMENTATION.md` - CI/CD Integration](TEST-SUITE-DOCUMENTATION.md#cicd-integration)

### Technical References
- **Report formats**: [`TEST-SUITE-DOCUMENTATION.md` - Report Formats](TEST-SUITE-DOCUMENTATION.md#report-formats)
- **Performance metrics**: [`TEST-SUITE-DOCUMENTATION.md` - Performance Metrics](TEST-SUITE-DOCUMENTATION.md#performance-metrics)
- **Best practices**: [`TEST-SUITE-DOCUMENTATION.md` - Best Practices](TEST-SUITE-DOCUMENTATION.md#best-practices)

---

## 🎯 Test Coverage Summary

### By Component

**Syntax Validation** (47+ tests)
- PowerShell syntax correctness
- Non-ASCII character detection
- Placeholder identification
- Function definitions

**CIS Hardening** (20+ tests)
- Function validation
- Service availability
- Registry configuration
- Audit policies

**Deployment Scripts** (15+ tests)
- Function signatures
- Parameter validation
- Error handling
- System requirements

**Compliance** (30+ tests)
- CIS Benchmark v2.0
- BitLocker configuration
- Deprecated function detection
- ASR rules validation
- Event logging
- Credential protection

**Integration** (7 scenarios)
- Image capture/deployment
- Rollback procedures
- Format conversions
- Forensics capabilities

---

## 🔧 Configuration Options

### Basic Settings
```powershell
# Stop on first failure
$Script:Config.StopOnFirstFailure = $true

# Verbose logging
$Script:Config.VerboseLogging = $true

# Skip HTML reports
$Script:Config.GenerateHTMLReports = $false
```

### Timeouts
```powershell
# Increase default timeout
$Script:Config.DefaultTimeoutSeconds = 60

# Long-running test timeout
$Script:Config.LongRunningTimeoutSeconds = 120
```

### Reporting
```powershell
# Custom report location
$Script:Config.ReportBaseDir = "C:\custom\reports"

# Include performance metrics
$Script:Config.EnablePerformanceMetrics = $true
```

See [`test-suite.config.ps1`](test-suite.config.ps1) for complete options.

---

## 🐛 Troubleshooting Quick Links

| Issue | Solution | Reference |
|-------|----------|-----------|
| Execution policy | Set-ExecutionPolicy | [`QUICK-START.md`](QUICK-START.md#troubleshooting) |
| DISM not found | Skip with -SkipDISMCheck | [`Test-Deployment-Scripts.ps1`](Test-Deployment-Scripts.ps1) |
| Permission denied | Run as Administrator | [`QUICK-START.md`](QUICK-START.md#troubleshooting) |
| Report not generated | Check reports directory | [`README.md`](README.md#troubleshooting) |

---

## 📞 Support Resources

### Quick Help
- **5-minute guide**: Start with [`QUICK-START.md`](QUICK-START.md)
- **Common issues**: See [`README.md` Troubleshooting](README.md#troubleshooting)
- **Test details**: Review [`TEST-SUITE-DOCUMENTATION.md`](TEST-SUITE-DOCUMENTATION.md)

### Getting More Help
1. Check test output for specific error messages
2. Review test file implementation comments
3. Consult documentation for known issues
4. Check troubleshooting sections

---

## 📈 Key Metrics

| Metric | Value |
|--------|-------|
| Test Scripts | 6 |
| Test Cases | 120+ |
| Documentation Files | 5 |
| Total Lines of Code | 3,169 |
| Total Documentation | 1,466 lines |
| Expected Runtime | 30-60 seconds |
| Report Formats | JSON, HTML |

---

## ✅ Checklist for First Run

- [ ] Navigate to `tests/` directory
- [ ] Set execution policy: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- [ ] Run tests: `.\Run-All-Tests.ps1`
- [ ] Wait for completion (30-60 seconds)
- [ ] Check for green output (✓ PASS)
- [ ] Open `reports/test-results.html` in browser
- [ ] Review results and metrics
- [ ] Check exit code: `echo $LASTEXITCODE` (should be 0)

---

## 🎓 Learning Paths

### Beginner (New User)
1. Read [`00-START-HERE.md`](00-START-HERE.md)
2. Follow [`QUICK-START.md`](QUICK-START.md)
3. Run `.\Run-All-Tests.ps1`
4. Review HTML report
5. Done! ✓

### Intermediate (Operator)
1. Review [`README.md`](README.md)
2. Understand test coverage
3. Configure custom settings
4. Schedule regular runs
5. Monitor metrics

### Advanced (Developer)
1. Study [`TEST-SUITE-DOCUMENTATION.md`](TEST-SUITE-DOCUMENTATION.md)
2. Review test implementations
3. Understand mock data structure
4. Add custom tests
5. Integrate with CI/CD

---

## 📝 Version & Status

- **Version**: 1.0
- **Release Date**: April 20, 2024
- **Status**: ✓ Production Ready
- **Files**: 13 total
- **Quality**: ✓ Comprehensive

---

## 🚀 Ready to Start?

### Quick Path (5 minutes)
```powershell
cd tests
.\Run-All-Tests.ps1
Invoke-Item .\reports\test-results.html
```

### Documentation Path
1. Start with [`00-START-HERE.md`](00-START-HERE.md)
2. Then [`QUICK-START.md`](QUICK-START.md)
3. Finally [`README.md`](README.md)

### Technical Path
1. Review [`TEST-SUITE-DOCUMENTATION.md`](TEST-SUITE-DOCUMENTATION.md)
2. Study test implementations
3. Configure [`test-suite.config.ps1`](test-suite.config.ps1)
4. Run custom test combinations

---

**Let's get started!** 🎉

Pick your path above and get testing!

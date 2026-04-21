```
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║                    CONTRIBUTING GUIDE                                    ║
║         How to Contribute to Windows Safety Jump Box                     ║
║                                                                           ║
║              🛡️  CUSTOM PC REPUBLIC  🛡️                                 ║
║         IT Synergy Energy for the Republic                              ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

# Contributing to Windows Safety Jump Box

Thank you for your interest in contributing! This document provides comprehensive guidance for contributing code, documentation, tests, and other improvements to the Windows Safety Jump Box project.

---

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Environment Setup](#development-environment-setup)
- [How to Contribute](#how-to-contribute)
- [Commit Message Format](#commit-message-format)
- [Pull Request Process](#pull-request-process)
- [Code Style & Standards](#code-style--standards)
- [Testing Requirements](#testing-requirements)
- [Security Considerations](#security-considerations)
- [CIS Control Development Guidelines](#cis-control-development-guidelines)
- [Documentation Standards](#documentation-standards)
- [Troubleshooting Contributions](#troubleshooting-contributions)

---

## Code of Conduct

Please review [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) before contributing. We're committed to maintaining a welcoming, respectful, and harassment-free community.

**Key Points:**
- ✅ Be professional and respectful
- ✅ Assume good intentions
- ✅ Accept constructive criticism
- ✅ Focus on shared goals
- ❌ No harassment, discrimination, or personal attacks

**Report violations:** `conduct@custompc.local`

---

## Getting Started

### Prerequisites

Before contributing, ensure you have:

1. **Windows Environment:**
   - Windows 11 Pro/Enterprise OR Windows Server 2022
   - Administrator access on your development machine
   - 16GB RAM minimum (32GB recommended)
   - 100GB free disk space

2. **Software:**
   - PowerShell 5.1 or later (check: `$PSVersionTable.PSVersion`)
   - Git for Windows (https://git-scm.com/download/win)
   - Visual Studio Code (optional but recommended) with:
     - PowerShell extension
     - GitLens extension

3. **Knowledge:**
   - Familiarity with PowerShell scripting
   - Understanding of Windows security concepts
   - Basic knowledge of CIS Benchmarks
   - Git version control basics

### Getting the Code

```powershell
# Clone the repository
git clone https://github.com/customtechrepublic/Windows-Safety-Jump-Box.git
cd Windows-Safety-Jump-Box

# Create a new branch for your work
git checkout -b feature/your-feature-name

# (Or for bug fixes)
git checkout -b fix/issue-description
```

### Fork Workflow (Recommended)

If you don't have write access:

1. **Fork** the repository on GitHub
2. **Clone** your fork: `git clone https://github.com/YOUR-USERNAME/Windows-Safety-Jump-Box.git`
3. **Add upstream:** `git remote add upstream https://github.com/customtechrepublic/Windows-Safety-Jump-Box.git`
4. **Create branch** from your fork

---

## Development Environment Setup

### 1. Create Development VM

```powershell
# Create a test VM (Hyper-V or VMware)
# OS: Windows 11 Enterprise or Server 2022
# RAM: 16GB minimum
# Disk: 100GB
# Network: Connected for package downloads

# Inside VM, enable script execution:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
```

### 2. Install Prerequisites

```powershell
# Install Git
# Download from: https://git-scm.com/download/win

# Install Visual Studio Code (optional)
# Download from: https://code.visualstudio.com/

# Install Windows ADK (if testing image building)
# Download from: https://docs.microsoft.com/en-us/windows-hardware/get-started/adk-install

# Verify PowerShell version
$PSVersionTable.PSVersion  # Should be 5.1 or later
```

### 3. Clone Repository

```powershell
cd C:\Projects  # Or your development directory
git clone https://github.com/YOUR-USERNAME/Windows-Safety-Jump-Box.git
cd Windows-Safety-Jump-Box
```

### 4. Set Git Configuration

```powershell
# Configure git if not already done
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Set line endings to Windows (CRLF)
git config --global core.autocrlf true

# Set core.safecrlf to warn
git config --global core.safecrlf warn
```

### 5. Create Development Branch

```powershell
# Update main branch
git fetch origin
git checkout main
git pull origin main

# Create feature branch
git checkout -b feature/descriptive-name

# OR for bug fixes
git checkout -b fix/issue-number-description
```

---

## How to Contribute

### Contribution Types

#### 1. Bug Fixes

**What counts as a bug:**
- Scripts crash or error unexpectedly
- Hardening settings not applied correctly
- Deployment fails
- Compliance audit fails
- Documentation is incorrect

**How to contribute:**
1. Check if issue already exists
2. Create or find the GitHub issue
3. Create branch: `git checkout -b fix/issue-123-description`
4. Fix the bug with tests
5. Update documentation if needed
6. Submit pull request

#### 2. New Features

**What counts as a feature:**
- New CIS control implementation
- New hardening profile
- New deployment method
- New compliance check
- New utility function

**How to contribute:**
1. Discuss in issues or discussions first
2. Get approval from maintainers
3. Create branch: `git checkout -b feature/new-feature-name`
4. Implement with tests and documentation
5. Submit pull request

#### 3. Security Improvements

**What counts as security improvement:**
- Hardening enhancement
- Vulnerability fix
- Security best practice addition
- Attack surface reduction
- Audit capability enhancement

**How to contribute:**
1. **IMPORTANT:** Report security issues to `security@custompc.local` first
2. Do not create public issues for vulnerabilities
3. Follow responsible disclosure process
4. Once approved, implement and submit PR

**Reference:** See [SECURITY.md](SECURITY.md)

#### 4. Documentation

**What counts as documentation:**
- README updates
- New guides or tutorials
- API documentation
- Troubleshooting guides
- Examples

**How to contribute:**
1. Fork repository
2. Create branch: `git checkout -b docs/documentation-topic`
3. Add/update documentation
4. Run spell check
5. Submit pull request

#### 5. Tests

**What counts as tests:**
- New test cases
- Compliance verification tests
- Deployment validation tests
- Integration tests
- Security validation tests

**How to contribute:**
1. Create branch: `git checkout -b test/test-description`
2. Add test files to `tests/` directory
3. Follow test standards (see below)
4. Submit pull request with test results

### Finding Issues to Work On

1. **Good for Beginners:**
   - Issues tagged `good-first-issue`
   - Issues tagged `help-wanted`
   - Documentation updates

2. **Specific Areas:**
   - Issues tagged `hardening` for CIS controls
   - Issues tagged `deployment` for deployment features
   - Issues tagged `testing` for test improvements

3. **See All Issues:**
   - Repository → Issues tab
   - Filter by labels or search by keyword

### Claiming an Issue

1. **Comment on the issue:** "I'd like to work on this"
2. **Wait for acknowledgment:** Maintainers will assign you
3. **Start work:** Create branch and begin development
4. **Ask questions:** Comment on issue if you need clarification

---

## Commit Message Format

### Standard Format

```
[TYPE] Brief description (50 chars max)

Longer description explaining the change (wrap at 72 chars)

- Bullet point 1
- Bullet point 2

Fixes #123
```

### Commit Types

Use these prefixes to categorize commits:

| Type | Usage | Example |
|------|-------|---------|
| `feat` | New feature | `feat: add CIS L2 hardening profile` |
| `fix` | Bug fix | `fix: resolve deployment crash on UEFI systems` |
| `docs` | Documentation only | `docs: update Getting Started guide` |
| `test` | Tests only | `test: add compliance verification tests` |
| `refactor` | Code refactoring | `refactor: consolidate hardening functions` |
| `perf` | Performance improvement | `perf: optimize image capture speed` |
| `security` | Security fix/improvement | `security: enhance BitLocker validation` |
| `ci` | CI/CD changes | `ci: add automated testing workflow` |
| `chore` | Maintenance/tooling | `chore: update dependencies` |

### Commit Message Examples

**Good:**
```
feat: implement Device Guard hardening controls

Add Device Guard configuration to CIS Complete profile
- Enable code integrity with UEFI lock
- Configure Device Guard policy
- Add compliance verification

Implements #156
```

**Good:**
```
fix: correct BitLocker TPM validation

BitLocker was failing on systems with TPM but no UEFI
- Check TPM version correctly
- Fall back to password protection if TPM unavailable
- Update documentation

Fixes #342
```

**Bad:**
```
Updated files
```

**Bad:**
```
Fixed bug in deploy script and added new tests and updated docs
```

### Guidelines

- ✅ Use imperative mood: "add feature" not "added feature"
- ✅ Capitalize first letter of description
- ✅ Don't end description with period
- ✅ Keep first line under 50 characters
- ✅ Reference issues: `Fixes #123`, `Implements #456`, `Related to #789`
- ✅ Explain WHY, not WHAT (code shows WHAT)

---

## Pull Request Process

### Before Creating a PR

1. ✅ Update your branch: `git pull origin main`
2. ✅ Make sure all tests pass
3. ✅ Run security checks
4. ✅ Update documentation
5. ✅ Test manually in non-production environment
6. ✅ Review your own changes first

### Creating a Pull Request

```powershell
# Push to your fork/branch
git push origin feature/your-feature-name

# Create PR on GitHub
# - Title: Brief summary
# - Description: Detailed explanation
# - Reference issues: Fixes #123
```

### PR Title Format

Follow the same format as commit messages:

```
[TYPE] Brief description (60 chars max)

Examples:
feat: add Credential Guard hardening
fix: resolve deployment on Server 2022
docs: improve troubleshooting guide
```

### PR Description Template

```markdown
## Description
Brief description of changes

## Type
- [ ] Bug fix
- [ ] New feature
- [ ] Documentation
- [ ] Testing
- [ ] Security improvement

## Related Issues
Fixes #123
Implements #456

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
- [ ] Tested on Windows 11 Pro
- [ ] Tested on Windows Server 2022
- [ ] All test cases pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] Security review completed
- [ ] No breaking changes (or documented)

## Screenshots/Logs (if applicable)
```

### PR Review Process

1. **Automated Checks:**
   - Code style validation
   - Test suite runs
   - Security scanning

2. **Maintainer Review:**
   - Code quality review
   - Logic verification
   - Security assessment
   - Documentation check

3. **Community Review:**
   - Anyone can comment
   - Questions and discussions encouraged
   - Consensus sought

4. **Revisions:**
   - Address feedback constructively
   - Push updates to same branch
   - Re-request review

5. **Approval & Merge:**
   - At least 1 maintainer approval required
   - All checks passing
   - Merged to main branch

### After Merge

- ✅ Delete your branch
- ✅ Celebrate your contribution! 🎉
- ✅ You may be mentioned in release notes

---

## Code Style & Standards

### PowerShell Style Guide

#### Naming Conventions

```powershell
# Functions: Verb-Noun format (PascalCase)
function Deploy-Image {
    # Good
}

function deployImage {
    # Bad - not verb-noun
}

# Variables: camelCase or descriptive
$imageFile = "install.wim"      # Good
$imagePath = "C:\images\img"     # Good
$img = "C:\images\img"           # Avoid - too cryptic

# Constants: UPPER_CASE
$HARDENING_TIMEOUT = 300
$CIS_PROFILE = "Complete"

# Internal variables: Start with underscore
$_internalCounter = 0
$_tempPath = "$env:TEMP\temp"
```

#### Formatting

```powershell
# Indentation: 4 spaces (not tabs)
function Deploy-Image {
    param([string]$Path)
    
    if ($Path) {
        Write-Host "Deploying image..."
    }
}

# Braces: Opening on same line
if ($condition) {
    # Code here
} else {
    # Code here
}

# Line length: Wrap at 100 characters
# Bad:
$longValue = "This is a very long line that exceeds the recommended width and should be wrapped to improve readability"

# Good:
$longValue = "This is a very long line that exceeds " +
    "the recommended width and should be wrapped"
```

#### Parameter Declarations

```powershell
# Good: Clear parameter types and help
function Deploy-Image {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ImagePath,
        
        [Parameter(Mandatory=$true)]
        [string]$TargetDisk,
        
        [Parameter(Mandatory=$false)]
        [switch]$EnableBitLocker = $false,
        
        [Parameter(Mandatory=$false)]
        [int]$Timeout = 300
    )
    
    # Implementation
}
```

#### Comments & Documentation

```powershell
# File header
<#
.SYNOPSIS
    Brief one-line description

.DESCRIPTION
    Longer description of what the function does

.PARAMETER ImagePath
    Path to the WIM file

.PARAMETER TargetDisk
    Target disk for deployment

.EXAMPLE
    PS> Deploy-Image -ImagePath "C:\image.wim" -TargetDisk "C:"

.NOTES
    Author: Your Name
    Date: 2026-04-19
    Security: Requires admin privileges
#>

# Inline comments
# Use full sentences with proper grammar
# Explain WHY, not WHAT (code shows WHAT)
$retryCount = 0  # Track failures for retry logic
```

#### Error Handling

```powershell
# Always use Try-Catch for critical operations
try {
    $result = Invoke-Command -ComputerName $server -ScriptBlock {
        Get-BitLockerVolume
    }
} catch {
    Write-Error "Failed to get BitLocker status: $($_.Exception.Message)"
    exit 1
}

# Validate inputs
if (-not (Test-Path $ImagePath)) {
    Write-Error "Image not found: $ImagePath"
    exit 1
}

# Use Write-Error, not Write-Host for errors
Write-Error "Error message"
Write-Warning "Warning message"
Write-Verbose "Verbose output"
```

### Code Review Standards

Your code will be reviewed for:

1. **Correctness:** Does it work as intended?
2. **Security:** Does it introduce vulnerabilities?
3. **Performance:** Is it efficient?
4. **Maintainability:** Is it easy to understand and modify?
5. **Consistency:** Does it follow project standards?
6. **Documentation:** Is it well-documented?
7. **Testing:** Is it adequately tested?

### DRY Principle

```powershell
# Bad: Repeated code
function Apply-CISMandatory {
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "ConsentPromptBehaviorAdmin" -Value 2
    Set-ItemProperty -Path "HKLM:\Software\Policies\Microsoft\Windows\Defender" -Name "DisableRealtimeMonitoring" -Value 0
    # ... repeat for each setting
}

# Good: Use functions
function Set-CISSetting {
    param([string]$Path, [string]$Name, [int]$Value)
    Set-ItemProperty -Path $Path -Name $Name -Value $Value
}

function Apply-CISMandatory {
    Set-CISSetting -Path "HKLM:\Software\Policies\Microsoft\Windows\System" -Name "ConsentPromptBehaviorAdmin" -Value 2
    Set-CISSetting -Path "HKLM:\Software\Policies\Microsoft\Windows\Defender" -Name "DisableRealtimeMonitoring" -Value 0
}
```

---

## Testing Requirements

### Before Submitting a PR

All changes MUST be tested according to these requirements:

### 1. Unit Testing

Create test files in `tests/` directory:

```powershell
# tests/Test-YourFunction.ps1

# Use Pester framework (PowerShell testing)
Describe "Deploy-Image" {
    It "Should validate image file exists" {
        { Deploy-Image -ImagePath "nonexistent.wim" } | Should -Throw
    }
    
    It "Should accept valid parameters" {
        { Deploy-Image -ImagePath "C:\test.wim" -TargetDisk "C:" } | Should -Not -Throw
    }
}

# Run tests:
# Invoke-Pester tests/Test-YourFunction.ps1
```

### 2. Integration Testing

Test how your changes work with existing code:

```powershell
# Test the complete workflow
1. Create test VM with clean Windows installation
2. Apply your hardening changes
3. Verify all settings applied correctly
4. Run compliance verification
5. Test deployment of captured image
```

### 3. Compatibility Testing

Test on required platforms:

- ✅ Windows 11 Pro
- ✅ Windows 11 Enterprise
- ✅ Windows Server 2022
- ✅ On both physical hardware and VMs

### 4. Manual Testing Checklist

Before submitting:

- [ ] Tested on Windows 11 Pro
- [ ] Tested on Windows 11 Enterprise
- [ ] Tested on Windows Server 2022
- [ ] Verified in non-production environment
- [ ] All error cases tested
- [ ] User documentation updated
- [ ] Help text/comments added
- [ ] No console errors or warnings
- [ ] Performance acceptable
- [ ] Security review completed

### 5. Compliance Testing

For hardening changes:

```powershell
# Run compliance verification
.\hardening\Verify-CIS-Compliance.ps1 -ExportReport "test-report.csv"

# Verify your changes:
# - New controls show PASS
# - Existing controls not affected
# - Compliance percentage correct
# - No unexpected failures
```

### 6. Test Results Documentation

Include test results in PR:

```
## Test Results

**Platform:** Windows 11 Enterprise (Build 22621.1413)

**Test Cases:**
- ✅ Feature X works correctly
- ✅ Edge case Y handled
- ✅ Error case Z shows proper message
- ✅ Rollback restores previous state

**Compliance Verification:**
- ✅ CIS Mandatory: 25/25 controls passing
- ✅ CIS Complete: 60/60 controls passing
- ✅ No regressions detected

**Performance:**
- Deploy time: 8 minutes (expected: 8-12 min)
- Memory usage: 2.3 GB (expected: <3 GB)
- Acceptable ✅
```

---

## Security Considerations

### Security Review for Contributors

All contributions must consider:

1. **Input Validation:**
   - Validate all user inputs
   - Check file paths exist
   - Verify permissions

2. **Error Handling:**
   - Don't expose sensitive data in errors
   - Log security-relevant actions
   - Fail securely

3. **Registry Access:**
   - Use correct registry paths
   - Verify values set correctly
   - Check security permissions

4. **Credential Handling:**
   - Never log passwords/credentials
   - Use secure credential storage
   - Clear sensitive data from memory

5. **Privilege Requirements:**
   - Document required privileges
   - Verify admin rights when needed
   - Fail with clear error if insufficient

Example:

```powershell
function Apply-HardeningControl {
    param([string]$ControlPath)
    
    # Check admin privileges
    if (-not ([Security.Principal.WindowsPrincipal]`
        [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Error "This function requires administrator privileges"
        return $false
    }
    
    # Validate input
    if (-not $ControlPath -or $ControlPath.Length -eq 0) {
        Write-Error "ControlPath cannot be empty"
        return $false
    }
    
    try {
        # Apply the control
        Set-ItemProperty -Path $ControlPath -Name "Value" -Value 1 -ErrorAction Stop
        Write-Verbose "Applied hardening control: $ControlPath"
        return $true
    } catch {
        Write-Error "Failed to apply control: $($_.Exception.Message)"
        return $false
    }
}
```

### Security Checklist for Contributors

- [ ] No hardcoded passwords or secrets
- [ ] All credentials stored securely
- [ ] Input validation implemented
- [ ] Error messages don't expose sensitive data
- [ ] Privilege requirements documented
- [ ] Security review of registry modifications
- [ ] Audit logging included where appropriate
- [ ] No unsafe PowerShell features used
- [ ] Code follows principle of least privilege
- [ ] Breaking changes documented

---

## CIS Control Development Guidelines

When adding new CIS controls:

### 1. Research the Control

```powershell
# Reference official CIS benchmark documentation
# Document:
# - Control number and name
# - CIS benchmark version
# - Description and rationale
# - Expected value
# - Remediation steps
```

### 2. Implement the Control

```powershell
<#
.SYNOPSIS
    Apply CIS 5.2.2.1 - Ensure Accounts are protected

.NOTES
    CIS Benchmark: Windows 11 v2.0
    Control ID: 5.2.2.1
    Description: Ensure that Accounts are protected with a password
#>
function Apply-CIS-5-2-2-1 {
    param([string]$Action = "Apply")
    
    if ($Action -eq "Verify") {
        # Check if setting is applied
        $policy = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
            -Name "RequireSignOrSeal" -ErrorAction SilentlyContinue
        return $policy.RequireSignOrSeal -eq 1
    } else {
        # Apply the control
        Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
            -Name "RequireSignOrSeal" -Value 1 -Type DWord
    }
}
```

### 3. Add Verification Logic

```powershell
# Function must verify the control is applied
function Verify-CIS-5-2-2-1 {
    $status = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
        -Name "RequireSignOrSeal" -ErrorAction SilentlyContinue
    
    if ($status.RequireSignOrSeal -eq 1) {
        return @{
            Status = "PASS"
            Value = $status.RequireSignOrSeal
            Expected = 1
        }
    } else {
        return @{
            Status = "FAIL"
            Value = $status.RequireSignOrSeal
            Expected = 1
        }
    }
}
```

### 4. Add Rollback Support

```powershell
# Store original value for rollback
function Backup-CIS-5-2-2-1 {
    param([string]$BackupPath = "rollback")
    
    $status = Get-ItemProperty -Path "HKLM:\System\CurrentControlSet\Services\Netlogon\Parameters" `
        -Name "RequireSignOrSeal" -ErrorAction SilentlyContinue
    
    $backup = @{
        Control = "5.2.2.1"
        OriginalValue = $status.RequireSignOrSeal
        Timestamp = Get-Date
    }
    
    $backup | ConvertTo-Json | Out-File -Path "$BackupPath\5-2-2-1.json"
}
```

### 5. Document Impact

```powershell
# Document impact and compatibility
<#
.NOTES
    Impact:
    - May affect SMB communication with older systems
    - Requires SMBv2 or later
    
    Compatibility:
    - Windows 11: ✅ Fully compatible
    - Server 2022: ✅ Fully compatible
    - Older systems: ⚠️ May cause network issues
    
    Testing:
    - Verify SMB communication still works
    - Test network shares remain accessible
#>
```

---

## Documentation Standards

### Writing Documentation

1. **Use Clear Language:**
   - Write for technical audience
   - Explain technical concepts
   - Provide examples

2. **Structure:**
   - Use headings and subheadings
   - Organize logically
   - Keep related content together

3. **Examples:**
   - Show command examples
   - Include expected output
   - Show both success and error cases

### File Header Template

```markdown
# Title of Document

## Overview
Brief description of the document purpose

## Table of Contents
- [Section 1](#section-1)
- [Section 2](#section-2)

## Prerequisites
What readers should know before reading

## Main Content
[Your content here]

## Examples
[Practical examples]

## See Also
- Related documentation
- External resources

## Version
Last updated: 2026-04-19
Organization: Custom PC Republic
```

---

## Troubleshooting Contributions

### Common Issues

**"My PR was rejected"**
- Review feedback carefully
- Ask for clarification if needed
- Make requested changes
- Resubmit

**"Build/tests are failing"**
- Check test output for specific errors
- Run tests locally first
- Ensure all platforms tested
- Ask for help in PR comments

**"I don't know how to implement something"**
- Check existing code for patterns
- Ask in GitHub discussions
- Reference similar implementations
- Request guidance in issue

### Getting Help

- **GitHub Discussions:** Ask questions in public
- **Issues:** Reference existing issues
- **PR Comments:** Ask maintainers for guidance
- **Email:** `conduct@custompc.local` for process questions

---

## Recognition & Attribution

### How Contributors Are Recognized

- ✅ Listed in project README
- ✅ Mentioned in release notes
- ✅ Acknowledgment in commit history
- ✅ Optional: Website attribution

### Contributors List

To add yourself to the contributors list after your first PR:

1. Add your GitHub username to `.github/CONTRIBUTORS.md`
2. Include your name and contribution area (if desired)

---

## Licensing

By contributing to this project, you agree that:

1. Your contributions will be licensed under the MIT License
2. You have the right to grant this license
3. You understand the implications of MIT licensing

---

## Additional Resources

- [PowerShell Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/developer/cmdlet/cmdlet-development-guidelines)
- [CIS Benchmarks](https://www.cisecurity.org/benchmarks)
- [Git Workflow Guide](https://guides.github.com/introduction/flow/)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

## Policy Version

- **Version:** 1.0
- **Last Updated:** April 19, 2026
- **Organization:** Custom PC Republic

---

**Custom PC Republic - Enterprise Hardening Solutions**  
*IT Synergy Energy for the Republic* 🛡️

**Thank you for contributing! Your work makes this project better for everyone.** 🙌

# GitHub Actions Workflows Documentation

Comprehensive CI/CD workflows for the Windows-Safety-Jump-Box repository.

## Table of Contents

1. [Workflow Overview](#workflow-overview)
2. [Workflow Descriptions](#workflow-descriptions)
3. [Setup and Configuration](#setup-and-configuration)
4. [Manual Triggers](#manual-triggers)
5. [Secrets Configuration](#secrets-configuration)
6. [Artifact Outputs](#artifact-outputs)
7. [Troubleshooting](#troubleshooting)
8. [Best Practices](#best-practices)

---

## Workflow Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                     CI/CD Pipeline                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  On PR/Commit ──→ [Validate] ──→ [Security Audit] ──→ Review   │
│                                                                  │
│  Manual/Weekly ──→ [Build Win11] ──→ [Build Server2022]       │
│                         ↓                    ↓                  │
│                    [Generate Manifest] [Generate Manifest]      │
│                         ↓                    ↓                  │
│                    [Upload Artifacts]  [Upload Artifacts]       │
│                         ↓                    ↓                  │
│                    [Publish Release] ←──────┘                   │
│                         ↓                                       │
│                   [Deploy Test] ──→ [Compliance/Security Tests] │
│                         ↓                    ↓                  │
│                    [Cleanup]        [Generate Report]          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

---

## Workflow Descriptions

### 1. **validate.yml** - Code and Test Validation
**Trigger**: Automatically on push to main/develop, Pull requests  
**Schedule**: On-demand only  

**Purpose**: Ensures code quality and test coverage before merge

**Steps**:
- PowerShell syntax validation on all `.ps1` files
- PSScriptAnalyzer for code quality rules
- Hardcoded secrets detection (regex patterns)
- Markdown documentation validation
- Run full test suite (`tests/Run-All-Tests.ps1`)
- Generate test reports (JSON and HTML)
- Post results as PR comments

**Key Features**:
- ✓ Prevents syntax errors in main branch
- ✓ Detects potential hardcoded credentials
- ✓ Enforces code quality standards
- ✓ Comprehensive test execution
- ✓ PR comments with results

**Outputs**:
- `test-reports/` - Test execution results
- `script-analysis-results.csv` - Code analysis findings
- PR comment with validation summary

---

### 2. **build-windows-11.yml** - Windows 11 Image Build
**Trigger**: Weekly (Sunday 2 AM UTC) + Manual dispatch  
**Timeout**: 6 hours  

**Purpose**: Builds CIS-hardened Windows 11 images in multiple formats

**Manual Trigger Parameters**:
```yaml
packer_debug: Enable Packer debug output (true/false)
iso_source: Custom ISO URL or local path (optional)
```

**Build Steps**:
1. Generate unique build version and artifact ID
2. Validate Packer templates and tools
3. Download Windows 11 ISO (or use provided source)
4. Configure build variables
5. Execute Packer build (Hyper-V, QEMU)
6. Capture WIM image with hardening applied
7. Generate VHDX variant
8. Create Boot.wim
9. Calculate SHA256 checksums
10. Generate MANIFEST.json with metadata
11. Create GitHub release with artifacts

**CIS Hardening Applied**:
- Windows Defender enabled and configured
- Windows Firewall hardened
- BitLocker encryption ready
- UAC strengthened
- AppLocker policies enabled
- Security policies applied

**Outputs**:
- `output/windows11_hardened_*.wim` - Windows image
- `output/windows11_hardened_*.vhdx` - Virtual disk image
- `output/boot_*.wim` - Boot image
- `output/MANIFEST_*.json` - Build metadata
- `output/CHECKSUMS_*.txt` - File hashes

**Concurrency**: Max 1 concurrent Windows 11 build per branch

---

### 3. **build-server-2022.yml** - Server 2022 Image Build
**Trigger**: Weekly (Sunday 3 AM UTC) + Manual dispatch  
**Timeout**: 6 hours  

**Purpose**: Builds CIS-hardened Windows Server 2022 images with multiple variants

**Manual Trigger Parameters**:
```yaml
edition:         # Edition to build
  - standard     # Standard Edition
  - datacenter   # Datacenter Edition
  - all          # Both editions (matrix build)

hypervisor:      # Hypervisor variant
  - hyper-v      # Hyper-V optimized
  - vmware       # VMware Tools
  - virtualbox   # VirtualBox tools
  - all          # All variants (matrix)

packer_debug:    # Enable debug output (true/false)
```

**Build Matrix**:
- Standard + Hyper-V
- Standard + VMware
- Standard + VirtualBox
- Datacenter + Hyper-V
- Datacenter + VMware
- Datacenter + VirtualBox

**Max parallel builds**: 2 (configurable)

**Build Steps** (per matrix combination):
1. Validate templates for edition and hypervisor
2. Download Server 2022 ISO for edition
3. Create build variables
4. Execute Packer build with hypervisor tools
5. Generate manifest for edition/hypervisor combo
6. Calculate checksums
7. Upload artifacts by variant

**Consolidation Steps**:
1. Download all build artifacts
2. Generate consolidated manifest
3. Create unified release tag
4. Generate compliance reports

**Outputs** (per variant):
- `output/server-2022/server2022_*.wim`
- `output/server-2022/server2022_*.vhdx`
- `output/server-2022/MANIFEST_*.json`
- `output/server-2022/CHECKSUMS_*.txt`
- Consolidated release with all variants

**Concurrency**: Max 2 concurrent Server 2022 builds

---

### 4. **security-audit.yml** - Security Analysis
**Trigger**: Nightly (1 AM UTC) + Manual dispatch + All PRs  
**Timeout**: 30 minutes  

**Purpose**: Comprehensive security scanning and vulnerability detection

**Security Tests**:

1. **PowerShell Script Analysis (PSScriptAnalyzer)**
   - Checks for security best practices
   - Identifies potential vulnerabilities
   - Enforces PowerShell standards
   - Output: SARIF format for GitHub Security tab

2. **Credential Scanning (gitleaks)**
   - Scans entire repository history
   - Detects hardcoded secrets
   - Finds API keys, passwords, tokens
   - Output: SARIF format

3. **Static Application Security Testing (SAST)**
   - Custom patterns for common issues
   - SQL injection detection
   - Path traversal detection
   - Weak cryptography detection
   - Hardcoded secrets patterns

**Key Features**:
- ✓ Automated credential detection
- ✓ Security code review
- ✓ SARIF format for GitHub integration
- ✓ HTML reports for human review
- ✓ PR comments with findings

**Outputs**:
- `pss-analysis-results.csv` - Script analysis findings
- `pss-analysis-results.sarif` - GitHub Security tab
- `gitleaks-results.sarif` - Credential scan results
- `sast-report.html` - Security assessment
- `hardening-analysis.json` - Hardening script analysis

**GitHub Integration**:
- Uploads to Security tab automatically
- Creates PR comments with summary
- Blocks merge if critical issues found (optional)

---

### 5. **publish-release.yml** - Release Management
**Trigger**: Manual dispatch only  
**Timeout**: 30 minutes  

**Purpose**: Creates versioned releases with all build artifacts and compliance reports

**Manual Trigger Parameters**:
```yaml
release_type:              # Version increment
  - patch                  # v1.0.0 → v1.0.1
  - minor                  # v1.0.0 → v1.1.0
  - major                  # v1.0.0 → v2.0.0

release_title:             # Custom release title
include_artifacts:         # Include build artifacts (true/false)
create_compliance_report:  # Generate CIS report (true/false)
```

**Release Process**:
1. Calculate new version (semantic versioning)
2. Generate release notes from manifest files
3. Gather all build artifacts
4. Generate SHA256 checksums for all files
5. Create CIS compliance report
6. Generate deployment checklists
7. Create GitHub release with tag
8. Upload all artifacts to release
9. Add release badges and metadata
10. Send notifications

**Generated Documents**:
- `RELEASE_NOTES.md` - Human-readable release summary
- `MANIFEST.json` - Machine-readable artifact metadata
- `CHECKSUMS.txt` - File integrity verification
- `CIS_COMPLIANCE_REPORT.md` - CIS benchmark compliance
- `DEPLOYMENT_CHECKLIST.md` - Pre/post deployment steps

**Outputs**:
- GitHub release with semantic version tag
- All build artifacts attached
- Compliance and deployment documentation
- Release notes with features/improvements

**Version Tagging**:
- Format: `v{major}.{minor}.{patch}`
- Examples: `v1.0.0`, `v1.1.2`, `v2.0.0`
- Builds on latest tag or defaults to `v1.0.0`

---

### 6. **deploy-test.yml** - Test Deployment
**Trigger**: Manual dispatch only  
**Timeout**: 2 hours  

**Purpose**: Deploy built images to test environments and validate

**Manual Trigger Parameters**:
```yaml
test_environment:      # Deployment target
  - local              # Local Hyper-V
  - azure              # Azure VM
  - hyper-v            # Hyper-V (explicit)

image_type:           # Image to deploy
  - windows11          # Windows 11 Pro
  - server2022         # Windows Server 2022

run_compliance_tests: # Execute CIS tests (true/false)
run_security_tests:   # Execute security tests (true/false)
cleanup_after:        # Remove test VM after (true/false)
```

**Deployment Workflow**:

1. **Prepare** (all environments):
   - Generate unique test ID
   - Generate test VM name
   - Validate prerequisites

2. **Deploy to Hyper-V**:
   - Verify Hyper-V enabled
   - Download/prepare VHDX image
   - Create virtual disk
   - Create VM configuration
   - Start VM and wait for boot

3. **Deploy to Azure** (requires credentials):
   - Login to Azure subscription
   - Create resource group
   - Deploy VM from image
   - Wait for readiness

4. **Run Compliance Tests**:
   - CIS Benchmark validation (10 tests)
   - Group Policy verification
   - Security policy checks
   - Configuration validation
   - Generate JSON results

5. **Run Security Tests**:
   - Vulnerability scan
   - Port security check
   - Service hardening validation
   - Privilege escalation tests
   - Credential exposure checks

6. **Generate Reports**:
   - HTML test report
   - JSON result files
   - Pass/fail summary
   - Security score

7. **Cleanup** (if enabled):
   - Stop test VM
   - Remove virtual disk
   - Clean temporary files
   - Generate cleanup report

**Test Results**:
- Compliance tests: 10 categories
- Security tests: 8 vulnerability checks
- Overall pass rate percentage
- Security score (0-100)

**Outputs**:
- `deployment-test-report.html` - Detailed results
- `compliance-test-results.json` - CIS test results
- `security-test-results.json` - Security assessment
- `cleanup-report.json` - Resource cleanup status

---

## Setup and Configuration

### 1. Initial Setup

**Step 1: Create workflows directory** (already exists, but verify)
```bash
mkdir -p .github/workflows
```

**Step 2: Copy workflow files**
```bash
# Files created:
# - .github/workflows/validate.yml
# - .github/workflows/build-windows-11.yml
# - .github/workflows/build-server-2022.yml
# - .github/workflows/security-audit.yml
# - .github/workflows/publish-release.yml
# - .github/workflows/deploy-test.yml
# - .github/workflows/config.yml
```

**Step 3: Commit to repository**
```bash
git add .github/workflows/
git commit -m "Add comprehensive CI/CD workflows"
git push
```

### 2. Configure Repository Settings

**Enable in GitHub Settings** → Actions:
- ✓ Allow all actions
- ✓ Allow local actions
- ✓ Set workflow permissions

**Enable in GitHub Settings** → Secrets and variables:
- See [Secrets Configuration](#secrets-configuration) below

### 3. Configure Branch Protection

**For main branch**:
```
Require status checks to pass before merging:
- ✓ validate (Validate Code and Tests)
- ✓ security-audit (Security Audit)
```

**For develop branch** (optional):
```
Require status checks to pass before merging:
- ✓ validate (Validate Code and Tests)
```

---

## Secrets Configuration

### Required Secrets (Optional for basic use)

To enable all features, configure these in GitHub Settings → Secrets and variables:

```
AZURE_CREDENTIALS
├── Type: Repository secret
├── Format: JSON
├── Used by: deploy-test.yml (Azure deployment)
└── Value: Service Principal credentials
  {
    "clientId": "...",
    "clientSecret": "...",
    "subscriptionId": "...",
    "tenantId": "..."
  }

AZURE_SUBSCRIPTION_ID
├── Type: Repository secret
├── Used by: deploy-test.yml (Azure VM creation)
└── Value: Your Azure subscription ID

SLACK_WEBHOOK_URL
├── Type: Repository secret
├── Used by: build workflows (notifications)
└── Value: https://hooks.slack.com/services/...

TEAMS_WEBHOOK_URL
├── Type: Repository secret
├── Used by: build workflows (notifications)
└── Value: https://outlook.webhook.office.com/webhookb2/...
```

### Adding Secrets

**Via GitHub Web UI**:
1. Go to Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: (from list above)
4. Value: (your secret value)
5. Click "Add secret"

**Via GitHub CLI**:
```bash
gh secret set AZURE_SUBSCRIPTION_ID --body "your-subscription-id"
gh secret set SLACK_WEBHOOK_URL --body "your-webhook-url"
```

### Secrets NOT Required for Basic Use

These workflows function without secrets:
- `validate.yml` - No secrets needed
- `security-audit.yml` - No secrets needed
- `build-windows-11.yml` - No secrets needed (basic mode)
- `build-server-2022.yml` - No secrets needed (basic mode)
- `publish-release.yml` - No secrets needed (basic mode)

Secrets enable optional features like:
- Azure VM deployment
- Slack/Teams notifications
- Credential storage

---

## Manual Triggers

### 1. Run Validation Workflow
```bash
gh workflow run validate.yml -f test_filter="All"
```

**Available parameters**:
- `test_filter`: Syntax, CIS, Deployment, Compliance, Integration, All

### 2. Trigger Windows 11 Build
```bash
gh workflow run build-windows-11.yml \
  -f packer_debug="false" \
  -f iso_source=""
```

**Parameters**:
- `packer_debug`: Enable Packer debug logging (true/false)
- `iso_source`: ISO URL or local path (optional)

### 3. Trigger Server 2022 Build
```bash
gh workflow run build-server-2022.yml \
  -f edition="standard" \
  -f hypervisor="hyper-v" \
  -f packer_debug="false"
```

**Parameters**:
- `edition`: standard, datacenter, or all
- `hypervisor`: hyper-v, vmware, virtualbox, or all
- `packer_debug`: Enable debug mode (true/false)

### 4. Run Security Audit
```bash
gh workflow run security-audit.yml
```

**No parameters** - Runs all security checks

### 5. Create Release
```bash
gh workflow run publish-release.yml \
  -f release_type="minor" \
  -f release_title="CIS Hardened Windows Images - v1.1.0" \
  -f create_compliance_report="true"
```

**Parameters**:
- `release_type`: major, minor, or patch
- `release_title`: Custom release title
- `include_artifacts`: Include build artifacts (true/false)
- `create_compliance_report`: Generate CIS report (true/false)

### 6. Deploy Test
```bash
gh workflow run deploy-test.yml \
  -f test_environment="hyper-v" \
  -f image_type="windows11" \
  -f run_compliance_tests="true" \
  -f run_security_tests="true" \
  -f cleanup_after="true"
```

**Parameters**:
- `test_environment`: local, azure, or hyper-v
- `image_type`: windows11 or server2022
- `run_compliance_tests`: Execute CIS tests (true/false)
- `run_security_tests`: Execute security tests (true/false)
- `cleanup_after`: Remove test resources (true/false)

---

## Artifact Outputs

### Build Artifacts Location
All build artifacts are saved to `output/` directory and uploaded as GitHub artifacts.

### validate.yml Artifacts
```
test-reports/
├── consolidated-report.json      # Overall test results
├── syntax-report.json            # PowerShell syntax tests
├── cis-report.json               # CIS compliance tests
├── deployment-report.json        # Deployment script tests
├── compliance-report.json        # Compliance tests
└── integration-report.html       # Integration tests HTML

script-analysis-results.csv       # PSScriptAnalyzer findings
```

### build-windows-11.yml Artifacts
```
output/
├── windows11_hardened_TIMESTAMP.wim      # Windows image
├── windows11_hardened_TIMESTAMP.vhdx     # Virtual disk
├── boot_TIMESTAMP.wim                    # Boot image
├── MANIFEST_TIMESTAMP.json               # Metadata
└── CHECKSUMS_TIMESTAMP.txt               # File hashes
```

### build-server-2022.yml Artifacts
```
output/server-2022/
├── server2022_standard_hyper-v_TIMESTAMP.wim
├── server2022_standard_hyper-v_TIMESTAMP.vhdx
├── server2022_standard_vmware_TIMESTAMP.wim
├── server2022_standard_vmware_TIMESTAMP.vhdx
├── server2022_standard_virtualbox_TIMESTAMP.wim
├── server2022_standard_virtualbox_TIMESTAMP.vhdx
├── server2022_datacenter_*.{wim,vhdx}    # Variants
├── MANIFEST_*.json                       # Per-variant manifests
└── CHECKSUMS_*.txt                       # Per-variant checksums
```

### security-audit.yml Artifacts
```
security-analysis-reports/
├── pss-analysis-report.html       # PowerShell analysis
├── sast-report.html               # SAST findings
├── sast-findings.csv              # CSV format
└── hardening-analysis.json        # Hardening metrics
```

### publish-release.yml Artifacts
```
release-artifacts/
├── MANIFEST.json                  # Consolidated manifest
├── CHECKSUMS.txt                  # All file hashes
└── (all build artifacts)

compliance-reports/
├── CIS_COMPLIANCE_REPORT.md       # CIS benchmark report
└── DEPLOYMENT_CHECKLIST.md        # Deployment steps
```

### deploy-test.yml Artifacts
```
deployment-test-report/
├── deployment-test-report.html     # Test results (HTML)
├── compliance-test-results.json    # CIS test results
└── security-test-results.json      # Security test results

cleanup-report/
└── cleanup-report.json             # Resource cleanup status
```

### Artifact Retention Policies
```
Test reports:        30 days
Build artifacts:     90 days
Release artifacts:  180 days
Security reports:    30 days
Compliance reports:  90 days
```

---

## Troubleshooting

### Common Issues and Solutions

#### 1. PowerShell Execution Policy Error
**Error**: `File cannot be loaded because running scripts is disabled`

**Solution**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
# Or in workflow:
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
```

#### 2. Packer Not Found
**Error**: `packer: command not found`

**Solution**:
- Verify Packer is in PATH
- Check cache is working: `git clean -fdx .github/`
- Manually install: Download from https://www.packer.io/downloads

#### 3. ISO Download Timeout
**Error**: `Invoke-WebRequest: The underlying connection was closed`

**Solution**:
- Increase timeout in workflow
- Use pre-downloaded ISO (provide via `iso_source`)
- Check internet connectivity

#### 4. Hyper-V VM Not Found
**Error**: `Get-VM: VM not found`

**Solution**:
- Verify Hyper-V is enabled
- Check VM naming conventions
- Ensure VM creation completed successfully

#### 5. Azure Authentication Failed
**Error**: `Azure CLI: Authentication failed`

**Solution**:
- Verify AZURE_CREDENTIALS secret is set correctly
- Check Azure subscription access
- Renew service principal credentials if expired

#### 6. Insufficient Disk Space
**Error**: `Out of disk space`

**Solution**:
- Clean old artifacts: `gh run list --limit 100 | xargs gh run delete`
- Reduce retention periods in config.yml
- Use Azure Blob Storage for long-term storage

#### 7. Test Timeouts
**Error**: `Workflow run timed out`

**Solution**:
- Increase timeout in workflow definition (max 360 minutes)
- Reduce test scope with `-TestFilter` parameter
- Optimize test execution

#### 8. Release Version Collision
**Error**: `Tag already exists`

**Solution**:
- Use `release_type: major` to skip version
- Delete old tag: `git push origin :refs/tags/tagname`
- Use manual version in release title

### Enabling Debug Logging

#### PowerShell Debug Mode
```yaml
- name: Enable PowerShell debug
  shell: pwsh
  run: |
    $DebugPreference = "Continue"
    $VerbosePreference = "Continue"
```

#### Packer Debug Mode
```bash
# In workflow dispatch, set:
packer_debug: true

# Or manually:
export PACKER_LOG=1
export PACKER_LOG_PATH="./packer-debug.log"
```

#### GitHub Actions Debug Logging
```bash
# Enable secret debugging (shows all variables):
export ACTIONS_STEP_DEBUG=true
```

### Checking Workflow Status

**View all workflow runs**:
```bash
gh run list --workflow=validate.yml --limit 10
```

**View specific run details**:
```bash
gh run view RUN_ID --log
```

**Download artifacts from run**:
```bash
gh run download RUN_ID -D artifacts/
```

### Manual Debug Steps

If workflow fails, manually run steps:

```powershell
# 1. Validate syntax
Get-ChildItem -Filter "*.ps1" -Recurse | ForEach-Object {
    [System.Management.Automation.PSParser]::Tokenize((Get-Content $_), [ref]$null)
}

# 2. Run tests
./tests/Run-All-Tests.ps1 -TestFilter "All"

# 3. Check hardcoded secrets
Get-ChildItem -Filter "*.ps1" -Recurse | 
    Select-String -Pattern "password|api_key|secret" -AllMatches

# 4. Analyze scripts
Invoke-ScriptAnalyzer -Path . -Recurse
```

---

## Best Practices

### Workflow Development

1. **Always test locally first**
   - Run scripts locally before committing
   - Verify syntax with PSScriptAnalyzer
   - Test in development branch first

2. **Use meaningful commit messages**
   - Reference the workflow being changed
   - Describe what and why
   - Example: "Fix: PowerShell timeout in validation workflow"

3. **Document manual parameters**
   - Always include in PR description
   - Explain non-obvious choices
   - Link to related issues

4. **Version your builds**
   - Use semantic versioning (major.minor.patch)
   - Auto-increment in publish workflow
   - Tag releases consistently

### Security

1. **Never commit secrets**
   - Use GitHub secrets for credentials
   - Scan for hardcoded passwords before commit
   - Enable branch protection rules

2. **Review security findings**
   - Check SARIF results in Security tab
   - Address critical findings before merge
   - Keep dependencies updated

3. **Audit workflow access**
   - Review who can trigger manual workflows
   - Limit release creation to maintainers
   - Audit deployment credentials regularly

### Performance

1. **Cache build tools**
   - Workflows use caching for Packer, tools
   - Enable GitHub Actions caching
   - Clean cache if issues occur: `gh run list ... | xargs gh run delete`

2. **Optimize test execution**
   - Run quick tests first (syntax)
   - Run security tests in parallel
   - Skip expensive tests if not needed

3. **Monitor workflow duration**
   - Windows builds take 1-2 hours
   - Plan build schedules accordingly
   - Use matrix strategies for parallel builds

### Maintenance

1. **Keep workflows updated**
   - Review GitHub Actions releases
   - Update action versions regularly
   - Test after major updates

2. **Monitor artifact retention**
   - Clean up old artifacts periodically
   - Archive important releases
   - Monitor storage usage

3. **Document changes**
   - Update this file with any modifications
   - Maintain CHANGELOG.md for releases
   - Document configuration changes

---

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [PowerShell Best Practices](https://docs.microsoft.com/en-us/powershell/scripting/learn/ps101)
- [CIS Benchmark](https://www.cisecurity.org/benchmark)
- [Windows Hardening Guide](https://docs.microsoft.com/en-us/windows-server/security/windows-server-security)
- [Packer Documentation](https://www.packer.io/docs)

---

**Last Updated**: 2026-04-20  
**Version**: 1.0  
**Maintainer**: Windows Safety Jump Box Team


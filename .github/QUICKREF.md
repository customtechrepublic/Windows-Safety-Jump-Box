# Quick Reference Guide - GitHub Actions Workflows

## 🚀 Common Commands

### View Workflow Status
```bash
# List recent runs
gh run list --limit 10

# List specific workflow
gh run list --workflow=validate.yml --limit 5

# View run details
gh run view RUN_ID --log

# Download artifacts
gh run download RUN_ID -D artifacts/
```

### Trigger Workflows

**Validation**
```bash
gh workflow run validate.yml
```

**Windows 11 Build**
```bash
# Basic build
gh workflow run build-windows-11.yml

# With custom ISO
gh workflow run build-windows-11.yml -f iso_source="https://example.com/win11.iso"

# Debug mode
gh workflow run build-windows-11.yml -f packer_debug="true"
```

**Server 2022 Build**
```bash
# Build Standard edition
gh workflow run build-server-2022.yml -f edition="standard"

# Build all editions
gh workflow run build-server-2022.yml -f edition="all" -f hypervisor="all"

# Single variant
gh workflow run build-server-2022.yml -f edition="datacenter" -f hypervisor="hyper-v"
```

**Security Audit**
```bash
gh workflow run security-audit.yml
```

**Publish Release**
```bash
# Create patch release
gh workflow run publish-release.yml -f release_type="patch"

# Create minor release
gh workflow run publish-release.yml -f release_type="minor" -f release_title="My Release"

# Create major release
gh workflow run publish-release.yml -f release_type="major" -f create_compliance_report="true"
```

**Deploy Test**
```bash
# Test local
gh workflow run deploy-test.yml -f test_environment="hyper-v" -f image_type="windows11"

# Test Azure
gh workflow run deploy-test.yml -f test_environment="azure" -f image_type="server2022"

# Full test with cleanup
gh workflow run deploy-test.yml \
  -f test_environment="hyper-v" \
  -f image_type="windows11" \
  -f run_compliance_tests="true" \
  -f run_security_tests="true" \
  -f cleanup_after="true"
```

---

## 📊 Workflow Overview

| Workflow | Trigger | Duration | Purpose |
|----------|---------|----------|---------|
| **validate** | Push/PR | 5-15 min | Code quality, tests |
| **security-audit** | Nightly/PR | 10-20 min | Security scanning |
| **build-win11** | Weekly Sun 2AM | 60-120 min | Windows 11 image |
| **build-server2022** | Weekly Sun 3AM | 60-120 min | Server 2022 image |
| **publish-release** | Manual | 5-10 min | Create release |
| **deploy-test** | Manual | 30-60 min | Test deployment |

---

## 🔑 Required Secrets (Optional)

```bash
# Azure deployment
gh secret set AZURE_CREDENTIALS --body '{"clientId":"...","clientSecret":"...",...}'
gh secret set AZURE_SUBSCRIPTION_ID --body "your-sub-id"

# Slack notifications
gh secret set SLACK_WEBHOOK_URL --body "https://hooks.slack.com/services/..."

# Teams notifications
gh secret set TEAMS_WEBHOOK_URL --body "https://outlook.webhook.office.com/webhookb2/..."
```

---

## 📁 Artifact Locations

```
GitHub Release Assets:
  ├── windows11_hardened_TIMESTAMP.wim (build artifact)
  ├── windows11_hardened_TIMESTAMP.vhdx (build artifact)
  ├── boot_TIMESTAMP.wim (build artifact)
  ├── MANIFEST_TIMESTAMP.json (metadata)
  └── CHECKSUMS_TIMESTAMP.txt (integrity)

Workflow Artifacts (30-90 day retention):
  test-reports/                      (from validate)
  security-analysis-reports/         (from security-audit)
  deployment-test-report/            (from deploy-test)
  compliance-reports/                (from publish-release)
  release-artifacts/                 (from publish-release)
```

---

## 🔍 Troubleshooting Quick Tips

| Problem | Solution |
|---------|----------|
| PowerShell execution error | `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process` |
| Packer not found | Check PATH, verify cache, or install manually |
| ISO download timeout | Use pre-downloaded ISO via `iso_source` parameter |
| VM not found (Hyper-V) | Verify Hyper-V enabled, check VM naming |
| Azure auth failed | Verify AZURE_CREDENTIALS secret, check permissions |
| Out of disk space | Clean artifacts: `gh run list --limit 100 \| xargs gh run delete` |
| Test timeout | Increase timeout in workflow, reduce test scope |
| Release tag collision | Use different release_type or manually increment |

---

## 📋 Branch Protection Setup

```bash
# Protect main branch - require passing validation
gh api repos/OWNER/REPO/branches/main/protection \
  -X PUT \
  -f required_status_checks.strict=true \
  -f required_status_checks.contexts='["validate","security-audit"]' \
  -f required_pull_request_reviews.required_approving_review_count=1
```

---

## 🎯 Typical Workflow Usage

### Daily Development
```bash
# 1. Make changes
git checkout -b feature/my-feature
# ... edit files ...

# 2. Commit and push
git add .
git commit -m "Add new feature"
git push -u origin feature/my-feature

# 3. Create PR (GitHub Web)
# - Validate workflow runs automatically
# - Security audit runs automatically
# - Review results in PR

# 4. Merge when checks pass
git merge origin/feature/my-feature
git push origin main
```

### Weekly Build & Release
```bash
# 1. Windows 11 builds Sunday 2 AM UTC
# 2. Server 2022 builds Sunday 3 AM UTC
# 3. Check build status Monday morning

# List weekend builds
gh run list --workflow=build-windows-11.yml --created=">2026-04-19"

# Review artifacts
gh run download LATEST_WIN11_RUN -D artifacts/win11/
gh run download LATEST_SERVER_RUN -D artifacts/server2022/

# 4. Create release
gh workflow run publish-release.yml \
  -f release_type="minor" \
  -f release_title="Weekly CIS Hardened Images"
```

### Monthly Testing & Validation
```bash
# 1. Test Windows 11 locally
gh workflow run deploy-test.yml \
  -f test_environment="hyper-v" \
  -f image_type="windows11" \
  -f run_compliance_tests="true"

# 2. Test Server 2022 in Azure (if configured)
gh workflow run deploy-test.yml \
  -f test_environment="azure" \
  -f image_type="server2022" \
  -f run_security_tests="true"

# 3. Review test results
gh run view LATEST_TEST_RUN --log

# 4. Download report
gh run download LATEST_TEST_RUN -D test-results/
```

---

## 🔐 Security Checklist

- [ ] No secrets in code (checked by validate)
- [ ] No hardcoded credentials (checked by security-audit)
- [ ] SARIF results reviewed in Security tab
- [ ] Critical issues addressed before merge
- [ ] Branch protection enabled
- [ ] PR reviews required
- [ ] Secrets rotated periodically
- [ ] Audit logs reviewed

---

## 📈 Performance Tips

1. **Cache Management**
   ```bash
   # Clear workflow cache if needed
   gh run list --limit 100 | xargs gh run delete
   ```

2. **Parallel Builds**
   - Server 2022 matrix runs up to 2 builds simultaneously
   - Windows 11 builds sequentially (concurrency: 1)

3. **Test Optimization**
   - Skip expensive tests: `-TestFilter "Syntax,CIS"`
   - Run only on PR for heavy tests

4. **Artifact Cleanup**
   - Automatic retention: 30-180 days
   - Archive important releases manually
   - Monitor storage usage

---

## 🎓 Learning Resources

- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [GitHub CLI Reference](https://cli.github.com/manual/)
- [PowerShell Best Practices](https://docs.microsoft.com/powershell)
- [CIS Benchmarks](https://www.cisecurity.org/benchmark)
- [Packer Docs](https://www.packer.io/docs)

---

## 📞 Getting Help

**View Full Documentation**
- Main guide: `.github/WORKFLOWS.md`
- Configuration: `.github/workflows/config.yml`
- Implementation details: `.github/CI_CD_IMPLEMENTATION.md`
- This quick reference: `.github/QUICKREF.md`

**Check Workflow Logs**
```bash
gh run view RUN_ID --log > workflow.log
```

**Verify Syntax**
```bash
# YAML validation
python -m yaml .github/workflows/*.yml

# PowerShell validation
pwsh -NoProfile -Command "Get-ChildItem -Filter '*.ps1' -Recurse | ForEach-Object { [System.Management.Automation.PSParser]::Tokenize((Get-Content $_), [ref]$null) }"
```

---

## 🗓️ Scheduled Events

```
Weekly Build Schedule:
  ├── Sunday 2:00 AM UTC → Windows 11 build (build-windows-11.yml)
  ├── Sunday 3:00 AM UTC → Server 2022 build (build-server-2022.yml)
  └── Daily 1:00 AM UTC  → Security audit (security-audit.yml)

Continuous Triggers:
  ├── On push to main/develop → validate.yml
  ├── On pull request → validate.yml + security-audit.yml
  └── On manual dispatch → Any workflow
```

---

## 📊 Status Dashboard

```bash
# Get workflow status
for workflow in validate security-audit build-windows-11 build-server-2022 publish-release deploy-test; do
  echo "=== $workflow ==="
  gh run list --workflow=$workflow.yml --limit 1 --json "status,conclusion,createdAt"
done
```

---

## 🎬 Getting Started (5 minutes)

1. **Commit Workflows**
   ```bash
   cd /path/to/repo
   git add .github/workflows/
   git commit -m "Add CI/CD workflows"
   git push
   ```

2. **Test Validation**
   ```bash
   gh workflow run validate.yml
   # Wait ~5-15 minutes
   gh run view --latest
   ```

3. **Check Results**
   ```bash
   gh run download --latest -D artifacts/
   ls artifacts/
   ```

4. **Read Full Guide**
   - Open `.github/WORKFLOWS.md`
   - Review configuration in `.github/workflows/config.yml`

5. **Configure Secrets** (Optional)
   ```bash
   gh secret set AZURE_SUBSCRIPTION_ID --body "YOUR_SUB_ID"
   ```

---

**Last Updated**: 2026-04-20  
**Quick Reference v1.0**


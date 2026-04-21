```
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║              GITHUB SECRETS CONFIGURATION                                ║
║         Windows Safety Jump Box - CI/CD Secrets Setup Guide              ║
║                                                                           ║
║              🛡️  CUSTOM PC REPUBLIC  🛡️                                 ║
║         IT Synergy Energy for the Republic                              ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
```

# GitHub Secrets Configuration Guide

This document provides guidance on setting up GitHub Secrets for automated CI/CD pipelines, cloud deployments, and notifications.

---

## Table of Contents

- [Overview](#overview)
- [Security Best Practices](#security-best-practices)
- [Available Secrets](#available-secrets)
- [Setup Instructions](#setup-instructions)
- [Workflow Integration](#workflow-integration)
- [Troubleshooting](#troubleshooting)

---

## Overview

GitHub Secrets are encrypted environment variables used in GitHub Actions workflows. They enable secure storage of:

- ✅ Cloud credentials (Azure, AWS)
- ✅ API tokens and keys
- ✅ Deployment credentials
- ✅ Notification webhooks
- ✅ Code signing certificates

### Why Use Secrets?

- **Security:** Credentials never appear in logs or code
- **Automation:** Enables CI/CD without manual intervention
- **Consistency:** Same secrets used across workflows
- **Auditability:** GitHub logs secret usage

### Secret Types

| Type | Description | Scope |
|------|-------------|-------|
| **Repository Secrets** | Available to all workflows in repo | This repo only |
| **Organization Secrets** | Available to all repos in organization | Entire organization |
| **Environment Secrets** | Environment-specific (dev, staging, prod) | Specific environment |

---

## Security Best Practices

### ⚠️ Critical Guidelines

1. **Never Commit Secrets**
   - ❌ Don't hardcode credentials
   - ❌ Don't commit .env files
   - ❌ Don't commit API keys

2. **Use Repository Secrets**
   - ✅ Store in GitHub Secrets
   - ✅ Use for each repository
   - ✅ Rotate regularly

3. **Principle of Least Privilege**
   - ✅ Create service accounts for automation
   - ✅ Grant minimum required permissions
   - ✅ Use read-only where possible
   - ✅ Separate secrets by function

4. **Access Control**
   - ✅ Limit who can manage secrets
   - ✅ Use branch protection rules
   - ✅ Require PR reviews
   - ✅ Audit secret usage

5. **Secret Rotation**
   - ✅ Rotate credentials quarterly
   - ✅ Immediately rotate exposed secrets
   - ✅ Use secret expiration dates
   - ✅ Keep rotation log

### Secret Naming Convention

```
{SERVICE}_{ENVIRONMENT}_{CREDENTIAL_TYPE}

Examples:
AZURE_PROD_STORAGE_KEY
AWS_DEV_ACCESS_KEY_ID
PACKER_VARS_WINDOWS_ISO
SLACK_WEBHOOK_DEPLOYMENTS
GITHUB_TOKEN_REPO_ACCESS
```

---

## Available Secrets

### Azure Credentials

#### `AZURE_SUBSCRIPTION_ID`

**Description:** Azure subscription ID for resource deployment

**Format:** `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

**How to Obtain:**
```bash
az account show --query id --output tsv
```

**Usage:** Azure VM creation, image uploads, resource group deployment

#### `AZURE_CLIENT_ID`

**Description:** Azure service principal client ID

**Format:** `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

**How to Obtain:**
```bash
az ad sp create-for-rbac --name "GithubActions" --query appId
```

**Usage:** Authentication for Azure CLI

#### `AZURE_CLIENT_SECRET`

**Description:** Azure service principal password

**Format:** Long alphanumeric string

**⚠️ Security:** Generate new secret periodically

**How to Obtain:**
```bash
az ad sp create-for-rbac --name "GithubActions" --query password
```

#### `AZURE_TENANT_ID`

**Description:** Azure tenant (directory) ID

**Format:** `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx`

**How to Obtain:**
```bash
az account show --query tenantId --output tsv
```

---

### AWS Credentials

#### `AWS_ACCESS_KEY_ID`

**Description:** AWS IAM access key ID

**Format:** `AKIA...` (20 characters)

**How to Obtain:**
```bash
aws iam create-access-key --user-name github-actions
```

**Usage:** AWS CLI and SDK authentication

#### `AWS_SECRET_ACCESS_KEY`

**Description:** AWS IAM secret access key

**Format:** Long alphanumeric string (40 characters)

**⚠️ Security:** Generate new keys regularly

**How to Obtain:**
```bash
aws iam create-access-key --user-name github-actions
```

#### `AWS_DEFAULT_REGION`

**Description:** Default AWS region for deployments

**Format:** `us-east-1`, `eu-west-1`, etc.

**Common Values:**
- `us-east-1` - US East (N. Virginia)
- `us-west-2` - US West (Oregon)
- `eu-west-1` - EU (Ireland)
- `ap-southeast-1` - Asia Pacific (Singapore)

---

### Packer Variables

#### `PACKER_VAR_WINDOWS_ISO`

**Description:** Path or URL to Windows ISO file

**Format:** Local path or public URL

**Examples:**
- `C:\ISOs\Windows11Enterprise.iso`
- `https://example.com/Windows11.iso`

**Usage:** Packer build configuration

#### `PACKER_VAR_HYPERV_HOST`

**Description:** Hyper-V host system

**Format:** Hostname or IP address

**Usage:** Remote Hyper-V deployment

#### `PACKER_VAR_VMWARE_HOST`

**Description:** VMware ESXi host

**Format:** Hostname or IP address

**Usage:** VMware VM creation

---

### Slack Notifications

#### `SLACK_WEBHOOK_DEPLOYMENTS`

**Description:** Slack webhook URL for deployment notifications

**Format:** `https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX`

**How to Obtain:**
1. Go to Slack workspace
2. Create new Slack app at https://api.slack.com/apps
3. Enable Incoming Webhooks
4. Create new webhook to channel
5. Copy webhook URL

**Usage:** Post build/deployment notifications to Slack

**⚠️ Security:** Webhook URLs are secret, treat as credentials

---

### GitHub Token

#### `GITHUB_TOKEN`

**Description:** GitHub personal access token for repository access

**Format:** `ghp_...` (GitHub Personal Access Token)

**Permissions Needed:**
- `repo` - Full repository access
- `workflow` - GitHub Actions workflows
- `admin:repo_hook` - Webhooks
- `admin:public_repo` - Public repo management

**How to Obtain:**
1. GitHub Settings → Developer settings → Personal access tokens
2. Click "Generate new token"
3. Select required scopes
4. Copy token (only shown once!)

**⚠️ Security:** Treat like password, never share

**Usage:**
- Release automation
- Automated PR creation
- Repository management

---

### Code Signing Certificates

#### `CODESIGN_CERTIFICATE_B64`

**Description:** Base64-encoded code signing certificate

**Format:** Base64 string of .pfx file

**How to Encode:**
```powershell
$cert = [System.IO.File]::ReadAllBytes("cert.pfx")
$encoded = [Convert]::ToBase64String($cert)
$encoded | Set-Clipboard
```

**Usage:** Signing PowerShell scripts or executables

**⚠️ Security:** Protect certificate and password

#### `CODESIGN_CERTIFICATE_PASSWORD`

**Description:** Password for code signing certificate

**Usage:** Unlock certificate for signing

---

### API Keys

#### `DOCKERHUB_USERNAME`

**Description:** Docker Hub username

**Format:** Docker username

**Usage:** Docker image push/pull authentication

#### `DOCKERHUB_TOKEN`

**Description:** Docker Hub access token

**Format:** Docker access token (not password!)

**How to Obtain:**
1. Docker Hub account settings
2. Security → Access Tokens
3. Create new token
4. Copy token immediately

**⚠️ Security:** Use access token, not password

---

## Setup Instructions

### Step 1: Navigate to Secrets Settings

```
GitHub Repository
→ Settings
→ Secrets and variables
→ Actions
```

### Step 2: Create New Secret

1. Click "New repository secret"
2. Enter name (use naming convention)
3. Enter secret value
4. Click "Add secret"

### Step 3: Verify Secret Created

- Check list shows new secret
- Value displays as `●●●●●●●●` (masked)
- Name is available for workflow reference

### Step 4: Update Workflows

Reference secrets in GitHub Actions:

```yaml
- name: Deploy to Azure
  env:
    AZURE_CREDENTIALS: ${{ secrets.AZURE_CREDENTIALS }}
    AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
  run: |
    # Workflow commands using secrets
```

---

## Workflow Integration

### Using Secrets in Workflows

#### PowerShell Example

```yaml
name: Deploy with Hardening

on: [push]

jobs:
  deploy:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Deploy Image
        shell: powershell
        env:
          AZURE_SUBSCRIPTION_ID: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          AZURE_CLIENT_ID: ${{ secrets.AZURE_CLIENT_ID }}
          AZURE_CLIENT_SECRET: ${{ secrets.AZURE_CLIENT_SECRET }}
          AZURE_TENANT_ID: ${{ secrets.AZURE_TENANT_ID }}
        run: |
          .\deployment\Deploy-Image.ps1 `
            -SubscriptionId $env:AZURE_SUBSCRIPTION_ID `
            -ClientId $env:AZURE_CLIENT_ID
```

#### Bash Example

```yaml
- name: Build with Packer
  env:
    AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
    AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
    PACKER_VAR_WINDOWS_ISO: ${{ secrets.PACKER_VAR_WINDOWS_ISO }}
  run: |
    packer build build/packer/windows11-enterprise.pkr.hcl
```

### Sensitive Data Handling

**Good:**
```powershell
# Secrets passed via environment variables
$password = $env:SECRET_PASSWORD
```

**Bad:**
```powershell
# Hardcoding secrets (NEVER do this!)
$password = "MySecretPassword123"
```

### Masking Output

Prevent secrets from appearing in logs:

```yaml
- name: Masked operation
  run: |
    echo "::add-mask::${{ secrets.SENSITIVE_VALUE }}"
    # Now ${{ secrets.SENSITIVE_VALUE }} will show as *** in logs
```

---

## Required Secrets by Workflow

### Basic Build Workflow

**Minimal Secrets Needed:**
- GitHub repository read access (automatic)

### Cloud Deployment Workflow

**Azure Deployment:**
- `AZURE_SUBSCRIPTION_ID`
- `AZURE_CLIENT_ID`
- `AZURE_CLIENT_SECRET`
- `AZURE_TENANT_ID`

**AWS Deployment:**
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

### Full CI/CD Pipeline

**Build & Deploy:**
- Cloud credentials (Azure or AWS)
- Packer variables
- Code signing certificate (optional)

**Notifications:**
- `SLACK_WEBHOOK_DEPLOYMENTS`

**Repository:**
- `GITHUB_TOKEN` (usually automatic)

---

## Secret Rotation Schedule

### Quarterly Rotation

**Every 3 months:**
- [ ] Rotate Azure service principal secret
- [ ] Rotate AWS access keys
- [ ] Rotate code signing certificates
- [ ] Review secret access logs
- [ ] Audit secret usage

### Immediate Rotation

**If exposed or compromised:**
- [ ] Rotate immediately
- [ ] Update all dependent workflows
- [ ] Review access logs
- [ ] Disable old credential
- [ ] Notify team members

### Rotation Checklist

```
1. Generate new credential
2. Create new GitHub secret
3. Update workflows to use new secret
4. Test workflows pass
5. Disable/delete old credential
6. Document rotation in security log
7. Confirm no workflow failures
```

---

## Troubleshooting

### Issue: Secret Not Available in Workflow

**Symptoms:** Workflow fails with "undefined variable" or "secret not found"

**Solutions:**
1. Check secret name spelling (case-sensitive)
2. Verify secret exists in Settings → Secrets
3. Check workflow references correct secret: `${{ secrets.SECRET_NAME }}`
4. Ensure workflow has access to secrets
5. Re-save workflow file (may need to re-run)

### Issue: Secret Appears in Logs

**Symptoms:** Sensitive data visible in GitHub Actions logs

**Solutions:**
1. ✅ GitHub automatically masks known secrets
2. If still visible, use `::add-mask::`
3. Rotate exposed secret immediately
4. Review who has access to logs

### Issue: Authentication Fails

**Symptoms:** Workflow fails with "unauthorized" or "authentication error"

**Solutions:**
1. Verify credentials are current
2. Check service account permissions
3. Confirm environment variables are set
4. Test credentials manually
5. Check for special characters needing escaping

### Issue: Cannot Add Secret (Permission Denied)

**Symptoms:** "You don't have permission to manage secrets"

**Solutions:**
1. Check you have admin access to repository
2. Organization may have restricted secret management
3. Contact repository admin
4. Use branch-level secrets if available

---

## Best Practices

### ✅ Do

- ✅ Use strong, random passwords
- ✅ Rotate secrets quarterly
- ✅ Use service accounts for automation
- ✅ Grant minimum required permissions
- ✅ Monitor secret usage logs
- ✅ Document where each secret is used
- ✅ Use branch protection rules
- ✅ Require PR reviews

### ❌ Don't

- ❌ Hardcode secrets in code
- ❌ Commit .env files
- ❌ Share secrets via Slack/email
- ❌ Use personal passwords for automation
- ❌ Reuse same secret across all repos
- ❌ Leave secrets in code comments
- ❌ Ignore rotation schedule

---

## Emergency Procedures

### If Secret Is Compromised

1. **Immediately:**
   - [ ] Identify which secret was exposed
   - [ ] Note time and location of exposure
   - [ ] Disable exposed credential (if possible)

2. **Within 1 Hour:**
   - [ ] Generate new secret
   - [ ] Update GitHub secret
   - [ ] Update all workflows
   - [ ] Test workflows

3. **Within 24 Hours:**
   - [ ] Audit logs for unauthorized access
   - [ ] Check for suspicious deployments
   - [ ] Notify relevant teams
   - [ ] Document incident

4. **Follow Up:**
   - [ ] Review how exposure occurred
   - [ ] Implement preventive measures
   - [ ] Update security procedures
   - [ ] Share lessons learned

---

## References

### GitHub Documentation

- [GitHub Secrets Documentation](https://docs.github.com/en/actions/security-guides/encrypted-secrets)
- [GitHub Actions Best Practices](https://docs.github.com/en/actions/guides/security-hardening-for-github-actions)

### Cloud Provider Documentation

- [Azure Service Principals](https://docs.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

### Security Standards

- [OWASP Secrets Management](https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html)

---

## Support

**Questions about secrets setup?**

- Check GitHub documentation first
- Review examples in this guide
- Contact security@custompc.local
- Open GitHub issue with `[SECRETS]` tag

---

**Custom PC Republic - Enterprise Hardening Solutions**  
*IT Synergy Energy for the Republic* 🛡️

**Last Updated:** April 19, 2026  
**Organization:** Custom PC Republic  

⚠️ **Keep your secrets safe!**

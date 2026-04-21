# Windows Server 2022 Hardened Image Builder

Comprehensive Packer configuration for building enterprise-grade hardened Windows Server 2022 images with CIS Level 2 security controls, BitLocker encryption, and multi-hypervisor support.

## Overview

This configuration automates the creation of production-ready Windows Server 2022 images optimized for:

- **Security**: CIS Level 2 Mandatory hardening applied during build
- **Encryption**: BitLocker Full Disk Encryption with TPM 2.0 support
- **Enterprise**: WSUS integration, domain-ready, audit logging enabled
- **Flexibility**: Support for Standard and Datacenter editions
- **Compatibility**: Hyper-V (Gen1/Gen2), VMware ESXi/Workstation

## Architecture

```
build/packer/
├── windows-server-2022.pkr.hcl       # Main Packer configuration
├── variables.pkr.hcl                  # Shared and Server 2022 variables
└── provisioners/
    ├── install-server-updates.ps1     # OS updates and feature management
    ├── configure-bitlocker.ps1        # BitLocker and TPM setup
    ├── configure-server-manager.ps1   # Administrative hardening
    └── sysprep-answer.xml             # Sysprep configuration for generalization

examples/
└── build-server-2022.ps1              # Build automation wrapper script
```

## Configuration Details

### Editions Supported

- **Standard Edition**: Suitable for single-server deployments
- **Datacenter Edition**: For cluster/multi-server environments with unlimited VM rights

### Hypervisor Support

| Hypervisor | Boot Mode | Generation | Features |
|-----------|-----------|-----------|----------|
| Hyper-V | UEFI | Gen 2 | Secure Boot, TPM 2.0, UEFI firmware |
| Hyper-V | BIOS | Gen 1 | Legacy BIOS, No Secure Boot |
| VMware | UEFI | vSphere 7.0+ | vMotion compatible, thin provisioning |

### Default Resource Configuration

| Resource | Default | Adjustable |
|----------|---------|-----------|
| vCPU | 4 cores | via `vm_cpu` variable |
| RAM | 8 GB | via `vm_memory` variable |
| Disk | 60 GB | via `disk_size` variable |
| Boot | UEFI | via hypervisor selection |
| Secure Boot | Enabled | Automatic per firmware |

## Security Features

### CIS Level 2 Hardening

All CIS Level 2 Mandatory controls are applied including:

- Firewall policy enforcement
- User Account Control (UAC) hardening
- Windows Defender configuration
- PowerShell logging and restrictions
- Audit policy configuration
- Registry security settings
- Service hardening
- Protocol security (TLS 1.2+)

See `hardening/CIS_Level2_Mandatory.ps1` for specific controls applied.

### BitLocker Encryption

- **UEFI Systems**: TPM 2.0 protector with recovery password
- **BIOS Systems**: Password protector
- **Recovery Keys**: Automatically backed up to `C:\provisioning\`
- **Startup**: Automatic unlock for system drive

### Administrative Security

- Remote Desktop Protocol (RDP) hardened with SSL/TLS
- Network Level Authentication (NLA) enforced
- Windows Remote Management (WinRM) secured
- User Account Control (UAC) enforced for admin tasks
- Administrative audit logging enabled

## Building Images

### Prerequisites

1. **Packer** >= 1.7.0
2. **Windows Server 2022 ISO** (Standard or Datacenter edition)
3. **Hypervisor** (Hyper-V or VMware)
4. **Administrator Privileges** on build host
5. **Disk Space**: Minimum 60 GB free for temporary images

### Quick Start

#### Build Standard Edition for Hyper-V UEFI

```powershell
.\examples\build-server-2022.ps1 -Edition Standard -Hypervisor HypervUEFI
```

#### Build Datacenter Edition for Hyper-V BIOS

```powershell
.\examples\build-server-2022.ps1 -Edition Datacenter -Hypervisor HypervBIOS
```

#### Build for VMware

```powershell
.\examples\build-server-2022.ps1 -Edition Standard -Hypervisor VMware
```

### Advanced Usage

#### Custom ISO Path

```powershell
.\examples\build-server-2022.ps1 `
    -Edition Datacenter `
    -Hypervisor HypervUEFI `
    -ISOPath "D:\ISOs\WindowsServer2022.iso" `
    -ISOChecksumFile "D:\ISOs\WindowsServer2022.sha256"
```

#### Validation Only (Dry Run)

```powershell
.\examples\build-server-2022.ps1 -Edition Standard -DryRun $true
```

#### Debug Mode

```powershell
.\examples\build-server-2022.ps1 -Edition Standard -DebugMode $true
```

### Direct Packer Commands

If using Packer directly instead of the wrapper script:

```bash
# Initialize Packer plugins
cd build/packer
packer init .

# Validate configuration
packer validate `
  -var="server_edition=Standard" `
  -var="server_2022_iso_path=C:\ISOs\WindowsServer2022.iso" `
  .

# Build Standard Edition
packer build `
  -only=windows-server-2022-hyperv-uefi `
  -var="server_edition=Standard" `
  -var="server_2022_iso_path=C:\ISOs\WindowsServer2022.iso" `
  .

# Build Datacenter Edition
packer build `
  -only=windows-server-2022-hyperv-uefi `
  -var="server_edition=Datacenter" `
  -var="server_2022_iso_path=C:\ISOs\WindowsServer2022-Datacenter.iso" `
  .
```

## Configuration Files

### windows-server-2022.pkr.hcl

Main Packer configuration defining:

- **Three build sources**:
  - `hyperv-iso.windows_server_2022_uefi`: Hyper-V Gen 2 (UEFI)
  - `hyperv-iso.windows_server_2022_bios`: Hyper-V Gen 1 (BIOS)
  - `vmware-iso.windows_server_2022_vmware`: VMware ESXi/Workstation

- **Three build blocks**:
  - `windows-server-2022-hyperv-uefi`: Build for Hyper-V UEFI
  - `windows-server-2022-hyperv-bios`: Build for Hyper-V BIOS
  - `windows-server-2022-vmware`: Build for VMware

- **Provisioning chain**:
  1. System readiness verification
  2. Provisioner file deployment
  3. Windows Update installation
  4. CIS Level 2 hardening application
  5. BitLocker/TPM configuration
  6. Server Manager hardening
  7. Sysprep generalization

### variables.pkr.hcl

Defines all variables used across configurations:

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `server_edition` | string | Standard | Server edition (Standard/Datacenter) |
| `server_2022_iso_path` | string | C:\ISOs\... | Windows Server 2022 ISO path |
| `server_2022_iso_checksum_file` | string | C:\ISOs\... | ISO SHA256 checksum file |
| `server_domain` | string | (empty) | Optional domain to join |
| `vm_memory` | number | 8192 | VM RAM in MB |
| `vm_cpu` | number | 4 | CPU core count |
| `disk_size` | number | 61440 | Disk size in MB (60 GB) |
| `enable_bitlocker` | bool | true | Enable BitLocker encryption |
| `enable_tpm` | bool | true | Enable TPM 2.0 support |

### Provisioner Scripts

#### install-server-updates.ps1

- Enables Windows Update service
- Searches for and installs available updates
- Configures WSUS client settings
- Disables unnecessary Windows features
- Configures Server Manager
- Sets up administrative RDP with security hardening
- Hardens .NET Framework TLS

#### configure-bitlocker.ps1

- Detects system boot mode (UEFI/BIOS)
- Enables TPM 2.0 support
- Configures BitLocker Group Policy
- Enables BitLocker on system drive
- Backs up recovery keys
- Configures BitLocker auditing

#### configure-server-manager.ps1

- Disables Server Manager auto-launch
- Hardens RPC and DCOM
- Configures WinRM for remote management
- Secures HTTPS-only communication
- Hardens UAC for administrative tasks
- Enables administrative audit logging

#### sysprep-answer.xml

Unattend configuration for Sysprep:

- Generic computer name (SERVER2022)
- DHCP network configuration
- DNS configuration
- OOBE settings
- Administrator account setup
- Auto-login disabled
- IE Enhanced Security enabled
- Windows Defender enabled

## Build Process Timeline

### Build Stages

1. **Initialization** (1 minute)
   - Packer plugin loading
   - Variable validation
   - Image template creation

2. **OS Installation** (5-10 minutes)
   - VM provisioning
   - Windows Server 2022 installation
   - Driver installation

3. **Updates & Features** (15-20 minutes)
   - Windows Update search and install
   - Feature configuration
   - Role/feature management

4. **Hardening & Security** (5-10 minutes)
   - CIS Level 2 controls applied
   - BitLocker configuration
   - Administrative security setup

5. **Sysprep & Cleanup** (5 minutes)
   - System generalization
   - Provisioning files cleanup
   - Image finalization

**Total Build Time**: 30-45 minutes (first build with updates)
**Subsequent Builds**: 20-30 minutes (if no updates available)

## Output Images

### Manifest Files

Build completion generates manifest JSON files:

- `manifest-ws2022-hyperv-uefi.json`: Hyper-V UEFI build metadata
- `manifest-ws2022-hyperv-bios.json`: Hyper-V BIOS build metadata
- `manifest-ws2022-vmware.json`: VMware build metadata

### Image Locations

**Hyper-V**: Exported VHD/VHDX in Packer output directory
**VMware**: VMDK files ready for vSphere import

## Variables Reference

### Server Edition Variables

```hcl
# Windows Server 2022 Edition
variable "server_edition" {
  type        = string
  description = "Standard or Datacenter"
  default     = "Standard"
}

# Licensing Type
variable "server_licensing_type" {
  type        = string
  description = "RETAIL, VOLUME, or MSDN"
  default     = "VOLUME"
}

# Optional Domain Join
variable "server_domain" {
  type        = string
  description = "Domain to join post-build (leave empty to skip)"
  default     = ""
}
```

### Resource Configuration Variables

```hcl
variable "vm_memory" {
  type        = number
  description = "RAM in MB (recommended: 8192+ for Server)"
  default     = 8192
}

variable "vm_cpu" {
  type        = number
  description = "CPU cores (recommended: 4+)"
  default     = 4
}

variable "disk_size" {
  type        = number
  description = "Disk size in MB (recommended: 61440+ = 60 GB)"
  default     = 61440
}
```

### Security Variables

```hcl
variable "enable_bitlocker" {
  type        = bool
  description = "Enable BitLocker encryption"
  default     = true
}

variable "enable_tpm" {
  type        = bool
  description = "Enable TPM 2.0 (requires UEFI)"
  default     = true
}
```

## Troubleshooting

### Build Failures

#### WinRM Connection Timeout

**Symptom**: Build hangs at WinRM connection step

**Solution**:
- Increase `winrm_timeout` in HCL
- Verify Windows is fully installed before WinRM becomes available
- Check Packer logs: `$env:PACKER_LOG=1`

#### Windows Update Hangs

**Symptom**: Build stuck on Windows Update phase

**Solution**:
- Retry build (some updates require restart)
- Consider disabling Windows Update: `-var="skip_windows_update=true"`
- Manually stage critical updates in provisioner

#### BitLocker Already Enabled

**Symptom**: BitLocker enable fails because it's already active

**Solution**:
- Script checks for existing BitLocker status
- If building from existing image with BitLocker, consider:
  - Disabling BitLocker before building
  - Using separate unencrypted staging build

#### Sysprep Fails

**Symptom**: Build fails at Sysprep stage

**Solution**:
- Verify Sysprep hasn't already run on source VM
- Check sysprep-answer.xml is properly formatted
- Review Windows logs: `C:\Windows\System32\Sysprep\Panther\`

### Performance Issues

#### Build Too Slow

**Optimization**:
- Increase `vm_memory` and `vm_cpu` for parallel operations
- Use SSD storage for VM temporary files
- Pre-cache Windows updates on local cache

#### Network Latency

**Optimization**:
- Place ISO on local high-speed storage
- Configure local Windows Update cache
- Use direct HTTPS for WinRM instead of HTTP

## Security Compliance

### CIS Benchmarks

- **CIS Level 1**: Applicable to all deployments
- **CIS Level 2**: Mandatory controls applied in this build
- **CIS Level 2 Only**: Controls requiring specific infrastructure

### NIST Framework Alignment

- **AM**: Asset Management - Automated inventory via image metadata
- **ID**: Identification - Local accounts and audit trails
- **PR**: Protection - BitLocker, firewall, hardened protocols
- **DE**: Detection - Audit logging configured
- **RS**: Response - Event logging for incident response
- **RC**: Recovery - Snapshot capability via hypervisor

### Compliance Validation

After build, validate hardening:

```powershell
# Verify hardening applied
& 'C:\hardening\Verify-CIS-Compliance.ps1'

# Check BitLocker status
Get-BitLockerVolume

# Verify audit policies
auditpol /get /category:*
```

## Advanced Customization

### Modify Hardening Controls

Edit `hardening/CIS_Level2_Mandatory.ps1` to customize controls:

```powershell
# In build provisioner
provisioner "powershell" {
  inline = [
    "& 'C:\\provisioning\\cis-hardening-server.ps1' " +
    "-RollbackPoint $true"
  ]
}
```

### Add Additional Provisioners

Add new provisioners to `windows-server-2022.pkr.hcl`:

```hcl
provisioner "powershell" {
  script = "${path.root}/provisioners/custom-role-setup.ps1"
}
```

### Create Edition-Specific Builds

Add conditions in provisioners:

```powershell
if ($env:SERVER_EDITION -eq "Datacenter") {
  # Datacenter-specific configuration
}
```

### Custom Post-Build Steps

Modify Sysprep or add post-processors:

```hcl
post-processor "manifest" {
  output     = "manifest-custom.json"
  strip_path = true
}
```

## Integration with CI/CD

### GitHub Actions

```yaml
- name: Build Server 2022 Image
  run: |
    & '.\examples\build-server-2022.ps1' `
      -Edition ${{ matrix.edition }} `
      -Hypervisor HypervUEFI
```

### Azure Pipelines

```yaml
- task: PowerShell@2
  inputs:
    targetType: 'filePath'
    filePath: '$(Build.SourcesDirectory)/examples/build-server-2022.ps1'
    arguments: '-Edition Standard -Hypervisor HypervUEFI'
```

## Best Practices

1. **Test Builds**: Run with `-DryRun $true` first
2. **Log Review**: Check build logs for warnings
3. **Version Control**: Track ISO checksums and build parameters
4. **Update Frequency**: Rebuild quarterly for security patches
5. **Backup Recovery Keys**: Store BitLocker keys securely
6. **Documentation**: Document any custom modifications
7. **Access Control**: Restrict build artifact access

## Resources

- [Packer Documentation](https://www.packer.io/docs)
- [Windows Server 2022 Documentation](https://learn.microsoft.com/en-us/windows-server/)
- [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/)
- [BitLocker Documentation](https://learn.microsoft.com/en-us/windows/security/information-protection/bitlocker/bitlocker-overview)

## Support and Maintenance

### Build Log Locations

- **Wrapper Script Logs**: `examples/logs/build-*.log`
- **Packer Debug Logs**: Set `$env:PACKER_LOG=1` and check Packer output

### Troubleshooting Guide

See `docs/BUILD_TROUBLESHOOTING.md` for detailed troubleshooting steps.

### Updates and Changes

Check `CHANGELOG.md` for latest updates to:
- Packer plugin versions
- Windows Server 2022 patch levels
- CIS benchmark updates
- Security hardening changes

---

**Last Updated**: April 2026
**Version**: 1.0
**Status**: Production Ready

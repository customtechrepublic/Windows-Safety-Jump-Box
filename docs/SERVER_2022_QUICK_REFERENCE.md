# Windows Server 2022 Build - Quick Reference

## Files Created

| File | Purpose |
|------|---------|
| `build/packer/windows-server-2022.pkr.hcl` | Main Packer configuration for Server 2022 |
| `build/packer/variables.pkr.hcl` | Updated with Server 2022 variables |
| `build/packer/provisioners/install-server-updates.ps1` | OS updates and feature management |
| `build/packer/provisioners/configure-bitlocker.ps1` | BitLocker and TPM setup |
| `build/packer/provisioners/configure-server-manager.ps1` | Administrative hardening |
| `build/packer/provisioners/sysprep-answer.xml` | Sysprep generalization config |
| `examples/build-server-2022.ps1` | Build automation wrapper |
| `docs/WINDOWS_SERVER_2022_BUILD.md` | Complete documentation |

## Quick Start Commands

### Build Standard Edition (Hyper-V UEFI)
```powershell
.\examples\build-server-2022.ps1 -Edition Standard -Hypervisor HypervUEFI
```

### Build Datacenter Edition (Hyper-V BIOS)
```powershell
.\examples\build-server-2022.ps1 -Edition Datacenter -Hypervisor HypervBIOS
```

### Build for VMware
```powershell
.\examples\build-server-2022.ps1 -Edition Standard -Hypervisor VMware
```

### Validate Configuration (Dry Run)
```powershell
.\examples\build-server-2022.ps1 -Edition Standard -DryRun $true
```

## Build Options

| Parameter | Options | Default |
|-----------|---------|---------|
| `-Edition` | Standard, Datacenter | Standard |
| `-Hypervisor` | HypervUEFI, HypervBIOS, VMware | HypervUEFI |
| `-ISOPath` | File path | C:\ISOs\WindowsServer2022.iso |
| `-DebugMode` | $true, $false | $false |
| `-DryRun` | $true, $false | $false |

## System Defaults

- **Memory**: 8 GB RAM
- **CPUs**: 4 cores
- **Disk**: 60 GB
- **Secure Boot**: Enabled (UEFI)
- **TPM**: 2.0 (UEFI)
- **BitLocker**: Enabled
- **RDP**: Secured (SSL/TLS + NLA)
- **WinRM**: HTTPS only

## Security Features Applied

✓ CIS Level 2 Mandatory hardening
✓ BitLocker Full Disk Encryption
✓ TPM 2.0 support (UEFI)
✓ Windows Defender enabled
✓ Firewall hardened
✓ RDP secured
✓ WinRM HTTPS-only
✓ Audit logging
✓ Weak protocols disabled (TLS 1.2+)

## Build Time

- **First Build**: 30-45 minutes (includes Windows Update)
- **Subsequent**: 20-30 minutes

## Output Files

- **Hyper-V**: VHD/VHDX files in build output
- **VMware**: VMDK files
- **Manifest**: manifest-ws2022-*.json

## Variable Customization

Override defaults with `-var` flag:

```powershell
.\examples\build-server-2022.ps1 `
  -Edition Standard `
  -Hypervisor HypervUEFI `
  -ISOPath "D:\Custom\WindowsServer2022.iso" `
  -WinRMPassword "YourPassword123!@#"
```

## Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| WinRM timeout | Windows slow to boot | Increase vm_memory or disable unnecessary services |
| Windows Update hangs | Large update queue | Retry or skip with variables |
| BitLocker fails | Already enabled | Check existing BitLocker status |
| Sysprep fails | Already generalized | Use fresh source VM |

## Logs

- Build logs: `examples/logs/build-*.log`
- Packer debug: Set `$env:PACKER_LOG=1`

## Architecture

```
Hyper-V (UEFI/BIOS) ─┐
                     ├─ Packer ─ Windows Update ─ CIS Hardening ─ BitLocker ─ Sysprep
VMware (UEFI) ──────┘
```

## Edition Comparison

| Feature | Standard | Datacenter |
|---------|----------|-----------|
| Cost | Lower | Higher |
| VMs | Restricted | Unlimited |
| Clustering | Basic | Advanced |
| Storage Spaces | Limited | Full |
| Hyper-V | Basic | Advanced |
| Licensing | Per-core | Per-core |

## Next Steps

1. **Verify Prerequisites**:
   - Packer installed
   - Windows Server 2022 ISO available
   - Hypervisor configured

2. **Run First Build**:
   ```powershell
   .\examples\build-server-2022.ps1 -Edition Standard -DryRun $true
   ```

3. **Execute Full Build**:
   ```powershell
   .\examples\build-server-2022.ps1 -Edition Standard
   ```

4. **Deploy Image**:
   - Import VHDX/VMDK to hypervisor
   - Configure network and storage
   - Join domain if needed

5. **Post-Deployment**:
   - Run `Verify-CIS-Compliance.ps1`
   - Configure roles/features as needed
   - Configure monitoring and backups

## Documentation

- Full guide: `docs/WINDOWS_SERVER_2022_BUILD.md`
- CIS Controls: `hardening/CIS_Level2_Mandatory.ps1`
- Examples: `examples/build-server-2022.ps1` (inline comments)

## Support

- Check build logs for errors
- Enable debug mode: `-DebugMode $true`
- Review Packer documentation: https://www.packer.io/docs

# Quick Start Template Configuration Format

**File Format:** `.ps1config` (PowerShell Configuration Files)  
**Location:** `/templates/` directory in the repository  
**Usage:** Fetched by `Build-Factory.ps1` from GitHub Raw URLs  

---

## Template Structure

Each template is a PowerShell hashtable that defines:
1. Metadata (name, description, compatibility)
2. Components to remove (AppxPackages, Windows Features)
3. Services to disable
4. AppLocker policy rules
5. Registry hardening rules
6. CIS benchmark mapping

---

## Example: JumpBox.ps1config

```powershell
@{
    # ===== METADATA =====
    TemplateName = "Secure Jump Box"
    TemplateID = "jumpbox-001"
    Version = "1.0"
    Author = "Custom PC Republic"
    Description = "Network administration workstation. Hardened for remote management via SSH/RDP."
    
    # ===== COMPATIBILITY =====
    TargetOS = @("Pro", "Enterprise")
    MinimumOSVersion = "22000"  # Windows 11
    CISLevel = "Level2"
    
    # ===== COMPONENTS TO REMOVE =====
    RemoveComponents = @(
        # Consumer apps
        "Microsoft.XboxApp",
        "Microsoft.XboxGameOverlay",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.GetHelp",
        "Microsoft.Cortana",
        "Microsoft.Weather",
        "Microsoft.News",
        "Microsoft.SkypeApp",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.OneDriveSync",
        "Microsoft.WindowsMaps",
        "Microsoft.YourPhone",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo",
        # Edge, if not required (keep Edge for security updates)
        # "Microsoft.MicrosoftEdge"
    )
    
    # ===== WINDOWS FEATURES TO DISABLE =====
    DisableWindowsFeatures = @(
        "TelnetClient",
        "TFTP",
        "SMB1Protocol",
        "Printing-PrintToPDFServices",
        "FaxServicesClientPackage"
    )
    
    # ===== SERVICES TO DISABLE =====
    DisableServices = @(
        @{Name="DiagTrack"; DisplayName="DiagTrack (diagnostic tracking)"}
        @{Name="dmwappushservice"; DisplayName="dmwappushservice (Device Management)"}
        @{Name="RemoteRegistry"; DisplayName="Remote Registry"}
        @{Name="RemoteAccess"; DisplayName="Remote Access Service"}
        @{Name="SCardSvr"; DisplayName="Smart Card"}
        @{Name="ScDeviceEnum"; DisplayName="Smart Card Device Enumeration"}
        @{Name="Fax"; DisplayName="Fax Service"}
        @{Name="TapiSrv"; DisplayName="Telephony"}
        @{Name="XblAuthManager"; DisplayName="Xbox Live Auth"}
        @{Name="XblGameSave"; DisplayName="Xbox Live Game Save"}
        @{Name="xbgm"; DisplayName="Xbox Game Monitoring"}
        @{Name="PrintSpooler"; DisplayName="Print Spooler"}
        @{Name="SNMP"; DisplayName="SNMP Service"}
        @{Name="WinRM"; DisplayName="Windows Remote Management"}
    )
    
    # ===== APPLOCKER POLICY =====
    EnableAppLocker = $true
    AppLockerAllowList = @(
        # Microsoft system binaries
        "C:\Windows\System32\*.exe",
        "C:\Windows\SysWOW64\*.exe",
        # PuTTY for SSH
        "C:\Program Files\PuTTY\putty.exe",
        "C:\Program Files (x86)\PuTTY\putty.exe",
        # Remote Desktop
        "C:\Windows\System32\mstsc.exe",
        # PowerShell
        "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe",
        "C:\Program Files\PowerShell\*.exe"
    )
    
    AppLockerDenyList = @(
        # Prevent execution from USB
        "D:\*.exe",
        "E:\*.exe",
        # Prevent suspicious locations
        "C:\Temp\*.exe",
        "%APPDATA%\*.exe"
    )
    
    # ===== REGISTRY HARDENING =====
    RegistryHardening = @(
        @{
            Path = "HKLM:\System\CurrentControlSet\Services\LanmanServer\Parameters"
            Name = "SMB1"
            Value = 0
            Type = "DWORD"
            Description = "Disable SMBv1 protocol"
        }
        @{
            Path = "HKLM:\System\CurrentControlSet\Control\Lsa"
            Name = "RestrictAnonymous"
            Value = 1
            Type = "DWORD"
            Description = "Restrict anonymous user access"
        }
        @{
            Path = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
            Name = "EnableLUA"
            Value = 1
            Type = "DWORD"
            Description = "Enable User Account Control"
        }
    )
    
    # ===== AUDIT POLICIES =====
    EnableAuditPolicies = @(
        "Logon/Logoff",
        "Account Logon",
        "Object Access",
        "Privilege Use",
        "Detailed Tracking",
        "Policy Change",
        "System"
    )
    
    # ===== FIREWALL RULES =====
    FirewallRules = @(
        @{
            Name = "Block LLMNR"
            Direction = "In"
            Protocol = "UDP"
            LocalPort = "5355"
            Action = "Block"
            Description = "Prevent LLMNR poisoning"
        }
        @{
            Name = "Block NetBIOS"
            Direction = "In"
            Protocol = "UDP"
            LocalPort = "137-139"
            Action = "Block"
            Description = "Disable NetBIOS services"
        }
    )
    
    # ===== ADDITIONAL CONFIGURATION =====
    EnableBitLocker = $true
    EnableCredentialGuard = $true
    EnableSecureBoot = $true
    RequireTPM = "2.0"
    
    # ===== CIS BENCHMARK MAPPING =====
    CISControls = @(
        "1.1.1",  # Ensure 'Enforce password history' is set to '24 or more password(s)'
        "1.1.2",  # Ensure 'Maximum password age' is set to '60 or fewer days'
        "1.1.3",  # Ensure 'Minimum password age' is set to '1 or more day(s)'
        # ... (abbreviated for brevity; full list in compliance report)
    )
    
    # ===== COMPLIANCE MAPPING =====
    Compliance = @{
        CIS = "Level2"
        NIST = @("AC-2", "AC-3", "SI-4", "SI-7")
        SOC2 = @("CC6.1", "CC6.2", "CC7.2")
        GDPR = @("32", "33", "34")  # Articles related to security
    }
}
```

---

## Example: Kiosk.ps1config

```powershell
@{
    TemplateName = "Kiosk / Family"
    TemplateID = "kiosk-001"
    Version = "1.0"
    Description = "Locked-down home machine for safe browsing and document editing."
    
    TargetOS = @("Home", "Pro")
    CISLevel = "Custom"
    
    RemoveComponents = @(
        # REMOVE EVERYTHING EXCEPT ESSENTIALS
        "Microsoft.XboxApp",
        "Microsoft.XboxGameOverlay",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.Cortana",
        "Microsoft.OneDrive",  # Prevent cloud sync confusion
        "Microsoft.MicrosoftEdge",  # Use browser policies instead
        # ... (remove all consumer apps)
    )
    
    # Keep ONLY Edge for browsing
    AllowedApplications = @(
        "Microsoft.MicrosoftEdge",  # Edge browser
        "Microsoft.WindowsNotepad",  # Simple notepad
        "Microsoft.Office.Word",    # Office Online if available
    )
    
    # Network: browsing only
    NetworkPolicy = "BrowserOnly"
    DisabledNetworkServices = @(
        "SMB",
        "RDP",
        "Print Spooler",
        "Remote Assistance"
    )
    
    # Shell customization
    ShellReplacement = @{
        Executable = "C:\Windows\System32\explorer.exe"
        Parameters = "/E, /select, C:\Users\Public\Documents"
        HideTaskbar = $true
        HideStartMenu = $true
        CustomLauncher = "C:\Factory\KioskLauncher.exe"  # Custom app launcher (3 icons only)
    }
    
    # Disable sensitive settings
    DisableSettings = @(
        "Control Panel",
        "Settings App (except Language)",
        "Command Prompt",
        "PowerShell",
        "Registry Editor",
        "Device Manager",
        "Task Manager"
    )
    
    # USB access: disabled
    DisableUSB = $true
    
    Compliance = @{
        CIS = "Custom"
        NIST = @("AC-3", "AC-6")
        SOC2 = @("CC6.1")
        GDPR = @("32")
    }
}
```

---

## Example: AppDedicated.ps1config (Quickbooks Server)

```powershell
@{
    TemplateName = "App-Dedicated: Quickbooks"
    TemplateID = "quickbooks-001"
    Version = "1.0"
    Description = "Minimalist server for Quickbooks accounting software only."
    
    TargetOS = @("Pro", "Enterprise", "Server2022")
    CISLevel = "Level2"
    
    # REMOVE EVERYTHING
    RemoveComponents = @(
        # Remove ALL consumer apps
        "*Xbox*",
        "*Cortana*",
        "*Weather*",
        "*News*",
        "*Maps*",
        "*OneDrive*",
        # Remove collaboration
        "*Teams*",
        "*Skype*",
        # Remove media
        "*ZuneMusic*",
        "*ZuneVideo*",
        # Remove browser (headless server, if no UI needed)
        # "*MicrosoftEdge*"
    )
    
    # KEEP ONLY ESSENTIALS
    KeepFeatures = @(
        ".NET Runtime",
        "Network Stack",
        "Windows Defender",
        "Event Logging"
    )
    
    # Only one service: The app itself
    RequiredServices = @(
        "WinDefend",  # Windows Defender
        "EventLog",   # Event logging
        "Networking"  # TCP/IP
    )
    
    # Database: SQL Server Express (if needed)
    PreinstallApps = @(
        @{
            Name = "SQLEXPRESS"
            Installer = "C:\Factory\SQLServerExpress.exe"
            Parameters = "/QUIET"
        }
    )
    
    # Network: License server access only
    NetworkPolicy = "LimitedNetwork"
    AllowedNetworkRanges = @(
        "192.168.1.0/24",      # Internal network
        "10.0.0.0/8"           # Corporate network
    )
    
    # Disable ALL unnecessary services
    DisableServices = @(
        "Print Spooler",
        "SNMP",
        "Remote Registry",
        "Remote Assistance",
        "Bluetooth",
        "Audio"  # If headless
    )
    
    # Firewall: Only allow Quickbooks license server
    FirewallAllowRules = @(
        @{
            Name = "Quickbooks License Server"
            RemoteAddress = "192.168.1.100"
            Port = "55051"
        }
    )
    
    Compliance = @{
        CIS = "Level2"
        NIST = @("AC-2", "AC-3", "SI-7")
        SOC2 = @("CC6.1", "CC7.2")
    }
}
```

---

## Template Validation Rules

When a template is loaded, `Build-Factory.ps1` validates:

1. **Required Fields:**
   - `TemplateName` (string)
   - `TemplateID` (unique identifier)
   - `TargetOS` (array of supported OS editions)

2. **Compatibility Checks:**
   - Selected template supports target OS
   - Required features are available (e.g., Hyper-V on Pro+)
   - BitLocker available (Pro/Enterprise only)

3. **Security Checks:**
   - No conflicting policies
   - AppLocker rules are valid
   - Registry paths exist

4. **Compliance Mapping:**
   - All CIS controls are documented
   - NIST mapping provided
   - SOC2 Trust Services identified

---

## How to Create a Custom Template

1. Copy an existing template (e.g., `JumpBox.ps1config`)
2. Modify the configuration hashtable
3. Test locally: `.\Build-Factory.ps1 -LocalISO "C:\iso\Windows11.iso" -TemplatePreset "YourTemplate"`
4. Submit PR to the repository
5. Community reviews and votes (GitHub reactions)
6. If approved, added to the official registry

---

## References

- [PHILOSOPHY.md](../PHILOSOPHY.md) - Why each template matters
- [MILESTONES.md](../MILESTONES.md) - Development timeline
- [TODO.md](../TODO.md) - Implementation tasks
- [CIS Benchmarks v2.0](https://www.cisecurity.org/cis-benchmarks/)
- [NIST SP 800-53](https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final)
- [SOC2 Trust Service Criteria](https://www.aicpa.org/resources/article/trust-service-criteria)

---

**Custom PC Republic: Functional Specialization, not One-Size-Fits-All**

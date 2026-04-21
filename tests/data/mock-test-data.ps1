# Test Configuration and Mock Data
# This file provides reference data for mock tests

# Mock Registry Paths for Testing
$MockRegistryPaths = @(
    "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters",
    "HKLM:\SOFTWARE\Microsoft\Windows Defender\Real-Time Protection",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System",
    "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers",
    "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces"
)

# Mock Service Names for Testing
$MockServices = @(
    @{ Name = "RpcSs"; DisplayName = "Remote Procedure Call" },
    @{ Name = "LanmanServer"; DisplayName = "Server" },
    @{ Name = "LanmanWorkstation"; DisplayName = "Workstation" },
    @{ Name = "W32Time"; DisplayName = "Windows Time" },
    @{ Name = "BITS"; DisplayName = "Background Intelligent Transfer Service" }
)

# Mock Audit Policies for Testing
$MockAuditPolicies = @(
    "Logon/Logoff",
    "Account Management",
    "Process Creation",
    "File System",
    "Registry",
    "Audit Policy Change",
    "Authentication Policy Change"
)

# Mock CIS Benchmark Controls
$MockCISControls = @{
    "1.1" = @{ 
        Control = "Authentication"
        Description = "Account Lockout Policy"
        Level = 1
    }
    "1.2" = @{ 
        Control = "Authentication"
        Description = "Password Policy"
        Level = 1
    }
    "2.2" = @{ 
        Control = "Administration"
        Description = "Windows Update Automatic Updates"
        Level = 1
    }
    "5.1" = @{ 
        Control = "User Account Control"
        Description = "Enable User Account Control"
        Level = 1
    }
    "10.1" = @{ 
        Control = "Auditing"
        Description = "Logon/Logoff Auditing"
        Level = 2
    }
    "17.1" = @{ 
        Control = "Encryption"
        Description = "Bitlocker Drive Encryption"
        Level = 2
    }
}

# Mock Image Formats Supported
$MockSupportedFormats = @{
    "WIM" = @{
        CanConvertTo = @("VHDX", "ISO")
        Compression = @("none", "fast", "maximum")
        MaxSize = "2TB"
    }
    "VHDX" = @{
        CanConvertTo = @("WIM", "VHD")
        Format = @("Dynamic", "Fixed")
        MaxSize = "16TB"
    }
    "ISO" = @{
        CanConvertTo = @()
        BootMethod = @("UEFI", "BIOS")
        MaxSize = "4GB"
    }
}

# Mock Deployment Scenarios
$MockDeploymentScenarios = @(
    @{
        Name = "StandardDeployment"
        Steps = @(
            "Prepare System",
            "Capture Current State",
            "Apply WIM Image",
            "Run CIS Hardening",
            "Enable BitLocker"
        )
        EstimatedTime = "45 minutes"
    }
    @{
        Name = "SecurityHardenedDeployment"
        Steps = @(
            "Prepare System",
            "Capture Current State",
            "Apply WIM Image",
            "Run CIS Level 1+2 Complete",
            "Enable BitLocker with TPM",
            "Configure ASR Rules",
            "Enable Audit Policies"
        )
        EstimatedTime = "60 minutes"
    }
    @{
        Name = "MinimalDeployment"
        Steps = @(
            "Prepare System",
            "Apply WIM Image"
        )
        EstimatedTime = "20 minutes"
    }
)

# Mock Forensics Tools for Boot Media
$MockForensicsTools = @(
    "FTK Imager",
    "DBAN",
    "Paladin",
    "EnCase",
    "Volatility",
    "Wireshark",
    "OSFortensics"
)

# Mock Function Names to Validate
$MockRequiredFunctions = @(
    "Write-Log",
    "Get-LogPath",
    "Test-Administrator",
    "Backup-Registry",
    "Restore-Registry",
    "Deploy-Image",
    "Enable-BitLocker",
    "Apply-CISHardening",
    "Create-Windows-PE"
)

# Mock Deprecated Functions to Detect
$MockDeprecatedFunctions = @(
    @{ Pattern = "Invoke-Expression"; Reason = "Security risk - code injection" },
    @{ Pattern = "Get-WmiObject"; Reason = "Deprecated in favor of Get-CimInstance" },
    @{ Pattern = "ConvertFrom-SecureString.*-AsPlainText"; Reason = "Exposes secure data" },
    @{ Pattern = "Remove-Item.*-Force -Recurse"; Reason = "Dangerous pattern" }
)

# NIST CSF Functions Mapping
$MockNISTMapping = @{
    "IDENTIFY" = @(
        "Asset Inventory",
        "Data Classification",
        "Access Rights"
    )
    "PROTECT" = @(
        "Access Control",
        "Encryption",
        "Hardening",
        "Backup"
    )
    "DETECT" = @(
        "Monitoring",
        "Logging",
        "Alerting"
    )
    "RESPOND" = @(
        "Incident Handler",
        "Communication Plan",
        "Recovery Plan"
    )
    "RECOVER" = @(
        "Recovery Procedures",
        "Business Continuity",
        "Restoration"
    )
}

# Expected Test Results Baseline
$MockExpectedResults = @{
    SyntaxTests = @{
        PassRate = 95.0
        MaxFailures = 3
    }
    CISTests = @{
        PassRate = 90.0
        MaxFailures = 5
    }
    DeploymentTests = @{
        PassRate = 85.0
        MaxFailures = 5
    }
    ComplianceTests = @{
        PassRate = 88.0
        MaxFailures = 5
    }
    IntegrationTests = @{
        PassRate = 80.0
        MaxFailures = 2
    }
}

# Export for use in tests
Export-ModuleMember -Variable `
    MockRegistryPaths, `
    MockServices, `
    MockAuditPolicies, `
    MockCISControls, `
    MockSupportedFormats, `
    MockDeploymentScenarios, `
    MockForensicsTools, `
    MockRequiredFunctions, `
    MockDeprecatedFunctions, `
    MockNISTMapping, `
    MockExpectedResults

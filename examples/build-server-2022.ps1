<#
.SYNOPSIS
    Windows Server 2022 Packer Build Automation Script
    
.DESCRIPTION
    Comprehensive automation wrapper for building hardened Windows Server 2022 images.
    Supports:
    - Standard and Datacenter editions
    - Multiple hypervisors (Hyper-V UEFI/BIOS, VMware)
    - CIS Level 2 hardening
    - BitLocker encryption
    - Input validation and error handling
    - Build log aggregation

.PARAMETER Edition
    Server edition: Standard or Datacenter (default: Standard)
    
.PARAMETER Hypervisor
    Target hypervisor: HypervUEFI, HypervBIOS, or VMware (default: HypervUEFI)
    
.PARAMETER ISOPath
    Path to Windows Server 2022 ISO file
    (default: C:\ISOs\WindowsServer2022.iso)
    
.PARAMETER ISOChecksumFile
    Path to ISO SHA256 checksum file
    (default: C:\ISOs\Server2022-SHA256SUMS.txt)
    
.PARAMETER WinRMPassword
    WinRM temporary password for provisioning
    (default: Packertemp123!@#)
    
.PARAMETER DebugMode
    Enable debug output (default: $false)
    
.PARAMETER DryRun
    Validate configuration without building (default: $false)

.EXAMPLE
    # Build Standard edition for Hyper-V UEFI
    .\build-server-2022.ps1 -Edition Standard -Hypervisor HypervUEFI
    
.EXAMPLE
    # Build Datacenter edition for VMware
    .\build-server-2022.ps1 -Edition Datacenter -Hypervisor VMware
    
.EXAMPLE
    # Validate configuration only
    .\build-server-2022.ps1 -Edition Standard -DryRun $true
    
.EXAMPLE
    # Build with debug output and custom ISO
    .\build-server-2022.ps1 `
        -Edition Datacenter `
        -Hypervisor HypervBIOS `
        -ISOPath "D:\Windows Server 2022 ISO\en_windows_server_2022_updated_march_2024_x64_dvd.iso" `
        -DebugMode $true

.NOTES
    Requirements:
    - Packer >= 1.7.0
    - Administrator privileges
    - Hyper-V or VMware installed (depending on target)
    - Windows Server 2022 ISO file
    - 60+ GB free disk space for temporary images
    
    Build times:
    - First build: 30-45 minutes (includes Windows Update)
    - Subsequent builds: 20-30 minutes
    
    Log files:
    - Stored in: <script-directory>\logs\build-<timestamp>.log
    - Packer manifest in build directory

#>

param(
    [ValidateSet("Standard", "Datacenter")]
    [string]$Edition = "Standard",
    
    [ValidateSet("HypervUEFI", "HypervBIOS", "VMware")]
    [string]$Hypervisor = "HypervUEFI",
    
    [string]$ISOPath = "C:\ISOs\WindowsServer2022.iso",
    
    [string]$ISOChecksumFile = "C:\ISOs\Server2022-SHA256SUMS.txt",
    
    [string]$WinRMPassword = "Packertemp123!@#",
    
    [bool]$DebugMode = $false,
    
    [bool]$DryRun = $false
)

# ============================================================================
# Script Configuration
# ============================================================================

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$packerDir = Join-Path -Path (Split-Path -Parent $scriptRoot) -ChildPath "build\packer"
$logsDir = Join-Path -Path $scriptRoot -ChildPath "logs"
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$logFile = Join-Path -Path $logsDir -ChildPath "build-ws2022-$timestamp.log"

# Create logs directory if needed
if (-not (Test-Path $logsDir)) {
    New-Item -Path $logsDir -ItemType Directory -Force | Out-Null
}

# ============================================================================
# Helper Functions
# ============================================================================

function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR", "DEBUG")]
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Console output
    switch ($Level) {
        "SUCCESS" { Write-Host $logMessage -ForegroundColor Green }
        "WARNING" { Write-Host $logMessage -ForegroundColor Yellow }
        "ERROR" { Write-Host $logMessage -ForegroundColor Red }
        "DEBUG" { if ($DebugMode) { Write-Host $logMessage -ForegroundColor Gray } }
        default { Write-Host $logMessage -ForegroundColor Cyan }
    }
    
    # Log file
    Add-Content -Path $logFile -Value $logMessage -ErrorAction SilentlyContinue
}

function Test-Prerequisites {
    Write-Log "Validating prerequisites..." -Level INFO
    
    # Check Packer installation
    $packerPath = Get-Command packer -ErrorAction SilentlyContinue
    if (-not $packerPath) {
        Write-Log "ERROR: Packer not found in PATH. Please install Packer >= 1.7.0" -Level ERROR
        return $false
    }
    Write-Log "  ✓ Packer found: $($packerPath.Source)" -Level SUCCESS
    
    # Check ISO file
    if (-not (Test-Path $ISOPath -PathType Leaf)) {
        Write-Log "ERROR: ISO file not found: $ISOPath" -Level ERROR
        return $false
    }
    Write-Log "  ✓ ISO file found: $ISOPath" -Level SUCCESS
    
    # Check ISO checksum file
    if (-not (Test-Path $ISOChecksumFile -PathType Leaf)) {
        Write-Log "WARNING: Checksum file not found: $ISOChecksumFile" -Level WARNING
        Write-Log "Build will proceed without checksum verification" -Level WARNING
    } else {
        Write-Log "  ✓ Checksum file found: $ISOChecksumFile" -Level SUCCESS
    }
    
    # Check Packer files
    $pkrFiles = @(
        "windows-server-2022.pkr.hcl",
        "variables.pkr.hcl",
        "provisioners\install-server-updates.ps1",
        "provisioners\configure-bitlocker.ps1",
        "provisioners\configure-server-manager.ps1",
        "provisioners\sysprep-answer.xml"
    )
    
    foreach ($file in $pkrFiles) {
        $fullPath = Join-Path -Path $packerDir -ChildPath $file
        if (-not (Test-Path $fullPath)) {
            Write-Log "ERROR: Required file not found: $fullPath" -Level ERROR
            return $false
        }
        Write-Log "  ✓ Found: $file" -Level DEBUG
    }
    
    # Check hypervisor availability
    switch ($Hypervisor) {
        "HypervUEFI" -or "HypervBIOS" {
            $hypervStatus = Get-WindowsFeature -Name Hyper-V -ErrorAction SilentlyContinue
            if (-not $hypervStatus -or -not $hypervStatus.Installed) {
                Write-Log "WARNING: Hyper-V does not appear to be installed" -Level WARNING
            } else {
                Write-Log "  ✓ Hyper-V is installed" -Level SUCCESS
            }
        }
        "VMware" {
            Write-Log "  ℹ VMware target selected (verify VMware Workstation/ESXi is accessible)" -Level INFO
        }
    }
    
    return $true
}

function Initialize-Build {
    Write-Log "Initializing build environment..." -Level INFO
    
    # Change to Packer directory
    Push-Location $packerDir
    
    # Initialize Packer
    Write-Log "  - Running packer init..." -Level DEBUG
    & packer init . 2>&1 | Tee-Object -FilePath $logFile -Append | Out-Null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Log "ERROR: Packer init failed" -Level ERROR
        Pop-Location
        return $false
    }
    
    Write-Log "  ✓ Packer initialized" -Level SUCCESS
    return $true
}

function Invoke-Build {
    Write-Log "Starting Packer build..." -Level INFO
    
    # Map hypervisor to Packer build name
    $buildName = "windows-server-2022-$($Hypervisor.ToLower())"
    
    # Build Packer command
    $packerArgs = @(
        "build"
        "-only=$buildName"
        "-var=`"server_edition=$Edition`""
        "-var=`"server_2022_iso_path=$ISOPath`""
        "-var=`"server_2022_iso_checksum_file=$ISOChecksumFile`""
        "-var=`"winrm_password=$WinRMPassword`""
    )
    
    # Add debug flag if requested
    if ($DebugMode) {
        $packerArgs += "-debug"
        $env:PACKER_LOG = "1"
        $env:PACKER_LOG_PATH = (Join-Path $logsDir "packer-debug-$timestamp.log")
    }
    
    $packerCmd = "packer " + ($packerArgs -join " ")
    Write-Log "Build command: $packerCmd" -Level DEBUG
    Write-Log "Edition: $Edition" -Level INFO
    Write-Log "Hypervisor: $Hypervisor" -Level INFO
    Write-Log "Build Name: $buildName" -Level INFO
    Write-Log "" -Level INFO
    
    # Execute build
    $buildOutput = & packer build `
        -only=$buildName `
        -var="server_edition=$Edition" `
        -var="server_2022_iso_path=$ISOPath" `
        -var="server_2022_iso_checksum_file=$ISOChecksumFile" `
        -var="winrm_password=$WinRMPassword" `
        . 2>&1
    
    # Capture output
    $buildOutput | Tee-Object -FilePath $logFile -Append
    
    if ($LASTEXITCODE -eq 0) {
        Write-Log "" -Level INFO
        Write-Log "✓ Build completed successfully!" -Level SUCCESS
        
        # Check for manifest file
        $manifestFile = Get-ChildItem -Path $packerDir -Filter "manifest-*.json" -ErrorAction SilentlyContinue | 
            Sort-Object -Property LastWriteTime -Descending | 
            Select-Object -First 1
        
        if ($manifestFile) {
            Write-Log "Manifest: $($manifestFile.FullName)" -Level INFO
        }
        
        return $true
    } else {
        Write-Log "" -Level ERROR
        Write-Log "✗ Build failed!" -Level ERROR
        Write-Log "Check log file for details: $logFile" -Level ERROR
        return $false
    }
}

function Invoke-DryRun {
    Write-Log "Running in DRY-RUN mode (validation only)..." -Level INFO
    
    $packerArgs = @(
        "validate"
        "-var=`"server_edition=$Edition`""
        "-var=`"server_2022_iso_path=$ISOPath`""
        "-var=`"server_2022_iso_checksum_file=$ISOChecksumFile`""
        "-var=`"winrm_password=$WinRMPassword`""
    )
    
    Write-Log "Running: packer validate ..." -Level DEBUG
    
    $validateOutput = & packer validate `
        -var="server_edition=$Edition" `
        -var="server_2022_iso_path=$ISOPath" `
        -var="server_2022_iso_checksum_file=$ISOChecksumFile" `
        -var="winrm_password=$WinRMPassword" `
        . 2>&1
    
    $validateOutput | Tee-Object -FilePath $logFile -Append
    
    if ($LASTEXITCODE -eq 0) {
        Write-Log "✓ Configuration validated successfully!" -Level SUCCESS
        return $true
    } else {
        Write-Log "✗ Validation failed!" -Level ERROR
        return $false
    }
}

# ============================================================================
# Main Execution
# ============================================================================

Write-Host "`n" -ForegroundColor Cyan
Write-Host "╔════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Windows Server 2022 Hardened Image Builder (Packer)         ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Log "Build Parameters:" -Level INFO
Write-Log "  - Edition: $Edition" -Level INFO
Write-Log "  - Hypervisor: $Hypervisor" -Level INFO
Write-Log "  - ISO Path: $ISOPath" -Level INFO
Write-Log "  - Log File: $logFile" -Level INFO
Write-Log "" -Level INFO

try {
    # Test prerequisites
    if (-not (Test-Prerequisites)) {
        exit 1
    }
    
    Write-Log "" -Level INFO
    
    # Initialize Packer
    if (-not (Initialize-Build)) {
        exit 1
    }
    
    Write-Log "" -Level INFO
    
    # Run dry-run or full build
    if ($DryRun) {
        if (-not (Invoke-DryRun)) {
            exit 1
        }
    } else {
        if (-not (Invoke-Build)) {
            exit 1
        }
    }
    
    Write-Log "" -Level INFO
    Write-Log "Build process completed. Log file: $logFile" -Level SUCCESS
    Write-Log "" -Level INFO
    
    # Cleanup
    Pop-Location
    
} catch {
    Write-Log "FATAL ERROR: $_" -Level ERROR
    Write-Log "Stack trace: $($_.ScriptStackTrace)" -Level ERROR
    Pop-Location
    exit 1
}

Write-Host ""
Write-Host "For more information, see: $logFile" -ForegroundColor Gray
Write-Host ""

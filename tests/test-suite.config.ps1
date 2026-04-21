# Test Suite Configuration
# Configuration file for Windows Safety Jump Box Test Suite

# ============================================================================
# Global Test Configuration
# ============================================================================

# Test Suite Versioning
$Script:TestSuiteVersion = "1.0"
$Script:TestSuiteAuthor = "Windows Safety Jump Box Team"
$Script:TestSuiteDescription = "Comprehensive PowerShell test suite for security hardening and deployment automation"

# ============================================================================
# Execution Configuration
# ============================================================================

# Default behavior settings
$Script:Config = @{
    # Execution
    StopOnFirstFailure = $false              # Continue or stop on first failure
    VerboseLogging = $true                   # Enable detailed logging
    GenerateReports = $true                  # Generate JSON reports
    GenerateHTMLReports = $true              # Generate HTML reports
    
    # Timeouts
    DefaultTimeoutSeconds = 30               # Default test timeout
    LongRunningTimeoutSeconds = 60           # Long-running test timeout
    
    # Paths
    ReportBaseDir = "$PSScriptRoot\reports"  # Base directory for reports
    DataDir = "$PSScriptRoot\data"           # Test data directory
    MockDataDir = "$PSScriptRoot\data\mock"  # Mock data directory
    
    # Reporting
    IncludeEnvironmentInfo = $true           # Include OS/system info in reports
    IncludeExecutionTime = $true             # Include timing metrics
    IncludeDetailedErrors = $true            # Include full error details
    
    # Performance
    EnablePerformanceMetrics = $true         # Collect performance metrics
    PerformanceThresholdMs = 5000            # Warning threshold in ms
    
    # Features
    EnableCI = $false                        # CI/CD mode
    EnableCloudIntegration = $false          # Cloud test integration
    SkipSystemValidation = $false            # Skip system requirement checks
}

# ============================================================================
# Test Suite Behavior
# ============================================================================

# Color scheme for output
$Script:ColorScheme = @{
    PASS = "Green"
    FAIL = "Red"
    WARN = "Yellow"
    SKIP = "Gray"
    INFO = "Cyan"
    START = "Magenta"
    DONE = "Green"
    DEBUG = "DarkCyan"
    ERROR = "DarkRed"
}

# Status codes
$Script:StatusCodes = @{
    Success = 0
    GeneralFailure = 1
    SyntaxFailure = 2
    CISFailure = 3
    DeploymentFailure = 4
    ComplianceFailure = 5
    IntegrationFailure = 6
}

# ============================================================================
# Test Filtering Options
# ============================================================================

# Available test suites
$Script:TestSuites = @{
    "Syntax" = @{
        Enabled = $true
        Description = "PowerShell Syntax Validation"
        Script = "Test-Scripts-Syntax.ps1"
        Critical = $true
        TimeoutSeconds = 30
    }
    "CIS" = @{
        Enabled = $true
        Description = "CIS Hardening Validation"
        Script = "Test-CIS-Hardening.ps1"
        Critical = $true
        TimeoutSeconds = 45
    }
    "Deployment" = @{
        Enabled = $true
        Description = "Deployment Scripts Validation"
        Script = "Test-Deployment-Scripts.ps1"
        Critical = $true
        TimeoutSeconds = 45
    }
    "Compliance" = @{
        Enabled = $true
        Description = "Compliance Validation"
        Script = "Test-Compliance.ps1"
        Critical = $false
        TimeoutSeconds = 60
    }
    "Integration" = @{
        Enabled = $true
        Description = "Integration Testing"
        Script = "Test-Integration.ps1"
        Critical = $false
        TimeoutSeconds = 90
    }
}

# ============================================================================
# System Requirements Validation
# ============================================================================

# Required Windows versions for testing
$Script:RequiredOSVersions = @(
    @{ Name = "Windows 11 Pro"; Build = "22000+" },
    @{ Name = "Windows 11 Enterprise"; Build = "22000+" },
    @{ Name = "Windows 10 Pro"; Build = "19041+" },
    @{ Name = "Windows 10 Enterprise"; Build = "19041+" },
    @{ Name = "Windows Server 2022"; Build = "20348+" },
    @{ Name = "Windows Server 2019"; Build = "17763+" }
)

# Optional but recommended components
$Script:OptionalComponents = @(
    @{ Name = "DISM"; Purpose = "Image deployment testing" },
    @{ Name = "BitLocker"; Purpose = "Encryption testing" },
    @{ Name = "Windows PE"; Purpose = "Boot media creation" },
    @{ Name = "PowerShell 7+"; Purpose = "Enhanced performance" }
)

# ============================================================================
# Test Data Configuration
# ============================================================================

# Mock data locations
$Script:MockDataPaths = @{
    Registry = "$PSScriptRoot\data\mock-registry"
    Services = "$PSScriptRoot\data\mock-services"
    Images = "$PSScriptRoot\data\mock-images"
    Deployments = "$PSScriptRoot\data\mock-deployments"
    Policies = "$PSScriptRoot\data\mock-policies"
}

# ============================================================================
# Compliance Framework Configuration
# ============================================================================

# Supported compliance frameworks
$Script:ComplianceFrameworks = @{
    "CIS_Benchmark_v2.0" = @{
        Enabled = $true
        Version = "2.0"
        Scope = @("Windows 11", "Windows 10", "Windows Server 2022", "Windows Server 2019")
    }
    "NIST_CSF" = @{
        Enabled = $true
        Version = "1.1"
        Functions = @("Identify", "Protect", "Detect", "Respond", "Recover")
    }
    "NIST_800_53" = @{
        Enabled = $false
        Version = "Rev. 5"
        Scope = "Federal systems"
    }
}

# ============================================================================
# Performance Thresholds
# ============================================================================

# Expected performance baseline (in milliseconds)
$Script:PerformanceBaseline = @{
    SyntaxValidation = @{ Min = 2000; Max = 5000; Warning = 3500 }
    CISValidation = @{ Min = 5000; Max = 10000; Warning = 8000 }
    DeploymentValidation = @{ Min = 3000; Max = 8000; Warning = 6000 }
    ComplianceValidation = @{ Min = 5000; Max = 15000; Warning = 12000 }
    IntegrationTests = @{ Min = 10000; Max = 20000; Warning = 18000 }
}

# ============================================================================
# Report Configuration
# ============================================================================

# Report settings
$Script:ReportConfig = @{
    # JSON Reports
    IncludeTimestamp = $true
    IncludeOSVersion = $true
    IncludeSystemInfo = $true
    IncludeExecutionMetrics = $true
    IncludeSummary = $true
    
    # HTML Reports
    Theme = "Dark"  # "Light" or "Dark"
    IncludeGraphs = $true
    IncludeTrendData = $true
    IncludeNISTMapping = $true
    ResponsiveDesign = $true
    
    # Archive
    RetentionDays = 90  # Keep reports for this many days
    MaxReportsToKeep = 100  # Maximum number of reports to retain
    AutoArchive = $true  # Automatically archive old reports
}

# ============================================================================
# CI/CD Configuration
# ============================================================================

# CI/CD specific settings
$Script:CICDConfig = @{
    # GitHub Actions
    GitHubActionsMode = $false
    GitHubAnnotations = $true
    
    # Azure Pipelines
    AzurePipelinesMode = $false
    AzureLogging = $true
    
    # Jenkins
    JenkinsMode = $false
    JenkinsLogging = $true
    
    # Generic CI/CD
    FailFast = $false  # Exit on first failure
    RequireAllPassing = $true  # Require all tests to pass
    AllowWarnings = $true  # Allow tests with warnings to pass
}

# ============================================================================
# Logging Configuration
# ============================================================================

# Logging settings
$Script:LoggingConfig = @{
    # Console logging
    EnableConsoleLogging = $true
    VerboseConsole = $false
    ColorizedOutput = $true
    
    # File logging
    EnableFileLogging = $true
    LogFileDir = "$PSScriptRoot\reports\logs"
    LogFileRetentionDays = 30
    LogFileMaxSize = 10MB
    
    # Levels
    MinimumLevel = "Information"  # Debug, Information, Warning, Error, Critical
}

# ============================================================================
# Advanced Options
# ============================================================================

# Advanced configuration options
$Script:AdvancedOptions = @{
    # Parallel execution
    EnableParallelExecution = $false  # Run tests in parallel (experimental)
    MaxParallelJobs = 4  # Maximum concurrent test runners
    
    # Debugging
    EnableDebugMode = $false  # Enable debug output
    EnableBreakpoints = $false  # Enable PS debugger breakpoints
    CaptureStackTrace = $true  # Capture full stack traces on error
    
    # Validation
    StrictValidation = $true  # Strict parameter validation
    ValidateMockData = $true  # Validate mock data on load
    
    # Features
    EnableMockDataRefresh = $true  # Refresh mock data each run
    EnableSelfHealing = $false  # Automatic test recovery (experimental)
}

# ============================================================================
# Helper Functions
# ============================================================================

# Initialize test configuration
function Initialize-TestConfig {
    Write-Verbose "Initializing test configuration..."
    
    # Create required directories
    foreach ($path in $Script:MockDataPaths.Values) {
        if (-not (Test-Path $path)) {
            New-Item -ItemType Directory -Path $path -Force | Out-Null
        }
    }
    
    # Create reports directory
    if (-not (Test-Path $Script:Config.ReportBaseDir)) {
        New-Item -ItemType Directory -Path $Script:Config.ReportBaseDir -Force | Out-Null
    }
    
    # Create log directory
    if (-not (Test-Path $Script:LoggingConfig.LogFileDir)) {
        New-Item -ItemType Directory -Path $Script:LoggingConfig.LogFileDir -Force | Out-Null
    }
}

# Get test configuration value
function Get-TestConfigValue {
    param(
        [string]$Key,
        [object]$DefaultValue = $null
    )
    
    if ($Script:Config.ContainsKey($Key)) {
        return $Script:Config[$Key]
    }
    return $DefaultValue
}

# Set test configuration value
function Set-TestConfigValue {
    param(
        [string]$Key,
        [object]$Value
    )
    
    $Script:Config[$Key] = $Value
}

# Export configuration functions
Export-ModuleMember -Function Initialize-TestConfig, Get-TestConfigValue, Set-TestConfigValue -Variable `
    Config, ColorScheme, StatusCodes, TestSuites, MockDataPaths, ComplianceFrameworks, ReportConfig, CICDConfig

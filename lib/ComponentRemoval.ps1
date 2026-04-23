# ============================================================================
# Windows Factory - Component Removal Module
# Language of the Land (LotL) Approach
# ============================================================================
# Functions:
# - Remove-AppxPackage: Remove Windows Store apps (bloatware)
# - Get-AvailableAppxPackages: List all removable apps
# - Disable-WindowsFeature: Disable Windows optional features
# - Get-WindowsFeatures: List available Windows features
# - Disable-WindowsService: Disable unnecessary Windows services
# - Get-WindowsServices: List all services with status
# - Remove-ScheduledTask: Remove unnecessary scheduled tasks
# - Get-ScheduledTasks: List removable scheduled tasks
# - Clear-TemporaryFiles: Remove temporary files from image
# ============================================================================

$ErrorActionPreference = "Stop"

# ============================================================================
# Helper Functions
# ============================================================================

function Write-ComponentLog {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'SUCCESS', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] [ComponentRemoval] $Message"
    
    $color = @{
        'INFO'    = 'Cyan'
        'SUCCESS' = 'Green'
        'WARN'    = 'Yellow'
        'ERROR'   = 'Red'
    }
    Write-Host $logMessage -ForegroundColor $color[$Level]
}

function Test-AdminRights {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-ComponentLog "This module requires Administrator rights" "ERROR"
        throw "Administrator rights required"
    }
}

function Test-MountedImage {
    param([string]$MountPoint)
    if (-not (Test-Path "$MountPoint\Windows\System32")) {
        Write-ComponentLog "Not a valid Windows image mount: $MountPoint" "ERROR"
        throw "Invalid Windows image mount point"
    }
    return $true
}

# ============================================================================
# AppxPackage Management (Windows Store Apps)
# ============================================================================

function Get-AvailableAppxPackages {
    <#
    .SYNOPSIS
        Gets all AppxPackages available in the mounted image
    .PARAMETER MountPoint
        Path to mounted Windows image
    .PARAMETER AllUsers
        Include all user packages
    .EXAMPLE
        Get-AvailableAppxPackages -MountPoint "C:\Mount"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = "",
        
        [Parameter(Mandatory = $false)]
        [switch]$AllUsers
    )
    
    Write-ComponentLog "Getting AppxPackages..." "INFO"
    
    $packages = @()
    
    if ($MountPoint) {
        Test-MountedImage -MountPoint $MountPoint
        $online = "/Online"
        $imagePath = "/Image:$MountPoint"
    } else {
        $online = "/Online"
        $imagePath = ""
    }
    
    try {
        $output = Get-AppxPackage @()
        
        foreach ($app in $output) {
            $packages += @{
                Name = $app.Name
                Version = $app.Version
                Publisher = $app.PublisherID
                Architecture = $app.Architecture
                IsFramework = $app.IsFramework
                IsResourcePackage = $app.IsResourcePackage
            }
        }
    } catch {
        Write-ComponentLog "Error getting packages: $_" "WARN"
    }
    
    Write-ComponentLog "Found $($packages.Count) AppxPackages" "SUCCESS"
    return $packages
}

function Remove-AppxPackage {
    <#
    .SYNOPSIS
        Removes an AppxPackage from the image
    .PARAMETER PackageName
        Name of the package to remove
    .PARAMETER MountPoint
        Path to mounted Windows image
    .PARAMETER AllUsers
        Remove for all users
    .EXAMPLE
        Remove-AppxPackage -PackageName "Microsoft.XboxApp" -MountPoint "C:\Mount"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName,
        
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = "",
        
        [Parameter(Mandatory = $false)]
        [switch]$AllUsers
    )
    
    Test-AdminRights
    
    if ($MountPoint) {
        Test-MountedImage -MountPoint $MountPoint
    }
    
    Write-ComponentLog "Removing AppxPackage: $PackageName..." "INFO"
    
    try {
        if ($MountPoint) {
            $output = Get-AppxPackage -PackageName "*$PackageName*" -Path $MountPoint -ErrorAction SilentlyContinue @()
        } else {
            $output = Get-AppxPackage -PackageName "*$PackageName*" -ErrorAction SilentlyContinue @()
        }
        
        $removed = 0
        foreach ($pkg in $output) {
            try {
                if ($MountPoint) {
                    $pkg | Remove-AppxPackage -Path $MountPoint -ErrorAction Stop
                } else {
                    $pkg | Remove-AppxPackage -AllUsers -ErrorAction Stop
                }
                Write-ComponentLog "Removed: $($pkg.Name)" "SUCCESS"
                $removed++
            } catch {
                Write-ComponentLog "Could not remove $($pkg.Name): $_" "WARN"
            }
        }
        
        Write-ComponentLog "Removed $removed package(s)" "SUCCESS"
        return $removed
    } catch {
        Write-ComponentLog "Error removing package: $_" "ERROR"
        return 0
    }
}

function Remove-AppxProvisionedPackage {
    <#
    .SYNOPSIS
        Removes provisioned AppxPackage from image (affects new users)
    .PARAMETER PackageName
        Name of the package to remove
    .PARAMETER MountPoint
        Path to mounted Windows image
    .EXAMPLE
        Remove-AppxProvisionedPackage -PackageName "Microsoft.XboxApp" -MountPoint "C:\Mount"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$PackageName,
        
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = ""
    )
    
    Test-AdminRights
    
    if ($MountPoint) {
        Test-MountedImage -MountPoint $MountPoint
    }
    
    Write-ComponentLog "Removing provisioned AppxPackage: $PackageName..." "INFO"
    
    try {
        if ($MountPoint) {
            $pkgs = Get-AppxProvisionedPackage -Path $MountPoint -ErrorAction SilentlyContinue
        } else {
            $pkgs = Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
        }
        
        $removed = 0
        foreach ($pkg in $pkgs) {
            if ($pkg.PackageName -like "*$PackageName*") {
                try {
                    if ($MountPoint) {
                        Remove-AppxProvisionedPackage -PackageName $pkg.PackageName -Path $MountPoint -ErrorAction Stop
                    } else {
                        Remove-AppxProvisionedPackage -PackageName $pkg.PackageName -Online -ErrorAction Stop
                    }
                    Write-ComponentLog "Removed provisioned: $($pkg.PackageName)" "SUCCESS"
                    $removed++
                } catch {
                    Write-ComponentLog "Could not remove provisioned $($pkg.PackageName): $_" "WARN"
                }
            }
        }
        
        Write-ComponentLog "Removed $removed provisioned package(s)" "SUCCESS"
        return $removed
    } catch {
        Write-ComponentLog "Error removing provisioned package: $_" "ERROR"
        return 0
    }
}

# ============================================================================
# Windows Features Management
# ============================================================================

function Get-WindowsFeatures {
    <#
    .SYNOPSIS
        Gets available Windows optional features
    .PARAMETER MountPoint
        Path to mounted Windows image
    .EXAMPLE
        Get-WindowsFeatures -MountPoint "C:\Mount"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = ""
    )
    
    Test-AdminRights
    
    if ($MountPoint) {
        Test-MountedImage -MountPoint $MountPoint
    }
    
    Write-ComponentLog "Getting Windows features..." "INFO"
    
    try {
        if ($MountPoint) {
            $features = Get-WindowsOptionalFeature -Path $MountPoint -ErrorAction SilentlyContinue
        } else {
            $features = Get-WindowsOptionalFeature -Online -ErrorAction SilentlyContinue
        }
        
        $featureList = @()
        foreach ($feat in $features) {
            $featureList += @{
                FeatureName = $feat.FeatureName
                State = $feat.State.ToString()
                Enabled = $feat.Enabled
            }
        }
        
        Write-ComponentLog "Found $($featureList.Count) feature(s)" "SUCCESS"
        return $featureList
    } catch {
        Write-ComponentLog "Error getting features: $_" "ERROR"
        return @()
    }
}

function Disable-WindowsFeature {
    <#
    .SYNOPSIS
        Disables a Windows optional feature
    .PARAMETER FeatureName
        Name of the feature to disable
    .PARAMETER MountPoint
        Path to mounted Windows image
    .EXAMPLE
        Disable-WindowsFeature -FeatureName "TelnetClient" -MountPoint "C:\Mount"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FeatureName,
        
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = ""
    )
    
    Test-AdminRights
    
    if ($MountPoint) {
        Test-MountedImage -MountPoint $MountPoint
    }
    
    Write-ComponentLog "Disabling Windows feature: $FeatureName..." "INFO"
    
    try {
        if ($MountPoint) {
            $result = Disable-WindowsOptionalFeature -FeatureName $FeatureName -Path $MountPoint -NoRestart -ErrorAction Stop
        } else {
            $result = Disable-WindowsOptionalFeature -FeatureName $FeatureName -Online -NoRestart -ErrorAction Stop
        }
        
        Write-ComponentLog "Disabled feature: $FeatureName" "SUCCESS"
        return $true
    } catch {
        Write-ComponentLog "Could not disable feature: $_" "WARN"
        return $false
    }
}

function Enable-WindowsFeature {
    <#
    .SYNOPSIS
        Enables a Windows optional feature
    .PARAMETER FeatureName
        Name of the feature to enable
    .PARAMETER MountPoint
        Path to mounted Windows image
    .EXAMPLE
        Enable-WindowsFeature -FeatureName "HypervisorPlatform" -MountPoint "C:\Mount"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FeatureName,
        
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = ""
    )
    
    Test-AdminRights
    
    if ($MountPoint) {
        Test-MountedImage -MountPoint $MountPoint
    }
    
    Write-ComponentLog "Enabling Windows feature: $FeatureName..." "INFO"
    
    try {
        if ($MountPoint) {
            $result = Enable-WindowsOptionalFeature -FeatureName $FeatureName -Path $MountPoint -NoRestart -ErrorAction Stop
        } else {
            $result = Enable-WindowsOptionalFeature -FeatureName $FeatureName -Online -NoRestart -ErrorAction Stop
        }
        
        Write-ComponentLog "Enabled feature: $FeatureName" "SUCCESS"
        return $true
    } catch {
        Write-ComponentLog "Could not enable feature: $_" "ERROR"
        return $false
    }
}

# ============================================================================
# Windows Services Management
# ============================================================================

function Get-WindowsServices {
    <#
    .SYNOPSIS
        Gets all Windows services
    .PARAMETER MountPoint
        Path to mounted Windows image
    .EXAMPLE
        Get-WindowsServices -MountPoint "C:\Mount"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = ""
    )
    
    if ($MountPoint) {
        Test-MountedImage -MountPoint $MountPoint
    }
    
    Write-ComponentLog "Getting Windows services..." "INFO"
    
    try {
        if ($MountPoint) {
            $services = Get-WmiObject -Class Win32_Service -Namespace "root\default" -ComputerName "." -ErrorAction SilentlyContinue
        } else {
            $services = Get-Service -ErrorAction SilentlyContinue
        }
        
        $serviceList = @()
        foreach ($svc in $services) {
            if ($svc -is [System.ServiceProcess.ServiceController]) {
                $serviceList += @{
                    Name = $svc.Name
                    DisplayName = $svc.DisplayName
                    Status = $svc.Status.ToString()
                    StartType = $svc.StartType.ToString()
                }
            } else {
                $serviceList += @{
                    Name = $svc.Name
                    DisplayName = $svc.DisplayName
                    Status = $svc.State
                    StartType = $svc.StartMode
                }
            }
        }
        
        Write-ComponentLog "Found $($serviceList.Count) service(s)" "SUCCESS"
        return $serviceList
    } catch {
        Write-ComponentLog "Error getting services: $_" "ERROR"
        return @()
    }
}

function Disable-WindowsService {
    <#
    .SYNOPSIS
        Disables a Windows service
    .PARAMETER ServiceName
        Name of the service to disable
    .PARAMETER MountPoint
        Path to mounted Windows image
    .EXAMPLE
        Disable-WindowsService -ServiceName "DiagTrack" -MountPoint "C:\Mount"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServiceName,
        
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = ""
    )
    
    Test-AdminRights
    
    if ($MountPoint) {
        Test-MountedImage -MountPoint $MountPoint
    }
    
    Write-ComponentLog "Disabling Windows service: $ServiceName..." "INFO"
    
    try {
        if ($MountPoint) {
            # Registry-based disable for offline images
            $regPath = "HKLM:\$($MountPoint -replace ':', '')\Software\Microsoft\Windows\CurrentVersion\Run"
            $svcKey = "HKLM:\$($MountPoint -replace ':', '')\System\CurrentControlSet\Services\$ServiceName"
            
            if (Test-Path $svcKey) {
                Set-ItemProperty -Path $svcKey -Name "Start" -Value 4 -ErrorAction SilentlyContinue
                Write-ComponentLog "Disabled service via registry: $ServiceName" "SUCCESS"
            } else {
                Write-ComponentLog "Service not found: $ServiceName" "WARN"
            }
        } else {
            $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
            if ($service) {
                Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
                Set-Service -Name $ServiceName -StartupType Disabled -ErrorAction SilentlyContinue
                Write-ComponentLog "Disabled service: $ServiceName" "SUCCESS"
            } else {
                Write-ComponentLog "Service not found: $ServiceName" "WARN"
            }
        }
        
        return $true
    } catch {
        Write-ComponentLog "Error disabling service: $_" "ERROR"
        return $false
    }
}

function Stop-DisabledServices {
    <#
    .SYNOPSIS
        Disables a list of unnecessary services
    .PARAMETER Services
        Array of service names to disable
    .PARAMETER MountPoint
        Path to mounted Windows image
    .EXAMPLE
        Stop-DisabledServices -Services @("DiagTrack", "dmwappushservice", "RemoteRegistry") -MountPoint "C:\Mount"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$Services,
        
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = ""
    )
    
    Test-AdminRights
    
    $disabled = 0
    foreach ($svc in $Services) {
        $result = Disable-WindowsService -ServiceName $svc -MountPoint $MountPoint
        if ($result) { $disabled++ }
    }
    
    Write-ComponentLog "Disabled $disabled of $($Services.Count) services" "SUCCESS"
    return $disabled
}

# ============================================================================
# Scheduled Tasks Management
# ============================================================================

function Get-ScheduledTasks {
    <#
    .SYNOPSIS
        Gets scheduled tasks in the image
    .PARAMETER MountPoint
        Path to mounted Windows image
    .PARAMETER Folder
        Task folder to search
    .EXAMPLE
        Get-ScheduledTasks -MountPoint "C:\Mount"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = "",
        
        [Parameter(Mandatory = $false)]
        [string]$Folder = "\"
    )
    
    if ($MountPoint) {
        Test-MountedImage -MountPoint $MountPoint
    }
    
    Write-ComponentLog "Getting scheduled tasks..." "INFO"
    
    try {
        if ($MountPoint) {
            $tasks = Get-ScheduledTask -Path $Folder -Root -Path $MountPoint -ErrorAction SilentlyContinue
        } else {
            $tasks = Get-ScheduledTask -Path $Folder -Root -ErrorAction SilentlyContinue
        }
        
        $taskList = @()
        foreach ($task in $tasks) {
            $taskList += @{
                TaskName = $task.TaskName
                Path = $task.Path
                State = $task.State.ToString()
            }
        }
        
        Write-ComponentLog "Found $($taskList.Count) task(s)" "SUCCESS"
        return $taskList
    } catch {
        Write-ComponentLog "Error getting tasks: $_" "WARN"
        return @()
    }
}

function Remove-ScheduledTask {
    <#
    .SYNOPSIS
        Removes a scheduled task
    .PARAMETER TaskName
        Name of the task to remove
    .PARAMETER MountPoint
        Path to mounted Windows image
    .EXAMPLE
        Remove-ScheduledTask -TaskName "\Microsoft\XblGameSave\Task" -MountPoint "C:\Mount"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$TaskName,
        
        [Parameter(Mandatory = $false)]
        [string]$MountPoint = ""
    )
    
    Test-AdminRights
    
    if ($MountPoint) {
        Test-MountedImage -MountPoint $MountPoint
    }
    
    Write-ComponentLog "Removing scheduled task: $TaskName..." "INFO"
    
    try {
        if ($MountPoint) {
            Unregister-ScheduledTask -TaskName $TaskName -Path $MountPoint -Confirm:$false -ErrorAction SilentlyContinue
        } else {
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false -ErrorAction SilentlyContinue
        }
        
        Write-ComponentLog "Removed task: $TaskName" "SUCCESS"
        return $true
    } catch {
        Write-ComponentLog "Could not remove task: $_" "WARN"
        return $false
    }
}

# ============================================================================
# Temporary Files Cleanup
# ============================================================================

function Clear-TemporaryFiles {
    <#
    .SYNOPSIS
        Removes temporary files from the image
    .PARAMETER MountPoint
        Path to mounted Windows image
    .EXAMPLE
        Clear-TemporaryFiles -MountPoint "C:\Mount"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$MountPoint = ""
    )
    
    Test-AdminRights
    Test-MountedImage -MountPoint $MountPoint
    
    Write-ComponentLog "Cleaning temporary files..." "INFO"
    
    $totalFreed = 0
    $pathsToClean = @(
        "$MountPoint\Windows\Temp\*",
        "$MountPoint\Windows\Installer\$recycle.bin",
        "$MountPoint\Windows\Logs\*",
        "$MountPoint\Windows\WinSxS\Backup\*",
        "$MountPoint\Users\*\AppData\Local\Temp\*"
    )
    
    foreach ($path in $pathsToClean) {
        try {
            if (Test-Path (Split-Path $path -Parent)) {
                $size = (Get-ChildItem $path -Recurse -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum
                if ($size -and $size -gt 0) {
                    $totalFreed += $size
                }
                Remove-Item $path -Recurse -Force -ErrorAction SilentlyContinue
            }
        } catch {
            # Ignore errors for locked files
        }
    }
    
    $sizeMB = [math]::Round($totalFreed / 1MB, 2)
    Write-ComponentLog "Cleaned temporary files. Freed: $sizeMB MB" "SUCCESS"
    return $sizeMB
}

# ============================================================================
# Bulk Removal Functions
# ============================================================================

function Remove-Bloatware {
    <#
    .SYNOPSIS
        Removes common bloatware from the image
    .PARAMETER MountPoint
        Path to mounted Windows image
    .PARAMETER TemplateType
        Type of template (JumpBox, Kiosk, AppDedicated, DevHardened)
    .EXAMPLE
        Remove-Bloatware -MountPoint "C:\Mount" -TemplateType "JumpBox"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$MountPoint,
        
        [ValidateSet('JumpBox', 'Kiosk', 'AppDedicated', 'DevHardened', 'ForensicPE')]
        [Parameter(Mandatory = $false)]
        [string]$TemplateType = "JumpBox"
    )
    
    Test-AdminRights
    Test-MountedImage -MountPoint $MountPoint
    
    # Common consumer apps to remove
    $bloatwareApps = @(
        "Microsoft.XboxApp",
        "Microsoft.XboxGameOverlay",
        "Microsoft.XboxIdentityProvider",
        "Microsoft.WindowsFeedbackHub",
        "Microsoft.GetHelp",
        "Microsoft.Cortana",
        "Microsoft.Office.OneNote",
        "Microsoft.OneDriveSync",
        "Microsoft.MicrosoftOfficeHub",
        "Microsoft.BingNews",
        "Microsoft.BingWeather",
        "Microsoft.MicrosoftSolitaireCollection",
        "Microsoft.ZuneMusic",
        "Microsoft.ZuneVideo",
        "Microsoft.WindowsMaps",
        "Microsoft.YourPhone",
        "Microsoft.SkypeApp",
        "Microsoft.Paint",
        "Microsoft.M snfw",
        "Microsoft.Todos",
        "Microsoft.Whiteboard",
        "Microsoft.StickyNotes"
    )
    
    # Template-specific removals
    if ($TemplateType -eq "JumpBox") {
        # Network admin: Keep some utilities, remove consumer apps
        $appsToRemove = $bloatwareApps
    } elseif ($TemplateType -eq "Kiosk") {
        # Kiosk: Remove everything
        $appsToRemove = $bloatwareApps + @("Microsoft.Edge", "Microsoft.Win32WebViewHost")
    } elseif ($TemplateType -eq "AppDedicated") {
        # App Dedicated: Remove everything, keep only essential
        $appsToRemove = $bloatwareApps + @("*")
    } elseif ($TemplateType -eq "DevHardened") {
        # Dev: Keep essential dev tools, remove consumer apps
        $appsToRemove = $bloatwareApps | Where-Object { $_ -notmatch "OneNote|Whiteboard|StickyNotes" }
    } else {
        $appsToRemove = $bloatwareApps
    }
    
    Write-ComponentLog "Removing bloatware for template: $TemplateType..." "INFO"
    
    $removed = 0
    foreach ($app in $appsToRemove) {
        Remove-AppxPackage -PackageName $app -MountPoint $MountPoint
        Remove-AppxProvisionedPackage -PackageName $app -MountPoint $MountPoint
        $removed++
    }
    
    Write-ComponentLog "Removed $removed bloatware packages" "SUCCESS"
    return $removed
}

# ============================================================================
# Export Functions
# ============================================================================

Export-ModuleMember -Function @(
    'Get-AvailableAppxPackages',
    'Remove-AppxPackage',
    'Remove-AppxProvisionedPackage',
    'Get-WindowsFeatures',
    'Disable-WindowsFeature',
    'Enable-WindowsFeature',
    'Get-WindowsServices',
    'Disable-WindowsService',
    'Stop-DisabledServices',
    'Get-ScheduledTasks',
    'Remove-ScheduledTask',
    'Clear-TemporaryFiles',
    'Remove-Bloatware'
)
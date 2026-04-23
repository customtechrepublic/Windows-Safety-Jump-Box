# ============================================================================
# Windows Factory - Image Management Module
# Language of the Land (LotL) Approach
# ============================================================================
# Functions:
# - Mount-WimImage: Mount a WIM file for offline servicing
# - Dismount-WimImage: Save and unmount a WIM file
# - Get-WimImageInfo: Get image information from a WIM file
# - Expand-WimImage: Extract WIM contents to a directory
# - New-WimImage: Capture a directory to a new WIM file
# - Copy-WimImage: Copy an image within a WIM file
# - Split-WimImage: Split a WIM into multiple files
# ============================================================================

$ErrorActionPreference = "Stop"

# ============================================================================
# Helper Functions
# ============================================================================

function Write-ImageLog {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'SUCCESS', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] [ImageMgmt] $Message"
    
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
        Write-ImageLog "This module requires Administrator rights" "ERROR"
        throw "Administrator rights required"
    }
}

function Get-DismPath {
    $dismPath = Get-Command DISM.exe -ErrorAction SilentlyContinue
    if (-not $dismPath) {
        Write-ImageLog "DISM not found. Install Windows ADK." "ERROR"
        throw "DISM not available"
    }
    return $dismPath.Source
}

# ============================================================================
# Core Functions
# ============================================================================

function Mount-WimImage {
    <#
    .SYNOPSIS
        Mounts a WIM file for offline servicing
    .PARAMETER WIMPath
        Path to the WIM file
    .PARAMETER MountPoint
        Directory to mount the WIM image to
    .PARAMETER Index
        Image index within the WIM file (default: 1)
    .EXAMPLE
        Mount-WimImage -WIMPath "C:\isofiles\sources\install.wim" -MountPoint "C:\Mount" -Index 1
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$WIMPath,
        
        [Parameter(Mandatory = $true)]
        [string]$MountPoint,
        
        [Parameter(Mandatory = $false)]
        [int]$Index = 1
    )
    
    Test-AdminRights
    
    if (-not (Test-Path $WIMPath)) {
        Write-ImageLog "WIM file not found: $WIMPath" "ERROR"
        throw "WIM file not found"
    }
    
    if (-not (Test-Path (Split-Path -Parent $MountPoint))) {
        New-Item -ItemType Directory -Path (Split-Path -Parent $MountPoint) -Force | Out-Null
    }
    
    if (Test-Path $MountPoint) {
        Write-ImageLog "Mount point already exists. Dismounting first..." "WARN"
        Dismount-WimImage -MountPoint $MountPoint
    }
    
    New-Item -ItemType Directory -Path $MountPoint -Force | Out-Null
    
    Write-ImageLog "Mounting WIM image $Index from $WIMPath to $MountPoint..." "INFO"
    
    $dism = Get-DismPath
    $output = & $dism /Online /Mount-Image /ImageFile:$WIMPath /Index:$Index /MountDir:$MountPoint /ReadOnly
    
    if ($LASTEXITCODE -ne 0) {
        Write-ImageLog "Failed to mount WIM: $output" "ERROR"
        throw "DISM mount failed with exit code $LASTEXITCODE"
    }
    
    Write-ImageLog "WIM mounted successfully" "SUCCESS"
    return $true
}

function Dismount-WimImage {
    <#
    .SYNOPSIS
        Saves and unmounts a WIM file
    .PARAMETER MountPoint
        Directory where the WIM image is mounted
    .PARAMETER Commit
        If true, saves changes. If false, discards changes.
    .EXAMPLE
        Dismount-WimImage -MountPoint "C:\Mount" -Commit $true
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$MountPoint,
        
        [Parameter(Mandatory = $false)]
        [bool]$Commit = $true
    )
    
    Test-AdminRights
    
    if (-not (Test-Path $MountPoint)) {
        Write-ImageLog "Mount point does not exist: $MountPoint" "WARN"
        return $false
    }
    
    Write-ImageLog "Unmounting WIM from $MountPoint (Commit: $Commit)..." "INFO"
    
    $dism = Get-DismPath
    
    if ($Commit) {
        $output = & $dism /Online /Unmount-Image /MountDir:$MountPoint /Commit
    } else {
        $output = & $dism /Online /Unmount-Image /MountDir:$MountPoint /Discard
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-ImageLog "Failed to unmount WIM: $output" "ERROR"
        throw "DISM unmount failed with exit code $LASTEXITCODE"
    }
    
    Write-ImageLog "WIM unmounted successfully" "SUCCESS"
    return $true
}

function Get-WimImageInfo {
    <#
    .SYNOPSIS
        Gets information about images in a WIM file
    .PARAMETER WIMPath
        Path to the WIM file
    .EXAMPLE
        Get-WimImageInfo -WIMPath "C:\isofiles\sources\install.wim"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$WIMPath
    )
    
    if (-not (Test-Path $WIMPath)) {
        Write-ImageLog "WIM file not found: $WIMPath" "ERROR"
        throw "WIM file not found"
    }
    
    Write-ImageLog "Getting WIM image info from $WIMPath..." "INFO"
    
    $dism = Get-DismPath
    $output = & $dism /Get-ImageInfo /ImageFile:$WIMPath
    
    if ($LASTEXITCODE -ne 0) {
        Write-ImageLog "Failed to get WIM info: $output" "ERROR"
        throw "DISM failed with exit code $LASTEXITCODE"
    }
    
    $images = @()
    $lines = $output -split "`n"
    $currentImage = $null
    
    foreach ($line in $lines) {
        if ($line -match "Index\s*:\s*(\d+)") {
            if ($currentImage) { $images += $currentImage }
            $currentImage = @{
                Index = [int]$matches[1]
            }
        } elseif ($line -match "Name\s*:\s*(.+)") {
            $currentImage.Name = $matches[1].Trim()
        } elseif ($line -match "Description\s*:\s*(.+)") {
            $currentImage.Description = $matches[1].Trim()
        } elseif ($line -match "Size\s*:\s*(.+)") {
            $currentImage.Size = $matches[1].Trim()
        }
    }
    if ($currentImage) { $images += $currentImage }
    
    Write-ImageLog "Found $($images.Count) image(s)" "SUCCESS"
    return $images
}

function Expand-WimImage {
    <#
    .SYNOPSIS
        Extracts WIM contents to a directory
    .PARAMETER WIMPath
        Path to the WIM file
    .PARAMETER DestinationPath
        Directory to extract to
    .PARAMETER Index
        Image index to extract (default: 1)
    .EXAMPLE
        Expand-WimImage -WIMPath "C:\isofiles\sources\install.wim" -DestinationPath "C:\Extracted" -Index 1
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$WIMPath,
        
        [Parameter(Mandatory = $true)]
        [string]$DestinationPath,
        
        [Parameter(Mandatory = $false)]
        [int]$Index = 1
    )
    
    Test-AdminRights
    
    if (-not (Test-Path $WIMPath)) {
        Write-ImageLog "WIM file not found: $WIMPath" "ERROR"
        throw "WIM file not found"
    }
    
    if (Test-Path $DestinationPath) {
        Write-ImageLog "Destination directory exists. Removing..." "WARN"
        Remove-Item -Path $DestinationPath -Recurse -Force
    }
    
    New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
    
    Write-ImageLog "Extracting WIM image $Index to $DestinationPath..." "INFO"
    
    $dism = Get-DismPath
    $output = & $dism /Apply-Image /ImageFile:$WIMPath /Index:$Index /ApplyDir:$DestinationPath
    
    if ($LASTEXITCODE -ne 0) {
        Write-ImageLog "Failed to extract WIM: $output" "ERROR"
        throw "DISM apply failed with exit code $LASTEXITCODE"
    }
    
    Write-ImageLog "WIM extracted successfully" "SUCCESS"
    return $true
}

function New-WimImage {
    <#
    .SYNOPSIS
        Captures a directory to a new WIM file
    .PARAMETER SourcePath
        Directory to capture
    .PARAMETER WIMPath
        Path for the new WIM file
    .PARAMETER ImageName
        Name for the image
    .PARAMETER Compression
        Compression type: Maximum, Fast, None (default: Maximum)
    .EXAMPLE
        New-WimImage -SourcePath "C:\Windows" -WIMPath "C:\Output\capture.wim" -ImageName "Windows 11"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,
        
        [Parameter(Mandatory = $true)]
        [string]$WIMPath,
        
        [Parameter(Mandatory = $false)]
        [string]$ImageName = "Custom Image",
        
        [ValidateSet('Maximum', 'Fast', 'None')]
        [Parameter(Mandatory = $false)]
        [string]$Compression = "Maximum"
    )
    
    Test-AdminRights
    
    if (-not (Test-Path $SourcePath)) {
        Write-ImageLog "Source directory not found: $SourcePath" "ERROR"
        throw "Source directory not found"
    }
    
    $wimDir = Split-Path -Parent $WIMPath
    if (-not (Test-Path $wimDir)) {
        New-Item -ItemType Directory -Path $wimDir -Force | Out-Null
    }
    
    Write-ImageLog "Capturing $SourcePath to $WIMPath (Compression: $Compression)..." "INFO"
    
    $dism = Get-DismPath
    $output = & $dism /Capture-Image /ImageFile:$WIMPath /Name:$ImageName /SourcePath:$SourcePath /CompressionType:$Compression
    
    if ($LASTEXITCODE -ne 0) {
        Write-ImageLog "Failed to capture WIM: $output" "ERROR"
        throw "DISM capture failed with exit code $LASTEXITCODE"
    }
    
    Write-ImageLog "WIM captured successfully" "SUCCESS"
    return $true
}

function Optimize-WimImage {
    <#
    .SYNOPSIS
        Optimizes a WIM file to reduce size
    .PARAMETER WIMPath
        Path to the WIM file
    .EXAMPLE
        Optimize-WimImage -WIMPath "C:\Output\install.wim"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$WIMPath
    )
    
    Test-AdminRights
    
    if (-not (Test-Path $WIMPath)) {
        Write-ImageLog "WIM file not found: $WIMPath" "ERROR"
        throw "WIM file not found"
    }
    
    Write-ImageLog "Optimizing WIM file $WIMPath..." "INFO"
    
    $dism = Get-DismPath
    $output = & $dism /Optimize-Image /ImageFile:$WIMPath /Index:1
    
    if ($LASTEXITCODE -ne 0) {
        Write-ImageLog "Failed to optimize WIM: $output" "ERROR"
        throw "DISM optimize failed with exit code $LASTEXITCODE"
    }
    
    $size = (Get-Item $WIMPath).Length / 1MB
    Write-ImageLog "WIM optimized. New size: $([math]::Round($size, 2)) MB" "SUCCESS"
    return $true
}

function Export-WimImage {
    <#
    .SYNOPSIS
        Exports an image from one WIM to another with optimization
    .PARAMETER SourceWIMPath
        Path to the source WIM file
    .PARAMETER SourceIndex
        Index of the source image
    .PARAMETER DestinationWIMPath
        Path for the destination WIM file
    .PARAMETER DestinationName
        Name for the destination image
    .EXAMPLE
        Export-WimImage -SourceWIMPath "C:\install.wim" -SourceIndex 1 -DestinationWIMPath "C:\output.wim"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$SourceWIMPath,
        
        [Parameter(Mandatory = $false)]
        [int]$SourceIndex = 1,
        
        [Parameter(Mandatory = $true)]
        [string]$DestinationWIMPath,
        
        [Parameter(Mandatory = $false)]
        [string]$DestinationName = "Exported Image"
    )
    
    Test-AdminRights
    
    if (-not (Test-Path $SourceWIMPath)) {
        Write-ImageLog "Source WIM not found: $SourceWIMPath" "ERROR"
        throw "Source WIM not found"
    }
    
    $destDir = Split-Path -Parent $DestinationWIMPath
    if (-not (Test-Path $destDir)) {
        New-Item -ItemType Directory -Path $destDir -Force | Out-Null
    }
    
    Write-ImageLog "Exporting image from $SourceWIMPath to $DestinationWIMPath..." "INFO"
    
    $dism = Get-DismPath
    $output = & $dism /Export-Image /SourceImageFile:$SourceWIMPath /SourceIndex:$SourceIndex /DestinationImageFile:$DestinationWIMPath /Name:$DestinationName /CompressionType:Maximum
    
    if ($LASTEXITCODE -ne 0) {
        Write-ImageLog "Failed to export WIM: $output" "ERROR"
        throw "DISM export failed with exit code $LASTEXITCODE"
    }
    
    Write-ImageLog "WIM exported successfully" "SUCCESS"
    return $true
}

function Get-WimMountedImages {
    <#
    .SYNOPSIS
        Lists all currently mounted WIM images
    .EXAMPLE
        Get-WimMountedImages
    #>
    [CmdletBinding()]
    param()
    
    Test-AdminRights
    
    Write-ImageLog "Checking for mounted WIM images..." "INFO"
    
    $dism = Get-DismPath
    $output = & $dism /Get-MountedImageInfo
    
    if ($LASTEXITCODE -ne 0) {
        Write-ImageLog "Failed to get mounted image info: $output" "ERROR"
        throw "DISM failed with exit code $LASTEXITCODE"
    }
    
    $mountedImages = @()
    $lines = $output -split "`n"
    $currentImage = $null
    
    foreach ($line in $lines) {
        if ($line -match "Mount Dir\s*:\s*(.+)") {
            if ($currentImage) { $mountedImages += $currentImage }
            $currentImage = @{
                MountDir = $matches[1].Trim()
            }
        } elseif ($line -match "Image File\s*:\s*(.+)") {
            $currentImage.ImageFile = $matches[1].Trim()
        } elseif ($line -match "Image Index\s*:\s*(\d+)") {
            $currentImage.ImageIndex = [int]$matches[1]
        } elseif ($line -match "Status\s*:\s*(.+)") {
            $currentImage.Status = $matches[1].Trim()
        }
    }
    if ($currentImage) { $mountedImages += $currentImage }
    
    if ($mountedImages.Count -eq 0) {
        Write-ImageLog "No WIM images currently mounted" "INFO"
    } else {
        Write-ImageLog "Found $($mountedImages.Count) mounted image(s)" "SUCCESS"
    }
    
    return $mountedImages
}

# ============================================================================
# Export Functions
# ============================================================================

Export-ModuleMember -Function @(
    'Mount-WimImage',
    'Dismount-WimImage',
    'Get-WimImageInfo',
    'Expand-WimImage',
    'New-WimImage',
    'Optimize-WimImage',
    'Export-WimImage',
    'Get-WimMountedImages'
)
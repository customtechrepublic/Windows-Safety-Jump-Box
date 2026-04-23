# ============================================================================
# Windows Factory - Compliance Reporting Module
# Language of the Land (LotL) Approach
# ============================================================================
# Generates compliance audit reports mapped to CIS/NIST/SOC2/GDPR
# ============================================================================

$ErrorActionPreference = "Stop"

# ============================================================================
# Helper Functions
# ============================================================================

function Write-ComplianceLog {
    param(
        [string]$Message,
        [ValidateSet('INFO', 'SUCCESS', 'WARN', 'ERROR')]
        [string]$Level = 'INFO'
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] [Compliance] $Message"
    
    $color = @{
        'INFO'    = 'Cyan'
        'SUCCESS' = 'Green'
        'WARN'    = 'Yellow'
        'ERROR'   = 'Red'
    }
    Write-Host $logMessage -ForegroundColor $color[$Level]
}

# ============================================================================
# Compliance Database
# ============================================================================

$CisControlMapping = @{
    # CIS 1.x - Initial Setup
    '1.1.1' = @{NIST='AC-2'; SOC2='CC6.1'; Description='Enforce password history'}
    '1.1.2' = @{NIST='AC-2'; SOC2='CC6.1'; Description='Maximum password age'}
    '1.1.3' = @{NIST='AC-2'; SOC2='CC6.1'; Description='Minimum password age'}
    
    # CIS 2.x - Firewall
    '2.1.1' = @{NIST='SC-7'; SOC2='CC6.2'; Description='Windows Firewall enabled'}
    '2.2.1' = @{NIST='SC-7'; SOC2='CC6.2'; Description='Firewall default outbound'}
    
    # CIS 3.x - Windows Defender
    '3.1.1' = @{NIST='SI-3'; SOC2='CC6.1'; Description='Windows Defender enabled'}
    '3.2.1' = @{NIST='SI-4'; SOC2='CC6.2'; Description='Real-time protection'}
    
    # CIS 4.x - Audit
    '4.1.1' = @{NIST='AU-2'; SOC2='CC7.2'; Description='Audit logon events'}
    '4.2.1' = @{NIST='AU-3'; SOC2='CC7.2'; Description='Audit object access'}
    
    # CIS 5.x - Network
    '5.1.1' = @{NIST='SC-3'; SOC2='CC6.1'; Description='Restrict null session'}
    '5.2.1' = @{NIST='SC-4'; SOC2='CC6.1'; Description='Restrict anonymous'}
    
    # CIS 6.x - Credential
    '6.1.1' = @{NIST='IA-5'; SOC2='CC6.1'; Description='Credential Guard'}
    '6.2.1' = @{NIST='IA-5'; SOC2='CC6.1'; Description='HVCI enabled'}
    
    # CIS 7.x - Exploit
    '7.1.1' = @{NIST='SI-2'; SOC2='CC6.1'; Description='DEP enabled'}
    '7.2.1' = @{NIST='SI-2'; SOC2='CC6.1'; Description='ASLR enabled'}
    
    # CIS 8.x - Network Security
    '8.1.1' = @{NIST='SC-5'; SOC2='CC6.2'; Description='Disable IP routing'}
    '8.2.1' = @{NIST='SC-5'; SOC2='CC6.2'; Description='Disable NetBIOS'}
    
    # CIS 9.x - SMB
    '9.1.1' = @{NIST='SC-8'; SOC2='CC6.2'; Description='Disable SMBv1'}
    '9.2.1' = @{NIST='SC-8'; SOC2='CC6.2'; Description='Require SMB signing'}
    
    # CIS 10.x - Windows Update
    '10.1.1' = @{NIST='SI-4'; SOC2='CC7.2'; Description='Automatic updates'}
    '10.2.1' = @{NIST='SI-4'; SOC2='CC7.2'; Description='Update scheduling'}
}

$NistControlFamilies = @{
    'AC' = @{Name='Access Control'; Description='Controls who can access what'}
    'AU' = @{Name='Audit and Accountability'; Description='Tracks system events'}
    'IA' = @{Name='Identification and Authentication'; Description='Verifies user identity'}
    'SC' = @{Name='System and Communications Protection'; Description='Protects communications'}
    'SI' = @{Name='System and Information Integrity'; Description='Maintains data integrity'}
}

$Soc2Criteria = @{
    'CC6.1' = @{Name='Logical and Physical Access Controls'; Description='Access security'}
    'CC6.2' = @{Name='System Operations'; Description='Operational procedures'}
    'CC7.1' = @{Name='Change Management'; Description='Change control processes'}
    'CC7.2' = @{Name='Monitoring and Logging'; Description='Event tracking'}
    'CC7.3' = @{Name='Incident Management'; Description='Response procedures'}
}

$GDPRArticles = @{
    '32' = @{Name='Security of Processing'; Description='Appropriate technical measures'}
    '33' = @{Name='Notification of Breach'; Description='72-hour breach notification'}
    '34' = @{Name='Communication of Breach'; Description='Data subject notification'}
}

# ============================================================================
# Report Generation Functions
# ============================================================================

function New-ComplianceReport {
    <#
    .SYNOPSIS
        Creates a new compliance report
    .PARAMETER OutputPath
        Directory for report output
    .PARAMETER TemplateName
        Name of the template applied
    .PARAMETER CISLevel
        CIS Level: 1 or 2
    .EXAMPLE
        New-ComplianceReport -OutputPath "C:\Reports" -TemplateName "JumpBox" -Level 2
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,
        
        [Parameter(Mandatory = $true)]
        [string]$TemplateName,
        
        [ValidateSet(1, 2)]
        [Parameter(Mandatory = $false)]
        [int]$CISLevel = 2
    )
    
    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $reportID = "COMPLIANCE-$timestamp"
    
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }
    
    $report = @{
        ReportID = $reportID
        GeneratedDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        TemplateName = $TemplateName
        CISLevel = $CISLevel
        Controls = @()
        NISTMapping = @()
        SOC2Mapping = @()
        GDPRMapping = @()
    }
    
    Write-ComplianceLog "Creating compliance report: $reportID" "INFO"
    
    return $report
}

function Add-CISControl {
    <#
    .SYNOPSIS
        Adds a CIS control to the compliance report
    .PARAMETER Report
        Report object
    .PARAMETER ControlID
        CIS Control ID (e.g., "1.1.1")
    .PARAMETER Status
        Status: Pass, Fail, or N/A
    .EXAMPLE
        Add-CISControl -Report $report -ControlID "1.1.1" -Status "Pass"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Report,
        
        [Parameter(Mandatory = $true)]
        [string]$ControlID,
        
        [ValidateSet('Pass', 'Fail', 'N/A')]
        [Parameter(Mandatory = $false)]
        [string]$Status = "Pass"
    )
    
    $mapping = $CisControlMapping[$ControlID]
    
    if ($mapping) {
        $control = @{
            ID = $ControlID
            Description = $mapping.Description
            NIST = $mapping.NIST
            SOC2 = $mapping.SOC2
            Status = $Status
        }
        
        $Report.Controls += $control
        
        if ($mapping.NIST -and $Status -eq "Pass") {
            $Report.NISTMapping += $mapping.NIST
        }
        
        if ($mapping.SOC2 -and $Status -eq "Pass") {
            $Report.SOC2Mapping += $mapping.SOC2
        }
    }
    
    return $Report
}

function Export-ComplianceReport {
    <#
    .SYNOPSIS
        Exports compliance report to file
    .PARAMETER Report
        Report object
    .PARAMETER OutputPath
        Directory for report output
    .PARAMETER Format
        Format: Markdown, JSON, or HTML
    .EXAMPLE
        Export-ComplianceReport -Report $report -OutputPath "C:\Reports" -Format "Markdown"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Report,
        
        [Parameter(Mandatory = $true)]
        [string]$OutputPath,
        
        [ValidateSet('Markdown', 'JSON', 'HTML')]
        [Parameter(Mandatory = $false)]
        [string]$Format = "Markdown"
    )
    
    $reportFile = Join-Path $OutputPath "$($Report.ReportID).$($Format.ToLower())"
    
    if ($Format -eq "Markdown") {
        $content = "# Windows Factory - Compliance Audit Report`n`n"
        $content += "**Report ID:** $($ReportReportID)`n"
        $content += "**Generated:** $($Report.GeneratedDate)`n"
        $content += "**Template:** $($Report.TemplateName)`n"
        $content += "**CIS Level:** $($Report.CISLevel)`n`n"
        
        $content += "## Executive Summary`n`n"
        $passCount = ($Report.Controls | Where-Object { $_.Status -eq "Pass" }).Count
        $totalCount = $Report.Controls.Count
        $passRate = [math]::Round(($passCount / $totalCount) * 100, 1)
        
        $content += "- **Controls Applied:** $totalCount`n"
        $content += "- **Passed:** $passCount`n"
        $content += "- **Pass Rate:** $passRate%`n`n"
        
        $content += "## NIST 800-53 Coverage`n`n"
        $uniqueNIST = $Report.NISTMapping | Sort-Object -Unique
        foreach ($control in $uniqueNIST) {
            $family = $NistControlFamilies[$control.Substring(0, 2)]
            $content += "- **$control:** $($family.Name)`n"
        }
        $content += "`n"
        
        $content += "## SOC2 Trust Services Coverage`n`n"
        $uniqueSOC2 = $Report.SOC2Mapping | Sort-Object -Unique
        foreach ($criteria in $uniqueSOC2) {
            $details = $Soc2Criteria[$criteria]
            $content += "- **$criteria:** $($details.Name)`n"
        }
        $content += "`n"
        
        $content += "## CIS Controls Applied`n`n"
        $content += "| Control | Description | NIST | SOC2 | Status |`n"
        $content += "|--------|------------|-----|-----|-------|`n"
        foreach ($ctrl in $Report.Controls) {
            $content += "| $($ctrl.ID) | $($ctrl.Description) | $($ctrl.NIST) | $($ctrl.SOC2) | $($ctrl.Status) |`n"
        }
        
        $content += "`n`n---`n"
        $content += "*Generated by Windows Factory - Custom PC Republic*`n"
        
        $content | Out-File -FilePath $reportFile -Encoding UTF8
    }
    elseif ($Format -eq "JSON") {
        $Report | ConvertTo-Json -Depth 5 | Out-File -FilePath $reportFile -Encoding UTF8
    }
    elseif ($Format -eq "HTML") {
        $html = @"
<!DOCTYPE html>
<html>
<head>
    <title>Compliance Report - $($Report.ReportID)</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        h1 { color: #1a5f7a; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
        th { background-color: #1a5f7a; color: white; }
        .pass { color: green; }
        .fail { color: red; }
        .summary { background: #f0f0f0; padding: 20px; margin: 20px 0; }
    </style>
</head>
<body>
    <h1>Windows Factory - Compliance Audit Report</h1>
    <div class="summary">
        <p><strong>Report ID:</strong> $($Report.ReportID)</p>
        <p><strong>Generated:</strong> $($Report.GeneratedDate)</p>
        <p><strong>Template:</strong> $($Report.TemplateName)</p>
        <p><strong>CIS Level:</strong> $($Report.CISLevel)</p>
    </div>
    <h2>CIS Controls</h2>
    <table>
        <tr><th>Control</th><th>Description</th><th>NIST</th><th>SOC2</th><th>Status</th></tr>
"@
        foreach ($ctrl in $Report.Controls) {
            $statusClass = if ($ctrl.Status -eq "Pass") { "pass" } else { "fail" }
            $html += "        <tr><td>$($ctrl.ID)</td><td>$($ctrl.Description)</td><td>$($ctrl.NIST)</td><td>$($ctrl.SOC2)</td><td class='$statusClass'>$($ctrl.Status)</td></tr>`n"
        }
        
        $html += @"
    </table>
    <footer>
        <p>Generated by Windows Factory - Custom PC Republic</p>
    </footer>
</body>
</html>
"@
        $html | Out-File -FilePath $reportFile -Encoding UTF8
    }
    
    Write-ComplianceLog "Report saved: $reportFile" "SUCCESS"
    return $reportFile
}

function Get-ComplianceScore {
    <#
    .SYNOPSIS
        Calculates compliance score
    .PARAMETER Report
        Report object
    .EXAMPLE
        Get-ComplianceScore -Report $report
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Report
    )
    
    $total = $Report.Controls.Count
    if ($total -eq 0) {
        return 0
    }
    
    $pass = ($Report.Controls | Where-Object { $_.Status -eq "Pass" }).Count
    $score = [math]::Round(($pass / $total) * 100, 1)
    
    return $score
}

function Get-NistCoverage {
    <#
    .SYNOPSIS
        Gets NIST 800-53 coverage summary
    .PARAMETER Report
        Report object
    .EXAMPLE
        Get-NistCoverage -Report $report
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Report
    )
    
    $unique = $Report.NISTMapping | Sort-Object -Unique
    $coverage = @()
    
    foreach ($ctrl in $unique) {
        $family = $NistControlFamilies[$ctrl.Substring(0, 2)]
        $coverage += @{
            Control = $ctrl
            Family = $family.Name
            Description = $family.Description
        }
    }
    
    return $coverage
}

function Get-Soc2Coverage {
    <#
    .SYNOPSIS
        Gets SOC2 Trust Services coverage summary
    .PARAMETER Report
        Report object
    .EXAMPLE
        Get-Soc2Coverage -Report $report
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable]$Report
    )
    
    $unique = $Report.SOC2Mapping | Sort-Object -Unique
    $coverage = @()
    
    foreach ($crit in $unique) {
        $details = $Soc2Criteria[$crit]
        $coverage += @{
            Criteria = $crit
            Name = $details.Name
            Description = $details.Description
        }
    }
    
    return $coverage
}

# ============================================================================
# Export Functions
# ============================================================================

Export-ModuleMember -Function @(
    'New-ComplianceReport',
    'Add-CISControl',
    'Export-ComplianceReport',
    'Get-ComplianceScore',
    'Get-NistCoverage',
    'Get-Soc2Coverage'
)
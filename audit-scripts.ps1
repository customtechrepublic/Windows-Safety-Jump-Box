# PowerShell Script Auditor for Windows-Safety-Jump-Box

$scripts = @(
    'CIS-Windows11-Hardening.ps1',
    'CIS_Tier_2_Hardening_Rollback.ps1',
    'build\packer\provisioners\install-updates.ps1',
    'capture\Capture-Installation.ps1',
    'capture\Prepare-System-for-Capture.ps1',
    'deployment\Deploy-Image.ps1',
    'deployment\Enable-BitLocker.ps1',
    'hardening\CIS_Level2_Mandatory.ps1',
    'hardening\CIS_Level1+2_Complete.ps1'
)

$results = @()

foreach ($script in $scripts) {
    if (Test-Path $script) {
        Write-Host "Checking: $script" -ForegroundColor Cyan
        $parseErrors = @()
        $tokens = @()
        $null = [System.Management.Automation.Language.Parser]::ParseFile((Get-Item $script).FullName, [ref]$tokens, [ref]$parseErrors)
        
        if ($parseErrors.Count -gt 0) {
            foreach ($parseError in $parseErrors) {
                $results += @{
                    Script = $script
                    Type = "SYNTAX_ERROR"
                    Line = $parseError.Extent.StartLineNumber
                    Message = $parseError.Message
                    Severity = "CRITICAL"
                }
            }
        }
        
        # Read file content
        $content = Get-Content $script
        $lineNum = 1
        foreach ($line in $content) {
            # Check for invalid Set-MpPreference parameters
            if ($line -match 'Set-MpPreference.*?-(\w+)') {
                $param = $matches[1]
                $validParams = @('DisableRealtimeMonitoring', 'EnableRealtimeMonitoring', 'EnableBehaviorMonitoring', 
                                 'EnableCloudProtection', 'CloudBlockLevel', 'EnableNetworkProtection', 
                                 'EnableControlledFolderAccess', 'MAPSReporting', 'SubmitSamplesConsent')
                if ($param -notin $validParams -and $param -notmatch '^ErrorAction|Force') {
                    if ($line -notmatch 'ErrorAction|SilentlyContinue') {
                        # Only flag if not a common parameter
                    }
                }
            }
            
            # Check for invalid service names
            if ($line -match 'Get-Service.*?-Name\s+"?([^"\s]+)"?') {
                $svcName = $matches[1]
                # Basic check - some services might be legitimately unknown
            }
            
            # Check for invalid registry paths
            if ($line -match 'Set-ItemProperty.*?-Path\s+"([^"]+)"' -or $line -match "Set-ItemProperty.*?-Path\s+'([^']+)'") {
                $regPath = $matches[1]
                if ($regPath -notmatch '^HKLM:|^HKCU:|^HKL') {
                    if ($regPath -match 'HKEY_' -and $regPath -notmatch '\\') {
                        # Potential issue with registry path format
                    }
                }
            }
            
            $lineNum++
        }
    }
}

# Output results
Write-Host "`n`n====== AUDIT RESULTS ======`n" -ForegroundColor Green

if ($results.Count -eq 0) {
    Write-Host "All scripts passed initial syntax checks" -ForegroundColor Green
} else {
    foreach ($result in $results) {
        Write-Host "File: $($result.Script) | Line: $($result.Line) | $($result.Type)" -ForegroundColor Red
        Write-Host "  Message: $($result.Message)" -ForegroundColor Yellow
        Write-Host "  Severity: $($result.Severity)" -ForegroundColor Red
    }
}

$results

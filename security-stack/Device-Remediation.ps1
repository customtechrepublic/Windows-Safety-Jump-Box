# Device-Remediation.ps1
# This script remediates devices with "Unknown" status.
# Most "Unknown" devices are disconnected hardware - this script identifies critical issues and fixes what can be fixed.

$ErrorActionPreference = "Continue"

function Write-Step ([string]$msg) {
    Write-Host "`n>>> $msg" -ForegroundColor Cyan
}

function Check-Elevation {
    $user = [Security.Principal.WindowsIdentity]::GetCurrent()
    $role = [Security.Principal.WindowsBuiltInRole]::Administrator
    if (-not ([Security.Principal.WindowsPrincipal]$user).IsInRole($role)) {
        Write-Error "This script must be run as an Administrator."
    }
}

function Analyze-UnknownDevices {
    Write-Step "Analyzing Unknown Devices (Categorizing by Severity)..."
    
    $allUnknown = Get-PnpDevice | Where-Object { $_.Status -ne "OK" }
    
    # Categorize devices
    $critical = @()      # Device Descriptor Request Failed, etc.
    $peripheral = @()    # Disconnected phones, USB drives, cameras
    $virtual = @()       # Virtual/Software devices (safe to ignore)
    $hid = @()           # HID devices (keyboards, mice, headsets)
    
    foreach ($device in $allUnknown) {
        if ($device.FriendlyName -match "Unknown USB Device.*Failed") {
            $critical += $device
        } elseif ($device.Class -match "WPD|DiskDrive|Modem|USB" -and $device.FriendlyName -notmatch "Virtual|MIDI|Streaming|Test") {
            $peripheral += $device
        } elseif ($device.Class -match "SoftwareDevice|Volume|MEDIA" -or $device.FriendlyName -match "MIDI|Virtual|Test|Streaming") {
            $virtual += $device
        } elseif ($device.Class -match "HIDClass|Keyboard|Mouse") {
            $hid += $device
        }
    }
    
    Write-Host "[!] CRITICAL Issues (Actual Problems): $($critical.Count)" -ForegroundColor Red
    foreach ($dev in $critical) {
        Write-Host "    - $($dev.FriendlyName) [$($dev.Class)]"
    }
    
    Write-Host "[!] Disconnected Peripherals (Expected Unknown): $($peripheral.Count)" -ForegroundColor Yellow
    foreach ($dev in $peripheral) {
        Write-Host "    - $($dev.FriendlyName) [$($dev.Class)]"
    }
    
    Write-Host "[*] Virtual/Software Devices (Safe to Ignore): $($virtual.Count)" -ForegroundColor Gray
    
    Write-Host "[*] HID Input Devices (Keyboards/Mice/Headsets): $($hid.Count)" -ForegroundColor Gray
    
    return @{
        Critical = $critical
        Peripheral = $peripheral
        Virtual = $virtual
        HID = $hid
    }
}

function Remediate-CriticalUSBDevices {
    Write-Step "Remediating Critical USB Devices..."
    
    $critical = (Analyze-UnknownDevices).Critical
    
    if ($critical.Count -eq 0) {
        Write-Host "[PASS] No critical USB issues detected." -ForegroundColor Green
        return
    }
    
    foreach ($device in $critical) {
        Write-Host "[*] Attempting to remediate: $($device.FriendlyName)" -ForegroundColor Yellow
        
        # Get the device instance ID
        $instanceId = $device.InstanceId
        
        # Disable the device
        Write-Host "    [*] Disabling device..." -ForegroundColor Gray
        try {
            Disable-PnpDevice -InstanceId $instanceId -Confirm:$false -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        } catch {
            Write-Host "    [!] Could not disable: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        # Re-enable the device
        Write-Host "    [*] Re-enabling device..." -ForegroundColor Gray
        try {
            Enable-PnpDevice -InstanceId $instanceId -Confirm:$false -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 3
            
            $updatedDevice = Get-PnpDevice -InstanceId $instanceId -ErrorAction SilentlyContinue
            if ($updatedDevice.Status -eq "OK") {
                Write-Host "    [PASS] Device now has OK status!" -ForegroundColor Green
            } else {
                Write-Host "    [!] Device still has Unknown status. May need manual driver installation." -ForegroundColor Yellow
            }
        } catch {
            Write-Host "    [!] Could not re-enable: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

function Remediate-USBEnumeration {
    Write-Step "Re-Enumerating USB Devices..."
    
    # Disable all USB Root Hubs to force re-enumeration
    Write-Host "[*] Disabling USB Root Hubs to force re-enumeration..." -ForegroundColor Yellow
    
    try {
        Get-PnpDevice | Where-Object { $_.FriendlyName -match "USB Root Hub" } | ForEach-Object {
            Write-Host "    [-] Disabling: $($_.FriendlyName)"
            Disable-PnpDevice -InputObject $_ -Confirm:$false -ErrorAction SilentlyContinue
        }
        
        Start-Sleep -Seconds 3
        
        # Re-enable USB Root Hubs
        Get-PnpDevice | Where-Object { $_.FriendlyName -match "USB Root Hub" } | ForEach-Object {
            Write-Host "    [+] Re-enabling: $($_.FriendlyName)"
            Enable-PnpDevice -InputObject $_ -Confirm:$false -ErrorAction SilentlyContinue
        }
        
        Write-Host "[PASS] USB Re-enumeration complete. Devices should be refreshed." -ForegroundColor Green
    } catch {
        Write-Host "[!] USB Re-enumeration encountered issues: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

function Update-DriversForUnknownDevices {
    Write-Step "Triggering Windows Update for Driver Installation..."
    
    Write-Host "[*] Starting Windows Update scan for drivers..." -ForegroundColor Gray
    
    try {
        # Trigger Windows Update to search for drivers
        Start-Process "usoclient" -ArgumentList "StartScan" -WindowStyle Hidden -Wait -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 5
        
        # Install any available updates
        Start-Process "usoclient" -ArgumentList "StartInstallAfterScan" -WindowStyle Hidden -ErrorAction SilentlyContinue
        
        Write-Host "[INFO] Windows Update scan triggered. Please check Settings > Windows Update for driver installation progress." -ForegroundColor Gray
    } catch {
        Write-Host "[!] Could not trigger Windows Update: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

function Get-MediaTekDeviceStatus {
    Write-Step "Checking MediaTek USB Devices (Phone/Modem Ports)..."
    
    $mediatek = Get-PnpDevice | Where-Object { $_.FriendlyName -match "MediaTek" }
    
    if ($mediatek.Count -gt 0) {
        Write-Host "[!] Found $($mediatek.Count) MediaTek devices (likely phone/modem ports)" -ForegroundColor Yellow
        foreach ($dev in $mediatek) {
            Write-Host "    - $($dev.FriendlyName) [Status: $($dev.Status)]" -ForegroundColor Gray
        }
        Write-Host "[INFO] These may require phone-specific drivers or USB debugging enabled on the connected device." -ForegroundColor Gray
    }
}

function Generate-RemediationReport {
    Write-Step "Generating Remediation Report..."
    
    $ReportPath = "$PSScriptRoot\DeviceRemediationReport.txt"
    $Report = @()
    
    $Report += "=== DEVICE REMEDIATION REPORT ==="
    $Report += "Generated: $(Get-Date)"
    $Report += ""
    
    # Summary
    $allDevices = Get-PnpDevice
    $okDevices = ($allDevices | Where-Object { $_.Status -eq "OK" }).Count
    $unknownDevices = ($allDevices | Where-Object { $_.Status -ne "OK" }).Count
    
    $Report += "SUMMARY:"
    $Report += "  Total Devices: $($allDevices.Count)"
    $Report += "  OK Status: $okDevices"
    $Report += "  Unknown/Problem Status: $unknownDevices"
    $Report += ""
    
    # Categorized devices
    $analysis = Analyze-UnknownDevices
    
    $Report += "CRITICAL ISSUES: $($analysis.Critical.Count)"
    foreach ($dev in $analysis.Critical) {
        $Report += "  - $($dev.FriendlyName) [$($dev.Class)]"
    }
    $Report += ""
    
    $Report += "DISCONNECTED PERIPHERALS (Expected Unknown): $($analysis.Peripheral.Count)"
    foreach ($dev in $analysis.Peripheral) {
        $Report += "  - $($dev.FriendlyName) [$($dev.Class)]"
    }
    $Report += ""
    
    $Report += "VIRTUAL/SOFTWARE DEVICES (Safe to Ignore): $($analysis.Virtual.Count)"
    $Report += ""
    
    $Report += "HID INPUT DEVICES: $($analysis.HID.Count)"
    $Report += ""
    
    $Report += "RECOMMENDATIONS:"
    $Report += "  1. If devices are physically disconnected, Unknown status is NORMAL."
    $Report += "  2. Re-connect USB devices and run this script again."
    $Report += "  3. Check Windows Update (Settings > Windows Update) for driver installations."
    $Report += "  4. For phone/modem ports (MediaTek), ensure USB debugging is enabled on the device."
    $Report += "  5. For persistent 'Unknown' status on connected devices, manually install manufacturers' drivers."
    $Report += ""
    
    $Report | Out-File -FilePath $ReportPath -Encoding UTF8
    Write-Host "[INFO] Report saved to: $ReportPath" -ForegroundColor Gray
}

# Main Execution
Check-Elevation
Analyze-UnknownDevices
Remediate-CriticalUSBDevices
Remediate-USBEnumeration
Get-MediaTekDeviceStatus
Update-DriversForUnknownDevices
Generate-RemediationReport

Write-Step "Device Remediation Complete"
Write-Host "Next Steps:" -ForegroundColor White
Write-Host "  1. Review DeviceRemediationReport.txt for categorized device list" -ForegroundColor Gray
Write-Host "  2. Re-connect any physical USB devices and run this script again" -ForegroundColor Gray
Write-Host "  3. Check Windows Update for driver installations" -ForegroundColor Gray
Write-Host "  4. If issues persist, download manufacturer drivers for specific hardware" -ForegroundColor Gray

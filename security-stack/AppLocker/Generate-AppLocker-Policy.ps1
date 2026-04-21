<#
.SYNOPSIS
    AppLocker Base Policy for CIS Hardening
    
.DESCRIPTION
    XML policy that implements AppLocker controls for application whitelisting
#>

$policy = @"
<AppLockerPolicy Version="1">
  <RuleCollection Type="Exe" EnforcementMode="AuditOnly">
    <FilePathRule Id="921cc481-6e17-4653-8f75-050b4e797838" Name="All files" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions>
        <FilePathCondition Path="%PROGRAMFILES%\*" />
      </Conditions>
    </FilePathRule>
    <FilePathRule Id="921cc481-6e17-4653-8f75-050b4e797839" Name="All files" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions>
        <FilePathCondition Path="%WINDIR%\*" />
      </Conditions>
    </FilePathRule>
    <FilePathRule Id="921cc481-6e17-4653-8f75-050b4e797840" Name="All files in Program Files" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions>
        <FilePathCondition Path="%PROGRAMFILES(X86)%\*" />
      </Conditions>
    </FilePathRule>
    <FilePathRule Id="921cc481-6e17-4653-8f75-050b4e797841" Name="Deny PS1 execution from user temp" Description="" UserOrGroupSid="S-1-1-0" Action="Deny">
      <Conditions>
        <FilePathCondition Path="%APPDATA%\Local\Temp\*\*.ps1" />
      </Conditions>
    </FilePathRule>
  </RuleCollection>
  <RuleCollection Type="Dll" EnforcementMode="AuditOnly">
  </RuleCollection>
  <RuleCollection Type="Script" EnforcementMode="AuditOnly">
  </RuleCollection>
  <RuleCollection Type="Msi" EnforcementMode="AuditOnly">
    <MsiInstaller Id="03bc2e9c-0c25-4601-bfb8-59b0e88b3b88" Name="Installer Paths" Description="" UserOrGroupSid="S-1-1-0" Action="Allow">
      <Conditions>
        <FilePathCondition Path="%PROGRAMFILES%\*.msi" />
      </Conditions>
    </MsiInstaller>
  </RuleCollection>
</AppLockerPolicy>
"@

$policy | Out-File -FilePath "$PSScriptRoot\AppLocker-Base-Policy.xml" -Force
Write-Host "AppLocker base policy created" -ForegroundColor Green

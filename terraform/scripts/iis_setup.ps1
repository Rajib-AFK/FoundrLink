<#
.SYNOPSIS
    FoundrLink IIS Bootstrap Script
    Runs on the Azure Windows Server 2022 VM via CustomScriptExtension on first provision.
    Idempotent — safe to re-run.

.DESCRIPTION
    1. Installs IIS with all ASP.NET 4.8 features
    2. Installs .NET Framework 4.8 (if not already present)
    3. Installs URL Rewrite module
    4. Creates the FoundrLink application directory
    5. Configures the Default Web Site to point at FoundrLink
    6. Sets correct permissions for IIS_IUSRS
    7. Installs Web Management Service (for Web Deploy from Visual Studio)
    8. Opens Windows Firewall for ports 80, 443, 3389, 8172
#>

$ErrorActionPreference = "Stop"
$LogFile = "C:\foundrlink_setup.log"

function Log($msg) {
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$ts  $msg" | Tee-Object -FilePath $LogFile -Append
}

Log "=========================================="
Log " FoundrLink IIS Bootstrap — START"
Log "=========================================="

# ---------------------------------------------------------------------------
# 1. Install IIS + ASP.NET 4.8 Windows Features
# ---------------------------------------------------------------------------
Log "Installing IIS and ASP.NET features..."
$features = @(
    "Web-Server",
    "Web-WebServer",
    "Web-Common-Http",
    "Web-Default-Doc",
    "Web-Dir-Browsing",
    "Web-Http-Errors",
    "Web-Static-Content",
    "Web-Http-Redirect",
    "Web-App-Dev",
    "Web-Asp-Net45",      # ASP.NET 4.x (covers 4.7.2 / 4.8)
    "Web-Net-Ext45",
    "Web-ISAPI-Ext",
    "Web-ISAPI-Filter",
    "Web-Mgmt-Tools",
    "Web-Mgmt-Console",
    "Web-Mgmt-Service",   # Web Management Service (Web Deploy target)
    "Web-Scripting-Tools"
)
Install-WindowsFeature -Name $features -IncludeManagementTools
Log "IIS features installed."

# ---------------------------------------------------------------------------
# 2. Install .NET Framework 4.8 (Windows Server 2022 ships with 4.8 already,
#    but this ensures the hosting bundle is registered with IIS)
# ---------------------------------------------------------------------------
$dotnet48Key = "HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full"
$releaseVal  = (Get-ItemProperty $dotnet48Key -ErrorAction SilentlyContinue).Release
if ($releaseVal -ge 528040) {
    Log ".NET Framework 4.8+ already present (release=$releaseVal). Skipping download."
} else {
    Log "Installing .NET Framework 4.8 Runtime..."
    $url  = "https://go.microsoft.com/fwlink/?linkid=2088631"
    $dest = "C:\Temp\ndp48-x86-x64-allos-enu.exe"
    New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
    Start-Process -FilePath $dest -ArgumentList "/quiet /norestart" -Wait
    Log ".NET Framework 4.8 installed."
}

# ---------------------------------------------------------------------------
# 3. Install URL Rewrite 2.1 (needed for HTTPS redirect rules in web.config)
# ---------------------------------------------------------------------------
$urlRewritePath = "C:\Windows\System32\inetsrv\rewrite.dll"
if (Test-Path $urlRewritePath) {
    Log "URL Rewrite already installed. Skipping."
} else {
    Log "Installing URL Rewrite 2.1..."
    $url  = "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi"
    $dest = "C:\Temp\rewrite_amd64.msi"
    New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null
    Invoke-WebRequest -Uri $url -OutFile $dest -UseBasicParsing
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i $dest /quiet /norestart" -Wait
    Log "URL Rewrite installed."
}

# ---------------------------------------------------------------------------
# 4. Create the FoundrLink web root directory
# ---------------------------------------------------------------------------
$webRoot = "C:\inetpub\foundrlink"
if (-not (Test-Path $webRoot)) {
    New-Item -ItemType Directory -Path $webRoot -Force | Out-Null
    Log "Created web root: $webRoot"
} else {
    Log "Web root already exists: $webRoot"
}

# Create a holding page so the site is reachable before deployment
$holdingPage = Join-Path $webRoot "Default.aspx"
if (-not (Test-Path $holdingPage)) {
    @"
<%@ Page Language="C#" %>
<!DOCTYPE html>
<html><head><title>FoundrLink — Deploying</title>
<style>body{font-family:sans-serif;display:flex;justify-content:center;align-items:center;height:100vh;margin:0;background:#0d1117;color:#c9d1d9;}
h1{font-size:2rem;}p{color:#8b949e;}</style></head>
<body><div style="text-align:center">
<h1>🚀 FoundrLink</h1>
<p>Deployment in progress — check back shortly.</p>
</div></body></html>
"@ | Out-File -FilePath $holdingPage -Encoding UTF8
    Log "Holding page written."
}

# ---------------------------------------------------------------------------
# 5. Set IIS permissions on the web root
# ---------------------------------------------------------------------------
Log "Setting IIS permissions on $webRoot..."
icacls $webRoot /grant "IIS_IUSRS:(OI)(CI)M" /T | Out-Null
icacls $webRoot /grant "IUSR:(OI)(CI)M" /T | Out-Null
Log "Permissions set."

# ---------------------------------------------------------------------------
# 6. Configure IIS — Application Pool + Web Site
# ---------------------------------------------------------------------------
Import-Module WebAdministration -ErrorAction Stop

# Application Pool
$appPoolName = "FoundrLinkPool"
if (-not (Test-Path "IIS:\AppPools\$appPoolName")) {
    New-WebAppPool -Name $appPoolName
    Set-ItemProperty "IIS:\AppPools\$appPoolName" managedRuntimeVersion "v4.0"
    Set-ItemProperty "IIS:\AppPools\$appPoolName" managedPipelineMode    "Integrated"
    Set-ItemProperty "IIS:\AppPools\$appPoolName" startMode              "AlwaysRunning"
    Log "App pool '$appPoolName' created."
} else {
    Log "App pool '$appPoolName' already exists."
}

# Default Web Site → point to FoundrLink
Set-ItemProperty "IIS:\Sites\Default Web Site" physicalPath $webRoot
Set-ItemProperty "IIS:\Sites\Default Web Site" applicationPool $appPoolName
Log "Default Web Site configured → $webRoot with pool $appPoolName"

# Start the site
Start-WebSite "Default Web Site"
Log "Default Web Site started."

# ---------------------------------------------------------------------------
# 7. Enable and start Web Management Service (for Web Deploy)
# ---------------------------------------------------------------------------
Set-Service -Name "WMSVC" -StartupType Automatic
Start-Service -Name "WMSVC"
Log "Web Management Service (WMSVC) started."

# ---------------------------------------------------------------------------
# 8. Windows Firewall rules
# ---------------------------------------------------------------------------
Log "Configuring Windows Firewall..."
$firewallRules = @(
    @{ Name = "FoundrLink-HTTP";       Port = 80;   Protocol = "TCP" },
    @{ Name = "FoundrLink-HTTPS";      Port = 443;  Protocol = "TCP" },
    @{ Name = "FoundrLink-RDP";        Port = 3389; Protocol = "TCP" },
    @{ Name = "FoundrLink-WebDeploy";  Port = 8172; Protocol = "TCP" }
)

foreach ($rule in $firewallRules) {
    $existing = Get-NetFirewallRule -DisplayName $rule.Name -ErrorAction SilentlyContinue
    if (-not $existing) {
        New-NetFirewallRule `
            -DisplayName $rule.Name `
            -Direction   Inbound `
            -Protocol    $rule.Protocol `
            -LocalPort   $rule.Port `
            -Action      Allow
        Log "Firewall rule added: $($rule.Name) (port $($rule.Port))"
    } else {
        Log "Firewall rule already exists: $($rule.Name)"
    }
}

# ---------------------------------------------------------------------------
# 9. Done
# ---------------------------------------------------------------------------
Log "=========================================="
Log " FoundrLink IIS Bootstrap — COMPLETE"
Log " Web root    : $webRoot"
Log " App Pool    : $appPoolName (.NET 4.0 Integrated)"
Log " Log file    : $LogFile"
Log "=========================================="
Log ""
Log " NEXT STEPS:"
Log "  1. Publish FoundrLink from Visual Studio (Folder publish → Release)"
Log "  2. Copy/zip published files into $webRoot"
Log "  3. Update Web.config with the Azure SQL connection string"
Log "  4. Run Database/FoundrLink_Schema_And_Seed.sql on Azure SQL"
Log "  5. (Optional) Install win-acme for free Let's Encrypt SSL"


<#
.SYNOPSIS
    Deploys the FoundrLink Wiki documentation to https://github.com/Rajib-AFK/FoundrLink.wiki.git

.DESCRIPTION
    This script synchronizes all markdown files from the local 'wiki' directory
    to the GitHub Wiki repository for FoundrLink.
#>

[CmdletBinding()]
param(
    [string]$WikiRemoteUrl = "https://YashVinchhi@github.com/Rajib-AFK/FoundrLink.wiki.git",
    [string]$Token = "",
    [string]$WikiSourceDir = "",
    [string]$StagingDir = ""
)

if (-not [string]::IsNullOrWhiteSpace($Token)) {
    # If a GitHub Personal Access Token is supplied, inject it into the remote URL
    $WikiRemoteUrl = "https://$Token@github.com/Rajib-AFK/FoundrLink.wiki.git"
}

$scriptDir = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
if ([string]::IsNullOrWhiteSpace($WikiSourceDir)) {
    $WikiSourceDir = Join-Path $scriptDir "wiki"
}
if ([string]::IsNullOrWhiteSpace($StagingDir)) {
    $StagingDir = Join-Path $scriptDir ".wiki-staging"
}

Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host " FoundrLink GitHub Wiki Deployment Tool" -ForegroundColor Cyan
Write-Host " Target Wiki: https://github.com/Rajib-AFK/FoundrLink/wiki" -ForegroundColor Cyan
Write-Host " Remote Git:  $WikiRemoteUrl" -ForegroundColor Cyan
Write-Host "==============================================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $WikiSourceDir)) {
    Write-Error "Source directory '$WikiSourceDir' does not exist."
    exit 1
}

# 1. Prepare Staging Directory
if (Test-Path $StagingDir) {
    Remove-Item -Path $StagingDir -Recurse -Force
}
New-Item -ItemType Directory -Path $StagingDir -Force | Out-Null

# 2. Copy all Wiki files to Staging
Write-Host "[1/4] Copying Wiki markdown pages to staging..." -ForegroundColor Yellow
Get-ChildItem -Path $WikiSourceDir -Filter "*.md" | ForEach-Object {
    Copy-Item -Path $_.FullName -Destination $StagingDir -Force
    Write-Host "  -> Copied: $($_.Name)" -ForegroundColor Gray
}

# 3. Initialize Git in Staging
Write-Host "[2/4] Initializing local Git staging repository..." -ForegroundColor Yellow
Push-Location $StagingDir
try {
    git init -b master | Out-Null
    git config user.name "Yash Vinchhi"
    git config user.email "yashhvinchhi@gmail.com"
    git config commit.gpgsign false
    
    # Check if remote already exists, otherwise add
    git remote add origin $WikiRemoteUrl 2>$null
    if ($LASTEXITCODE -ne 0) {
        git remote set-url origin $WikiRemoteUrl
    }

    git add .
    git commit -m "Publish complete FoundrLink project documentation (v1.0)"

    # 4. Push to GitHub Wiki
    Write-Host "[3/4] Testing remote connection and pushing to GitHub Wiki..." -ForegroundColor Yellow
    
    $pushOutput = git push -u origin master 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "==============================================================" -ForegroundColor Green
        Write-Host " SUCCESS: Wiki pages successfully published to GitHub!" -ForegroundColor Green
        Write-Host " View the live wiki at: https://github.com/Rajib-AFK/FoundrLink/wiki" -ForegroundColor Green
        Write-Host "==============================================================" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "==============================================================" -ForegroundColor Magenta
        Write-Host " NOTICE: GitHub Wiki requires 1-time web initialization" -ForegroundColor Yellow
        Write-Host "==============================================================" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "GitHub returned: $pushOutput" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "Why did this happen?" -ForegroundColor White
        Write-Host "On GitHub, a wiki repository is only provisioned on the server" -ForegroundColor White
        Write-Host "after the owner visits the Wiki tab in their browser once." -ForegroundColor White
        Write-Host ""
        Write-Host "Quick 2-Step Action to activate:" -ForegroundColor Cyan
        Write-Host "  1. Visit: https://github.com/Rajib-AFK/FoundrLink/wiki" -ForegroundColor White
        Write-Host "  2. Click 'Create the first page' (type anything, e.g. 'Home') and click 'Save Page'." -ForegroundColor White
        Write-Host "  3. Re-run this script: .\deploy-wiki.ps1" -ForegroundColor White
        Write-Host ""
        Write-Host "As soon as you click Save Page on GitHub, this script will" -ForegroundColor White
        Write-Host "push all 19 comprehensive documentation pages in 2 seconds!" -ForegroundColor White
        Write-Host "==============================================================" -ForegroundColor Magenta
    }
}
finally {
    Pop-Location
}

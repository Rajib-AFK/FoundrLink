# FoundrLink Automated Regression Test Harness
# Executes all unit, security, validation, and fallback tests within the compiled assembly

$msbuild = "C:\Program Files\Microsoft Visual Studio\18\Community\MSBuild\Current\Bin\MSBuild.exe"
if (-not (Test-Path $msbuild)) {
    $msbuild = "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe"
}
if (-not (Test-Path $msbuild)) {
    $msbuild = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe"
}

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "  FoundrLink Test Suite (CE545 Enterprise Computing)      " -ForegroundColor Cyan
Write-Host "  Author: Chirag Fofandi (24CE0503)                      " -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Build Project
Write-Host "`n[1/2] Compiling FoundrLink.csproj..." -ForegroundColor Yellow
$buildOutput = & $msbuild FoundrLink.csproj /t:Build /p:Configuration=Debug /v:m 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed! Output:" -ForegroundColor Red
    $buildOutput | ForEach-Object { Write-Host $_ -ForegroundColor Red }
    exit 1
}
Write-Host "Build Succeeded!" -ForegroundColor Green

# 2. Execute Tests via Reflection
Write-Host "`n[2/2] Executing Automated Test Suite..." -ForegroundColor Yellow
$dllPath = Join-Path $PSScriptRoot "bin\FoundrLink.dll"

# Load dependencies
Add-Type -Path $dllPath

$runnerType = [FoundrLink.Tests.TestRunner]
$results = $runnerType::RunAllTests()

$passedCount = 0
$failedCount = 0

Write-Host "`nTest Execution Results:" -ForegroundColor White
Write-Host "--------------------------------------------------------------------------------------------------" -ForegroundColor Gray

foreach ($r in $results) {
    if ($r.Passed) {
        $passedCount++
        Write-Host "  [PASS] " -ForegroundColor Green -NoNewline
        Write-Host "$($r.TestName) " -ForegroundColor White -NoNewline
        Write-Host "($($r.DurationMs) ms)" -ForegroundColor DarkGray
    } else {
        $failedCount++
        Write-Host "  [FAIL] " -ForegroundColor Red -NoNewline
        Write-Host "$($r.TestName) " -ForegroundColor Red -NoNewline
        Write-Host "($($r.DurationMs) ms)" -ForegroundColor DarkGray
        Write-Host "         Error: $($r.ErrorMessage)" -ForegroundColor Yellow
    }
}

Write-Host "--------------------------------------------------------------------------------------------------" -ForegroundColor Gray
Write-Host "Total Tests: $($results.Count) | Passed: $passedCount | Failed: $failedCount" -ForegroundColor $(if ($failedCount -eq 0) { 'Green' } else { 'Red' })
Write-Host "==========================================================`n" -ForegroundColor Cyan

if ($failedCount -gt 0) {
    exit 1
}
exit 0

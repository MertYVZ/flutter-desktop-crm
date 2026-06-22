# Build a release Windows app and package it as an Inno Setup installer (.exe).
#
# Usage (from repository root on Windows):
#   .\scripts\build_windows_installer.ps1
#   .\scripts\build_windows_installer.ps1 -SkipBuild
#   .\scripts\build_windows_installer.ps1 -ZipOnly
#
# Output:
#   dist/Ok_Teknik_Metal_CRM_<version>_windows_setup.exe
#   (or dist/Ok_Teknik_Metal_CRM_<version>_windows.zip when Inno Setup is missing)
#
#Requires -Version 5.1

[CmdletBinding()]
param(
    [switch]$SkipBuild,
    [switch]$ZipOnly,
    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Show-Usage {
    @"
Build Ok Teknik Metal CRM Windows release installer.

Usage:
  .\scripts\build_windows_installer.ps1 [options]

Options:
  -SkipBuild   Skip "flutter build windows --release" (use existing Release folder)
  -ZipOnly     Skip Inno Setup; create a ZIP of the Release build only
  -Help        Show this help

Output:
  dist/Ok_Teknik_Metal_CRM_<version>_windows_setup.exe
  dist/Ok_Teknik_Metal_CRM_<version>_windows.zip   (fallback or -ZipOnly)

Prerequisites:
  Flutter SDK, Visual Studio 2022 with "Desktop development with C++"
  Inno Setup 6 (optional; ZIP fallback if ISCC.exe is not found)

"@ | Write-Host
}

if ($Help) {
    Show-Usage
    exit 0
}

if ($env:OS -ne 'Windows_NT') {
    Write-Error 'Windows installer packaging must run on Windows.'
}

$RootDir = Split-Path -Parent $PSScriptRoot
Set-Location $RootDir

$PubspecPath = Join-Path $RootDir 'pubspec.yaml'
$AppInfoPath = Join-Path $RootDir 'macos\Runner\Configs\AppInfo.xcconfig'
$CmakePath = Join-Path $RootDir 'windows\CMakeLists.txt'

foreach ($required in @($PubspecPath, $AppInfoPath, $CmakePath)) {
    if (-not (Test-Path -LiteralPath $required)) {
        throw "Missing required file: $required"
    }
}

$AppName = (
    Select-String -Path $AppInfoPath -Pattern '^\s*PRODUCT_NAME\s*=\s*(.+)$' |
    Select-Object -First 1
).Matches.Groups[1].Value.Trim()

$VersionLine = (
    Select-String -Path $PubspecPath -Pattern '^\s*version:\s*(\S+)' |
    Select-Object -First 1
).Matches.Groups[1].Value.Trim()
$Version = ($VersionLine -split '\+')[0]

$BinaryName = (
    Select-String -Path $CmakePath -Pattern 'set\(BINARY_NAME\s+"([^"]+)"\)' |
    Select-Object -First 1
).Matches.Groups[1].Value.Trim()

$ReleaseDir = Join-Path $RootDir 'build\windows\x64\runner\Release'
$ExePath = Join-Path $ReleaseDir "$BinaryName.exe"
$DistDir = Join-Path $RootDir 'dist'
$OutputBaseName = "Ok_Teknik_Metal_CRM_${Version}_windows_setup"
$InstallerPath = Join-Path $DistDir "$OutputBaseName.exe"
$ZipPath = Join-Path $DistDir "Ok_Teknik_Metal_CRM_${Version}_windows.zip"
$IssPath = Join-Path $RootDir 'scripts\windows_installer.iss'

Write-Host "==> App:           $AppName"
Write-Host "==> Version:       $Version"
Write-Host "==> Executable:    $ExePath"
Write-Host "==> Installer out: $InstallerPath"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'flutter is not on PATH.'
}

if (-not $SkipBuild) {
    Write-Host '==> Building Windows release...'
    flutter build windows --release
} else {
    Write-Host '==> Skipping flutter build (-SkipBuild)'
}

if (-not (Test-Path -LiteralPath $ExePath)) {
    throw @"
Release executable not found at:
  $ExePath
Run without -SkipBuild or build manually: flutter build windows --release
"@
}

New-Item -ItemType Directory -Force -Path $DistDir | Out-Null

function Find-InnoSetupCompiler {
    $candidates = @(
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "$env:ProgramFiles\Inno Setup 6\ISCC.exe"
    )
    foreach ($path in $candidates) {
        if (Test-Path -LiteralPath $path) {
            return $path
        }
    }
    return $null
}

function New-ReleaseZip {
    param(
        [string]$DestinationZip
    )

    if (Test-Path -LiteralPath $DestinationZip) {
        Remove-Item -LiteralPath $DestinationZip -Force
    }

    Write-Host "==> Creating ZIP archive: $DestinationZip"
    Compress-Archive -Path (Join-Path $ReleaseDir '*') -DestinationPath $DestinationZip -CompressionLevel Optimal
}

if ($ZipOnly) {
    New-ReleaseZip -DestinationZip $ZipPath
    Write-Host ''
    Write-Host 'Done.'
    Write-Host "  ZIP: $ZipPath"
    exit 0
}

$Iscc = Find-InnoSetupCompiler
if (-not $Iscc) {
    Write-Warning 'Inno Setup (ISCC.exe) not found; creating ZIP fallback.'
    Write-Warning 'Install Inno Setup 6: https://jrsoftware.org/isdl.php'
    New-ReleaseZip -DestinationZip $ZipPath
    Write-Host ''
    Write-Host 'Done (ZIP fallback).'
    Write-Host "  ZIP: $ZipPath"
    exit 0
}

if (Test-Path -LiteralPath $InstallerPath) {
    Remove-Item -LiteralPath $InstallerPath -Force
}

Write-Host "==> Compiling installer with Inno Setup..."
Write-Host "    ISCC: $Iscc"

$isccArgs = @(
    "/DMyAppVersion=$Version",
    "/DSourceDir=$ReleaseDir",
    "/DOutputDir=$DistDir",
    "/DOutputBaseFilename=$OutputBaseName",
    $IssPath
)

& $Iscc @isccArgs
if ($LASTEXITCODE -ne 0) {
    throw "Inno Setup compiler failed with exit code $LASTEXITCODE"
}

if (-not (Test-Path -LiteralPath $InstallerPath)) {
    throw "Installer was not created at $InstallerPath"
}

$sizeMb = [math]::Round((Get-Item -LiteralPath $InstallerPath).Length / 1MB, 2)
Write-Host ''
Write-Host 'Done.'
Write-Host "  Installer: $InstallerPath"
Write-Host "  Size:      $sizeMb MB"

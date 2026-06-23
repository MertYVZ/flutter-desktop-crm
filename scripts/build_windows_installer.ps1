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
$CmakePath = Join-Path $RootDir 'windows\CMakeLists.txt'
$WindowsMainPath = Join-Path $RootDir 'windows\runner\main.cpp'

foreach ($required in @($PubspecPath, $CmakePath, $WindowsMainPath)) {
    if (-not (Test-Path -LiteralPath $required)) {
        throw "Missing required file: $required"
    }
}

function Get-FirstRegexGroup {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path,

        [Parameter(Mandatory = $true)]
        [string]$Pattern,

        [Parameter(Mandatory = $true)]
        [string]$Description
    )

    $match = Select-String -Path $Path -Pattern $Pattern | Select-Object -First 1
    if (-not $match) {
        throw "Could not read $Description from $Path"
    }

    return $match.Matches.Groups[1].Value.Trim()
}

function Convert-ToFileNameToken {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Value
    )

    $invalidPattern = "[{0}]" -f [regex]::Escape(([System.IO.Path]::GetInvalidFileNameChars() -join ''))
    return (($Value -replace $invalidPattern, '') -replace '\s+', '_')
}

$AppName = Get-FirstRegexGroup `
    -Path $WindowsMainPath `
    -Pattern 'window\.Create\(L"([^"]+)"' `
    -Description 'Windows app display name'

$VersionLine = Get-FirstRegexGroup `
    -Path $PubspecPath `
    -Pattern '^\s*version:\s*(\S+)' `
    -Description 'pubspec version'
$Version = ($VersionLine -split '\+')[0]

$BinaryName = Get-FirstRegexGroup `
    -Path $CmakePath `
    -Pattern 'set\(BINARY_NAME\s+"([^"]+)"\)' `
    -Description 'Windows binary name'

$ExeName = "$BinaryName.exe"
$ReleaseDir = Join-Path $RootDir 'build\windows\x64\runner\Release'
$ExePath = Join-Path $ReleaseDir $ExeName
$DistDir = Join-Path $RootDir 'dist'
$OutputPrefix = Convert-ToFileNameToken -Value $AppName
$OutputBaseName = "${OutputPrefix}_${Version}_windows_setup"
$InstallerPath = Join-Path $DistDir "$OutputBaseName.exe"
$ZipPath = Join-Path $DistDir "${OutputPrefix}_${Version}_windows.zip"
$IssPath = Join-Path $RootDir 'scripts\windows_installer.iss'
$Publisher = 'Ok Teknik Metal'

Write-Host "==> App:           $AppName"
Write-Host "==> Publisher:     $Publisher"
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

$env:OKTM_APP_NAME = $AppName
$env:OKTM_APP_PUBLISHER = $Publisher
$env:OKTM_APP_EXE_NAME = $ExeName
$env:OKTM_APP_VERSION = $Version
$env:OKTM_SOURCE_DIR = $ReleaseDir
$env:OKTM_OUTPUT_DIR = $DistDir
$env:OKTM_OUTPUT_BASE_FILENAME = $OutputBaseName

& $Iscc $IssPath
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

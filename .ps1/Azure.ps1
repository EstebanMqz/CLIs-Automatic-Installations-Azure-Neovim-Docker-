<#
.SYNOPSIS
    Installs the Azure PowerShell module on Windows.

.DESCRIPTION
    Automates the installation of the Azure (Az) module. 
    Includes administrative privilege checks, NuGet provider enforcement, 
    scoped installation, and persistent profile configuration for module autoloading and error handling. Doesn´t add the module to the system PATH, as it is imported via the PowerShell natively and all their cmdlets for autocompletion and loading.

.NOTES
    Author  : EstebanMqz
    License : Apache-2.0
    Source  : https://github.com/EstebanMqz/CLIs-Automatic-Installations-Azure-Neovim-Docker-/blob/main/.ps1/Azure.ps1
#>

# Self-elevate to Administrator if not already elevated
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Administrator privileges required for Azure module setup. Requesting UAC..." -ForegroundColor Yellow
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Checking for Azure (Az) module..." -ForegroundColor Cyan

try {
    # Enforce TLS 1.2 to ensure a reliable connection to the PowerShell Gallery
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    if (-not (Get-Module -Name Az -ListAvailable -ErrorAction SilentlyContinue)) {
        Write-Host "Ensuring NuGet provider is available..." -ForegroundColor Yellow
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null

        Write-Host "Setting PSGallery to Trusted to prevent installation prompts..." -ForegroundColor Yellow
        Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted -ErrorAction SilentlyContinue
        
        Write-Host "Installing Az module..." -ForegroundColor Yellow
        Install-Module -Name Az -AllowClobber -Scope AllUsers -Force -Confirm:$false
    }
}
catch {
    Write-Error "Failed to install the Az module: $($_.Exception.Message)"
    exit 1
}

# 1. Correctly retrieve the module base path.
# We sort by Version descending to ensure we get the latest installed version.
# Accessing -ListAvailable ensures we look at the disk, even if not yet imported.
$azModule = Get-Module -Name Az -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1

if ($null -eq $azModule) {
    Write-Error "Az module installation failed or could not be located."
    exit 1
}

$azModulePath = $azModule.ModuleBase
Write-Host "Az module located at: $azModulePath" -ForegroundColor Green

# 2. Verify and update the PowerShell Profile for persistence
if (-not $PROFILE) {
    Write-Warning "PowerShell profile is not defined in this host. Skipping profile update."
    return
}

$profileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
}
if (-not (Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force | Out-Null
}

# Append the Import-Module command to the profile if it's not already there
$importCmd = "Import-Module Az -DisableNameChecking"
if (Test-Path $PROFILE) {
    $profileContent = Get-Content $PROFILE -Raw
    if ($profileContent -notmatch "Import-Module\s+Az") {
        Add-Content -Path $PROFILE -Value "`n# Azure Module Autoloader`n$importCmd"
        Write-Host "Added 'Import-Module Az -DisableNameChecking' to your PowerShell profile." -ForegroundColor Cyan
    }
}

Write-Host "`nSummary of installed Az submodules:" -ForegroundColor Cyan
Get-Module -Name Az.* -ListAvailable | Select-Object Name, Version | Sort-Object Name | Format-Table
Write-Host "Azure setup complete." -ForegroundColor Green

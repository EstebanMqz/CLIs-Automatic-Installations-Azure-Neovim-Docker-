# Then, add the line `Import-Module -Name Az` to the profile script and save it. This way, the module will be imported every time you start a new PowerShell session, and autocompletion will be available without needing to import the module manually each time.
# By following these steps, you can easily install a PowerShell module that provides autocompletion for commands and parameters, enhancing your productivity in the PowerShell console.
# #Could you chain all the necessary commands together to install the module and enable autocompletion in one go?
# Certainly! You can chain the necessary commands together in a single line to install the module, import it, and enable autocompletion. Here's how you can do it for the `Az` module but chained together.

# Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Checking for Azure (Az) module..." -ForegroundColor Cyan

try {
    if (-not (Get-Module -Name Az -ListAvailable -ErrorAction SilentlyContinue)) {
        Write-Host "Ensuring NuGet provider is available..." -ForegroundColor Yellow
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
        
        Write-Host "Installing Az module..." -ForegroundColor Yellow
        Install-Module -Name Az -AllowClobber -Scope AllUsers -Force -Confirm:$false
    }
}
catch {
    Write-Error "Failed to install the Az module: $($_.Exception.Message)"
    exit 1
}

# 1. Correctly retrieve the module base path (using the first match if multiple exist)
$azModule = Get-Module -Name Az -ListAvailable | Select-Object -First 1

if ($null -eq $azModule) {
    Write-Error "Az module installation failed or could not be located."
    exit 1
}

$azModulePath = $azModule.ModuleBase
Write-Host "Az module located at: $azModulePath" -ForegroundColor Green

# 2. Programmatically update the PowerShell Profile for persistence
$profileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path $profileDir)) {
    New-Item -Path $profileDir -ItemType Directory -Force | Out-Null
}
if (-not (Test-Path $PROFILE)) {
    New-Item -Path $PROFILE -ItemType File -Force | Out-Null
}

# Append the Import-Module command to the profile if it's not already there
$importCmd = "Import-Module Az"
if (Test-Path $PROFILE) {
    $profileContent = Get-Content $PROFILE -Raw
    if ($profileContent -notmatch "Import-Module\s+Az") {
        Add-Content -Path $PROFILE -Value "`n# Azure Module Autoloader`n$importCmd"
        Write-Host "Added 'Import-Module Az' to your PowerShell profile." -ForegroundColor Cyan
    }
}

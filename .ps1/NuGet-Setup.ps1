# Requires -RunAsAdministrator
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Configuring NuGet and PowerShell Gallery for modern requirements..." -ForegroundColor Cyan

try {
    # 1. Enforce TLS 1.2
    # The PowerShell Gallery and NuGet feeds now require TLS 1.2. 
    # Older Windows environments default to TLS 1.0/1.1.
    Write-Host "Enforcing TLS 1.2 protocol..." -ForegroundColor Gray
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # 2. Install/Update the NuGet Package Provider
    # This is the core engine PowerShell uses to interact with NuGet-based feeds.
    Write-Host "Installing latest NuGet Provider..." -ForegroundColor Yellow
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -Confirm:$false | Out-Null

    # 3. Update PowerShellGet and PackageManagement
    # Modern versions of the Az module and other modern CLIs require 
    # updated versions of these base modules.
    Write-Host "Updating PowerShellGet and PackageManagement modules..." -ForegroundColor Yellow
    
    # We use -AllowClobber to ensure we can overwrite older system-provided versions.
    $moduleParams = @{
        Force        = $true
        AllowClobber = $true
        Scope        = 'AllUsers'
        Confirm      = $false
        ErrorAction  = 'SilentlyContinue'
    }

    Install-Module -Name PackageManagement @moduleParams
    Install-Module -Name PowerShellGet @moduleParams

    # 4. Set PSGallery to Trusted
    # This avoids the "Untrusted repository" prompt when installing modules.
    Write-Host "Setting PowerShell Gallery to 'Trusted'..." -ForegroundColor Gray
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

    Write-Host "`n✅ NuGet and PowerShell module management updated successfully." -ForegroundColor Green
    Write-Host "You may need to restart your PowerShell session for all changes to take effect." -ForegroundColor Yellow
}
catch {
    Write-Host "`n❌ Failed to configure NuGet: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Trace: $($_.ScriptStackTrace)" -ForegroundColor DarkGray
    exit 1
}

# Requires Administrator privileges to modify System PATH
$neovimUrl = "https://github.com/neovim/neovim/releases/latest/download/nvim-win64.zip"
$downloadPath = "$env:TEMP\nvim-win64.zip"
$extractPath = "C:\Neovim"
$binPath = "$extractPath\nvim-win64\bin"

# 1. Download Neovim
Write-Host "Downloading Neovim..." -ForegroundColor Cyan
$oldProgress = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $neovimUrl -OutFile $downloadPath
$ProgressPreference = $oldProgress

# 2. Remove old installation if exists
if (Test-Path -Path $extractPath) {
    Write-Host "Cleaning up old installation at $extractPath..." -ForegroundColor Yellow
    Remove-Item -Path $extractPath -Recurse -Force -ErrorAction SilentlyContinue
}
New-Item -ItemType Directory -Path $extractPath | Out-Null

# 3. Extract zip
Write-Host "Extracting files..." -ForegroundColor Cyan
Expand-Archive -Path $downloadPath -DestinationPath $extractPath -Force

# 4. Add Neovim to System PATH
$path = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($path -notlike "*$binPath*") {
    $newPath = "$path;$binPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    Write-Host "SUCCESS: Added Neovim to system PATH." -ForegroundColor Green
    Write-Host "Please restart your terminal (or run 'refreshenv') to use 'nvim'." -ForegroundColor Yellow
} else {
    Write-Host "Neovim path already exists in system PATH." -ForegroundColor Gray
}

# 5. Cleanup downloaded zip
Remove-Item -Path $downloadPath
Write-Host "Neovim installed successfully at $extractPath." -ForegroundColor Green
Write-Host "You can run 'nvim' from any terminal after restarting it." -ForegroundColor Cyan
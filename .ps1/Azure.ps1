#Module installation and autocompletion setup for Az module in PowerShell
Install-Module -Name Az -AllowClobber -Scope AllUsers
#Import the module to enable autocompletion
$azModulePath = (Get-Module -Name Az -ListAvailable).ModuleBase
#Add the module path to the environment variable for autocompletion
$env:PATH += ";$azModulePath"
#Open the PowerShell profile to add the module import command for autocompletion
notepad $PROFILE
#Add Microsoft.PowerShell_profile.ps1
$env:PATH += ";$azModulePath"
#Save and close the profile file

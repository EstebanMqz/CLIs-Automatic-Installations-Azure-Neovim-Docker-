# Azure CLI Installation Script

This repository contains a PowerShell script to automate the installation of the Azure CLI on Windows. The script ensures a smooth and efficient installation process by handling all necessary steps, from downloading the installer to verifying the installation.

## Features

- **Download the Installer**:  
  The script downloads the Azure CLI MSI installer from the official Microsoft URL ([https://aka.ms/installazurecliwindows](https://aka.ms/installazurecliwindows)) to the system's temporary directory.

- **Run the Installer**:  
  The `msiexec.exe` command is used to run the installer silently (`/quiet`) without requiring user interaction. The `/norestart` flag prevents the system from restarting automatically.

- **Verify Installation**:  
  After installation, the script checks if the `az` command is available using `Get-Command`. If found, it confirms the installation was successful.

- **Cleanup**:  
  The downloaded installer is deleted from the temporary directory to save space.

- **Output Messages**:  
  The script provides clear messages to indicate the progress and result of the installation process.

## Benefits

- Fully automated installation process.
- Ensures the Azure CLI is properly added to the system PATH.
- Provides user-friendly messages for better clarity.

## Usage

1. Download the script from this repository.
2. Run the script in a PowerShell terminal with administrator privileges.
3. Follow the on-screen instructions.

## Notes

- Ensure you have administrator privileges before running the script.
- Restart your terminal or run `refreshenv` after installation to apply the changes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
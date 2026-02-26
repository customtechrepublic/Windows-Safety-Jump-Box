# CIS Hardening Scripts

This repository contains scripts for hardening Windows systems according to the Center for Internet Security (CIS) benchmarks. Below you will find instructions on how to use these scripts effectively.

## Prerequisites
- Ensure you have administrator permissions on the Windows machine.
- Windows PowerShell is installed and available.
- The machine should be running a compatible version of the Windows operating system.

## Installation
1. Clone the repository to your local machine:
   ```bash
   git clone https://github.com/customtechrepublic/Windows-Safety-Jump-Box.git
   ```
2. Navigate to the directory:
   ```bash
   cd Windows-Safety-Jump-Box
   ```
3. Review the scripts to ensure you understand their purpose and effect before executing them.

## Usage
- To run a script, open PowerShell as an administrator and navigate to the scripts' directory:
   ```bash
   cd path_to_scripts_directory
   ```
- Execute a script using the following command:
   ```powershell
   .\script_name.ps1
   ```

## Testing
- Always test scripts in a safe or non-production environment first to verify behavior.
- Review the changes made to the system after running the scripts by checking relevant settings or using security assessment tools.

## Rollback Procedures
- If you encounter issues after running a hardening script, you can revert to your previous system state if you have a backup. 
- It is recommended to take a full system backup before applying scripts.
- Document any system changes made during the hardening process to facilitate easy rollback where necessary.

## Contact
For support or inquiries, please contact the repository owner at customtechrepublic.
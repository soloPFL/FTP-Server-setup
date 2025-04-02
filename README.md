# FTP Server Management Script Guide

This guide provides instructions on how to use the FTP server management script to install, configure, and manage an FTP server using `vsftpd` on a Linux system. The script also supports SSL configuration using Let's Encrypt and Certbot.

## Prerequisites

- Ensure you have `sudo` privileges on your Linux system.
- The script is designed for Debian-based systems (e.g., Ubuntu).

## Script Features

- Install and configure `vsftpd`.
- Create and delete FTP users.
- Create and delete shared directories for users.
- Start, stop, and restart the FTP server.
- Configure SSL using Let's Encrypt.
- Install necessary dependencies (`snapd`, `certbot`) if SSL is enabled.

## Usage Instructions

1. **Save the Script**:
   - Save the script to a file, e.g., `ftp_manager.sh`.

2. **Make the Script Executable**:
   - Open a terminal and navigate to the directory containing the script.
   - Run the following command to make the script executable:
     ```bash
     chmod +x ftp_manager.sh
     ```

3. **Run the Script**:
   - Execute the script with `sudo`:
     ```bash
     sudo ./ftp_manager.sh
     ```

4. **Follow the Menu Prompts**:
   - The script provides a menu-driven interface. Select the desired option by entering the corresponding number.

## Menu Options

1. **Install FTP Server**:
   - Installs `vsftpd` on your system.

2. **Start FTP Server**:
   - Starts the `vsftpd` service.

3. **Stop FTP Server**:
   - Stops the `vsftpd` service.

4. **Restart FTP Server**:
   - Restarts the `vsftpd` service.

5. **Configure FTP Server**:
   - Configures `vsftpd` based on user inputs.
   - Prompts for enabling write access, local user access, user isolation, passive mode, and SSL.
   - If SSL is enabled, prompts for an email address and hostname to obtain an SSL certificate from Let's Encrypt.
   - Installs `snapd` and `certbot` if not already installed.

6. **Create FTP User**:
   - Prompts for a username and password to create a new FTP user.

7. **Delete FTP User**:
   - Prompts for a username to delete an existing FTP user.

8. **Create Share**:
   - Prompts for a username and share name to create a shared directory for the user.

9. **Delete Share**:
   - Prompts for a username and share name to delete a shared directory for the user.

10. **Exit**:
    - Exits the script.

## Notes

- Ensure that the necessary ports (e.g., 21 for FTP, 10000-10100 for passive mode) are open in your firewall settings.
- The script assumes default configurations for `vsftpd`. Adjust the settings as needed for your environment.
- The SSL configuration uses Let's Encrypt, which requires a valid domain name pointing to your server.

By following these instructions, you can easily set up and manage an FTP server with SSL support using this script.

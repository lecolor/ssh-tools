# SSH Login Script with Password Encryption

This script allows you to securely connect to remote servers via SSH using stored passwords that are encrypted with AES-256-CBC encryption. The passwords are saved in a local file and retrieved when connecting to the same server, reducing the need to enter the password each time.

## Features
- **Password Encryption:** The script uses AES-256-CBC encryption to securely store and retrieve passwords.
- **Password Management:** Passwords are saved for each target server and can be updated or removed.
- **Automatic SSH Connection:** Once the password is retrieved, it will be used to automatically log into the remote server.
- **Terminal Title Change:** Upon successful SSH login, the terminal tab title is updated to reflect the user and host (`user@host`).

## Prerequisites
- `sshpass` tool: This is used for non-interactive SSH login.
- `openssl`: For encryption and decryption of passwords.
- macOS or Linux terminal: The terminal needs to support control characters to update the tab title.

## Usage

### Basic Usage

1. **Initial Connection (First Time Login):**
    
    ```bash
    ./ssh_login.sh username@hostname
    ```

    - The first time you connect, you will be prompted to enter the password for the server.
    - The password will be encrypted and saved locally for future use.

2. **Subsequent Connections:**
    - The password will be retrieved from the encrypted password file and used to connect automatically without re-entering the password.

3. **Clear All Saved Passwords:**
    - To clear all saved passwords, use:
    
    ```bash
    ./ssh_login.sh -c
    ```

4. **Delete Password for a Specific Host:**
    - To delete the saved password for a specific host:
    
    ```bash
    ./ssh_login.sh -d username@hostname
    ```

    - The `-d` option requires the target host as a parameter (e.g., `user@192.168.1.100`).

5. **Help:**
    - To display help and usage information:
    
    ```bash
    ./ssh_login.sh -h
    ```

### Options
- `-h` : Show help/usage information.
- `-c` : Clear all saved passwords.
- `-d username@hostname` : Delete password for the specified target host (requires target host as an argument).

## Example Usage

### Connecting for the First Time:
```bash
./ssh_login.sh user@192.168.1.100  
```

## Adding the Script to `PATH`

To make it easier to run the script from anywhere, you can add it to your system's `PATH` by creating a symbolic link (soft link).

1. **Move the script to a directory in your PATH:**

    You can move the script to a directory that is already in your system's `PATH`, such as `/usr/local/bin`:

    ```bash
    sudo mv ssh_login.sh /usr/local/bin/ssh_login
    ```

2. **Alternatively, create a symlink:**

    If you prefer not to move the script, you can create a symlink in a directory that is already in your `PATH`, for example:

    ```bash
    sudo ln -s /path/to/ssh_login.sh /usr/local/bin/ssh_login
    ```

    Make sure `/usr/local/bin` (or the path where you create the symlink) is in your `PATH`. To check, you can run:

    ```bash
    echo $PATH
    ```

After this setup, you can run the script simply by typing `ssh_login username@hostname` from anywhere in the terminal, without needing to specify the full path to the script.

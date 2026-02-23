#!/usr/bin/pwsh
# Linux-compatible PowerShell user management script

$csvPath = "/home/vinit-ranjan/Developer/Automating-User-Management/users.csv"
$logFile = "/home/vinit-ranjan/Developer/Automating-User-Management/user-management.log"

# Logging function
function Log-Action {
    param([string]$message)
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    Add-Content -Path $logFile -Value "$timestamp - $message"
}

# Ensure log directory exists
if (-not (Test-Path (Split-Path $logFile))) {
    New-Item -ItemType Directory -Path (Split-Path $logFile) -Force
}

# Import CSV
$users = Import-Csv -Path $csvPath

foreach ($user in $users) {
    $username = $user.Username.Trim()
    $password = $user.Password.Trim()
    $role = $user.Role.Trim()

    if (-not $username) {
        Log-Action "Skipping row with empty username."
        continue
    }

    bash -c "id -u $username 2>/dev/null"
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        Log-Action "User '$username' exists. Updating password."
        bash -c "echo '${username}:$password' | sudo chpasswd"

        if ($role -eq "Admin") {
            bash -c "sudo usermod -aG sudo $username"
            Log-Action "User '$username' ensured in sudo group."
        }
        elseif ($role -eq "Standard User") {
            bash -c "sudo gpasswd -d $username sudo 2>/dev/null"
            Log-Action "User '$username' removed from sudo group."
        }

    }
    else {
        Log-Action "User '$username' does not exist. Creating..."
        bash -c "sudo useradd -m -p $(openssl passwd -1 $password) $username"
        Log-Action "User '$username' created."

        if ($role -eq "Admin") {
            bash -c "sudo usermod -aG sudo $username"
            Log-Action "User '$username' added to sudo group."
        }
        else {
            Log-Action "User '$username' assigned standard privileges."
        }
    }

    # Ensure home directory exists and permissions are correct
    if (-not (Test-Path "/home/$username")) {
        bash -c "sudo mkdir /home/$username"
        bash -c "sudo chown ${username}:${username} /home/$username"
        bash -c "sudo chmod 700 /home/$username"
        Log-Action "Home directory for '$username' created and secured."
    }
    else {
        bash -c "sudo chown ${username}:$username /home/$username"
        bash -c "sudo chmod 700 /home/$username"
        Log-Action "Home directory for '$username' already exists and permissions updated."
    }
}

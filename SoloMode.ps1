# Ensure the script runs as Administrator
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# Import BurntToast module (install if not available)
if (-not (Get-Module -ListAvailable -Name BurntToast)) {
    Install-Module -Name BurntToast -Force -Scope CurrentUser
    Import-Module BurntToast
}

# Function to send notifications
function Send-Notification {
    param (
        [string]$Title,
        [string]$Message
    )
    New-BurntToastNotification -Text $Title, $Message
}

# Function to enable Windows Firewall
function Ensure-FirewallEnabled {
    $firewallProfiles = Get-NetFirewallProfile -All
    if ($firewallProfiles.Enabled -contains $false) {
        Write-Host "Windows Firewall is disabled. Enabling it now..."
        Set-NetFirewallProfile -All -Enabled True
        Send-Notification -Title "Firewall Status" -Message "Windows Firewall has been enabled."
        Write-Host "Windows Firewall enabled."
    } else {
        Write-Host "Windows Firewall is already enabled."
    }
}

# Function to disable Windows Firewall
function Disable-Firewall {
    Write-Host "Disabling Windows Firewall..."
    Set-NetFirewallProfile -All -Enabled False
    Send-Notification -Title "Firewall Status" -Message "Windows Firewall has been disabled."
    Write-Host "Windows Firewall disabled."
}

# Function to enable Solo Mode
function Enable-SoloMode {
    Write-Host "Activating Destiny 2 Solo Mode..."
    Ensure-FirewallEnabled
    New-NetFirewallRule -DisplayName "Destiny2-Solo-1" -Direction Outbound -RemotePort 27000-27200,3097 -Protocol TCP -Action Block
    New-NetFirewallRule -DisplayName "Destiny2-Solo-2" -Direction Outbound -RemotePort 27000-27200,3097 -Protocol UDP -Action Block
    New-NetFirewallRule -DisplayName "Destiny2-Solo-3" -Direction Inbound -RemotePort 27000-27200,3097 -Protocol TCP -Action Block
    New-NetFirewallRule -DisplayName "Destiny2-Solo-4" -Direction Inbound -RemotePort 27000-27200,3097 -Protocol UDP -Action Block
    Write-Host "Solo Mode activated."
    Send-Notification -Title "Destiny 2" -Message "Solo Mode has been activated."
}

# Function to disable Solo Mode
function Disable-SoloMode {
    Write-Host "Deactivating Destiny 2 Solo Mode..."
    Remove-NetFirewallRule -DisplayName "Destiny2-Solo-1" -ErrorAction SilentlyContinue
    Remove-NetFirewallRule -DisplayName "Destiny2-Solo-2" -ErrorAction SilentlyContinue
    Remove-NetFirewallRule -DisplayName "Destiny2-Solo-3" -ErrorAction SilentlyContinue
    Remove-NetFirewallRule -DisplayName "Destiny2-Solo-4" -ErrorAction SilentlyContinue
    Write-Host "Solo Mode deactivated."
    Send-Notification -Title "Destiny 2" -Message "Solo Mode has been deactivated."
    Disable-Firewall
}

# Function to monitor key press for backtick (`) and toggle Solo Mode
function Monitor-KeyPress {
    $backtickPressed = $false
    while ($true) {
        $key = [Console]::ReadKey($true)
        if ($key.Key -eq 'Backtick') {
            if ($backtickPressed) {
                Write-Host "Backtick key pressed again. Disabling Solo Mode..."
                Disable-SoloMode
            } else {
                Write-Host "Backtick key pressed. Enabling Solo Mode..."
                Enable-SoloMode
            }
            $backtickPressed = -not $backtickPressed
        }
        Start-Sleep -Milliseconds 100
    }
}

# Start monitoring key press in a separate thread
Start-Job -ScriptBlock { Monitor-KeyPress }

# Monitor the game process
Write-Host "Waiting for Destiny 2 to start..."
Send-Notification -Title "Destiny 2" -Message "Monitoring for game launch..."
while (-not (Get-Process -Name "Destiny2" -ErrorAction SilentlyContinue)) {
    Start-Sleep -Seconds 5
}

# Enable Solo Mode when the game starts
Enable-SoloMode

# Wait for the game process to exit
Write-Host "Destiny 2 detected. Monitoring process..."
while (Get-Process -Name "Destiny2" -ErrorAction SilentlyContinue) {
    Start-Sleep -Seconds 5
}

# Disable Solo Mode when the game closes
Disable-SoloMode
Write-Host "Destiny 2 has closed. Script completed."
Send-Notification -Title "Destiny 2" -Message "Game closed. Script completed."

#!/bin/bash

## TODO
## maybe add rmlint and rmlint-shredder (gui)

## removed the e flag to prevent the script from exiting on errors
set -uo pipefail

# Validate essential environment variables
if [ -z "${HOME:-}" ]; then
    echo "ERROR: HOME environment variable is not set"
    exit 1
fi

USER_HOME=$HOME
BASHTEST_DIR="$USER_HOME/bashtest"
CONFIG_DIR="$USER_HOME/.config"
LOG_FILE="$BASHTEST_DIR/script.log"
# AUTO_MODE true --> script run automatically, execute all operations no asking for confirmation
AUTO_MODE=false
TEMP_DIR="/tmp/temp_cash"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
    log "ERROR: $1"
    return 1
}

check_file_exists() {
    if [ ! -f "$1" ]; then
        log "Warning: File $1 does not exist"
        return 1
    fi
    return 0
}

check_dir_exists() {
    if [ ! -d "$1" ]; then
        log "Warning: Directory $1 does not exist"
        return 1
    fi
    return 0
}

# Check if user has sudo privileges
check_sudo() {
    if ! sudo -v &>/dev/null; then
        error "You need sudo privileges to run some parts of this script"
        log "Please make sure you can use sudo and try again"
        return 1
    fi
    return 0
}

# Function to handle privilege escalation
sudo_if_needed() {
    if [ "$(id -u)" -eq 0 ]; then
        "$@"
    else
        sudo "$@"
    fi
}

print_banner() {
    echo "
 ██████╗ █████╗ ███████╗██╗  ██╗
██╔════╝██╔══██╗██╔════╝██║  ██║
██║     ███████║███████╗███████║
██║     ██╔══██║╚════██║██╔══██║
╚██████╗██║  ██║███████║██║  ██║
 ╚═════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝
                                 
Customized Arch System Helper
-----------------------------
"
}

yes_no() {
    local prompt="$1"
    local action="$2"
    
    if [ "$AUTO_MODE" = true ]; then
        if eval "$action"; then
            log "$prompt - Completed"
        else
            log "$prompt - Failed and continuing..."
        fi
        return 0
    fi

    while true; do
        read -rp "$prompt (Y/n): " answer
        case "${answer,,}" in
            y|yes|"") 
                if eval "$action"; then
                    log "$prompt - Completed"
                else
                    log "$prompt - Failed and continuing..."
                fi
                ;;
            n|no) 
                log "$prompt - Skipped"
                ;;
            *) echo "Please answer yes or no."; continue;;
        esac
        break
    done
    return 0
}

install_yay() {
    log "Installing Yay"
    
    mkdir -p "$TEMP_DIR" || { error "Failed to create temporary directory"; return 1; }
    
    if [ -d "$TEMP_DIR/yay" ]; then
        log "Removing existing Yay directory"
        rm -rf "$TEMP_DIR/yay" || error "Failed to remove existing Yay directory"
    fi
    
    if ! git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay"; then
        error "Failed to clone Yay repository"
        return 1
    fi
    
    if ! (cd "$TEMP_DIR/yay" && makepkg -si); then
        error "Failed to build and install Yay"
        return 1
    fi
    
    if ! command -v yay &> /dev/null; then
        error "Yay installation failed - command not found"
        return 1
    fi
    
    if ! yay -Y --gendb; then
        error "Failed to generate Yay database"
        return 1
    fi
    
    if ! yay -Syu --devel; then
        error "Failed to update system with Yay"
        return 1
    fi
    
    if ! yay -Y --devel --save; then
        error "Failed to save Yay development settings"
        return 1
    fi
    
    log "Yay installation completed successfully"
    return 0
}

configure_system_files() {
    log "Configuring system files"

    # Array of file operations: source, destination, description
    declare -A file_ops=(
        ["$BASHTEST_DIR/nobeep.conf"]="/etc/modprobe.d/nobeep.conf:Disable PC speaker beep"
        ["$BASHTEST_DIR/30-touchpad.conf"]="/etc/X11/xorg.conf.d/30-touchpad:Touchpad configuration"
        ["$BASHTEST_DIR/.migrate"]="$USER_HOME/.migrate:Migration file"
        ["$BASHTEST_DIR/audio_disable_powersave.conf"]="/etc/modprobe.d/audio_disable_powersave.conf: Disable Audio Powersave mode"
    )

    for source in "${!file_ops[@]}"; do
        IFS=':' read -r destination description <<< "${file_ops[$source]}"
        
        if ! check_file_exists "$source"; then
            log "Skipping $description - source file not found"
            continue
        fi
        
        # Create destination directory if it doesn't exist
        dest_dir=$(dirname "$destination")
        if [ ! -d "$dest_dir" ]; then
            if ! sudo_if_needed mkdir -p "$dest_dir"; then
                error "Failed to create directory $dest_dir for $description"
                continue
            fi
        fi
        
        # Copy file with proper error handling - use sudo for system directories
        if [[ "$destination" == /etc/* || "$destination" == /usr/* || "$destination" == /lib/* || "$destination" == /sys/* ]]; then
            if sudo_if_needed cp "$source" "$destination"; then
                if [[ -f "$destination" ]]; then
                    log "Successfully copied $description to $destination"
                else
                    error "Failed to verify $description at $destination"
                fi
            else
                error "Failed to copy $description to $destination"
            fi
        else
            # Regular copy for user files
            if cp "$source" "$destination"; then
                if [[ -f "$destination" ]]; then
                    log "Successfully copied $description to $destination"
                else
                    error "Failed to verify $description at $destination"
                fi
            else
                error "Failed to copy $description to $destination"
            fi
        fi
    done

    # Create Flameshot directory with proper error handling
    if [ ! -d "$USER_HOME/00/Pictures" ]; then
        if ! mkdir -p "$USER_HOME/00/Pictures"; then
            error "Failed to create Pictures directory"
            return 0  
        fi
    fi
    
    if mkdir -p "$USER_HOME/00/Pictures/Flameshot"; then
        log "Created Flameshot directory"
    else
        error "Failed to create Flameshot directory"
    fi
    
    return 0
}

setup_batnotify() {
    log "Setting up battery monitor"
    
    # Create bin directory if it doesn't exist
    if ! mkdir -p "$USER_HOME/.local/bin"; then
        error "Failed to create .local/bin directory"
        return 1
    fi
    
    # Create battery monitor script with improved error handling
    cat > "$USER_HOME/.local/bin/batnotify.sh" << 'EOL'
#!/bin/bash

# Exit on error
set -e

# Function to log errors
log_error() {
    echo "$(date +'%Y-%m-%d %H:%M:%S') ERROR: $1" >> "$HOME/.local/share/batnotify.log"
    notify-send -u normal "Battery Monitor Error" "$1"
}

# Create log directory
mkdir -p "$HOME/.local/share" 2>/dev/null || true

while true; do
    # Check if battery exists
    if ! ls /sys/class/power_supply/BAT* &>/dev/null; then
        log_error "No battery found"
        sleep 300
        continue
    fi
    
    # Read battery info with error handling
    if ! battery_level=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null); then
        log_error "Failed to read battery level"
        sleep 300
        continue
    fi
    
    if ! battery_status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null); then
        log_error "Failed to read battery status"
        sleep 300
        continue
    fi

    if [[ "$battery_status" == "Discharging" && "$battery_level" -gt 0 && "$battery_level" -le 7 ]]; then
        notify-send -u critical "Low Battery" "Battery level is ${battery_level}%"
        sleep_time=$((battery_level * 10))
    else
        sleep_time=300
    fi

    sleep $sleep_time
done
EOL

    # Make script executable
    if ! chmod +x "$USER_HOME/.local/bin/batnotify.sh"; then
        error "Failed to make battery monitor script executable"
        return 1
    fi
    
    # Create systemd user directory
    if ! mkdir -p "$USER_HOME/.config/systemd/user/"; then
        error "Failed to create systemd user directory"
        return 1
    fi
    
    # Create a systemd user service
    cat > "$USER_HOME/.config/systemd/user/batnotify.service" << EOL
[Unit]
Description=Battery Notification Service
After=graphical-session.target
PartOf=graphical-session.target

[Service]
ExecStart=$USER_HOME/.local/bin/batnotify.sh
Restart=always
RestartSec=30

[Install]
WantedBy=default.target
EOL

    if [ -f "$USER_HOME/.config/systemd/user/batnotify.service" ]; then
        if ! sudo_if_needed systemctl --user enable batnotify.service; then
            error "Failed to enable battery monitor service"
            return 1
        fi
        
        if ! sudo_if_needed systemctl --user start batnotify.service; then
            error "Failed to start battery monitor service"
            return 1
        fi
        
        log "Battery monitor service enabled and started"
    else
        error "Failed to create systemd service for battery monitor"
        return 1
    fi
    
    log "Battery monitor setup complete"
    return 0
}

setup_dotfiles() {
    local dotfiles_dir="$USER_HOME/.cfg"
    local dotfiles_backup="$USER_HOME/.cfg-bk"

    log "Setting up dotfiles"
    
    # Check if dotfiles directory already exists
    if [ -d "$dotfiles_dir" ]; then
        log "Dotfiles directory already exists. Backing up..."
        if ! mv "$dotfiles_dir" "${dotfiles_dir}.old.$(date +%Y%m%d%H%M%S)"; then
            error "Failed to backup existing dotfiles directory"
            return 0  
        fi
    fi
    
    # Clone repository
    if ! git clone --bare https://github.com/cristian158/spweedy "$dotfiles_dir"; then
        error "Failed to clone dotfiles repository"
        return 0  
    fi

    # Define function for working with dotfiles instead of an alias
    dots() {
        git --git-dir="$dotfiles_dir" --work-tree="$USER_HOME" "$@"
    }

    # Create backup directory
    if ! mkdir -p "$dotfiles_backup"; then
        error "Failed to create dotfiles backup directory"
        return 0  
    fi
    
    # Backup existing files that would be overwritten
    dots_output=$(dots checkout 2>&1) || true
    echo "$dots_output" | grep -E '\s+\.' | while read -r file; do
        file_path=$(echo "$file" | sed 's/^\s*//')
        backup_dir="$dotfiles_backup/$(dirname "$file_path")"
        
        if ! mkdir -p "$backup_dir"; then
            error "Failed to create backup directory for $file_path"
            continue
        fi
        
        if ! mv "$USER_HOME/$file_path" "$backup_dir/"; then
            error "Failed to backup file $file_path"
        fi
    done

    # Checkout dotfiles
    if ! dots checkout; then
        error "Failed to checkout dotfiles"
        return 0  
    fi

    # Configure git
    if ! dots config --local status.showUntrackedFiles no; then
        error "Failed to configure dotfiles git repository"
        return 0  
    fi
    
    # Add function to bashrc if it doesn't exist
    if ! grep -q "dots()" "$USER_HOME/.bashrc"; then
        echo "dots() { git --git-dir=\"$dotfiles_dir\" --work-tree=\"$USER_HOME\" \"\$@\"; }" >> "$USER_HOME/.bashrc"
        log "Added dots function to .bashrc"
    fi
    
    log "Dotfiles setup complete"
    return 0
}

setup_zsh() {
    log "Setting up Zsh and related tools"
    
    yes_no "Install Zsh" "yay -S --needed zsh"
    
    yes_no "Install Powerlevel10k" "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \"$USER_HOME/.powerlevel10k\" && echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >> \"$USER_HOME/.zshrc\""
    
    yes_no "Install Zsh addons" "yay -S --needed zsh-autosuggestions zsh-syntax-highlighting"
    
    yes_no "Set Zsh as default shell" "sudo_if_needed chsh -s $(which zsh) $USER"
    
    log "Zsh setup completed"
}

cleanup() {
    log "Cleaning up temporary files"
    
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR" || log "Warning: Failed to remove temporary directory"
    fi
    
    log "Cleanup complete"
}

main() {
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --auto)
                AUTO_MODE=true
                log "Running in automatic mode"
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [--auto] [--help]"
                echo "  --auto    Run in automatic mode (no prompts)"
                echo "  --help    Show this help message"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                echo "Usage: $0 [--auto] [--help]"
                exit 1
                ;;
        esac
    done
    
    # Check for root privileges - we don't want to run the entire script as root
    if [ "$(id -u)" -eq 0 ]; then
        error "This script should not be run as root"
        log "Please run as a normal user. The script will use sudo for commands that need root privileges."
        exit 1
    fi
    
    # Check if sudo is available and the user has sudo privileges
    if ! check_sudo; then
        log "Some operations may fail without sudo privileges"
        yes_no "Continue without sudo privileges?" "true" || exit 1
    fi
    
    # Check if running on Arch Linux
    if [ ! -f "/etc/arch-release" ]; then
        log "Warning: This script is designed for Arch Linux but the system doesn't appear to be Arch"
    fi

    log "Welcome to:"
    print_banner

    mkdir -p "$TEMP_DIR" || { error "Failed to create temporary directory"; exit 1; }

    if check_file_exists "$BASHTEST_DIR/.bashrc"; then
        yes_no "Copy and source .bashrc" "cp \"$BASHTEST_DIR/.bashrc\" \"$USER_HOME/.bashrc\" && source \"$USER_HOME/.bashrc\""
    fi
    
    if check_file_exists "$BASHTEST_DIR/pacman.conf"; then
        yes_no "Configure pacman" "sudo_if_needed cp \"$BASHTEST_DIR/pacman.conf\" \"/etc/pacman.conf\""
    fi

    yes_no "Perform full system update" "sudo_if_needed pacman -Syu"
    yes_no "Install Yay" "install_yay"

    # Split package installation into groups
    yes_no "Install base packages" "yay -S --needed base-devel git curl wget"
    yes_no "Install window manager and utilities" "yay -S --needed bspwm sxhkd polybar dunst rofi feh picom"
    yes_no "Install terminal" "yay -S --needed alacritty"
    yes_no "Install system utilities" "yay -S --needed alsa-utils bluez bluez-utils network-manager-applet xclip ufw"
    yes_no "Install file managers and archivers" "yay -S --needed ranger pcmanfm-gtk3 p7zip xarchiver-gtk2"
    yes_no "Install text editors and development tools" "yay -S --needed neovim vim github-cli"
    yes_no "Install media tools" "yay -S --needed mpd ncmpcpp sxiv"
    yes_no "Install fonts and themes" "yay -S --needed ttf-iosevka ttf-nerd-fonts-symbols"

    if check_dir_exists "$CONFIG_DIR/ranger/plugins"; then
        yes_no "Install Ranger DevIcons" "git clone https://github.com/alexanderjeurissen/ranger_devicons \"$CONFIG_DIR/ranger/plugins/ranger_devicons\" && ranger --copy-config=all"
    else
        yes_no "Install Ranger DevIcons" "mkdir -p \"$CONFIG_DIR/ranger/plugins\" && git clone https://github.com/alexanderjeurissen/ranger_devicons \"$CONFIG_DIR/ranger/plugins/ranger_devicons\" && ranger --copy-config=all"
    fi
    
    yes_no "Install NvChad" "git clone https://github.com/NvChad/NvChad \"$CONFIG_DIR/nvim\" --depth 1"
    yes_no "Install Matcha GTK theme" "git clone https://github.com/vinceliuice/Matcha-gtk-theme.git \"$TEMP_DIR/Matcha-gtk-theme\" && (cd \"$TEMP_DIR/Matcha-gtk-theme\" && ./install.sh -c dark -t sea)"
    yes_no "Install Qogir icon theme" "git clone https://github.com/vinceliuice/Qogir-icon-theme.git \"$TEMP_DIR/Qogir-icon-theme\" && (cd \"$TEMP_DIR/Qogir-icon-theme\" && ./install.sh -c standard -t manjaro)"
    yes_no "Install Tela icon theme" "git clone https://github.com/vinceliuice/Tela-icon-theme.git \"$TEMP_DIR/Tela-icon-theme\" && (cd \"$TEMP_DIR/Tela-icon-theme\" && ./install.sh)"

    yes_no "Install GTK engines" "yay -S --needed gtk-engine-murrine gtk-engines"

    # Setup Zsh and related tools
    setup_zsh

    yes_no "Configure system files" "configure_system_files"
    yes_no "Setup battery monitor" "setup_batnotify"
    yes_no "Setup dotfiles" "setup_dotfiles"

    log "Script execution completed. Check the log for details on which operations were performed or skipped."
}

# Set up trap handlers
trap cleanup EXIT
trap 'echo "Script interrupted. Exiting..."; exit 1' SIGINT SIGTERM

main "$@"

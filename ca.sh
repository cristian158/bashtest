#!/bin/bash

## TODO
## maybe add rmlint and rmlint-shredder (gui)
## fix the a flag option somewhere here

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
# Variable to track if .migrate should be run at the end (for AUTO_MODE)
RUN_MIGRATE=false

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

# Add flag file to indicate ca.sh completion
    # Create a flag file to indicate ca.sh has been run
    if [ "$AUTO_MODE" = true ]; then
        touch "$USER_HOME/.ca_sh_completed"
        log "Created flag file to indicate ca.sh completion"
    fi

# Configure sudo to not require password in AUTO_MODE
setup_auto_mode() {
    log "Setting up auto mode (passwordless sudo)"
    
    # Check if we're already root
    if [ "$(id -u)" -eq 0 ]; then
        log "Already running as root, no need to configure sudo"
        return 0
    fi
    
    # Create a temporary sudoers file
    local temp_sudoers="/tmp/temp_sudoers_$$"
    local current_user="$(whoami)"
    
    echo "$current_user ALL=(ALL) NOPASSWD: ALL" > "$temp_sudoers"
    
    # Check syntax
    if ! visudo -c -f "$temp_sudoers"; then
        error "Failed to create valid sudoers file"
        rm -f "$temp_sudoers"
        return 1
    fi
    
    # Add to sudoers.d
    if ! sudo cp "$temp_sudoers" "/etc/sudoers.d/99_$current_user"; then
        error "Failed to install sudoers file"
        rm -f "$temp_sudoers"
        return 1
    fi
    
    # Set proper permissions
    if ! sudo chmod 0440 "/etc/sudoers.d/99_$current_user"; then
        error "Failed to set permissions on sudoers file"
        return 1
    fi
    
    rm -f "$temp_sudoers"
    log "Auto mode configured successfully - sudo will no longer prompt for password"
    
    return 0
}

# Function to create a non-interactive version of .migrate
create_noninteractive_migrate() {
    log "Creating non-interactive version of .migrate"
    
    if [ ! -f "$USER_HOME/.migrate" ]; then
        error "Cannot find .migrate script"
        return 1
    fi
    
    # Create a modified version that sets NONINTERACTIVE environment variable
    cat "$USER_HOME/.migrate" | sed '1s|^|#!/usr/bin/env bash\nNONINTERACTIVE=1\n|' | grep -v '^#!/usr/bin/env bash' > "$USER_HOME/.migrate_auto"
    
    chmod +x "$USER_HOME/.migrate_auto"
    log "Created non-interactive .migrate_auto script"
    
    return 0
}
yes_no() {
    local prompt="$1"
    local action="$2"
    
    if [ "$AUTO_MODE" = true ]; then
        log "AUTO_MODE: $prompt"
        
        # In AUTO_MODE, we don't need to worry about sudo for most commands
        # Just execute the command directly
        if eval "$action"; then
            log "$prompt - Completed automatically (AUTO_MODE)"
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
# 5. Modify the install_yay function to use --noconfirm flags in AUTO_MODE
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
    
    if [ "$AUTO_MODE" = true ]; then
        # Non-interactive installation in AUTO_MODE
        if ! (cd "$TEMP_DIR/yay" && makepkg -si --noconfirm); then
            error "Failed to build and install Yay"
            return 1
        fi
    else
        # Regular interactive installation
        if ! (cd "$TEMP_DIR/yay" && makepkg -si); then
            error "Failed to build and install Yay"
            return 1
        fi
    fi
    
    if ! command -v yay &> /dev/null; then
        error "Yay installation failed - command not found"
        return 1
    fi
    
    if ! yay -Y --gendb; then
        error "Failed to generate Yay database"
        return 1
    fi
    
    if [ "$AUTO_MODE" = true ]; then
        # Non-interactive updates in AUTO_MODE
        if ! yay -Syu --devel --noconfirm; then
            error "Failed to update system with Yay"
            return 1
        fi
    else
        if ! yay -Syu --devel; then
            error "Failed to update system with Yay"
            return 1
        fi
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
        ["$BASHTEST_DIR/audio_disable_powersave.conf"]="/etc/modprobe.d/audio_disable_powersave.conf:Disable Audio Powersave mode"
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
        if ! systemctl --user enable batnotify.service; then
            error "Failed to enable battery monitor service"
            return 1
        fi
        
        if ! systemctl --user start batnotify.service; then
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
    log "Setting up dotfiles"
    
    # Copy the .migrate script to the user's home directory if it doesn't exist
    if [ ! -f "$USER_HOME/.migrate" ]; then
        if ! cp "$BASHTEST_DIR/.migrate" "$USER_HOME/.migrate"; then
            error "Failed to copy .migrate script to home directory"
            return 1
        fi
        
        if ! chmod +x "$USER_HOME/.migrate"; then
            error "Failed to make .migrate script executable"
            return 1
        fi
        
        log "Copied .migrate script to home directory"
    else
        log ".migrate script already exists in home directory"
    fi
    
    # In AUTO_MODE, create a non-interactive version of .migrate
    if [ "$AUTO_MODE" = true ]; then
        create_noninteractive_migrate
        RUN_MIGRATE=true
        log "Dotfiles setup: .migrate will be executed automatically at the end of the script"
    else
        # Inform the user about the next step
        log "Dotfiles setup: Please run ~/.migrate after this script completes to set up your dotfiles"
    fi
    
    return 0
}

# 6. Modify setup_zsh function to use --noconfirm flags in AUTO_MODE
setup_zsh() {
    log "Setting up Zsh and related tools"
    
    if [ "$AUTO_MODE" = true ]; then
        yes_no "Install Zsh" "yay -S --needed --noconfirm zsh"
        
        yes_no "Install Powerlevel10k" "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \"$USER_HOME/.powerlevel10k\" && echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >> \"$USER_HOME/.zshrc\""
        
        yes_no "Install Zsh addons" "yay -S --needed --noconfirm zsh-autosuggestions zsh-syntax-highlighting"
        
        yes_no "Set Zsh as default shell" "sudo_if_needed chsh -s $(which zsh) $USER"
    else
        yes_no "Install Zsh" "yay -S --needed zsh"
        
        yes_no "Install Powerlevel10k" "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \"$USER_HOME/.powerlevel10k\" && echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >> \"$USER_HOME/.zshrc\""
        
        yes_no "Install Zsh addons" "yay -S --needed zsh-autosuggestions zsh-syntax-highlighting"
        
        yes_no "Set Zsh as default shell" "sudo_if_needed chsh -s $(which zsh) $USER"
    fi
    
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
            --auto|-a)
                AUTO_MODE=true
                RUN_MIGRATE=true
                log "Running in automatic mode (god mode with elevated privileges)"
                shift
                ;;
            --help|-h)
                echo "Usage: $0 [--auto|a] [--help]"
                echo "  --auto, a    Run in automatic mode (no prompts, passwordless sudo)"
                echo "  --help, h    Show this help message"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                echo "Usage: $0 [--auto|a] [--help]"
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
#  Set RUN_MIGRATE=true by default when AUTO_MODE is enabled (already applied)
#  Add automatic creation of non-interactive migrate script and bypass sudo check in AUTO_MODE
# Set up auto mode if requested 
    if [ "$AUTO_MODE" = true ]; then
        if ! setup_auto_mode; then
            log "Warning: Failed to set up auto mode, continuing with regular sudo"
        fi
        # Create non-interactive migrate script in auto mode
        create_noninteractive_migrate
    fi
    
    # Check if sudo is available and the user has sudo privileges
    if ! check_sudo; then
        if [ "$AUTO_MODE" = true ]; then
            log "Some operations may fail without sudo privileges, continuing anyway in AUTO_MODE"
        else
            log "Some operations may fail without sudo privileges"
            yes_no "Continue without sudo privileges?" "true" || exit 1
        fi
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
    
    if check_file_exists "$BASHTEST_DIR/pacman.conf"; then
        yes_no "Configure pacman" "sudo_if_needed cp \"$BASHTEST_DIR/pacman.conf\" \"/etc/pacman.conf\""
    fi


# tlp or auto-cpufreq
#  Add --noconfirm flags to all pacman and yay commands in AUTO_MODE
    # In AUTO_MODE, we'll use --noconfirm for pacman and yay to avoid prompts
    if [ "$AUTO_MODE" = true ]; then
        yes_no "Perform full system update" "sudo_if_needed pacman -Syu --noconfirm"
        yes_no "Install Yay" "install_yay"

        # Split package installation into groups with --noconfirm
        yes_no "Install base packages" "yay -S --needed --noconfirm base-devel git curl wget"
        yes_no "Install window manager and utilities" "yay -S --needed --noconfirm bspwm sxhkd polybar dunst rofi feh picom"
        yes_no "Install system utilities" "yay -S --needed --noconfirm alacritty alsa-utils bluez bluez-utils network-manager-applet xclip ufw android-file-transfer android-udev ntfs-3g btop fastfetch gvfs gvfs-mtp hblock libnotify lsd lxappearance-gtk3 mediainfo mlocate ntfs-3g pacman-contrib reflector ripgrep rsync tldr udisks2 ueberzug timeshift rmlint gparted"
        yes_no "Install file managers and archivers" "yay -S --needed --noconfirm ranger pcmanfm-gtk3 p7zip xarchiver-gtk2"
        yes_no "Install text editors and development tools" "yay -S --needed --noconfirm neovim vim github-cli"
        yes_no "Install media tools" "yay -S --needed --noconfirm mpd ncmpcpp sxiv nsxiv flameshot vlc qpdfview qrencode "
        yes_no "Install fonts and themes" "yay -S --needed --noconfirm ttf-iosevka ttc-iosevka ttf-nerd-fonts-symbols gruvbox-plus-icon-theme"
        yes_no "Install second layer software" "yay -S --needed --noconfirm ardour baobab bitwarden brave-bin calf cursor-bin docker-desktop gimp handbrake inkscape kdenlive nicotine qbittorrent okular bleachbit tenacity gstreamer visual-studio-code-bin lsp-plugins-landspa"
    else
        yes_no "Perform full system update" "sudo_if_needed pacman -Syu"
        yes_no "Install Yay" "install_yay"

        # Split package installation into groups
        yes_no "Install base packages" "yay -S --needed base-devel git curl wget"
        yes_no "Install window manager and utilities" "yay -S --needed bspwm sxhkd polybar dunst rofi feh picom"
        yes_no "Install system utilities" "yay -S --needed alacritty alsa-utils bluez bluez-utils network-manager-applet xclip ufw android-file-transfer android-udev ntfs-3g btop fastfetch gvfs gvfs-mtp hblock libnotify lsd lxappearance-gtk3 mediainfo mlocate ntfs-3g pacman-contrib reflector ripgrep rsync tldr udisks2 ueberzug timeshift rmlint gparted"
        yes_no "Install file managers and archivers" "yay -S --needed ranger pcmanfm-gtk3 p7zip xarchiver-gtk2"
        yes_no "Install text editors and development tools" "yay -S --needed neovim vim github-cli"
        yes_no "Install media tools" "yay -S --needed mpd ncmpcpp sxiv nsxiv flameshot vlc qpdfview qrencode "
        yes_no "Install fonts and themes" "yay -S --needed ttf-iosevka ttc-iosevka ttf-nerd-fonts-symbols gruvbox-plus-icon-theme"
        yes_no "Install second layer software" "yay -S --needed ardour baobab bitwarden brave-bin calf cursor-bin docker-desktop gimp handbrake inkscape kdenlive nicotine qbittorrent okular bleachbit tenacity gstreamer visual-studio-code-bin lsp-plugins-landspa"
    fi

    if check_dir_exists "$CONFIG_DIR/ranger/plugins"; then
        yes_no "Install Ranger DevIcons" "git clone https://github.com/alexanderjeurissen/ranger_devicons \"$CONFIG_DIR/ranger/plugins/ranger_devicons\" && ranger --copy-config=all"
    else
        yes_no "Install Ranger DevIcons" "mkdir -p \"$CONFIG_DIR/ranger/plugins\" && git clone https://github.com/alexanderjeurissen/ranger_devicons \"$CONFIG_DIR/ranger/plugins/ranger_devicons\" && ranger --copy-config=all"
    fi
    
    yes_no "Install NvChad" "git clone https://github.com/NvChad/NvChad \"$CONFIG_DIR/nvim\" --depth 1"
    yes_no "Install Matcha GTK theme" "git clone https://github.com/vinceliuice/Matcha-gtk-theme.git \"$TEMP_DIR/Matcha-gtk-theme\" && (cd \"$TEMP_DIR/Matcha-gtk-theme\" && ./install.sh -c dark -t sea)"
    yes_no "Install Qogir icon theme" "git clone https://github.com/vinceliuice/Qogir-icon-theme.git \"$TEMP_DIR/Qogir-icon-theme\" && (cd \"$TEMP_DIR/Qogir-icon-theme\" && ./install.sh -c standard -t manjaro)"
    yes_no "Install Tela icon theme" "git clone https://github.com/vinceliuice/Tela-icon-theme.git \"$TEMP_DIR/Tela-icon-theme\" && (cd \"$TEMP_DIR/Tela-icon-theme\" && ./install.sh)"

#  Add --noconfirm flag to GTK engines installation in AUTO_MODE
    if [ "$AUTO_MODE" = true ]; then
        yes_no "Install GTK engines" "yay -S --needed --noconfirm gtk-engine-murrine gtk-engines"
    else
        yes_no "Install GTK engines" "yay -S --needed gtk-engine-murrine gtk-engines"
    fi

    # Setup Zsh and related tools
    setup_zsh

    yes_no "Configure system files" "configure_system_files"
    yes_no "Setup battery monitor" "setup_batnotify"
    yes_no "Setup dotfiles" "setup_dotfiles"

    log "Script execution completed. Check the log for details on which operations were performed or skipped."
    
    # Run .migrate automatically if in AUTO_MODE and the flag is set
    if [ "$AUTO_MODE" = true ] && [ "$RUN_MIGRATE" = true ]; then
        log "AUTO_MODE: Running .migrate automatically as part of the domino effect"

        # Ensure .migrate has executable permissions
        if [ ! -x "$USER_HOME/.migrate" ]; then
            log "Setting executable permissions on .migrate"
            chmod +x "$USER_HOME/.migrate" || {
                error "Failed to set executable permissions on .migrate"
                return 1
            }
        fi

        # Run regular .migrate
        log "Executing $USER_HOME/.migrate"
        (cd "$USER_HOME" && bash -c "./.migrate")
        migrate_status=$?

        if [ "$migrate_status" -eq 0 ]; then
            log ".migrate execution completed successfully"
        else
            error ".migrate execution failed with exit code $migrate_status"
        fi
    fi
}

# Set up trap handlers
trap cleanup EXIT
trap 'echo "Script interrupted. Exiting..."; exit 1' SIGINT SIGTERM

main "$@"

#!/bin/bash

## removed the e flag to prevent the script from exiting on errors
set -uo pipefail

# Validate essential environment variables
if [ -z "${HOME:-}" ]; then
    echo "ERROR: HOME environment variable is not set"
    exit 1
fi

USER_HOME=$HOME
SYS_DIR="$USER_HOME/bashtest/sys"
CONFIG_DIR="$USER_HOME/.config"
LOG_FILE="$SYS_DIR/script.log"
# AUTO_MODE true --> script run automatically, execute all operations no asking for confirmation
AUTO_MODE=false
AUTO_SUDOERS_FILE=""
TEMP_DIR="/tmp/temp_cash"

# Package groups for installation
BASE_PACKAGES="base-devel git curl wget"
WM_UTILITIES="bspwm sxhkd polybar dunst rofi feh picom"
SYSTEM_UTILITIES="alacritty alsa-utils bluez bluez-utils network-manager-applet xclip ufw android-file-transfer android-udev ntfs-3g btop fastfetch gvfs gvfs-mtp hblock libnotify lsd lxappearance mediainfo mlocate pacman-contrib reflector ripgrep rsync tldr udisks2 aeberzug timeshift rmlint gparted bettercap fzf i3lock-color nmap"
FILE_MANAGERS="ranger pcmanfm-gtk3 p7zip xarchiver"
TEXT_EDITORS="neovim vim github-cli"
MEDIA_TOOLS="mpd ncmpcpp sxiv nsxiv flameshot vlc qpdfview qrencode"
FONTS_THEMES="ttf-iosevka ttc-iosevka ttf-nerd-fonts-symbols gruvbox-plus-icon-theme"
SECOND_LAYER="ardour baobab bitwarden brave-bin calf cursor-bin docker-desktop gimp handbrake inkscape kdenlive nicotine qbittorrent okular bleachbit tenacity gstreamer visual-studio-code-bin lsp-plugins-ladspa darktable"

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
    AUTO_SUDOERS_FILE="/etc/sudoers.d/99_$current_user"
    if ! sudo cp "$temp_sudoers" "$AUTO_SUDOERS_FILE"; then
        error "Failed to install sudoers file"
        rm -f "$temp_sudoers"
        AUTO_SUDOERS_FILE=""
        return 1
    fi
    
    # Set proper permissions
    if ! sudo chmod 0440 "$AUTO_SUDOERS_FILE"; then
        error "Failed to set permissions on sudoers file"
        AUTO_SUDOERS_FILE=""
        return 1
    fi
    
    rm -f "$temp_sudoers"
    log "Auto mode configured successfully - sudo will no longer prompt for password"
    
    return 0
}

yes_no() {
    local prompt="$1"
    local action="$2"
    
    if [ "$AUTO_MODE" = true ]; then
        log "AUTO_MODE: $prompt"
        
        # In AUTO_MODE, continue top to bottom even when a step fails.
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
                    return 0
                else
                    log "$prompt - Failed and continuing..."
                    return 1
                fi
                ;;
            n|no) 
                log "$prompt - Skipped"
                return 1
                ;;
            *) echo "Please answer yes or no."; continue;;
        esac
    done
}

# install_yay --noconfirm in AUTO_MODE
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

rangit() {
	git clone https://github.com/alexanderjeurissen/ranger_devicons "$CONFIG_DIR/ranger/plugins/ranger_devicons"
}

configure_system_files() {
    log "Configuring system files"

    # Array of file operations: source, destination, description
    declare -A file_ops=(
        ["$SYS_DIR/nobeep.conf"]="/etc/modprobe.d/nobeep.conf:Disable PC speaker beep"
        ["$SYS_DIR/30-touchpad.conf"]="/etc/X11/xorg.conf.d/30-touchpad.conf:Touchpad configuration"
        ["$SYS_DIR/audio_disable_powersave.conf"]="/etc/modprobe.d/audio_disable_powersave.conf:Disable Audio Powersave mode"
        ["$SYS_DIR/.Xresources"]="$USER_HOME/.Xresources:Xresources configuration"
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
            return 1  
        fi
    fi
    
    if mkdir -p "$USER_HOME/00/Pictures/Flameshot"; then
        log "Created Flameshot directory"
    else
        error "Failed to create Flameshot directory"
    fi

    # Create .local/share/gnupg
    if ! mkdir -p "$USER_HOME/.local/share/gnupg"; then
        error "Failed to create gnup directory"
        return 1  
    fi
    
    return 0
}

# check cause there are 2 batnotify.sh files, they do similar stuff, they are in different folders and the one executed is in .xinitrc
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


# Modify setup_zsh function to use --noconfirm flags in AUTO_MODE
setup_zsh() {
    log "Setting up Zsh and related tools"
    
    local install_cmd=""
    if [ "$AUTO_MODE" = true ]; then
        install_cmd="yay -S --needed --noconfirm"
    else
        install_cmd="yay -S --needed"
    fi
    
    # Pre-check packages
    local packages_to_install=""
    for pkg in zsh zsh-autosuggestions zsh-syntax-highlighting; do
        if ! pacman -Q "$pkg" &>/dev/null; then
            packages_to_install="$packages_to_install $pkg"
        fi
    done
    
    # Check Powerlevel10k directory
    local p10k_dir="$USER_HOME/.config/powerlevel10k"
    local clone_p10k=false
    if [ ! -d "$p10k_dir" ]; then
        clone_p10k=true
    fi
    
    # Unified prompt
    local action=""
    if [ -n "$packages_to_install" ] || [ "$clone_p10k" = true ]; then
        action="if [ -n \"$packages_to_install\" ]; then $install_cmd$packages_to_install; fi"
        if [ "$clone_p10k" = true ]; then
            action="$action; git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \"$p10k_dir\""
        fi
        yes_no "Set up Zsh and related tools (install packages and clone Powerlevel10k)" "$action"
    else
        log "Zsh and related tools are already set up"
    fi
    
    # Uncomment below to set Zsh as default shell
    # if command -v zsh >/dev/null 2>&1; then
    #     yes_no "Set Zsh as default shell" "sudo_if_needed chsh -s $(which zsh) $USER"
    # fi
    
    log "Zsh setup completed"
}

setup_themes() {
    log "Setting up themes and GTK engines"
    
    local install_cmd=""
    if [ "$AUTO_MODE" = true ]; then
        install_cmd="yay -S --needed --noconfirm"
    else
        install_cmd="yay -S --needed"
    fi
    
    # Pre-check GTK engines
    local engines_to_install=""
    for pkg in gtk-engine-murrine gtk-engines; do
        if ! pacman -Q "$pkg" &>/dev/null; then
            engines_to_install="$engines_to_install $pkg"
        fi
    done
    
    # Check themes
    local themes_to_install=""
    if [ ! -d "/usr/share/themes/Matcha-sea-dark" ]; then
        themes_to_install="$themes_to_install matcha"
    fi
    if [ ! -d "/usr/share/icons/Qogir-manjaro" ]; then
        themes_to_install="$themes_to_install qogir"
    fi
    if [ ! -d "/usr/share/icons/Tela" ]; then
        themes_to_install="$themes_to_install tela"
    fi
    
    # Build action
    local action=""
    if [ -n "$engines_to_install" ]; then
        action="$install_cmd$engines_to_install"
    fi
    if [[ "$themes_to_install" == *"matcha"* ]]; then
        action="$action; [ ! -d \"$TEMP_DIR/Matcha-gtk-theme\" ] && git clone https://github.com/vinceliuice/Matcha-gtk-theme.git \"$TEMP_DIR/Matcha-gtk-theme\"; (cd \"$TEMP_DIR/Matcha-gtk-theme\" && ./install.sh -c dark -t sea)"
    fi
    if [[ "$themes_to_install" == *"qogir"* ]]; then
        action="$action; [ ! -d \"$TEMP_DIR/Qogir-icon-theme\" ] && git clone https://github.com/vinceliuice/Qogir-icon-theme.git \"$TEMP_DIR/Qogir-icon-theme\"; (cd \"$TEMP_DIR/Qogir-icon-theme\" && ./install.sh -c standard -t manjaro)"
    fi
    if [[ "$themes_to_install" == *"tela"* ]]; then
        action="$action; [ ! -d \"$TEMP_DIR/Tela-icon-theme\" ] && git clone https://github.com/vinceliuice/Tela-icon-theme.git \"$TEMP_DIR/Tela-icon-theme\"; (cd \"$TEMP_DIR/Tela-icon-theme\" && ./install.sh)"
    fi
    
    # Unified prompt
    if [ -n "$action" ]; then
        yes_no "Install themes and GTK engines (Matcha GTK, Qogir icons, Tela icons, GTK engines)" "$action"
    else
        log "Themes and GTK engines are already installed"
    fi
    
    log "Themes and GTK engines setup completed"
}


cleanup() {
    log "Cleaning up temporary files"
    
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR" || log "Warning: Failed to remove temporary directory"
    fi
    
    if [ -n "$AUTO_SUDOERS_FILE" ] && [ -f "$AUTO_SUDOERS_FILE" ]; then
        if sudo_if_needed rm -f "$AUTO_SUDOERS_FILE"; then
            log "Removed temporary sudoers file $AUTO_SUDOERS_FILE"
        else
            log "Warning: Failed to remove temporary sudoers file $AUTO_SUDOERS_FILE"
        fi
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
                echo "Usage: $0 [--auto|-a] [--help]"
                echo "  --auto, -a    Run in automatic mode (no prompts, passwordless sudo)"
                echo "  --help, -h    Show this help message"
                exit 0
                ;;
            *)
                error "Unknown option: $1"
                echo "Usage: $0 [--auto|-a] [--help]"
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
        if [ "$AUTO_MODE" = true ]; then
            log "Some operations may fail without sudo privileges, continuing anyway in AUTO_MODE"
        else
            log "Some operations may fail without sudo privileges"
            yes_no "Continue without sudo privileges?" "true" || exit 1
        fi
    else
        # Configure passwordless sudo if in AUTO_MODE and sudo is available
        if [ "$AUTO_MODE" = true ]; then
            setup_auto_mode
        fi
    fi

    # Check if running on Arch Linux
    if [ ! -f "/etc/arch-release" ]; then
        log "Warning: This script is designed for Arch Linux but the system doesn't appear to be Arch"
    fi

    log "Welcome to:"
    print_banner

    mkdir -p "$TEMP_DIR" || { error "Failed to create temporary directory"; exit 1; }
    
    if check_file_exists "$SYS_DIR/pacman.conf"; then
        yes_no "Configure pacman" "sudo_if_needed cp \"$SYS_DIR/pacman.conf\" \"/etc/pacman.conf\""
    fi

    if check_file_exists "$SYS_DIR/makepkg.conf"; then
        yes_no "Configure makepkg" "sudo_if_needed cp \"$SYS_DIR/makepkg.conf\" \"/etc/makepkg.conf\""
    fi


# tlp or auto-cpufreq
#  Add --noconfirm flags to all pacman and yay commands in AUTO_MODE
    # In AUTO_MODE, we'll use --noconfirm for pacman and yay to avoid prompts
    if [ "$AUTO_MODE" = true ]; then
        pacman_cmd="sudo_if_needed pacman -Syu --noconfirm"
        yay_cmd="yay -S --needed --noconfirm"
    else
        pacman_cmd="sudo_if_needed pacman -Syu"
        yay_cmd="yay -S --needed"
    fi

    yes_no "Configure system files" "configure_system_files"
    yes_no "Perform full system update" "$pacman_cmd"
    yes_no "Install Yay" "install_yay"

    # Split package installation into groups
    yes_no "Install base packages" "$yay_cmd $BASE_PACKAGES"
    yes_no "Install window manager and utilities" "$yay_cmd $WM_UTILITIES"
    yes_no "Install system utilities" "$yay_cmd $SYSTEM_UTILITIES"
    yes_no "Install file managers and archivers" "$yay_cmd $FILE_MANAGERS"
    # add rangit as a function to run after 
    # ideally it would be implicit right after installing 
    rangit
    yes_no "Install text editors and development tools" "$yay_cmd $TEXT_EDITORS"
    # maybe similar thing for nvchad
    yes_no "Install media tools" "$yay_cmd $MEDIA_TOOLS"
    yes_no "Install fonts and themes" "$yay_cmd $FONTS_THEMES"
    yes_no "Install second layer software" "$yay_cmd $SECOND_LAYER"

    # yes_no "Install Ranger DevIcons" "rangit"
    yes_no "Install NvChad" "git clone https://github.com/NvChad/starter \"$CONFIG_DIR/nvim\" --depth 1" # delete .git
    setup_themes

    # Setup Zsh and related tools
    setup_zsh

    yes_no "Setup battery monitor" "setup_batnotify"

    # Add flag file to indicate ca.sh completion
    # Create a flag file to indicate ca.sh has been run
    if [ "$AUTO_MODE" = true ]; then
        touch "$USER_HOME/.ca_sh_completed"
        log "Created flag file to indicate ca.sh completion"
    fi

    log "Script execution completed. Check the log for details on which operations were performed or skipped."

}

# Set up trap handlers
trap cleanup EXIT
trap 'echo "Script interrupted. Exiting..."; exit 1' SIGINT SIGTERM

main "$@"




#################################################
####### AFTER INSTALL
## check /etc/passwd for right shell to user


######### TO CHECK
## batnotify moved to .files/scripts/ as a bash, it is ready and executed fomr




# Add a check when building yay so the required base-devel and network-manager-applet are installed before.
# Propose a function that checks the expected system file /etc/pacman.conf so the following lines are present and uncommented:
# - ILoveCandy
# - Color
# - ParallelDownloads = 10
# 
# Add command that keeps the sudo priviliges til the script ends or gets interrupted (crash, ctrl+c, etc) 
# 
# make a function that checks if the script has already been run and if so, skip the steps that have already been done (like cloning the dotfiles repo, defining the dots function, etc) and just do the necessary steps to get to the same state as if it was run for the first time (like checking out the dotfiles, configuring git, etc). This way, if the script gets interrupted or fails at some point, you can just run it again and it will pick up where it left off without causing issues or requiring manual cleanup.
#
#
# in AUTO MODE it still asks for password twice when making yay, have to run the script as root
#
#   yes_no "Continue without sudo?" "true" || exit 1 (line 502)
#   yes_no always returns 0, so || exit 1 is unreachable. If the user answers "no", the script keeps running anyway — the intent to exit is silently lost.
#
#   Security        
#   eval "$action" in yes_no (lines 139, 151)
#   This is risky. Passing multi-word commands as strings and running them through eval makes the code fragile and potentially exploitable if any input paths contain special characters. A common safer pattern is to pass function names and call them directly, or use arrays with   
#   "${cmd[@]}".                                                                         
#   setup_auto_mode writes NOPASSWD: ALL to /etc/sudoers.d/                     
#   The file is never cleaned up after the script ends, permanently granting passwordless sudo. Worth at least noting in a comment, or adding cleanup via the trap.
#                                                                                                                                               
#   Minor / TODOs Already Noted
#   - setup_auto_mode cleanup not trapped on exit
#   - The TODO about killing battery notifications on charger plug-in is a real gap — the batnotify.sh only checks Discharging status but never suppresses an existing notification    
#   - chsh lines are commented out — if intentional, they could just be removed                                                                                                                                                                   

## maybe add rmlint and rmlint-shredder (gui)
## install yt-dlp ripgrep man-pages man-db python-pip rate-mirror (rust)
## mod batnotify so it kills the noti's once the charger is plugged in
## add /etc/default/grub (timeout and style), regenerate, etc
## xorg-xrandr

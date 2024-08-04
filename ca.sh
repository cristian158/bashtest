#!/bin/bash

set -euo pipefail

USER_HOME=$HOME
BASHTEST_DIR="$USER_HOME/bashtest"
CONFIG_DIR="$USER_HOME/.config"
LOG_FILE="$BASHTEST_DIR/script.log"
AUTO_MODE=false
TEMP_DIR="/tmp/temp_cash"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
    log "ERROR: $1"
    return 1
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
            log "$prompt - Failed, but continuing..."
        fi
        return
    fi

    while true; do
        read -rp "$prompt (y/n): " answer
        case "${answer,,}" in
            y|yes) 
                if eval "$action"; then
                    log "$prompt - Completed"
                else
                    log "$prompt - Failed, but continuing..."
                fi
                ;;
            n|no) 
                log "$prompt - Skipped"
                ;;
            *) echo "Please answer yes or no."; continue;;
        esac
        break
    done
}

install_yay() {
    log "Installing Yay"
    git clone https://aur.archlinux.org/yay.git "$TEMP_DIR/yay" && 
    (cd "$TEMP_DIR/yay" && makepkg -si) &&
    yay -Y --gendb &&
    yay -Syu --devel &&
    yay -Y --devel --save
}

configure_system_files() {
    log "Configuring system files"

    # Array of file operations: source, destination, description
    declare -A file_ops=(
        ["$BASHTEST_DIR/nobeep.conf"]="/etc/modprobe.d/nobeep.conf:Disable PC speaker beep"
        ["$BASHTEST_DIR/30-touchpad.conf"]="/etc/X11/xorg.conf.d/30-touchpad:Touchpad configuration"
        ["$BASHTEST_DIR/.migrate"]="$USER_HOME/.migrate:Migration file"
        # file to avoid annoying noise while audio paused
        ["$BASHTEST_DIR/audio_disable_powersave.conf"]="/etc/modprobe.d/audio_disable_powersave.conf:Disable Audio Powersave mode"
    )

    for source in "${!file_ops[@]}"; do
        IFS=':' read -r destination description <<< "${file_ops[$source]}"
        if cp "$source" "$destination"; then
            if [[ -f "$destination" ]]; then
                log "Successfully copied $description to $destination"
            else
                error "Failed to verify $description at $destination"
            fi
        else
            error "Failed to copy $description to $destination"
        fi
    done

    # Create Flameshot directory
    mkdir -p "$USER_HOME/00/Pictures/Flameshot" && log "Created Flameshot directory" || error "Failed to create Flameshot directory"
}

setup_batnotify() {
    log "Setting up battery monitor"
    
    mkdir -p "$USER_HOME/.local/bin"
    cat > "$USER_HOME/.local/bin/batnotify.sh" << 'EOL'
#!/bin/bash

while true; do
    battery_level=$(cat /sys/class/power_supply/BAT*/capacity)
    battery_status=$(cat /sys/class/power_supply/BAT*/status)

    if [[ "$battery_status" == "Discharging" && "$battery_level" -gt 0 && "$battery_level" -le 7 ]]; then
        notify-send -u critical "Low Battery" "Battery level is ${battery_level}%"
        sleep_time=$((battery_level * 10))
    else
        sleep_time=300
    fi

    sleep $sleep_time
done
EOL

    chmod +x "$USER_HOME/.local/bin/batnotify.sh"
    
    # Create a systemd user service
    # now it doesn't need to be in .xinitrc
    mkdir -p "$USER_HOME/.config/systemd/user/"
    cat > "$USER_HOME/.config/systemd/user/batnotify.service" << EOL
[Unit]
Description=Battery Notification Service

[Service]
ExecStart=$USER_HOME/.local/bin/batnotify.sh

[Install]
WantedBy=default.target
EOL

    systemctl --user enable batnotify.service
    systemctl --user start batnotify.service
    
    log "Battery monitor setup complete"
}

setup_dotfiles() {
    local dotfiles_dir="$USER_HOME/.cfg"
    local dotfiles_backup="$USER_HOME/.cfg-bk"

    log "LA MIGRA WEEEEYYYY"
    if ! git clone --bare https://github.com/cristian158/spweedy "$dotfiles_dir"; then
        error "Failed to clone dotfiles repository"
        return 1
    fi

    alias dots="git --git-dir=$dotfiles_dir --work-tree=$USER_HOME"

    mkdir -p "$dotfiles_backup"
    if ! dots checkout 2>&1 | grep -E '\s+\.' | awk {'print $1'} | xargs -I{} mv {} "$dotfiles_backup/{}"; then
        error "Failed to backup existing files"
        return 1
    fi

    if ! dots checkout; then
        error "Failed to checkout dotfiles"
        return 1
    fi

    dots config --local status.showUntrackedFiles no
    echo "alias dots='git --git-dir=$dotfiles_dir --work-tree=$USER_HOME'" >> "$USER_HOME/.bashrc"
}

setup_zsh() {
    log "Setting up Zsh and related tools"
    
    # Install Zsh
    yes_no "Install Zsh" "yay -S --needed zsh"
    
    # Install Powerlevel10k
    yes_no "Install Powerlevel10k" "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \"$USER_HOME/.powerlevel10k\" && echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >> \"$USER_HOME/.zshrc\""
    
    # Install Zsh addons
    yes_no "Install Zsh addons" "yay -S --needed zsh-autosuggestions zsh-syntax-highlighting"
    
    # Set Zsh as default shell
    yes_no "Set Zsh as default shell" "chsh -s $(which zsh)"
    
    log "Zsh setup completed"
}

cleanup() {
    log "Performing cleanup"
    
    # Remove temporary directory
    rm -rf "$TEMP_DIR"
    
    # Remove any leftover package files
    yay -Scc --noconfirm
    
    # Clean pacman cache
    pacman -Scc --noconfirm
    
    # Remove orphaned packages
    pacman -Rns $(pacman -Qtdq) --noconfirm

    # Clear system journal logs older than 1 days
    journalctl --vacuum-time=1d

    # Clear user cache
    rm -rf "$USER_HOME/.cache/*"

    # Clear thumbnails cache
    rm -rf "$USER_HOME/.thumbnails/*"
    rm -rf "$USER_HOME/.cache/thumbnails/*"

    log "Cleanup completed"
}

main() {
    if [[ "${1:-}" == "--auto" ]]; then
        AUTO_MODE=true
        log "Running in automatic mode"
    fi

    log "Welcome to:"
    print_banner

    # Create temporary directory
    mkdir -p "$TEMP_DIR"

    # Check and copy necessary files
    [[ -f "$BASHTEST_DIR/.bashrc" ]] && yes_no "Copy and source .bashrc" "cp \"$BASHTEST_DIR/.bashrc\" \"$USER_HOME/.bashrc\" && source \"$USER_HOME/.bashrc\""
    [[ -f "$BASHTEST_DIR/pacman.conf" ]] && yes_no "Configure pacman" "cp \"$BASHTEST_DIR/pacman.conf\" \"/etc/pacman.conf\""

    yes_no "Perform full system update" "pacman -Syu"
    yes_no "Install Yay" "install_yay"

    # Split package installation into groups
    yes_no "Install base packages" "yay -S --needed base-devel git curl wget"
    yes_no "Install window manager and utilities" "yay -S --needed bspwm sxhkd polybar dunst rofi feh picom"
    yes_no "Install terminal" "yay -S --needed alacritty"
    yes_no "Install system utilities" "yay -S --needed alsa-utils bluez bluez-utils network-manager-applet ufw"
    yes_no "Install file managers and archivers" "yay -S --needed ranger pcmanfm-gtk3 p7zip xarchiver-gtk2"
    yes_no "Install text editors and development tools" "yay -S --needed neovim vim github-cli"
    yes_no "Install media tools" "yay -S --needed mpd ncmpcpp sxiv"
    yes_no "Install fonts and themes" "yay -S --needed ttf-iosevka ttf-nerd-fonts-symbols"

    yes_no "Install Ranger DevIcons" "git clone https://github.com/alexanderjeurissen/ranger_devicons \"$CONFIG_DIR/ranger/plugins/ranger_devicons\" && ranger --copy-config=all"
    yes_no "Install NvChad" "git clone https://github.com/NvChad/NvChad \"$CONFIG_DIR/nvim\" --depth 1 && nvim"
    yes_no "Install Matcha GTK theme" "git clone https://github.com/vinceliuice/Matcha-gtk-theme.git \"$TEMP_DIR/Matcha-gtk-theme\" && (cd \"$TEMP_DIR/Matcha-gtk-theme\" && ./install.sh -c dark -t sea)"
    yes_no "Install Qogir icon theme" "git clone https://github.com/vinceliuice/Qogir-icon-theme.git \"$TEMP_DIR/Qogir-icon-theme\" && (cd \"$TEMP_DIR/Qogir-icon-theme\" && ./install.sh -c standard -t manjaro)"
    yes_no "Install Tela icon theme" "git clone https://github.com/vinceliuice/Tela-icon-theme.git \"$TEMP_DIR/Tela-icon-theme\" && (cd \"$TEMP_DIR/Tela-icon-theme\" && ./install.sh)"

    yes_no "Install GTK engines" "yay -S --needed gtk-engine-murrine gtk-engines"

    # Setup Zsh and related tools
    setup_zsh

    yes_no "Configure system files" "configure_system_files"
    yes_no "Setup battery monitor" "setup_batnotify"
    yes_no "Setup dotfiles" "setup_dotfiles"

    cleanup

    log "Script execution completed. Check the log for details on which operations were performed or skipped."
}

trap cleanup EXIT
trap 'echo "Script interrupted. Exiting..."; exit 1' SIGINT

main "$@"




###############################################################################
## 
## Deprecated
#
#   exists() {
#       if [ -e "$1" ]; then
#           log ":: $2 $(if [ -d "$1" ]; then echo "directory"; else echo "file"; fi) exists"
#       else
#           log ":: $2 not found"
#       fi
#   }


#!/usr/bin/env bash

# Strict error handling
set -euo pipefail

# Constants
LOG_FILE="/home/$USER/bashtest/script.log"
DOTFILES_DIR="/home/$USER/.cfg"
DOTFILES_BACKUP="/home/$USER/.cfg-bk"
BASHRC="/home/$USER/.bashrc"
BASHTEST_DIR="/home/$USER/bashtest"

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | sudo tee -a "$LOG_FILE"
}

# Ctrl+C handler
ctrl_c() {
    log "Ctrl+C caught... Exiting!"
    exit 1
}

trap ctrl_c SIGINT

# Yes/No prompt function
yes_no() {
    local prompt="$1"
    local action="$2"
    while true; do
        read -rp "$prompt (y/n): " answer
        case "${answer,,}" in
            y|yes) $action; log "$prompt finished"; return 0 ;;
            n|no ) log "$prompt skipped"; return 1 ;;
            * ) echo "Please answer yes or no." ;;
        esac
    done
}

# Check if file/directory exists
exists() {
    if [[ -e "$1" ]]; then
        if [[ -d "$1" ]]; then
            log ":: $2 directory exists"
        else
            log ":: $2 file exists"
        fi
        return 0
    else
        log ":: $2 not confirmed"
        return 1
    fi
}

# Install Yay
install_yay() {
    log 'Cloning Yay'
    if git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si; then
        cd .. && rm -rf ./yay
        yay -Y --gendb
        log ':: Checking for development package updates'
        yay -Syu --devel
        log ':: Making development package updates permanently enabled'
        yay -Y --devel --save
    else
        log "Error: Failed to install Yay"
        return 1
    fi
}

# Install Ranger DevIcons
install_ranger_devicons() {
    local devi="/home/$USER/.config/ranger/plugins/ranger_devicons"
    log "Cloning Devicons"
    if git clone https://github.com/alexanderjeurissen/ranger_devicons "$devi"; then
        exists "$devi" "DevIcons"
        ranger --copy-config=all && log ':: Ranger Configured'
        echo "default_linemode devicons
set preview_images true
set preview_images_method ueberzug
map DD shell mv %s /home/${USER}/.local/share/Trash/files/" >> "/home/${USER}/.config/ranger/rc.conf"
        log ':: rc.conf configured'
    else
        log "Error: Failed to clone ranger_devicons"
        return 1
    fi
}

# Build package
build_package() {
    local name="$1"
    local repo="$2"
    local dir="$3"
    local specs="$4"
    local file="$5"
    local trash="$6"

    cd "$BASHTEST_DIR"
    log "Cloning $repo"
    if git clone "$repo" && cd "$dir"; then
        log ":: Installing $name"
        if ./install.sh $specs; then
            cd ..
            exists "$file" "$name"
            rm -rf "$trash"
            log "$name finished"
        else
            log "Error: Failed to install $name"
            return 1
        fi
    else
        log "Error: Failed to clone $repo"
        return 1
    fi
}

# Configure files
config_files() {
    local beepfile="/etc/modprobe.d/nobeep.conf"
    local touchpad="/etc/X11/xorg.conf.d/30-touchpad"
    local migra="$BASHTEST_DIR/.migrate"
    local flamefolder="/home/$USER/00/Pictures/Flameshot"

    log "Creating No Beep"
    sudo cp "$BASHTEST_DIR/nobeep.conf" "$beepfile" && exists "$beepfile" "Beepfile"

    log "Configuring Touchpad"
    sudo cp "$BASHTEST_DIR/30-touchpad.conf" "$touchpad" && exists "$touchpad" "Touchpad File"

    log "Copying Migrate file"
    cp "$migra" "/home/$USER/" || log "Error: Failed to copy migrate file"

    log "Creating dir for Flameshot"
    mkdir -p "$flamefolder" && exists "$flamefolder" "Flame Folder"
}

# Setup dotfiles
setup_dotfiles() {
    log "Setting up dotfiles repository"
    if git clone --bare https://github.com/cristian158/spweedy "$DOTFILES_DIR"; then
        alias dots="/usr/bin/git --git-dir=$DOTFILES_DIR --work-tree=$HOME"
        mkdir -p "$DOTFILES_BACKUP"
        
        dots checkout 2>&1 | grep -E "\s+\." | awk {'print $1'} | 
            xargs -I{} mv {} "$DOTFILES_BACKUP/{}"
        
        if dots checkout; then
            dots config --local status.showUntrackedFiles no
            log "Dotfiles setup completed successfully"
            echo "alias dots='/usr/bin/git --git-dir=$DOTFILES_DIR --work-tree=$HOME'" >> "$BASHRC"
        else
            log "Error: Failed to checkout dotfiles"
            return 1
        fi
    else
        log "Error: Failed to clone dotfiles repository"
        return 1
    fi
}

# Main script execution
main() {
    log "Welcome to CASH"
    echo "NOTE: Migrate needed, not included!!"

    # Copy and source .bashrc
    if cp "$BASHTEST_DIR/.bashrc" "$BASHRC" && source "$BASHRC"; then
        log "Bashrc copied and sourced successfully"
    else
        log "Error: Failed to copy or source .bashrc"
        exit 1
    fi

    # Configure pacman
    sudo cp "$BASHTEST_DIR/pacman.conf" "/etc/pacman.conf"

    # Run updates and installations
    yes_no "Full Update" "sudo pacman -Syu"
    yes_no "Install Yay" install_yay
    yes_no "Install Essentials" "yay -S --needed alacritty alsa-utils auto-cpufreq blueman bluez-utils bluez bluez-libs bspwm btop dunst dvtm fastfetch feh flameshot github-cli gvfs gvfs-mtp hblock libnotify lsd lxappearance-gtk3 mediainfo mlocate mpd neovim network-manager-applet ncmpcpp ntfs-3g p7zip pacman-contrib pcmanfm-gtk3 picom polybar ranger reflector ripgrep rofi rsync sxiv sxhkd tldr ttc-iosevka ttf-nerd-fonts-symbols udisks2 ueberzug ufw vim xarchiver-gtk2 xclip xorg"
    yes_no "Install Ranger DevIcons" install_ranger_devicons

    # Build packages
    yes_no "Install NvChad" "build_package 'NvChad' 'https://github.com/NvChad/starter /home/$USER/.config/nvim --depth 1' '/home/$USER/.config/nvim' '' '/home/$USER/.config/nvim/LICENSE' '/home/$USER/.config/nvim/.git'"
    yes_no "Install GTK engines" "yay -S --needed gtk-engine-murrine gtk-engines"
    yes_no "Install Matcha" "build_package 'Matcha' 'https://github.com/vinceliuice/Matcha-gtk-theme' 'Matcha-gtk-theme' '-c dark -t sea' '' './Matcha-gtk-theme'"
    yes_no "Install Qogir" "build_package 'Qogir' 'https://github.com/vinceliuice/Qogir-icon-theme' 'Qogir-icon-theme' '-c standard -t manjaro' 'home/.local/share/icons/Qogir-manjaro' './Qogir-icon-theme'"
    yes_no "Install Tela" "build_package 'Tela' 'https://github.com/vinceliuice/Tela-icon-theme' 'Tela-icon-theme' '' 'home/.local/share/icons/Tela' './Tela-icon-theme'"
    yes_no "Install Zsh" "build_package 'Zsh' 'https://github.com/romkatv/powerlevel10k.git home/.config/powerlevel10k --depth=1' '' '' '' ''"
    yes_no "Install Zsh addons" "yay -S --needed zsh-autosuggestions zsh-syntax-highlighting"

    yes_no "Configure files" config_files
    yes_no "Setup dotfiles" setup_dotfiles

    log "Thanks for coming!"
}

# Run the main function
main

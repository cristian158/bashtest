#!/bin/bash

set -euo pipefail

USER_HOME=$HOME
BASHTEST_DIR="$USER_HOME/bashtest"
CONFIG_DIR="$USER_HOME/.config"
LOG_FILE="$BASHTEST_DIR/script.log"

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
    log "ERROR: $1"
    return 1
}

yes_no() {
    local prompt="$1"
    local action="$2"
    
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

exists() {
    if [ -e "$1" ]; then
        log ":: $2 $(if [ -d "$1" ]; then echo "directory"; else echo "file"; fi) exists"
    else
        log ":: $2 not found"
    fi
}

install_yay() {
    log "Installing Yay"
    git clone https://aur.archlinux.org/yay.git && 
    (cd yay && makepkg -si) &&
    rm -rf ./yay &&
    yay -Y --gendb &&
    yay -Syu --devel &&
    yay -Y --devel --save
}

setup_dotfiles() {
    local dotfiles_dir="$USER_HOME/.cfg"
    local dotfiles_backup="$USER_HOME/.cfg-bk"

    log "Setting up dotfiles"
    git clone --bare https://github.com/cristian158/spweedy "$dotfiles_dir" &&
    alias dots="git --git-dir=$dotfiles_dir --work-tree=$USER_HOME" &&
    mkdir -p "$dotfiles_backup" &&
    dots checkout 2>&1 | grep -E '\s+\.' | awk {'print $1'} | xargs -I{} mv {} "$dotfiles_backup/{}" &&
    dots checkout &&
    dots config --local status.showUntrackedFiles no &&
    echo "alias dots='git --git-dir=$dotfiles_dir --work-tree=$USER_HOME'" >> "$USER_HOME/.bashrc"
}

main() {
    log "Welcome to CASH (Customized Arch System Helper)"

    # Check if necessary files exist before copying
    if [ -f "$BASHTEST_DIR/.bashrc" ]; then
        yes_no "Copy and source .bashrc" "cp \"$BASHTEST_DIR/.bashrc\" \"$USER_HOME/.bashrc\" && source \"$USER_HOME/.bashrc\""
    else
        log "Warning: $BASHTEST_DIR/.bashrc not found. Skipping."
    fi

    if [ -f "$BASHTEST_DIR/pacman.conf" ]; then
        yes_no "Configure pacman" "sudo cp \"$BASHTEST_DIR/pacman.conf\" \"/etc/pacman.conf\""
    else
        log "Warning: $BASHTEST_DIR/pacman.conf not found. Skipping."
    fi

    yes_no "Perform full system update" "sudo pacman -Syu"
    yes_no "Install Yay" "install_yay"

    yes_no "Install essential packages" "yay -S --needed alacritty alsa-utils auto-cpufreq blueman bluez-utils bluez bluez-libs bspwm btop dunst dvtm fastfetch feh flameshot github-cli gvfs gvfs-mtp hblock libnotify lsd lxappearance-gtk3 mediainfo mlocate mpd neovim network-manager-applet ncmpcpp ntfs-3g p7zip pacman-contrib pcmanfm-gtk3 picom polybar ranger reflector ripgrep rofi rsync sxiv sxhkd tldr ttc-iosevka ttf-nerd-fonts-symbols udisks2 ueberzug ufw vim xarchiver-gtk2 xclip xorg"

    yes_no "Install Ranger DevIcons" "git clone https://github.com/alexanderjeurissen/ranger_devicons \"$CONFIG_DIR/ranger/plugins/ranger_devicons\" && ranger --copy-config=all && echo 'default_linemode devicons\nset preview_images true\nset preview_images_method ueberzug\nmap DD shell mv %s $USER_HOME/.local/share/Trash/files/' >> \"$CONFIG_DIR/ranger/rc.conf\""

    yes_no "Install NvChad" "git clone https://github.com/NvChad/NvChad \"$CONFIG_DIR/nvim\" --depth 1 && nvim"
    yes_no "Install Matcha GTK theme" "git clone https://github.com/vinceliuice/Matcha-gtk-theme.git && (cd Matcha-gtk-theme && ./install.sh -c dark -t sea) && rm -rf Matcha-gtk-theme"
    yes_no "Install Qogir icon theme" "git clone https://github.com/vinceliuice/Qogir-icon-theme.git && (cd Qogir-icon-theme && ./install.sh -c standard -t manjaro) && rm -rf Qogir-icon-theme"
    yes_no "Install Tela icon theme" "git clone https://github.com/vinceliuice/Tela-icon-theme.git && (cd Tela-icon-theme && ./install.sh) && rm -rf Tela-icon-theme"
    yes_no "Install Zsh with Powerlevel10k" "git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \"$USER_HOME/.powerlevel10k\" && echo 'source ~/.powerlevel10k/powerlevel10k.zsh-theme' >> \"$USER_HOME/.zshrc\""

    yes_no "Install GTK engines" "yay -S --needed gtk-engine-murrine gtk-engines"
    yes_no "Install Zsh addons" "yay -S --needed zsh-autosuggestions zsh-syntax-highlighting"

    yes_no "Configure system files" "
        [ -f \"$BASHTEST_DIR/nobeep.conf\" ] && sudo cp \"$BASHTEST_DIR/nobeep.conf\" \"/etc/modprobe.d/nobeep.conf\";
        [ -f \"$BASHTEST_DIR/30-touchpad.conf\" ] && sudo cp \"$BASHTEST_DIR/30-touchpad.conf\" \"/etc/X11/xorg.conf.d/30-touchpad\";
        [ -f \"$BASHTEST_DIR/.migrate\" ] && cp \"$BASHTEST_DIR/.migrate\" \"$USER_HOME/\";
        mkdir -p \"$USER_HOME/00/Pictures/Flameshot\"
    "

    yes_no "Setup dotfiles" "setup_dotfiles"

    log "Script execution completed. Check the log for details on which operations were performed or skipped."
}

trap 'echo "Script interrupted. Exiting..."; exit 1' SIGINT

main
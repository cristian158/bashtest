#!/usr/bin/env bash
set -euo pipefail

# Logging function
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1" | tee -a $HOME/TESTS/script.log
}

# Msg when Ctrl C is pressed
ctrl_c() {
    echo "
    Ctrl+C caught... Bye!!"
    sleep 2
    exit 1
}

trap ctrl_c SIGINT

yes_no() { 
    local prompt="$1"
    local action="$2"
    while true; do
        read -rp "$prompt (y/n): " answer
        case "$answer" in
            [yY]* ) $action; log "$prompt finished"; return 0;;
            [nN]* ) log "$prompt skipped"; return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# check if file exists 
exists() {
    if [ -e "$1" ]; then 
        if [ -d "$1" ]; then
            log ":: $2 directory exists"
        else
            log ":: $2 file exists"
        fi
    else
        log ":: $2 not confirmed" 
    fi 
}

# Build yay 
getyay() {
    log 'Cloning Yay'
    if git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si; then
        cd .. 
        rm -rf ./yay 
        yay -Y --gendb
        echo ':: Check for development package updates' && yay -Syu --devel 
        echo ':: Make development package updates permanently enabled' && yay -Y --devel --save
    else
        log "Error: Failed to install Yay"
        return 1
    fi
}

# Ranger DevIcons 
rangit() {
    local devi="$HOME/.config/ranger/plugins/ranger_devicons"
    log "Cloning Devicons"
    if git clone https://github.com/alexanderjeurissen/ranger_devicons $devi; then
        exists $devi "DevIcons" 
        ranger --copy-config=all && echo ':: Ranger Configd'
        sleep 1 
        echo "
        #########################
        ### Added by CASH 

        default_linemode devicons
        set preview_images true
        set preview_images_method ueberzug

        map DD shell mv %s /home/${USER}/.local/share/Trash/files/" >> $HOME/.config/ranger/rc.conf 
        echo ':: rc.conf confd'
    else
        log "Error: Failed to clone ranger_devicons"
        return 1
    fi
}

# Build pkg
buildit() {
    local name="$1"
    local repo="$2"
    local dir="$3"
    local specs="$4"
    local file="$5"
    local trash="$6"
    local extra="$7"
    while true; do 
        read -rp "Do you want to install $name? (y/n): " answer
        case "$answer" in 
            [yY]* ) 
              log "Cloning $repo" 
              if git clone $repo && cd $dir; then
                  log ":: Installing $name"
                  if ./install.sh $specs; then
                      cd ..
                      exists $file $name 
                      $extra
                      rm -rf $trash 
                      log "$name finished"
                      return 0
                  else
                      log "Error: Failed to install $name"
                      return 1
                  fi
              else
                  log "Error: Failed to clone $repo"
                  return 1
              fi
              ;;
            [nN]* ) log "$name skipped"; return 1;;
            * ) echo "Please answer yes or no.";;
         esac
    done
}

# Some files i need
config_files() {
    local beepfile="/etc/modprobe.d/nobeep.conf"
    local touchpad="/etc/X11/xorg.conf.d/30-touchpad"
    local migra="$HOME/bashtest/.migrate"
    local flamefolder="$HOME/00/Pictures/Flameshot"
    log "Creating No Beep"
    if sudo cp $HOME/bashtest/nobeep.conf $beepfile; then
        exists $beepfile "Beepfile"
    else
        log "Error: Failed to copy nobeep.conf"
    fi
    log "Touchpad"
    if sudo cp $HOME/bashtest/30-touchpad.conf $touchpad; then
        exists $touchpad "Touchpad File"
    else
        log "Error: Failed to copy touchpad config"
    fi
    if cp $migra $HOME/; then
        log "Migrate file copied successfully"
    else
        log "Error: Failed to copy migrate file"
    fi
    log "Creating dir for Flameshot"
    if mkdir -p $flamefolder; then
        exists $flamefolder "Flame Folder"
    else
        log "Error: Failed to create Flameshot directory"
    fi
}


# Setup dotfiles 
setup_dotfiles() {
    local dotfiles_dir="$HOME/.cfg"
    local dotfiles_backup="$HOME/.cfg-bk"
    
    log "Setting up dotfiles repository"
    
    # Initialize the bare repository
    if git clone --bare https://github.com/cristian158/spweedy $dotfiles_dir; then
        # Define the alias in the current shell scope
        alias dotfiles='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
        
        # Backup existing dotfiles
        mkdir -p $dotfiles_backup
        dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} $dotfiles_backup/{}
        
        # Checkout the actual content from the bare repository to $HOME
        if dotfiles checkout; then
            dotfiles config --local status.showUntrackedFiles no
            log "Dotfiles setup completed successfully"
        else
            log "Error: Failed to checkout dotfiles"
            return 1
        fi
    else
        log "Error: Failed to clone dotfiles repository"
        return 1
    fi
    
    # Add the alias to .bashrc for future use
    echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> $HOME/.bashrc
}

###########################################################################
###########################################################################
## Beginning of the actual script
##

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

log "Welcome to CASH"
echo NOTE: Migrate needed, not included!!

## make sure .bashrc is copied and sourced 
if cp $HOME/bashtest/.bashrc $HOME/.bashrc && source $HOME/.bashrc; then
    log "Bashrc copied and sourced successfully"
    echo "alias dotfiles='/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME"
else
    log "Error: Failed to copy or source .bashrc"
    exit 1
fi

### add mods to pacman.conf maybeee
# sudo cp $HOME/bashtest/pacman.conf /etc/pacman.conf

yes_no "Full Update" "sudo pacman -Syu"

yes_no "Yay" getyay

yes_no "Essentials" "yay -S --needed alacritty alsa-utils auto-cpufreq blueman bluez-utils bluez bluez-libs bspwm btop dunst dvtm fastfetch feh flameshot gvfs gvfs-mtp hblock libnotify lsd lxappearance-gtk3 mediainfo mlocate mpd neovim network-manager-applet ncmpcpp ntfs-3g p7zip pacman-contrib pcmanfm-gtk3 picom polybar ranger reflector ripgrep rofi rsync sxiv sxhkd tldr ttc-iosevka ttf-nerd-fonts-symbols udisks2 ueberzug ufw vim xarchiver-gtk2 xclip xorg"

yes_no "Rangit" rangit 

buildit "NvChad" "https://github.com/NvChad/starter $HOME/.config/nvim --depth 1" "" "" "$HOME/.config/nvim/LICENSE" "~/.config/nvim/.git"

yes_no "Gtk engines" "yay -S --needed gtk-engine-murrine gtk-engines"

buildit "Matcha" "https://github.com/vinceliuice/Matcha-gtk-theme" "Matcha-gtk-theme" "-c dark -t sea" "" "./Matcha-gtk-theme"

buildit "Qogir" "https://github.com/vinceliuice/Qogir-icon-theme" "Qogir-icon-theme" "-c standard -t manjaro" "$HOME/.local/share/icons/Qogir-manjaro" './Qogir-icon-theme'

buildit "Tela" "https://github.com/vinceliuice/Tela-icon-theme" "Tela-icon-theme" "" "$HOME/.local/share/icons/Tela" "./Tela-icon-theme"

buildit "Zsh" "https://github.com/romkatv/powerlevel10k.git $HOME/.config/powerlevel10k --depth=1" "" "" "" "" "yay -S --needed zsh-autosuggestions zsh-syntax-highlighting"

yes_no "Config Files" config_files

yes_no "Setup dotfiles" setup_dotfiles

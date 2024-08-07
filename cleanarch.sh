#!/usr/bin/env bash

#######################################################
###/////////////////////////////////////////////////////
###
###      CCCC        AAA       SSSS     HH     HH
###    CC    CC    AA   AA   SS    SS   HH     HH
###   CC          AA     AA  SS         HH     HH
###   CC          AAAAAAAAA    SSSS     HHHHHHHHH
###   CC          AA     AA        SS   HH     HH
###    CC    CC   AA     AA  SS    SS   HH     HH
###      CCCC     AA     AA    SSSS     HH     HH
###
###              -- CLEAN ARCH SH --
###
###       Bash Script to set some shit I like
###          on a clean arch installation
###
###########################
#///////////////////////////

##############
## FUNCTIONS
#

skip_msg() {
			echo '=================SKIPPING===================='
			sleep 1
}

pause() {
			echo '============================================='
			sleep 1
}

smth() {
  echo 'Homething sappened...'
}

# Confirm installation of Packages group via pacman

confirm() {
	while true; do
		read -p ":: Do u want $1 ? Y/N " ANSWER
		case $ANSWER in
		[yY] | [yY][eE][sS])
			sudo pacman -S --needed $2
			echo ":: $3 INSTALLED"
			pause
      break
			;;
		[nN] | [nN][oO])
      skip_msg
			break
			;;
		*)
			smth >&2
			;;
		esac
	done
}


# Set git config

gitcfg() {
	while true; do
		read -p ":: Set git config? Y/N " ANSWER
		case $ANSWER in
		[yY] | [yY][eE][sS])
			git config --global user.email "cnovoa.o@gmail.com"
			git config --global user.name "Cristian Novoa"
			echo ':: Config DONE'
			pause
      break
			;;
		[nN] | [nN][oO])
			skip_msg
      break
			;;
		*)
			smth >&2
			;;
		esac
	done

}


# Function to install yay

getyay() {
	while true; do
		read -p ":: Want yay? Y/N " ANSWER
		case $ANSWER in
		[yY] | [yY][eE][sS])
			echo ':: Cloning yay'
			git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
			cd ..
      remove 'Yay folder' ~/bashtest/yay
      # generate dev pkg db for *-git pkgs that were installed without yay. This command should only be run once.
      yay -Y --gendb 
      echo ':: Check for development package updates'
      yay -Syu --devel 
      echo ':: Make development package updates permanently enabled'
      yay -Y --devel --save 
			echo 'YAY INSTALL DONE'
			pause
      break
			;;
		[nN] | [nN][oO])
      skip_msg
			break
			;;
		*)
			smth >&2
			;;
		esac
	done
}


# Function to install shit with yay

yayit() {
	while true; do
		read -p ":: Do u want $1 ? Y/N " ANSWER
		case $ANSWER in
		[yY] | [yY][eE][sS])
			yay -S --needed $2
			echo ":: $1 INSTALLED"
      pause
			break
			;;
		[nN] | [nN][oO])
      skip_msg
			break
			;;
		*)
			smth >&2
			;;
		esac
	done
}


# Function to install and confg Ranger

rangit() {
	while true; do
		read -p ":: Do u want Ranger DevIcons? Y/N " ANSWER
		case $ANSWER in
		[yY] | [yY][eE][sS])
      git clone https://github.com/alexanderjeurissen/ranger_devicons ~/.config/ranger/plugins/ranger_devicons
			echo ':: Ranger DevIcons cloned'
			sleep 1
      ranger --copy-config=all
			echo ':: Ranger Configd'
      sleep 1
      echo "
      #########################
      ### Added by CASH 

      default_linemode devicons
      set preview_images true
      set preview_images_method ueberzug

      map DD shell mv %s /home/${USER}/.local/share/Trash/files/

      " >> $HOME/.config/ranger/rc.conf
			echo ':: rc.conf confd'
			pause
      break
			;;
		[nN] | [nN][oO])
      skip_msg
			break
			;;
		*)
			smth >&2
			;;
		esac
	done

}


# Function to confg neovim 

nvimit() {
	while true; do
		read -p ":: Do u want NvChad? Y/N " ANSWER
		case $ANSWER in
		[yY] | [yY][eE][sS])
      echo ':: Cloning'
      git clone https://github.com/NvChad/starter ~/.config/nvim --depth 1
      if [ -e ~/.config/nvim/LICENSE ]; then echo ':: NvChad Starter cloned'; else 'Something went wrong maybe'; fi
			sleep 1
      echo 'Remember running :MasonInstallAll after lazy downloads plugins'
      sleep 1
      remove 'NvChad git folder' '~/.config/nvim/.git'
      echo ':: NvChad INSTALLED'
      pause
			break
			;;
		[nN] | [nN][oO])
      skip_msg
			break
			;;
		*)
			smth >&2
			;;
		esac
	done

}


# Remove some shit

remove() {
	while true; do
		read -p ":: Do u want remove $1 ? Y/N " ANSWER
		case $ANSWER in
		[yY] | [yY][eE][sS])
			rm -rf $2
			echo ":: $1 REMOVED"
      pause
			break
			;;
		[nN] | [nN][oO])
      skip_msg
			break
			;;
		*)
			smth >&2
			;;
		esac
	done
}


# Function to build shit from source

buildit() {
	while true; do
		read -p "Do u want $1? Y/N " ANSWER
		case $ANSWER in
		[yY] | [yY][eE][sS])
			git clone $2
			cd $3
			./install.sh $4
      #remove $5 $6
			cd ..
      pause
			break
			;;
		[nN] | [nN][oO])
      skip_msg
			break
			;;
		*)
			smth >&2
			;;
		esac
	done
}


# Function to install zsh shit

# echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
zshit() {
	while true; do
		read -p ":: Do u want powerlevel10k? Y/N " ANSWER
		case $ANSWER in
		[yY] | [yY][eE][sS])
			yayit 'zsh autosuggs/highlights?' 'zsh-autosuggestions zsh-syntax-highlighting'
			git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.config/powerlevel10k
			echo ':: ZSH-itted'
      pause
			break
			;;
		[nN] | [nN][oO])
      skip_msg
			break
			;;
		*)
			smth >&2
			;;
		esac
	done
}


## Ly display manager

lyit() {
	while true; do
		read -p ":: Do u want ly? Y/N " ANSWER
		case $ANSWER in
		[yY] | [yY][eE][sS])
			yay -S ly
			echo ':: Ly Installed'
			sleep 1
			sudo systemctl enable ly.service
      sudo systemctl status ly.service
      pause
      echo CASH Finished
      echo '============================================='
			sudo systemctl start ly.service
			break
			;;
		[nN] | [nN][oO])
      skip_msg
			break
			;;
		*)
			smth >&2
			;;
		esac
	done

}

###################################################################
###################################################################
## Beginning of the actual script
##

echo Welcome to CASH
sleep 1

## make sure .bashrc is copied and sourced 
cp .bashrc ~/.bashrc 
source ~/.bashrc

### add mods to pacman.conf maybeee

echo NOTE: Migrate needed, not included!!
sleep 1

confirm 'Full Update' -yu 'FULL UPDATE'

gitcfg

getyay

yayit 'Essentials' 'alacritty alsa-utils auto-cpufreq blueman bluez-utils bluez bluez-libs bspwm btop dunst dvtm fastfetch feh flameshot github-cli gvfs gvfs-mtp hblock libnotify lsd lxappearance-gtk3 mediainfo mlocate mpd neovim network-manager-applet ncmpcpp ntfs-3g p7zip pacman-contrib pcmanfm-gtk3 picom polybar ranger reflector ripgrep rofi rsync sxiv sxhkd tldr ttc-iosevka ttf-nerd-fonts-symbols udisks2 ueberzug ufw vim xarchiver-gtk2 xclip xorg' 
## something about bluez-libs already installed

rangit

nvimit

confirm 'gtk engines' 'gtk-engine-murrine gtk-engines' 'GTK ENGINES'


## add 
buildit 'Matcha Theme' https://github.com/vinceliuice/Matcha-gtk-theme Matcha-gtk-theme '-c dark -t sea'
echo ':: Matcha Version: ' $(pacman -Q | grep matcha)
remove 'Matcha folder' 'Matcha-gtk-theme'

buildit 'Qogir Cursor' https://github.com/vinceliuice/Qogir-icon-theme Qogir-icon-theme '-c standard -t manjaro'
if [ -e $HOME/.local/share/icons/Qogir-manjaro ]; then echo ':: Qogir Cursor installed'; else smth; fi
remove 'Qogir folder' 'Qogir-icon-theme'

buildit 'Tela Icons' https://github.com/vinceliuice/Tela-icon-theme Tela-icon-theme ''
## try yay tela-icon-theme
if [ -e $HOME/.local/share/icons/Tela ]; then echo ':: Tela Icons installed'; else smth; fi
remove 'Tela folder' 'Tela-icon-theme'

zshit

###
# install confirm msg 
# echo ' xxx installed'


####
#### it requires root privileges
#
#echo ':: Creating nobeep conf file'
#echo 'blacklist pcspkr
#blacklist snd_pcsp
#' >> /etc/modprobe.d/nobeep.conf 
#if [ -e /etc/modprobe.d/nobeep.conf ]; then echo 'Nobeep file done'; else echo 'Something happende...'; fi

#echo ':: Copying touchpad conf to etc'
#sudo cp ~/bashtest/30-touchpad.conf /etc/X11/xorg.conf.d/
#if [ -e /etc/X11/xorg.conf.d/30-touchpad.conf ]; then echo 'Touchpad conf file done'; else echo 'Something happened...'; fi


echo ':: NO BEEP and TOUCHPAD'
sleep 1
echo "tryng echoin 'blacklist pcspkr\nblacklist snd_pcsp' >> /etc/modprobe.d/nobeep.conf; copy /home/$USER/bashtest/30-touchpad.conf to /etc/X11/xorg.conf.d/"
sleep 1 
echo 'Remember exit the console'
su 

cp ~/bashtest/.migrate ~/ 
echo ':: Creating dir for Flameshot'
mkdir -p ~/00/Pictures/Flameshot 
if [ -e $HOME/00/Pictures/Flameshot/ ]; then echo 'Flameshot folder created'; else smth; fi
sleep 1

confirm 'firefox?' 'firefox'

yayit 'ardour/calf/musescore/nicotine/qbittorrent/vlc/bitwarden/bleachbit/timeshift/kdenlive/tenacity?' 'ardour calf musescore nicotine+ qbittorrent vlc bitwarden bleachbit timeshift kdenlive tenacity'

echo '
###################
### LA MIGRA WEYY
###################
'

cd 
echo ':: Cloning dotfiles into bare repository @ home'
git clone --bare https://github.com/cristian158/spweedy $HOME/.cfg
sleep 1 

if [ -e ~/.cfg ]; then echo ':: Dotfiles cloned into .cfg'; else smth; fi

config checkout

echo :: If there are conflicting files, maybe delete them and run config checkout again

echo :: Set config config config --local status.showUntrackedFiles no
# find right flag 


lyit




#################
###   Add
#
#  mpd & ncmpcpp & mpc script (not sure if necessary)
#  auto-cpufreq
#     $ git clone https://github.com/AdnanHodzic/auto-cpufreq.git
#     $ cd auto-cpufreq && sudo ./auto-cpufreq-installer
#     $ systemctl status auto-cpufreq
#     $ sudo auto-cpufreq --stats
#
#  create MIGRATION part
#
#
#################
###   Deprecated

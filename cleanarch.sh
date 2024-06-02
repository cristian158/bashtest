#! usr/bin/env bash

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

# Confirm installation of Packages group via pacman

confirm() {
	while true; do
		read -p ":: Do u want $1 Y/N " ANSWER
		case $ANSWER in
		[yY] | [yY][eE][sS])
			sudo pacman -S --needed $2
			echo :: SOFTWARE INSTALLED
			sleep 1
			break
			;;
		[nN] | [nN][oO])
			echo =================SKIPPING====================
			sleep 1
			break
			;;
		*)
			echo 'Please enter y/yes or n/no' >&2
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
			echo Config DONE
			sleep 1
			break
			;;
		[nN] | [nN][oO])
			echo =================SKIPPING====================
			sleep 1
			break
			;;
		*)
			echo 'I suggest u cut the bs' >&2
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
			echo :: Cloning yay
			git clone https://aur.archlinux.org/yay.git
			cd yay
			makepkg -si
			cd
			echo :: Removing yay folder
			rm -rf ~/bashtest/yay
			echo :: yay folder removed
			echo YAY INSTALL DONE
			echo '============================================='
			sleep 1
			break
			;;
		[nN] | [nN][oO])
			echo '=================SKIPPING===================='
			sleep 1
			break
			;;
		*)
			echo "Please enter y/yes or n/no" >&2
			;;
		esac
	done
}

# Function to install shit with yay

yayit() {
	while true; do
		read -p ":: Do u want $1 Y/N " ANSWER
		case $ANSWER in
		[yY] | [yY][eE][sS])
			yay -S --needed $2
			echo :: SOFTWARE INSTALLED
			sleep 1
			break
			;;
		[nN] | [nN][oO])
			echo '=================SKIPPING===================='
			sleep 1
			break
			;;
		*)
			echo 'Please enter y/yes or n/no' >&2
			;;
		esac
	done
}

# Function to build shit from source

buildit() {
	while true; do
		read -p "Do u want $1 Y/N " ANSWER
		case $ANSWER in
		[yY] | [yY][eE][sS])
			git clone $2
			cd $3
			/install.sh $4
			cd ..
			echo :: SOFWARE INSTALLED
			echo '============================================='
			sleep 1
			break
			;;
		[nN] | [nN][oO])
			echo '=================SKIPPING===================='
			sleep 1
			break
			;;
		*)
			echo 'Nigga Please' >&2
			;;
		esac
	done
}

# Function to install zsh shit

# echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
## maybe try to find better directory to clone to
zsh-it() {
	while true; do
		read -p ":: Do u want powerlevel10k? Y/N " ANSWER
		case $ANSWER in
		[yY] | [yY][eE][sS])
			yayit 'zsh autosuggs/highlights?' 'zsh-autosuggestions zsh-syntax-highlighting'
			git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.files/powerlevel10k
			echo 'source ~/.files/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
			echo ":: ZSH-itted"
			echo '============================================='
			sleep 1
			break
			;;
		[nN] | [nN][oO])
			echo '=================SKIPPING===================='
			sleep 1
			break
			;;
		*)
			echo 'Nigga Please' >&2
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
			#sudo systemctl start ly.service
			echo ':: Ly Service enabled/started'
			echo '============================================='
			sleep 1
			break
			;;
		[nN] | [nN][oO])
			echo '=================SKIPPING===================='
			sleep 1
			break
			;;
		*)
			echo 'Neighbour Please' >&2
			;;
		esac
	done

}

##################################
## Beginning of the actual script
##

echo Welcome to CASH
sleep 1

confirm 'Full Update' -yu 'FULL UPDATE'

gitcfg

getyay

yayit 'essentials?' 'vim xorg ntfs-3g udisks2 pacman-contrib p7zip rsync btop alacritty mlocate hblock ufw mediainfo bspwm sxhkd picom feh sxiv polybar rofi auto-cpufreq fastfetch flameshot dvtm neovim lxappearance-gtk3 pcmanfm-gtk3 gvfs gvfs-mtp reflector blueman bluez bluez-libs bluez-utils alsa-utils dunst libnotify tldr ttc-iosevka lsd xclip'

confirm 'firefox?' 'firefox'

yayit 'ardour/calf/musescore/nicotine/qbittorrent/vlc/bitwarden/bleachbit/timeshift/kdenlive/breeze/tenacity?' 'ardour calf musescore nicotine+ qbittorrent vlc bitwarden bleachbit timeshift kdenlive breeze tenacity-git'

confirm 'gtk engines' '-S gtk-engine-murrine gtk-engines' 'GTK ENGINES'
buildit 'matcha theme' 'https://github.com/vinceliuice/Matcha-gtk-theme' 'Matcha-gtk-theme' '-c dark -t sea'
buildit Icons https://github.com/vinceliuice/Qogir-icon-theme Qogir-icon-theme

zsh-it

lyit

echo CASH Finished
echo '============================================='

# yayit 'rsync/xbacklight/ufw/neovim/lxappearance/pcmanfm/gvfs?' 'rsync xbacklight ufw neovim lxappearance pcmanfm-gtk3 gvfs'

######
## Add
# mpd & ncmpcpp & mpc script
# neovim script
#
# auto-cpufreq
# nobeep
# touchpad

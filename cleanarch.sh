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
###       Bash Script to get some shit I like
###          on a clean arch installation
###
###########################
#///////////////////////////



##############
## FUNCTIONS 
#

# Confirm installation of Packages group via pacman
confirm () {
	while true; do
		read -p ":: Do u want $1 Y/N " ANSWER
		case $ANSWER in
		 [yY] | [yY][eE][sS])
		   sudo pacman $2
		   echo $3 DONE
		   break
		   ;;
		 [nN] | [nN][oO])
		   echo '=================SKIPPING===================='
		   break
		   ;;
		 *)
		   echo 'Please enter y/yes or n/no' >&2
		esac
	done
}

# Function to install yay
getyay () {
 while true; do
 	read -p ":: Want yay? (8M) Y/N " ANSWER
 	case $ANSWER in
 	 [yY] | [yY][eE][sS])
 	   git clone https://aur.archlinux.org/yay.git
 	   cd yay
 	   makepkg -si
 	   sudo pacman -U yay-11.3.2-1-x86_64.pkg.tar.zst
 	   echo "YAY INSTALL DONE"
 	   echo '============================================='
 	   break
 	   ;;
 	 [nN] | [nN][oO])
 	   echo '=================SKIPPING===================='
 	   break
 	   ;;
 	 *)
 	   echo "Please enter y/yes or n/no" >&2
 	 esac
 done
}

# Function to install shit with yay
yayit () {
	while true; do
		read -p ":: Do u want $1 Y/N " ANSWER
		case $ANSWER in
		 [yY] | [yY][eE][sS])
		   yay $2
		   echo $3 DONE
		   break
		   ;;
		 [nN] | [nN][oO])
		   echo '=================SKIPPING===================='
		   break
		   ;;
		 *)
		   echo 'Please enter y/yes or n/no' >&2
		esac
	done
}

# Function to build shit from source
buildit () {
	while true; do
		read -p "Do u want $1 Y/N " ANSWER
		case $ANSWER in
		 [yY] | [yY][eE][sS])
		   git clone $2
		   cd $3
		   ./install.sh $4
		   cd ..
		   echo "$5 DONE"
		   echo '============================================='
		   break
		   ;;
		 [nN] | [nN][oO])
		   echo '=================SKIPPING===================='
		   break
		   ;;
		 *)
		   echo 'Nigga Please' >&2
		esac
	done
}


# Function to install zsh shit
zshit () {
	while true; do
		read -p "Do u want powerlevel10k? Y/N " ANSWER
		case $ANSWER in
		 [yY] | [yY][eE][sS])
		  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.files/powerlevel10k
		  echo 'source ~/.files/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
		  echo "ZSHit DONE"
		  echo '============================================='
		  break
		  ;;
	  	 [nN] | [nN][oO])
		  echo '=================SKIPPING===================='
		  break
		  ;;
		 *)
		  echo 'Nigga Please' >&2
		esac
	done
}


##################################
## Beginning of the actual script 
##

echo Welcome to the Installation
sleep 1
confirm 'Full Update' -Syu 'FULL UPDATE'
confirm 'base-devel' '-S base-devel' 'BASE DEVEL'

getyay

confirm 'udisks2/mediainfo/btop/alsa-utils/lsd/alacritty/iosevka-fonts/picom' '-S udisks2 mediainfo btop alsa-utils lsd alacritty ttc-iosevka picom' 'SOFTWARE 1/6'
confirm 'firefox?' '-S firefox' 'SOFTWARE 2/6'
confirm 'musescore/nicotine?' '-S musescore nicotine+' 'SOFTWARE 3/6'
confirm 'qbittorrent/vlc?' '-S qbittorrent vlc' 'SOFTWARE 4/6'
yayit 'auto-cpufreq/bitwarden/fastfetch/stacer/timeshift? (102M)' '-S auto-cpufreq bitwarden fastfetch stacer timeshift' 'SOFTWARE 5/6'
yayit 'pulsemixer/flameshot/dvtm?' '-S pulsemixer flameshot dvtm' 'SOFTWARE 6/6'
yayit 'zsh-autosuggestions/zsh-syntax-highlighting?' '-S zsh-autosuggestions zsh-syntax-highlighting' 'zsh shit'

# git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
# echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc

zshit

# confirm 'gtk engines' '-S gtk-engine-murrine gtk-engines' 'GTK ENGINES'
# buildit 'matcha theme' 'https://github.com/vinceliuice/Matcha-gtk-theme' 'Matcha-gtk-theme' '-c dark -t sea'
# buildit Icons https://github.com/vinceliuice/Qogir-icon-theme Qogir-icon-theme

## REMOVE LIGHTDM
# yay -Rsn lightdm-gtk-greeter
# yay -Rsn lightdm


echo Installation Finished

######
## Add
# rsync
# ufw
# lsd
# mediainfo
# xdg-open
# arecord
# btop
# udisksctl
# fastfetch
# pulsemixer (or pipeware?)
# git
# nvim
# lxappearance
# ly display manager
# xbacklight
#
#
# kdenlive
# #### get zsh as default 
# #### mpd & ncmpcpp script

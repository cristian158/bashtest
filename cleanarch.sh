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

confirm () {
	while true; do
		read -p ":: Do u want $1 Y/N " ANSWER
		case $ANSWER in
			[yY] | [yY][eE][sS])
				sudo pacman -S $2
				echo SOFTWARE INSTALLED
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
		esac
	done
}

# Set git config

gitcfg () {
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
		esac
	done
}


# Function to install shit with yay

yayit () {
	while true; do
		read -p ":: Do u want $1 Y/N " ANSWER
		case $ANSWER in
			[yY] | [yY][eE][sS])
				yay -S $2
				echo SOFTWARE INSTALLED
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
				/install.sh $4
				cd ..
				echo SOFWARE INSTALLED
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
		esac
	done
}


# Function to install zsh shit

# echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
## maybe try to find better directory to clone to
zsh-it () {
	while true; do
		read -p "Do u want powerlevel10k? Y/N " ANSWER
		case $ANSWER in
			[yY] | [yY][eE][sS])
				git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/.files/powerlevel10k
				echo 'source ~/.files/powerlevel10k/powerlevel10k.zsh-theme' >>~/.zshrc
				echo "ZSH-itted"
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
		esac
	done
}

## REMOVE LIGHTDM

ldm-remove () {
	while true; do
		read -p "Shall we remove LightDM? Y/N " ANSWER
		case $ANSWER in
			[yY] | [yY][eE][sS])
				yay -Rsn lightdm-gtk-greeter
				yay -Rsn lightdm
				echo 'LightDM Removed'
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
		esac
	done
				
}


##################################
## Beginning of the actual script 
##

echo Welcome to CASH 
sleep 1
confirm 'Full Update' -Syu 'FULL UPDATE'

gitcfg

getyay

echo Removing yay folder
rm -rf yay
echo yay folder removed

confirm 'udisks2/mediainfo/xdg-utils/btop/alsa-utils/lsd/mlocate/alacritty/iosevka-fonts/picom' 'udisks2 mediainfo xdg-utils btop alsa-utils lsd mlocate alacritty ttc-iosevka picom'
yayit 'zsh-autosuggestions/zsh-syntax-highlighting?' 'zsh-autosuggestions zsh-syntax-highlighting'
confirm 'musescore/nicotine?' 'musescore nicotine+'
confirm 'qbittorrent/vlc?' 'qbittorrent vlc'
yayit 'auto-cpufreq/bitwarden/fastfetch/stacer/timeshift?' 'auto-cpufreq bitwarden fastfetch stacer timeshift'
yayit 'pulsemixer/flameshot/dvtm?' 'pulsemixer flameshot dvtm'
confirm 'firefox?' 'firefox'

zsh-it

ldm-remove

echo CASH Finished




## It seems currently included
# confirm 'base-devel' '-S base-devel' 'BASE DEVEL'


# confirm 'gtk engines' '-S gtk-engine-murrine gtk-engines' 'GTK ENGINES'
# buildit 'matcha theme' 'https://github.com/vinceliuice/Matcha-gtk-theme' 'Matcha-gtk-theme' '-c dark -t sea'
# buildit Icons https://github.com/vinceliuice/Qogir-icon-theme Qogir-icon-theme



######
## Add
# rsync
# ufw
# mediainfo
# nvim
# lxappearance
# ly display manager
# xbacklight
#
#
# kdenlive
# #### get zsh as default 
# #### mpd & ncmpcpp script

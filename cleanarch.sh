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
				sudo pacman -S --needed $2
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
		esac
	done
}


# Function to install shit with yay

yayit () {
	while true; do
		read -p ":: Do u want $1 Y/N " ANSWER
		case $ANSWER in
			[yY] | [yY][eE][sS])
				yay -S --needed $2
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
		read -p ":: Do u want powerlevel10k? Y/N " ANSWER
		case $ANSWER in
			[yY] | [yY][eE][sS])
				yayit 'zsh autosuggs/highlights?' 'zsh-autosuggestions zsh-syntax-highlighting'
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

confirm 'Full Update' -yu 'FULL UPDATE'

gitcfg

getyay

confirm 'udisks2/btop/alsa-utils/lsd/alacritty' 'udisks2 btop alsa-utils alacritty'
confirm 'iosevka-fonts/lsd/mediainfo?' 'ttc-iosevka lsd mediainfo'
confirm 'bspwm/sxhkd/picom?' 'bspwm sxhkd picom'
confirm 'feh/xrandr/rofi?' 'feh xorg-xrandr rofi'
yayit 'auto-cpufreq/fastfetch/polybar?' 'auto-cpufreq fastfetch polybar'
yayit 'pulsemixer/flameshot/dvtm?' 'pulsemixer flameshot dvtm'
yayit 'rsync/xbacklight/ufw/neovim/lxappearance?' 'rsync xbacklight ufw neovim lxappearance'

yayit 'ly' 'ly'
yayit 'bitwarden/stacer/timeshift?' 'bitwarden stacer timeshift'
confirm 'firefox?' 'firefox'
confirm 'musescore/nicotine?' 'musescore nicotine'
confirm 'qbittorrent/vlc?' 'qbittorrent vlc'
confirm 'kdenlive?' 'kdenlive'

zsh-it

ldm-remove


##############
## MIGRATION
#

echo :: STARTING MIGRATION
cd ~/
sleep 1

echo :: Committing alias config to .bashrc and .zshrc
echo "alias config='/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME'" >> $HOME/.bashrc
echo "alias config='/usr/bin/git --git-dir=$HOME/.cfg --work-tree=$HOME'" >> $HOME/.zshrc
sleep 1

echo :: Source repository to ignore the folder where to clone
echo ".cfg" >> $HOME/.gitignore
sleep 1

echo :: Cloning dotdiles into bare repository @ home
git clone --bare https://github.com/cristian158/spweedy $HOME/.cfg
sleep 1

echo :: Defining alias in current shell scope
alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
sleep 1 

echo :: Checkout actual content from the bare repository to home after sourcing files
source ~/.bashrc
#source ~/.zshrc
config checkout

read -p "Which files wanna delete? " AnS
echo :: Deleting $Ans
rm $Ans

echo :: Adding all
config add .
sleep 1

echo :: Committing makeover
config commit 'home makeover'
sleep 1 

echo :: Pushing changes (password required)
config push

echo CASH Finished
echo '============================================='


## It seems currently included
# confirm 'base-devel' '-S base-devel' 'BASE DEVEL'

# confirm 'gtk engines' '-S gtk-engine-murrine gtk-engines' 'GTK ENGINES'
# buildit 'matcha theme' 'https://github.com/vinceliuice/Matcha-gtk-theme' 'Matcha-gtk-theme' '-c dark -t sea'
# buildit Icons https://github.com/vinceliuice/Qogir-icon-theme Qogir-icon-theme

######
## Add
# libnotify
# mpd & ncmpcpp script

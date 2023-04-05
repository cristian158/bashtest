#! usr/bin/zsh

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
		read -p "Do u want $1 Y/N " ANSWER
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
 	read -p "Want yay? (8M) Y/N " ANSWER
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
		read -p "Do u want $1 Y/N " ANSWER
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



##################################
## Beginning of th actual script 
#


echo Welcome to the Installation
sleep 1
confirm 'Full Update' -Syu 'FULL UPDATE'
confirm 'base-devel (250M)' '-S base-devel' 'BASE DEVEL'

getyay

confirm 'ardour/audacious/clamtk? (80M)' '-S ardour audacious clamtk' 'SOFTWARE 1/6'
confirm 'atom? (107M)' '-S atom' 'SOFTWARE 2/6'
confirm 'audacity/firefox/kdenlive? (216M)' '-S audacity firefox kdenlive' 'SOFTWARE 3/6'
confirm 'mgba/musescore/nicotine/gthumb? (52M)' '-S mgba-qt musescore nicotine+ gthumb' 'SOFTWARE 4/6'
confirm 'qbittorrent/virtualbox/vlc? (68M)' '-S qbittorrent virtualbox vlc' 'SOFTWARE 5/6'

yayit 'gammy/bat(rust cat)?' '-S gammy bat' 'EXTRA1'
confirm 'mlocate? (1M)' '-S mlocate' 'EXTRA2'
yayit 'auto-cpufreq/bitwarden/fastfetch-git/stacer/timeshift/ifconfig? (102M)' '-S auto-cpufreq bitwardeni fastfetch-git stacer timeshift ifconfig' 'EXTRA3'
yayit 'pulsemixer/flameshot/dvtm?' '-S pulsemixer flameshot dvtm'

# confirm 'gtk engines' '-S gtk-engine-murrine gtk-engines' 'GTK ENGINES'
# buildit 'matcha theme' 'https://github.com/vinceliuice/Matcha-gtk-theme' 'Matcha-gtk-theme' '-c dark -t sea'
# buildit Icons https://github.com/vinceliuice/Qogir-icon-theme Qogir-icon-theme

echo Installation Finished

####
# Add
# lxappearance
# ly display manager
# xbacklight
# rsync
# ufw
# lsd
# mediainfo
# xdg-open
# arecord
# btop
# udisksctl
# fsatfetch
# pulsemixer (or pipeware?)
# nvim
# git
#
#
# #### get zsh as default 
# #### mpd & ncmpcpp script

#! usr/bin/bash

confirm () {
	while true; do
		read -p "Do u want $1? Y/N " ANSWER
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

buildit () {
	while true; do
		read -p "Do u want $1? Y/N " ANSWER
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

echo Welcome to the Installation
sleep 1
confirm 'Full Update' -Syu 'FULL UPDATE'
confirm 'base-devel (250M)' '-S base-devel' 'BASE DEVEL'

while true; do
	read -p "Want yay? (8M) Y/N " ANSWER
	case $ANSWER in
	 [yY] | [yY][eE][sS])
	   git clone https://aur.archlinux.org/yay.git
	   cd yay
	   makepkg -si
	   sudo pacman -U yay-10.3.0-1-x86_64.pkg.tar.zst
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

confirm 'ardour/audacious/clamtk? (80M)' '-S ardour audacious clamtk' 'SOFTWARE 1/6'
confirm 'atom (107M)' '-S atom' 'SOFTWARE 2/6'
confirm 'audacity/firefox/kdenlive? (216M)' '-S audacity firefox kdenlive' 'SOFTWARE 3/6'
confirm 'mgba/musescore/nicotine/gthumb? (52M)' '-S mgba-qt musescore nicotine+ gthumb' 'SOFTWARE 4/6'
confirm 'qbittorrent/redshift/spotifyd/virtualbox/vlc? (68M)' '-S qbittorrent redshift spotifyd virtualbox vlc' 'SOFTWARE 5/6'

while true; do
	read -p "Want auto-cpufreq/bitwarden/fastfetch-git/stacer/timeshift/ifconfig? (102M) Y/N " ANSWER
	case $ANSWER in
	 [yY] | [yY][eE][sS])
	   yay -S auto-cpufreq bitwarden fastfetch-git stacer timeshift ifconfig
	   echo "SOFTWARE 6/6 DONE"
	   echo '============================================='
	   break
	   ;;
	 [nN] | [nN][oO])
	   echo '=================SKIPPING===================='
	   break
	   ;;
	 *)
	   echo "Nigga Please" >&2
	esac
done

confirm 'gtk engines' '-S gtk-engine-murrine gtk-engines' 'GTK ENGINES'
buildit 'matcha theme' 'https://github.com/vinceliuice/Matcha-gtk-theme' 'Matcha-gtk-theme' '-c dark -t sea'
buildit Icons https://github.com/vinceliuice/Qogir-icon-theme Qogir-icon-theme

echo Installation Finished

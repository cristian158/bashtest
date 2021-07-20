#doar manjar

read -p "Want pacman-mirrors? Y/N " ANSWER
case "$ANSWER" in
 [yY] | [yY][eE][sS])
   sudo pacman-mirrors --fasttrack
   ;;
 [nN] | [nN][oO])
   echo '=================SKIPPING===================='
   ;;
 *)
   echo "Please enter y/yes or n/no"
   ;;
esac


#general
read -p "Want Full Update? Y/N " ANSWER
case "$ANSWER" in
 [yY] | [yY][eE][sS])
   sudo pacman -Syu
   echo "FULL UPDATE DONE"
   echo '====================================='
   ;;
 [nN] | [nN][oO])
   echo '=================SKIPPING===================='
   ;;
 *)
   echo "Please enter y/yes or n/no"
   ;;
esac

read -p "Want base-devel? Y/N " ANSWER
case "$ANSWER" in
 [yY] | [yY][eE][sS])
   sudo pacman -S base-devel
   echo "base-devel DONE"
   echo '====================================='
   ;;
 [nN] | [nN][oO])
   echo '=================SKIPPING===================='
   ;;
 *)
   echo "Please enter y/yes or n/no"
   ;;
esac


#yay
read -p "Want yay? Y/N " ANSWER
case "$ANSWER" in
 [yY] | [yY][eE][sS])
   git clone https://aur.archlinux.org/yay.git
   cd yay
   makepkg -si
   sudo pacman -U yay-10.3.0-1-x86_64.pkg.tar.zst
   echo "YAY INSTALL DONE"
   echo '====================================='
   ;;
 [nN] | [nN][oO])
   echo '=================SKIPPING===================='
   ;;
 *)
   echo "Please enter y/yes or n/no"
   ;;
esac


#softwari
read -p "Want ardour/audacious/clamtk? Y/N" ANSWER
case "$ANSWER" in
  [yY] | [yY][eE][sS])
    sudo pacman -S ardour audacious clamtk
    echo "SOFTWARE 1/6 DONE"
    echo '====================================='
    ;;
  [nN] | [nN][oO])
   echo '=================SKIPPING===================='
   ;;
  *)
   echo "Please enter Y/N"
   ;;
esac

read -p "Want atom? (107M) Y/N" ANSWER
case "$ANSWER" in
  [yY] | [yY][eE][sS])
    sudo pacman -S atom
    echo "SOFTWARE 2/6 DONE"
    echo '====================================='
    ;;
  [nN] | [nN][oO])
    echo '=================SKIPPING===================='
    ;;
  *)
    echo "Please enter Y/N"
    ;;
esac

read -p "Want audacity/firefox/kdenlive? (216M) Y/N" ANSWER
case "$ANSWER" in
  [yY] | [yY][eE][sS])
    sudo pacman -S audacity firefox kdenlive
    echo "SOFTWARE 3/6 DONE"
    echo '====================================='
    ;;
  [nN] | [nN][oO])
    echo '=================SKIPPING===================='
    ;;
  *)
    echo "Please enter Y/N"
    ;;
esac

read -p "Want mgba/musescore/nicotine? (43M) Y/N" ANSWER
case "$ANSWER" in
  [yY] | [yY][eE][sS])
    sudo pacman -S mgba-qt musescore nicotine+
    echo "SOFTWARE 4/6 DONE"
    echo '====================================='
    ;;
  [nN] | [nN][oO])
    echo '=================SKIPPING===================='
    ;;
  *)
    echo "Please enter Y/N"
    ;;
esac

read -p "Want qbittorrent/redshift/spotifyd/virtualbox/vlc? (68M) Y/N" ANSWER
case "$ANSWER" in
  [yY] | [yY][eE][sS])
    sudo pacman -S qbittorrent redshift spotifyd virtualbox vlc
    echo "SOFTWARE 5/6 DONE"
    echo '====================================='
    ;;
  [nN] | [nN][oO])
    echo '=================SKIPPING===================='
    ;;
  *)
    echo "Please enter Y/N"
    ;;
esac

read -p "Want auto-cpufreq/bitwarden/fastfetch/stacer/timeshift? Y/N" ANSWER
case "$ANSWER" in
  [yY] | [yY][eE][sS])
    yay -S auto-cpufreq bitwarden fastfetch stacer timeshift
    echo "SOFTWARE 6/6 DONE"
    echo '====================================='
    ;;
  [nN] | [nN][oO])
    echo '=================SKIPPING===================='
    ;;
  *)
    echo "Nigga please"
    ;;
esac

read -p "Want gtk engines? (1M) Y/N" ANSWER
case "$ANSWER" in
  [yY] | [yY][eE][sS])
    sudo pacman -S gtk-engine-murrine gtk-engines
    echo "GTK ENGINES DONE"
    echo '====================================='
    ;;
  [nN] | [nN][oO])
    echo '=================SKIPPING===================='
    ;;
  *)
    echo "Nigga Please"
    ;;
esac

#themes icons

read -p "Want Matcha theme? (12M) Y/N" ANSWER
case "$ANSWER" in
  [yY] | [yY][eE][sS])
    git clone https://github.com/vinceliuice/Matcha-gtk-theme
    cd Matcha-gtk-theme
    ./install.sh -c dark -t sea
    cd ..
    echo "GTK THEME DONE"
    ;;
  [nN] | [nN][oO])
    echo '=================SKIPPING===================='
    ;;
  *)
    echo "Nigga Please"
    ;;
esac

read -p "Want Icons? (14M) Y/N" ANSWER
case "$ANSWER" in
  [yY] | [yY][eE][sS])
    git clone https://github.com/vinceliuice/Qogir-icon-theme
    cd Qogir-icon-theme
    ./install.sh
    echo "ICONS DONE"
    ;;
  [nN] | [nN][oO])
    echo '=================SKIPPING===================='
    ;;
  *)
    echo "Nigga Please"
    ;;
esac

#CASE STATEMENT
#doar manjar

read -p "Want pacman-mirrors Y/N " ANSWER
case "$ANSWER" in
 [yY] | [yY][eE][sS])
   sudo pacman-mirrors --fasttrack
   ;;
 [nN] | [nN][oO])
   echo '====================================='
   ;;
 *)
   echo "Please enter y/yes or n/no"
   ;;
esac
# sudo pacman-mirrors --fasttrack

#general
sudo pacman -Syu
echo "FULL UPDATE DONE"
echo '====================================='
sudo pacman -S base-devel
echo "base-devel DONE"
echo '====================================='

#yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
sudo pacman -U yay-10.3.0-1-x86_64.pkg.tar.zst
echo "YAY INSTALL DONE"
echo '====================================='

#softwari
sudo pacman -S ardour audacious clamtk
echo "SOFTWARE 1/6 DONE"
sudo pacman -S atom
echo "SOFTWARE 2/6 DONE"
sudo pacman -S audacity firefox kdenlive
echo "SOFTWARE 3/6 DONE"
sudo pacman -S mgba-qt musescore nicotine+
echo "SOFTWARE 4/6 DONE"
sudo pacman -S qbittorrent redshift spotifyd virtualbox vlc
echo "SOFTWARE 5/6 DONE"
yay -S auto-cpufreq bitwarden fastfetch stacer timeshift
echo "SOFTWARE 6/6 DONE"
echo '====================================='

#themes icons
sudo pacman -S gtk-engine-murrine gtk-engines
echo "GTK ENGINES DONE"

git clone https://github.com/vinceliuice/Matcha-gtk-theme
cd Matcha-gtk-theme
./install.sh -c dark -t sea
cd ..
echo "GTK THEME DONE"

git clone https://github.com/vinceliuice/Qogir-icon-theme
cd Qogir-icon-theme
./install.sh
echo "ICONS DONE"

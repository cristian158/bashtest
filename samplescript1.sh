sudo pacman-mirrors --fasttrack
sudo pacman -Syu
sudo pacman -S base-devel

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
sudo pacman -U yay-10.3.0-1-x86_64.pkg.tar.zst

sudo pacman -S ardour audacious clamtk
sudo pacman -S atom
sudo pacman -S audacity firefox kdenlive
sudo pacman -S mgba-qt musescore nicotine+
sudo pacman -S qbittorrent redshift spotifyd virtualbox vlc
yay -S auto-cpufreq bitwarden fastfetch stacer timeshift

#themes
sudo pacman -S gtk-engine-murrine gtk-engines

git clone https://github.com/vinceliuice/Matcha-gtk-theme
cd Matcha-gtk-theme
./install.sh -c dark -t sea
cd..

git clone https://github.com/vinceliuice/
cd Qogir-icon-theme
./ install .sh

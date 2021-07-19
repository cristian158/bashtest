sudo pacman-mirrors --fasttrack
sudo pacman -Syu
sudo pacman -S base-devel
sudo pacman -S go

git clone https://aur.archlinux.org/yay.git
cd yay
makpkg
sudo pacman -U yay-10.3.0-1-x86_64.pkg.tar.zst

sudo pacman -S ardour audacious clamtk
sudo pacman -S atom
sudo pacman -S audacity firefox kdenlive
sudo pacman -S mgba-qt musescore nicotine+
sudo pacman -S qbittorrent redshift spotifyd virtualbox vlc
sudo pacman -S yay
yay -S auto-cpufreq bitwarden fastfetch stacer timeshift

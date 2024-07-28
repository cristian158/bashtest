# enable debug mode, which will print each command as it's executed
set -x

###################
###   ALIASES   ###
###################

#alias skreen='xrandr --output Virtual1 --mode 1920x1200'
alias ..='cd ..'
alias ...='cd ../..'
alias du='du -sh'
alias ffprobe='ffprobe -hide_banner'
alias ip='ip -c'
alias key='setxkbmap -layout us,es -option grp:alt_shift_toggle'
alias l='lsd -lh --group-dirs first' 
alias la='l -A'
alias lb='lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT'
alias luzi='bash ~/.files/scripts/luzi.sh'
alias lsusb='lsplug -h'
alias lss='/bin/ls'
alias lt='l -A --total-size'
alias mi='mediainfo'
alias mictest='arecord -vvv -f dat /dev/null'
alias mv='mv -v'
alias open='bash ~/.files/scripts/open.sh'
alias pm='pacman' 
alias pcman='pcmanfm'
alias rmv='mv -t  ~/.local/share/Trash/files'
alias rem='rm -rfv'
alias sens='sensors'
alias st='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'
alias sudb='sudo updatedb'
alias trash='cd ~/.local/share/Trash/files'
alias xo='xdg-open'
alias w2m='for f in *.{wav,WAV}; do ffmpeg -i "$f" -c:a libmp3lame -q:a 2 "${f%.*}.mp3"; done'
alias rsync='rsync -vahP'

## SOFTWARE
alias a='alsamixer'
alias b='btop'
alias bc='bc -q' # Arbitrary precision calculator language
alias f='fastfetch'
alias ff='ffmpeg-bar'
alias n='ncmpcpp'
alias nma='nohup nm-applet --indicator &; bash ~/.files/scripts/nohup.sh'
alias nmc='nmcli'
alias nv='cd ~/00/Docs/ && nvim'
alias ran='ranger'
alias svim='sudo -E vim'
alias v='nvim'
alias y='yay'


## NETWORK
alias hotS59='nmcli device wifi connect S59 password novoadoogee' 
alias myip='curl http://ipecho.net/plain; echo'
alias ping='ping -c 5 archlinux.org'
alias nmch='bash ~/.files/scripts/wifi-scan.sh'
alias NetInfo='bash ~/.files/scripts/NetInfo.sh'


## CONFIG FILES
alias vs='v ~/.config/sxhkd/sxhkdrc'
alias vz='v ~/.zshrc'
alias vp='v ~/.config/polybar/config.ini'
alias vb='v ~/.config/bspwm/bspwmrc'


#########################
###   CUSTOM SCRIPTS  ###
#########################

# JS Shell Script Example (/sbin)
# ~/github/00scripts/date.js
alias D='date.js'

# Custom Shell Script to get current WiFi Password
## fix
alias wifi='bash ~/.files/scripts/wifi-password.sh'

# Custom Shell Script to connect to WiFi
alias connect='bash ~/.files/scripts/connect-wifi.sh'



#####################
###   FUNCTIONS   ###
#####################

################################
### Make Dir & Enter it

mkcd(){ mkdir -p "$1"; cd "$1"; }


################################
### Pipe man pages through nvim

mani(){ man "$1" | nvim; }


################################
### cd's into dir and la's it

cds(){ cd "$1"; la; }


################################
### update mirrors, etc

refle(){ sudo reflector -c "$1" -a 6 --sort rate --save /etc/pacman.d/mirrorlist; }

################################
### Git aliases 

alias gits='git status'
alias gita='git add'
alias gitc='git commit -m'
alias gitp='git push'

# Bad practice :))
acp(){
	git add .
	git commit -m "$1"
	git push
}

################################
### Cut using rsync, WIP!!
#rsyncut(){
#	rsync
#}


#########################
###   ENV VARIABLES   ###
#########################
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"                      
export CARGO_HOME="$XDG_DATA_HOME"/cargo
export GNUPGHOME="$XDG_DATA_HOME"/gnupg
export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
export DVDCSS_CACHE="$XDG_DATA_HOME"/dvdcss
export ICEAUTHORITY="$XDG_CACHE_HOME"/ICEauthority
export MYSQL_HISTFILE="$XDG_DATA_HOME"/mysql_history
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
export HISTFILE="$XDG_STATE_HOME"/zsh/history
export PATH=/usr/local:$PATH
#export WINEPREFIX="$XDG_DATA_HOME"/wine
#export XINITRC="$XDG_CONFIG_HOME"/X11/xinitrc
#export HISTFILE="${XDG_STATE_HOME}"/bash/history
#nvidia-settings --config="$XDG_CONFIG_HOME"/nvidia/settings
PS1='[\u@\h \W]\$ '
alias config='/usr/bin/git --git-dir=/home/spweedy/.cfg --work-tree=/home/spweedy'

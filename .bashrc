###################
###   ALIASES   ###
###################

alias ..='cd ..'
alias ...='cd ../..'
alias du='du -sh'
alias l='lsd -lh --group-dirs first' 
alias la='l -A'
alias lt='l -A --total-size'
alias lss='/bin/ls'
alias lb='lsblk'
alias mi='mediainfo'
alias mv='mv -v'
alias pm='pacman' 
alias rem='rm -rfv'
alias trash='cd ~/.local/share/Trash/files'
alias ffprobe='ffprobe -hide_banner'
alias st='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'

## rsync with verbosity, archive (recursive, copy symlinks, preserve permissions, ...), human readable, show progress
alias rsync='rsync -vahP'
## rsync'ing w 10 threads or something:
## 	$ cd /path/source; ls -1 | xargs -n1 -P10 -I% rsync -varhP % /path/destiny/


## NETWORK
alias hotS59='nmcli device wifi connect S59 password novoadoogee' 
alias myip='curl http://ipecho.net/plain; echo'
alias ping='ping -c 5 archlinux.org'
alias nmch='bash ~/.files/scripts/wifi-scan.sh'
## alias nets='bash ~/.files/scripts/rofi-wifi-menu/rofi-wifi-menu.sh'
## nmc dev wifi show	| shows connected network (SSID, Security, Password, QRCode


## CONFIG FILES
alias vs='v ~/.config/sxhkd/sxhkdrc'
alias vz='v .zshrc'
alias vp='v ~/.config/polybar/config.ini'
alias vb='v ~/.config/bspwm/bspwmrc'



#########################
###   CUSTOM SCRIPTS  ###
#########################

# Custom Shell Script to get current WiFi Password
alias wifi='bash ~/.files/scripts/wifi-password.sh'



#####################
###   FUNCTIONS   ###
#####################

##########
### Make Dir & Enter it

mkcd(){ mkdir -p "$1"&& cd "$1" }
#cds(){ cd "$1"; ls }


##########
### GIT

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

##########
### CUT
rsyncut(){
	rsync
}


# Keybindings
bindkey "^d" backward-word
bindkey "^f" forward-word


#########################
###   ENV VARIABLES   ###
#########################
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"                      
export ATOM_HOME="$XDG_DATA_HOME"/atom
#export HISTFILE="${XDG_STATE_HOME}"/bash/history
export CARGO_HOME="$XDG_DATA_HOME"/cargo                        #~/.cargo
export GNUPGHOME="$XDG_DATA_HOME"/gnupg                         #~/.gnupg
export GTK_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc
export LESSHISTFILE="$XDG_CACHE_HOME"/less/history
export DVDCSS_CACHE="$XDG_DATA_HOME"/dvdcss
export ICEAUTHORITY="$XDG_CACHE_HOME"/ICEauthority
export MYSQL_HISTFILE="$XDG_DATA_HOME"/mysql_history
export NODE_REPL_HISTORY="$XDG_DATA_HOME"/node_repl_history
#export XINITRC="$XDG_CONFIG_HOME"/X11/xinitrc
export HISTFILE="$XDG_STATE_HOME"/zsh/history
export PATH=/usr/local:$PATH

PS1='[\u@\h \W]\$ '
alias config='/usr/bin/git --git-dir=/home/spweedy/.cfg --work-tree=/home/spweedy'

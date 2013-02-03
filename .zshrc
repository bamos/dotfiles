# ~/.zshrc

source ~/.private

DISABLE_AUTO_UPDATE='true'
plugins=(git) # Git aliases
ZSH_THEME=minimal
ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh

export USE_CCACHE=1
export CCACHE_DIR=~/.ccache

alias 1='cd +1'
alias h='hostname'
alias sudo='nocorrect sudo ' # Otherwise, `sudo vim` autocorrects
alias gcl='git clone'
alias dotup='git --git-dir=$HOME/.dotfiles/.git pull'
alias up='yaourt -Syua'
alias y='yaourt'
alias xa='xrandr --auto'
alias c='clear'

# Zenburn-esque ls colors
LS_COLORS='di=38;5;108:fi=00:*svn-commit.tmp=31'
LS_COLORS+=':ln=38;5;116:ex=38;5;186'
export LS_COLORS

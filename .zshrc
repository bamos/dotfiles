# ~/.zshrc

DISABLE_AUTO_UPDATE='true'
plugins=(git) # Git aliases
ZSH_THEME=minimal
ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh

export USE_CCACHE=1
export CCACHE_DIR=/mnt/data/Parts/Cache

alias sudo='nocorrect sudo' # Otherwise, `sudo vim` autocorrects
alias gcl='git clone'

LS_COLORS='di=38;5;108:fi=00:*svn-commit.tmp=31'
LS_COLORS+=':ln=38;5;116:ex=38;5;186'
export LS_COLORS

PATH=~/bin
PATH+=:/mnt/data/Coding/Linux/scripts
PATH+=:/usr/bin/vendor_perl:/usr/bin/core_perl
PATH+=:$HOME/.gem/ruby/1.9.1/bin
PATH+=:/opt/cuda/bin
PATH+=:/mnt/data/Documents/Research/Magnum/Android/.repo/repo
PATH+=:/opt/android-sdk/platform-tools:/opt/android-sdk/tools
PATH+=:/usr/local/bin:/usr/bin:/bin
PATH+=:/usr/local/sbin:/usr/sbin:/sbin
export PATH

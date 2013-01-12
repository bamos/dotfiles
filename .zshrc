# ~/.zshrc

DISABLE_AUTO_UPDATE="true"
plugins=(git vi-mode)
ZSH_THEME=minimal

ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh

PATH=:/mnt/data/Coding/Linux/scripts
PATH+=:/mnt/data/Documents/Research/Magnum/Android/.repo/repo
PATH+=:~/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin
PATH+=:/opt/android-sdk/tools
PATH+=:/usr/bin/vendor_perl
PATH+=:/usr/bin/core_perl
PATH+=:/opt/android-sdk/platform-tools:/opt/android-sdk/tools
PATH+=:~/.gem/ruby/1.9.1/bin
PATH+=:/opt/cuda/bin
export PATH

export USE_CCACHE=1
export CCACHE_DIR=/mnt/data/Parts/Cache

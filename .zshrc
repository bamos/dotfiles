# ~/.zshrc

ZSH=$HOME/.oh-my-zsh
ZSH_THEME="clean-bda"
#ZSH_THEME="clean"
plugins=(git)

source $ZSH/oh-my-zsh.sh

export PATH=/mnt/data/Coding/Linux/scripts:/mnt/data/Documents/Research/Magnum/Android/.repo/repo:~/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/sbin:/sbin:/opt/android-sdk/tools:/usr/bin/vendor_perl:/usr/bin/core_perl:/opt/android-sdk/platform-tools:/opt/android-sdk/tools
export USE_CCACHE=1
export CCACHE_DIR=/mnt/data/Parts/Cache

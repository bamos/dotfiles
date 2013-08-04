# ~/.zshrc

[[ -a ~/.private ]] && source ~/.private
[[ -a ~/.aliases ]] && source ~/.aliases

# http://www.zsh.org/mla/users/1999/msg00152.html
# function my_sudo {
#     while [[ $# > 0 ]]; do
#         case "$1" in
#         command) shift ; break ;;
#         nocorrect|noglob) shift ;;
#         *) break ;;
#         esac
#     done
#     if [[ $# = 0 ]]; then
#         command sudo zsh
#     else
#         noglob command sudo $@
#     fi
# }

DISABLE_AUTO_UPDATE='true'
plugins=(vi-mode git history-substring-search)
ZSH_THEME=minimal
ZSH=$HOME/.oh-my-zsh
source $ZSH/oh-my-zsh.sh

export USE_CCACHE=1
export CCACHE_DIR=~/.ccache

# Zenburn-esque ls colors
LS_COLORS='di=38;5;108:fi=00:*svn-commit.tmp=31'
LS_COLORS+=':ln=38;5;116:ex=38;5;186'
export LS_COLORS

export EDITOR=vim

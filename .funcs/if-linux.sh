# .funcs/if-linux.sh
#
# Linux-specific shell functions and aliases.
# Source this directly or source env.sh for everything,
# which will conditionally source this file.
#
# Brandon Amos
# http://bamos.github.io
# 2015/04/27

alias m="make -j$(cat /proc/cpuinfo | grep -c processor)"
alias za='zathura'
alias less='/usr/share/vim/vim74/macros/less.sh'
alias vim='vim -p'

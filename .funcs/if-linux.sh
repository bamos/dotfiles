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

VIM_LESS_CMD=`find /usr/share/vim -name less.sh | tail -n 1`
alias less=$VIM_LESS_CMD
alias vim='vim -p'

alias ns='nvidia-smi'

# http://stackoverflow.com/questions/6918057
list-subdir-by-files() {
  find . -xdev -type f | cut -d "/" -f 2 | sort | uniq -c | sort -n
}

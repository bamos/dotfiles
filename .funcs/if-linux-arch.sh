# .funcs/if-linux-arch.sh
#
# Arch Linux-specific shell functions and aliases.
# Source this directly or source env.sh for everything,
# which will conditionally source this file.
#
# Brandon Amos
# http://bamos.github.io
# 2015/04/27

alias y='yaourt'
alias ys='yaourt -S --noconfirm'
alias yr='yaourt -R --noconfirm'
alias up='yaourt -Syua'
alias yup='up --noconfirm'
alias i-int='ip address show wlp3s0'

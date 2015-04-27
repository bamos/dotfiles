# .funcs/if-linux-ubuntu.sh
#
# Ubuntu-specific shell functions and aliases.
# Source this directly or source env.sh for everything,
# which will conditionally source this file.
#
# Brandon Amos
# http://bamos.github.io
# 2015/04/27

alias agi='_ apt-get install -y'
alias agr='_ apt-get remove -y'
alias aup='_ apt-get update; _ apt-get upgrade;'
alias acs='apt-cache search'
alias chromium='chromium-browser'

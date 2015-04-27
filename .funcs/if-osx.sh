# .funcs/if-osx.sh
#
# OSX-specific shell functions and aliases.
# Source this directly or source env.sh for everything,
# which will conditionally source this file.
#
# Brandon Amos
# http://bamos.github.io
# 2015/04/27

alias m="make -j8"
#alias full-emacs="$HOME/Applications/Emacs.app/Contents/MacOS/Emacs"
#alias emacsclient="$HOME/Applications/Emacs.app/Contents/MacOS/bin/emacsclient"
alias brup='brew update; brew upgrade'
alias bri='brew install'
alias brun='brew uninstall'
alias i-int='ipconfig getifaddr en0'
if command -v mvim > /dev/null 2>&1; then
    alias less='/usr/local/Cellar/macvim/7.4-73/MacVim.app/Contents/Resources/vim/runtime/macros/less.sh'
    alias vim='mvim -v -p'
fi
alias za='Skim'
alias open-wallpaper='open $(get-osx-wallpaper.py)'
# alias rm-wallpaper='rm $(get-osx-wallpaper.py) && killall Dock'

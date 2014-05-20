# ~/.zshrc
# Brandon Amos <http://bamos.io>

# Add additional directories to the path.
pathadd() {
  [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]] && PATH="${PATH:+"$PATH:"}$1"
}

pathadd $HOME/bin
pathadd $HOME/.local/bin
REPOS=$HOME/repos
pathadd $REPOS/shell-scripts
pathadd $REPOS/python-scripts/python2.7
pathadd $REPOS/python-scripts/python3
unset REPOS

# Source external files.
[[ -a ~/.funcs ]] && source ~/.funcs
[[ -a ~/.aliases ]] && source ~/.aliases
[[ -a ~/.private ]] && source ~/.private
[[ -a ~/.mpv/shellrc.sh ]] && source ~/.mpv/shellrc.sh

# Initialize oh-my-zsh.
DISABLE_AUTO_UPDATE='true';
ZSH_THEME=bamos_minimal; ZSH=~/.oh-my-zsh; ZSH_CUSTOM=~/.zsh-custom
# zsh options: http://www.cs.elte.hu/zsh-manual/zsh_16.html
plugins=(vi-mode git history-substring-search)
source $ZSH/oh-my-zsh.sh

# Environment variables.
export LS_COLORS='di=38;5;108:fi=00:ln=38;5;116:ex=38;5;186'
export LSCOLORS='ExGxFxdxCxEgEdHbagacad'
export EDITOR=vim

# If a pattern for filename generation has no matches,
# delete the pattern from the argument list.
# Do not report an error unless all the patterns in a command have no matches.
set -o CSH_NULL_GLOB

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# ~/.zshrc
# Brandon Amos <http://bamos.github.io>

[[ -a ~/.private ]] && source ~/.private
[[ -a ~/.aliases ]] && source ~/.aliases
[[ -a ~/.funcs ]] && source ~/.funcs

DISABLE_AUTO_UPDATE='true'; ZSH_THEME=minimal; ZSH=$HOME/.oh-my-zsh;
plugins=(vi-mode git history-substring-search)
source $ZSH/oh-my-zsh.sh

export LS_COLORS='di=38;5;108:fi=00:ln=38;5;116:ex=38;5;186' # Zenburn-esque.
export USE_CCACHE=1; export CCACHE_DIR=~/.ccache
export EDITOR=vim

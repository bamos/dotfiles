# ~/.zshrc
# Brandon Amos <http://bamos.io>

[[ -a ~/.aliases ]] && source ~/.aliases
[[ -a ~/.funcs ]] && source ~/.funcs
[[ -a ~/.private ]] && source ~/.private

DISABLE_AUTO_UPDATE='true';
ZSH_THEME=bamos_minimal; ZSH=~/.oh-my-zsh; ZSH_CUSTOM=~/.zsh-custom
plugins=(vi-mode git history-substring-search)
source $ZSH/oh-my-zsh.sh

export LS_COLORS='di=38;5;108:fi=00:ln=38;5;116:ex=38;5;186' # Zenburn-esque.
export USE_CCACHE=1; export CCACHE_DIR=~/.ccache
export EDITOR=vim

# zsh options: http://www.cs.elte.hu/zsh-manual/zsh_16.html

# If a pattern for filename generation has no matches,
# delete the pattern from the argument list;
# do not report an error unless all the patterns in a command have no matches.
set -o CSH_NULL_GLOB

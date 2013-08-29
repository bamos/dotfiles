# ~/.zshrc
# Brandon Amos <http://bamos.github.io>

[[ -a ~/.private ]] && source ~/.private
[[ -a ~/.aliases ]] && source ~/.aliases

DISABLE_AUTO_UPDATE='true'; ZSH_THEME=minimal; ZSH=$HOME/.oh-my-zsh;
plugins=(vi-mode git history-substring-search)
source $ZSH/oh-my-zsh.sh

# Zenburn-esque ls colors
export LS_COLORS='di=38;5;108:fi=00:*svn-commit.tmp=31:ln=38;5;116:ex=38;5;186'
export USE_CCACHE=1; export CCACHE_DIR=~/.ccache
export EDITOR=vim

function rand-cd {
  FILES=$(find . -maxdepth 1 -type d | perl -lne 'print quotemeta')
  NUM_FILES=$(echo $FILES | wc -l)
  cd $(echo $FILES | xargs -n $NUM_FILES shuf -n1 -e)*
}

# ~/.zshrc
# Brandon Amos <http://bamos.github.io>

[[ -a ~/.private ]] && source ~/.private
[[ -a ~/.aliases ]] && source ~/.aliases

DISABLE_AUTO_UPDATE='true'; ZSH_THEME=minimal; ZSH=$HOME/.oh-my-zsh;
plugins=(vi-mode git history-substring-search)
source $ZSH/oh-my-zsh.sh

#export LS_COLORS='di=38;5;108:fi=00:*svn-commit.tmp=31:ln=38;5;116:ex=38;5;186'
export LS_COLORS='di=38;5;108:fi=00:ln=38;5;116:ex=38;5;186' # Zenburn-esque.
export USE_CCACHE=1; export CCACHE_DIR=~/.ccache
export EDITOR=vim

function rand-cd {
  DIRS=$(find . -maxdepth 1 -type d | sed 's/\(.*\)/"\1"/g')
  NUM_DIRS=$(echo $DIRS | wc -l)
  [[ $NUM_DIRS == 1 ]] && echo "Warning: No directories found."
  cd "$(echo $DIRS | xargs -n $NUM_DIRS shuf -n1 -e)"
  unset DIRS NUM_DIRS
}

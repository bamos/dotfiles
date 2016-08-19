# .funcs/git.sh
#
# Git shell functions and aliases.
# Source this directly or source env.sh for everything.
#
# Prefer these to git aliases for brevity.
# Some of these are duplicated from oh-my-zsh,
# but helpful on systems without oh-my-zsh.
#
# Brandon Amos
# http://bamos.github.io
# 2015/04/27

# Inspired by: https://github.com/robbyrussell/oh-my-zsh/blob/master/plugins/git/git.plugin.zsh
alias g='git'
alias ga='git add'
alias gc='git commit'
alias gclo='git clone'
alias gl='git pull'
alias gup='git pull --rebase'
alias gp='git push'
alias gpsuom='git push --set-upstream origin master'
alias gsr='git svn rebase'
alias gsd='git svn dcommit'
alias gu="git reset --soft 'HEAD^'"

# https://github.com/matthewmccullough/scripts/blob/master/git-finddirty
git-dirty() {
  OLDIFS=$IFS; IFS=$'\n'

  for gitprojpath in `find . -type d -name .git|sort|sed "s/\/\.git//"`; do
    pushd . >/dev/null
    cd $gitprojpath
    isdirty=$(git status -s | grep "^.*")
    if [ -n "$isdirty" ]; then
      echo "DIRTY:" $gitprojpath
    fi
    popd >/dev/null
  done
  IFS=$OLDIFS
}

git-clonecd() {
  local TMP=$(mktemp /tmp/gcloc-XXXXXX)
  git clone $@ 2>&1 | tee $TMP
  local DIR=$(grep "Cloning into" $TMP | sed -e "s/Cloning into '\(.*\)'.*/\1/g")
  if [[ ! -z $DIR ]]; then
    cd $DIR
  fi
  rm $TMP
}
alias gcloc='git-clonecd'

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

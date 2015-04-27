# .funcs.sh
# Custom shell functions and aliases that can be sources from
# bash or zsh.
#
# Brandon Amos: http://bamos.github.io
# 2015/04/23

die() { echo $@; exit -1; }

# Misc.
rand-cd() {
  local DIRS; DIRS=$(find . -maxdepth 1 -type d | sed 's/\(.*\)/"\1"/g')
  local NUM_DIRS=$(echo $DIRS | wc -l)
  [[ $NUM_DIRS == 1 ]] && die "Error: No directories found."
  cd "$(echo $DIRS | xargs -n $NUM_DIRS shuf -n1 -e)"
}
alias rcd='rand-cd'

wget-rec() {
  wget --recursive \
    --page-requisites \
    --html-extension \
    --convert-links \
    --no-parent \
    $*
}

d2h() { # diff2html
  local TMP_FILE=$(mktemp -t hdiff.XXXX)
  diff2html $@ > $TMP_FILE
  chromium $TMP_FILE
}

mkdircd() { mkdir -p $@ && cd ${@:${#@}}; }
alias mcd='mkdircd'

# Netjoin - Block until a network connection is obtained.
nj() {
  while true; do
    ping -c 1 8.8.8.8 &> /dev/null && break
    sleep 1
  done
}

# Android.
# TODO - Use ssh if available.
musicToAndroid() {
  { adb devices | grep "device$" &> /dev/null } \
    || { echo "No devices found."; return; }
  if [[ $(uname) == "Linux" ]]; then SORT=sort;
  else SORT=gsort; fi
  while read SONG; do
    echo "Syncing $SONG."
    #TODO - Get relative directory.
    adb push $SONG /sdcard/Music &> /dev/null
    [[ $? != 0 ]] && echo " + Failed."
  done < <(find $* -type f | $SORT -R)
  unset SORT
}
alias m2a='musicToAndroid'

# Docker.
docker-clean() {
  docker rm $(docker ps -a -q)
  docker rmi $(docker images -q)
}

docker-zsh() {
  local TAG=$1
  docker run -v /tmp:/host_tmp:rw -i -t $TAG /bin/zsh
}

# Thread functions.
ps-threads() { ps -C $1 -L -opsr,pid,ppid,lwp,state }
watch-threads() { watch -n 1 ps -C $1 -L -opsr,pid,ppid,lwp,state }

# Allow crontab in dotfiles.
[ -z "${CRONTABCMD+x}" ] && export CRONTABCMD=$(which crontab)
[ -z "${CRONTABFILE+x}" ] && export CRONTABFILE=$HOME/.crontab.$HOST
crontab() {
  if [[ $@ == "-e" ]]; then vim $CRONTABFILE && $CRONTABCMD $CRONTABFILE
  else $CRONTABCMD $@; fi
}

# Infinitely loop commands.
inf() {
  while true; do
    zsh -ci "source $HOME/.zshrc; $* ;"
    [[ $? == 0 ]] || return
  done;
}

memo() {
  echo "$*" | mail -n -s "$*" bamos@cmu.edu
}

function stopwatch(){
  case $(uname) in
    "Linux") DATE=date ;;
    "Darwin") DATE=gdate ;;
  esac
  local BEGIN=`$DATE +%s`
  while true; do
    echo -ne "$($DATE -u --date @$((`$DATE +%s` - $BEGIN)) +%H:%M:%S)\r";
  done
}

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

sys-find() {
  find / -name $@ 2>/dev/null
}

dump-packages() {
  yaourt -Qe | cut -d ' ' -f 1 | sed 's/^.*\///'
}

mkdir-mv() {
  [[ $# == 2 ]] || return -1
  mkdir -p $(dirname $2) && mv $1 $2
}

mkdir-cp() {
  [[ $# == 2 ]] || return -1
  mkdir -p $(dirname $2) && cp $1 $2
}

# Utilities and tools.
alias c='clear'
alias chax='chmod a+x'
alias h='hostname'
alias i-ext='curl icanhazip.com'
alias li='libreoffice'
alias psg='ps aux | grep'
alias rh='rehash'
alias sudo='nocorrect sudo'
alias xa='xrandr --auto'
alias xax='xrandr --auto; exit'
alias dual='xrandr --output VGA1 --right-of LVDS1 --auto'
alias dx='dual; exit'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
alias ......='cd ../../../../..'
alias grive='grive -p ~/grive'
alias wh='which'
alias j='jobs'

# Programs.
mu() {
  # TODO: Fix `read` for bash
  read "REPLY?Is this important? "
  [[ $REPLY =~ ^[Yy]$ ]] && mutt $*
}
alias rsyncdir='rsync -azv --progress'
alias bup='vim +BundleInstall +qall'
alias bcl='vim +BundleClean +qall'

# Music.
alias sync-music='rsyncdir $HOME/docs/music/ dijkstra:~/mnt/usb/music/'
alias remove-tags='eyeD3 --remove-all'
alias add-tags='picard'
alias get-tags='exiftool -json'

# Android.
alias pullimages="adb pull /storage/sdcard0/DCIM/Camera ."

# Git. Prefer these to git aliases for brevity.
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

alias pw='pwgen --numerals --symbols --ambiguous 15 1'

alias count-frames=$'grep -c \'^\\(\\\\frame{\\|\\\\begin{frame}\\\)\''
alias tmux='tmux -2'

alias f='sudo $(fc -ln -1)'

alias emacsd='emacs --daemon'
alias e='emacsclient -nw'

alias ts='tmux split-window'
alias tsh='tmux split-window -h'

alias psgrep='ps aux | grep'

alias clauncher='chromium --show-app-list'

alias random-mac="openssl rand -hex 6 | sed 's/\(..\)/\1:/g; s/.$//'"

# OS and distro-specific aliases.
case $(uname) in
  "Linux")
    alias m="make -j$(cat /proc/cpuinfo | grep -c processor)"
    alias za='zathura'
    alias less='/usr/share/vim/vim74/macros/less.sh'
    alias vim='vim -p'
    if command -v lsb_release &> /dev/null; then
      case $(lsb_release -s -i) in
        "Arch")
          alias y='yaourt'
          alias ys='yaourt -S --noconfirm'
          alias yr='yaourt -R --noconfirm'
          alias up='yaourt -Syua'
          alias yup='up --noconfirm'
          alias i-int='ip address show wlp3s0'
        ;;
        "Ubuntu")
          alias agi='_ apt-get install -y'
          alias agr='_ apt-get remove -y'
          alias aup='_ apt-get update; _ apt-get upgrade;'
          alias acs='apt-cache search'
          alias chromium='chromium-browser'
        ;;
      esac
    fi
  ;;
  "Darwin")
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
    alias rm-wallpaper='rm $(get-osx-wallpaper.py) && killall Dock'
  ;;
esac

unset -f die

# shellrc.sc
# Source this to add additional shell features for mpv.

alias mpvnova='mpv --no-video'
alias mpvp='mpv --no-video --shuffle --loop inf --playlist'

playdir() {
  mpv --no-video --shuffle --loop inf \
    --playlist <(find "$PWD" -type f -follow)
}
alias pd='playdir'

playdirs() {
  if [[ $(uname) == "Linux" ]]; then READLINK=readlink;
  else READLINK=greadlink; fi
  mpv --no-video --shuffle --loop inf \
    --playlist <(find "$@" -type f -follow -exec $READLINK -f {} \;)
  unset READLINK
}
alias pds='playdirs'

play-rand-dir() {
  local DIRS; DIRS=$(find . -maxdepth 1 -type d | sed 's/\(.*\)/"\1"/g')
  local NUM_DIRS=$(echo $DIRS | wc -l)
  [[ $NUM_DIRS == 1 ]] && echo "Warning: No directories found."
  cd "$(echo $DIRS | xargs -n $NUM_DIRS shuf -n1 -e)"
  pd
  cd ..
}
alias prd='play-rand-dir'

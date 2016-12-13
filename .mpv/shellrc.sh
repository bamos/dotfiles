# shellrc.sc
# Source this to add additional shell features for mpv.

alias mpvnova='mpv --no-video'
alias mpvshuf='mpvnova --shuffle --loop=inf'
mpvp() {
  mpvshuf --playlist <(cat $*)
}

playcurrentdir() {
  mpvshuf --playlist <(find "$PWD" -type f -follow \
    -not -path '*/\.*' -not -path '*.m3u' -exec realpath -s {} \;)
}
alias pcd='playcurrentdir'

playdir() {
  if [[ $# == 0 ]]; then
    echo "playdir requires one or more directories on input."
  else
    mpvshuf --playlist <(find "$@" -type f -follow \
      -not -path '*/\.*' -exec realpath -s {} \;)
  fi
}
alias pd='playdir'

alias random-mpv="find . -type f  | shuf | head -n 1 | xargs mpv"

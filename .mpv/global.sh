# Source this with mpv shell script plugins to provide the functions:
#
#   `die`: Prints a message and exits.
#   `get-current-track`: Return the path to the current file mpv is playing.
#     Usage: TRACK=$(get-current-track)

function die() { echo $*; exit -1; }

function get-current-track() {
  # On multiuser machines, output and grep on $USER too
  local MPV_PID=$(ps axo '%p %c'|grep [m]pv$|awk '{print $1}')
  local NUM_PID=$(echo $MPV_PID | wc -w)

  [ $NUM_PID -eq 0 ] && die "Error: Could not find mpv pid."
  [ $NUM_PID -gt 1 ] && die "Error: Found $NUM_PID mpv pids: \"$MPV_PID\""

  IFS=$'\n'
  for F in $(lsof -p ${MPV_PID} -Ftn |grep -A1 ^tREG|grep ^n|sed 's/^n//g'); do
    if test -w "$F" ; then
      echo "$F"
      return
    fi
  done
}

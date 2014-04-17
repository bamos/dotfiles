#!/bin/bash

function die() { echo $*; exit -1; }

# On multiuser machines, output and grep on $USER too
MPV_PID=$(ps axo '%p %c'|grep [m]pv$|awk '{print $1}')

if [ "$(echo ${MPV_PID}|wc -w)" -ne 1 ] ; then
  echo "Error: too many mpv PIDs: \"${MPV_PID}\" ($(echo ${MPV_PID}|wc -w))"
  exit 1
fi

IFS='
'
for F in $(lsof -p ${MPV_PID} -Ftn |grep -A1 ^tREG|grep ^n|sed 's/^n//g'); do
  if test -w "$F"; then
    CURRENT_TRACK="$F"
    break
  fi
done

[[ -z $CURRENT_TRACK ]] && die "Error: No current track found."

TMP_JSON=$(mktemp -t mpv.share.XXXXX)
exiftool -json "$CURRENT_TRACK" > $TMP_JSON
INFO=$(python <<EOF
import json
f=open('$TMP_JSON', 'r')
obj=json.load(f)[0]
f.close()
print('Hi, check out "' + obj["Title"] + '" by ' + obj['Artist'] + ".")
EOF
)
rm -f $TMP_JSON

# Use zenity because the terminal cannot be controlled with mpv running.
EMAIL=$(zenity --entry --title "Email to share with?" --text '')
[[ -z $EMAIL ]] && die "Error: No email input."
CONTENT=$(zenity --entry --title "Optional message body?" --text '')
mutt -s "$INFO" -- $EMAIL<<EOF
$CONTENT
EOF

if [[ $? == 0 ]]; then echo "Successfully shared with '$EMAIL'."
else echo "Failed to share with '$EMAIL'."; fi
echo $INFO

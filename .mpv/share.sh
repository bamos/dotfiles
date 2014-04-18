#!/bin/bash
#
# share.sh
# Share the name and artist of the current track via email using mutt.
#
# Brandon Amos <http://bamos.io>
# 2014.04.18

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/global.sh
TRACK=$(get-current-track)

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

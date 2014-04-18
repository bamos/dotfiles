#!/bin/bash
#
# info.sh
# Display info about the current track.
#
# Brandon Amos <http://bamos.io>
# 2014.04.18

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/global.sh
TRACK=$(get-current-track)

TMP_JSON=$(mktemp)
exiftool -json "$TRACK" > $TMP_JSON
python <<EOF
import json
f=open('$TMP_JSON', 'r')
obj=json.load(f)[0]
fields = ['Artist', 'Title']
print(
  '\n\n-----\n' +
  '\n'.join([x + ": " + obj[x] for x in fields]) +
  "\n-----\n"
)
EOF

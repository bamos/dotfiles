#!/bin/bash
#
# delete.sh
# Delete the current track. A single track can be recovered with `recover.sh`.
#
# Brandon Amos <http://bamos.io>
# 2014.04.18

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/global.sh
TRACK=$(get-current-track)

mv "$TRACK" /tmp/mpv-deleted
echo "$TRACK" > /tmp/mpv-deleted-name
echo "$TRACK deleted."

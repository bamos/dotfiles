#!/bin/bash

if test -w "/tmp/mplayer-deleted" ; then
  OLD_LOC=$(cat /tmp/mplayer-deleted-name)
  mv /tmp/mplayer-deleted "$OLD_LOC"
  if [[ $? == 0 ]]; then
    echo "Successfully recovered $FILE."
    rm /tmp/mplayer-deleted-name
  fi
else
  echo "Unable to recover file."
fi

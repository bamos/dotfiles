#!/bin/bash

if test -w "/tmp/mpv-deleted" ; then
  OLD_LOC=$(cat /tmp/mpv-deleted-name)
  mv /tmp/mpv-deleted "$OLD_LOC"
  if [[ $? == 0 ]]; then
    echo "Successfully recovered $FILE."
    rm /tmp/mpv-deleted-name
  fi
else
  echo "Unable to recover file."
fi

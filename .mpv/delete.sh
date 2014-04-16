#!/bin/bash

# On multiuser machines, output and grep on $USER too
MPV_PID=$(ps axo '%p %c'|grep [m]pv$|awk '{print $1}')

if [ "$(echo ${MPV_PID}|wc -w)" -ne 1 ] ; then
  echo "Error: too many mpv PIDs: \"${MPV_PID}\" ($(echo ${MPV_PID}|wc -w))"
  exit 1
fi

IFS='
'
for F in $(lsof -p ${MPV_PID} -Ftn |grep -A1 ^tREG|grep ^n|sed 's/^n//g'); do
  if test -w "$F" ; then
    mv "$F" /tmp/mpv-deleted
    echo "$F" > /tmp/mpv-deleted-name
    echo "$F deleted."
  fi
done

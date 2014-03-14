#!/bin/bash

# On multiuser machines, output and grep on $USER too
MYPID=$(ps axo '%p %c'|grep [m]pv$|awk '{print $1}')

if [ "$(echo ${MYPID}|wc -w)" -ne 1 ] ; then
  echo "#no safe output: too many PIDs: \"${MYPID}\" ($(echo ${MYPID}|wc -w))"
  exit 1
fi

IFS='
'
for FILE in $(lsof -p ${MYPID} -Ftn |grep -A1 ^tREG|grep ^n|sed 's/^n//g'); do
  if test -w "${FILE}" ; then
    mv "${FILE}" /tmp/mpv-deleted
    echo "${FILE}" > /tmp/mpv-deleted-name
    echo "${FILE} deleted."
  fi
done

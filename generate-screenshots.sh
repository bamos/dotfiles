#!/bin/bash

set -x
Xvfb :1 -screen 0 500x500x16 & XVFB_PROC=$!
sleep 1

export DISPLAY=localhost:1.0

exec i3 & I3_PROC=$!
sleep 1
xrdb ~/.Xresources -D$(hostname) -all

urxvt -e vim ~/.vimrc & URXVT_PROC=$!
sleep 1

scrot screenshots/vim.png
kill $URXVT_PROC


echo 'spawn zsh; send -- "clear\rls -a\r"; expect eof' > /tmp/bamos-expect
urxvt --hold -e expect -f /tmp/bamos-expect & URXVT_PROC=$!

sleep 1
scrot screenshots/zsh-ls.png
kill $URXVT_PROC
rm /tmp/bamos-expect

kill $I3_PROC
kill $XVFB_PROC

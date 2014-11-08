#!/bin/bash

set -x
cd ~/.dotfiles

Xvfb :1 -screen 0 500x500x16 & XVFB_PROC=$!
sleep 1

export DISPLAY=localhost:1.0

exec i3 & I3_PROC=$!
sleep 1
xrdb ~/.Xresources -D$(hostname) -all

urxvt_scrot() {
  urxvt $1 & URXVT_PROC=$!
  sleep $2

  scrot screenshots/$3.png
  kill $URXVT_PROC
}

urxvt_scrot "-e vim $HOME/.vimrc" 1 vim
urxvt_scrot "-e emacs -nw $HOME/.emacs.d/init.el" 3 emacs
urxvt_scrot "-e mutt" 5 mutt

echo 'spawn zsh; send -- "clear\rls -a\r"; expect eof' > /tmp/bamos-expect
urxvt_scrot "--hold -e expect -f /tmp/bamos-expect" 1 zsh
rm /tmp/bamos-expect

urxvt_scrot "-e screen -S bamos-screen" 1 screen
screen -X -S bamos-screen kill

urxvt_scrot "-e tmux new -s bamos-tmux" 1 tmux
tmux kill-session -t bamos-tmux

kill $I3_PROC
kill $XVFB_PROC

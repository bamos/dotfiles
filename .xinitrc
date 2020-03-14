#!/bin/bash

xsetroot -cursor_name left_ptr -solid "#262626"

# Set up the keyboard
setxkbmap dvorak
setxkbmap -option terminate:ctrl_alt_bksp
xmodmap ~/.Xmodmap
xset r 66 # Make the remapped capslock repeat

if [[ $(hostname) == tchaikovsky ]]; then
  xrandr --newmode "wide" 230.00  2560 2720 2992 3424  1080 1083 1093 1120 -hsync +vsync
  xrandr --addmode Virtual-1 wide
  xrandr --output Virtual-1 --mode wide
fi

# Set up the resources
xrdb ~/.Xresources -D$(hostname)

# redshift &

export LOCALE='en_US.UTF-8'


#exec i3 # -V >> ~/.i3/i3.log 2>&1
#exec gnome-session
exec xmonad

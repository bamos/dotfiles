#!/bin/sh

# Make ratpoison not display an "X" for the cursor
xsetroot -cursor_name left_ptr

# Set up the keyboard
setxkbmap dvorak
setxkbmap -option terminate:ctrl_alt_bksp
xmodmap ~/.Xmodmap
xset r 66 # Make the remapped capslock repeat

# Set up dual monitors, if connected
[[ `xrandr | grep -c "VGA1 connected"` == 1 ]] && \
  xrandr --output VGA1 --right-of LVDS1

# Set up the resources
xrdb ~/.Xresources

# Set up the touchpad
xinput --set-prop --type=int --format=32 \
    "SynPS/2 Synaptics TouchPad" "Synaptics Two-Finger Pressure" 4
xinput --set-prop --type=int --format=32 \
    "SynPS/2 Synaptics TouchPad" "Synaptics Two-Finger Width" 8
xinput --set-prop --type=int --format=8 \
    "SynPS/2 Synaptics TouchPad" "Synaptics Two-Finger Scrolling" 1 0

export LOCALE='en_US.UTF-8'

dunst &

exec i3 # -V >> ~/.i3/i3.log 2>&1
#exec enlightenment_start

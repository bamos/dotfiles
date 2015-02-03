#!/bin/bash

# Make ratpoison not display an "X" for the cursor
xsetroot -cursor_name left_ptr

# Set up the keyboard
setxkbmap dvorak
setxkbmap -option terminate:ctrl_alt_bksp
xmodmap ~/.Xmodmap
xset r 66 # Make the remapped capslock repeat

# Set up dual monitors, if connected.
if [[ $(hostname) == tchaikovsky ]]; then
  [[ `xrandr | grep -c "VGA1 connected"` == 1 ]] && \
    xrandr --output VGA1 --right-of LVDS1
  # Set up the touchpad
  xinput --set-prop --type=int --format=32 \
    "SynPS/2 Synaptics TouchPad" "Synaptics Two-Finger Pressure" 4
  xinput --set-prop --type=int --format=32 \
    "SynPS/2 Synaptics TouchPad" "Synaptics Two-Finger Width" 8
  xinput --set-prop --type=int --format=8 \
    "SynPS/2 Synaptics TouchPad" "Synaptics Two-Finger Scrolling" 1 0
elif [[ $(hostname) == derecho ]]; then
  xrandr --output VGA1 --right-of HDMI2
fi

# Set up the resources
xrdb ~/.Xresources -D$(hostname)


export LOCALE='en_US.UTF-8'

#exec i3 # -V >> ~/.i3/i3.log 2>&1
exec xmonad

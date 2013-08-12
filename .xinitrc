#!/bin/sh
#
# ~/.xinitrc
#
# Executed by startx

#if [ -d /etc/X11/xinit/xinitrc.d ]; then
#  for f in /etc/X11/xinit/xinitrc.d/*; do
#    [ -x "$f" ] && . "$f"
#  done
#  unset f
#fi

# Make ratpoison not display an "X" for the cursor
xsetroot -cursor_name left_ptr

# Set up the keyboard
setxkbmap dvorak

xmodmap ~/.Xmodmap
xset r 66 # Make the remapped capslock repeat
numlockx &

# Set up dual monitors, if connected
if [ `xrandr | grep -c "VGA1 connected"` == 1 ]; then
  xrandr --output VGA1 --right-of LVDS1
fi

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

#pkill redshift
#redshift -l 37.22311:-80.42105 -t 5500K:3000K &

#exec ck-launch-session gnome-session
#exec ck-launch-session gnome-session-cinnamon
#exec startxfce4
#exec ratpoison
#exec xmonad
#exec ck-launch-session startlxde
# exec dbus-launch i3
#exec i3 -V >> ~/.i3/i3log 2>&1
exec i3

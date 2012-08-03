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

xsetroot -cursor_name left_ptr

setxkbmap dvorak
xmodmap ~/.Xmodmap &
xset r 66 # Make the remapped capslock repeat

xrandr --output VGA1 --right-of LVDS1

xinput --set-prop --type=int --format=32 "SynPS/2 Synaptics TouchPad" "Synaptics Two-Finger Pressure" 4
xinput --set-prop --type=int --format=32 "SynPS/2 Synaptics TouchPad" "Synaptics Two-Finger Width" 8
xinput --set-prop --type=int --format=8  "SynPS/2 Synaptics TouchPad" "Synaptics Two-Finger Scrolling" 1 0

#exec ck-launch-session gnome-session
#exec ck-launch-session gnome-session-cinnamon
#exec startxfce4
#exec ratpoison
#exec xmonad
#exec ck-launch-session startlxde
exec ck-launch-session dbus-launch i3

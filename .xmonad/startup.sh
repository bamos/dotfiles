#!/bin/bash

export LOCALE='en_US.UTF-8'

xsetroot -cursor_name left_ptr -solid "#262626"

# Set all of this here as a hack to make it easier to
# automatically switch between monitors and keyboards/mice
xinput set-prop 'pointer:Logitech Wireless Mouse MX Master' \
       'libinput Natural Scrolling Enabled' 1
xinput set-prop 'pointer:ETPS/2 Elantech Touchpad' \
       'libinput Natural Scrolling Enabled' 1
xinput set-prop 'pointer:Magic Mouse 2' \
       'libinput Natural Scrolling Enabled' 1
xinput set-prop 'pointer:MX Master' \
       'libinput Natural Scrolling Enabled' 1

localectl set-x11-keymap us pc105 dvorak compose:ralt,caps:escape
setxkbmap dvorak -option compose:ralt
xmodmap ~/.Xmodmap
xset r 66 # Make the remapped capslock repeat

xrandr --auto
xrandr --output eDP-1 --mode 1280x720

pkill xmobar

if [[ $(xrandr | grep 'HDMI-2 connected') ]]; then
  # cvt 1920 810 60
  xrandr --newmode "1920x810_60.00"  127.50  1920 2024 2224 2528  810 813 823 841 -hsync +vsync
  xrandr --addmode HDMI-2 1920x810_60.00
  xrandr --output HDMI-2 --mode 1920x810_60.00
  xrandr --output HDMI-2 --left-of eDP-1
elif [[ $(xrandr | grep 'DP-1 connected.*673mm') ]]; then
  xrandr --newmode "1920x810_60.00"  127.50  1920 2024 2224 2528  810 813 823 841 -hsync +vsync
  xrandr --addmode DP-1 1920x810_60.00
  xrandr --output DP-1 --mode 1920x810_60.00
  xrandr --output DP-1 --left-of eDP-1
elif [[ $(xrandr | grep 'DP-1 connected.*697mm') ]]; then
  xrandr --output DP-1 --mode 1920x1080
  if [[ $(cat /proc/acpi/button/lid/LID/state | grep open) ]]; then
    xrandr --output DP-1 --left-of eDP-1
  else
    xrandr --output eDP-1 --same-as DP-1
    xmobar ~/.xmonad/xmobar.hs -x 1 &
  fi
elif [[ $(xrandr | grep 'DP-1 connected.*401mm') ]]; then
  xrandr --output DP-1 --mode 1920x1080
  if [[ $(cat /proc/acpi/button/lid/LID/state | grep open) ]]; then
    xrandr --output DP-1 --left-of eDP-1
  else
    xrandr --output eDP-1 --same-as DP-1
    xmobar ~/.xmonad/xmobar.hs -x 1 &
  fi
# elif [[ $(xrandr | grep 'DP-1 connected') ]]; then
#   xrandr --output DP-1 --mode 1280x800
#   xrandr --output eDP-1 --same-as DP-1
fi

# https://www.reddit.com/r/archlinux/comments/8n3iye
gamma=$(xrandr --verbose | grep Gamma | awk 'NR==1{print $2}')
if [[ $gamma == '1.0:1.0:1.0' ]]; then
    redshift &
fi

[[ $(pgrep xmobar) ]] || xmobar ~/.xmonad/xmobar.hs &

dropbox start

xrdb ~/.Xresources -D$(hostname)

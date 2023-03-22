#!/bin/bash

# bash ~/.config/polybar/launch.sh &
# conky -c ~/.config/qtile/scripts/conkyrc &
lxsession &
picom -b &
nm-applet &
volumeicon &
xsetroot -cursor_name left_ptr &
pamac-tray &
# blueberry-tray &
sxhkd -c ~/.config/qtile/scripts/sxhkdrc &
nitrogen --set-scaled --restore &
xidlehook --not-when-audio --not-when-fullscreen --timer 900 'systemctl suspend;i3lock -c 000000' '' &
# /usr/bin/emacs --daemon &

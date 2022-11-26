#!/bin/bash

# bash ~/.config/polybar/launch.sh &
conky -c ~/.config/qtile/scripts/conkyrc &
lxsession &
picom --experimental-backends -b &
nm-applet &
volumeicon &
xsetroot -cursor_name left_ptr &
pamac-tray &
# blueberry-tray &
sxhkd -c ~/.config/qtile/scripts/sxhkdrc &
nitrogen --set-scaled --restore &

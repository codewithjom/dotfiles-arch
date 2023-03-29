#!/bin/bash

lxsession &
picom -b &
nm-applet &
xsetroot -cursor_name left_ptr &
sxhkd -c ~/.config/i3/sxhkdrc &
nitrogen --set-zoom-fill $HOME/Downloads/wallpapers/0383.png &
xidlehook --not-when-audio --not-when-fullscreen --timer 900 'systemctl suspend;i3lock -c 000000' '' &

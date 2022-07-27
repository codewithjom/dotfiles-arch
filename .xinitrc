#!/bin/sh

# default arch init	scripts
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

lxsession &
picom --experimental-backends -b &
nm-applet &
volumeicon &
xsetroot -cursor_name left_ptr &
pamac-tray &
blueberry-tray &
# conky -c $HOME/.config/qtile/scripts/conkyrc &

# only choose 1 window manager
exec qtile start
# exec $HOME/.emacs.d/exwm/launch.sh

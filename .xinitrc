#!/bin/sh

# default arch init	scripts
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

# picom -b &
# xidlehook --not-when-audio --not-when-fullscreen --timer 900 'systemctl suspend;i3lock -c 000000' '' &
redshift-gtk &
sxhkd -c $HOME/.config/i3/sxhkdrc &

# only choose 1 window manager
# exec qtile start
exec i3
# startxfce4

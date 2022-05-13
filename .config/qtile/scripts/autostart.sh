#!/bin/bash

# conky -c $HOME/.config/qtile/scripts/conkyrc &
sxhkd -c ~/.config/qtile/scripts/sxhkdrc &
pamac-tray &
blueberry-tray &
nitrogen --set-scaled --restore &

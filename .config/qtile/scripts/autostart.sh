#!/bin/bash

conky -c $HOME/.config/qtile/scripts/conkyrc &
sxhkd -c ~/.config/qtile/scripts/sxhkdrc &
nitrogen --set-scaled --restore &

# -*- coding: utf-8 -*-
import os
import re
import socket
import subprocess
from datetime import datetime, timedelta
from time import time
from libqtile import qtile
from libqtile.config import Click, Drag, Group, KeyChord, Key, Match, Screen, ScratchPad, DropDown
from libqtile.command import lazy
from libqtile import layout, bar, widget, hook
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal, send_notification
from typing import List

mod = "mod4"  # Sets mod key to SUPER/WINDOWS
ctrl = "control"
ret = "Return"
s = "shift"
home = os.path.expanduser("~")

terminal = "alacritty"
browser1 = "qutebrowser"
# emacs = "emacsclient -c -a 'emacs' "
emacs = "emacs"
# editor = terminal + " -e nvim"
# editor = "emacsclient -c -a 'emacs' "
editor = "emacs"
file_manager = "pcmanfm"
screenshot = "scrot 'screenshot-%s.jpg' -e 'mv $f $$(xdg-user-dir PICTURES)'"

keys = [
    # APPLICATIONS
    Key([mod], "b", lazy.spawn(browser1)),
    Key([mod], "n", lazy.spawn(editor)),
    Key([mod, s], ret, lazy.spawn(emacs)),
    Key([mod], ret, lazy.spawn(terminal)),
    Key([mod, s], "f", lazy.spawn(file_manager)),
    Key([ctrl, s], ret, lazy.spawn(screenshot)),

    # ROFI
    Key([mod, s], "d", lazy.spawn("rofi -show drun")),

    # QTILE
    Key([mod], "x", lazy.shutdown()),  # LOGOUT
    Key([mod], "q", lazy.window.kill()),  # KILL WINDOW
    Key([mod, "shift"], "r", lazy.restart()),  # RESTART
    Key([mod], "Tab", lazy.next_layout()),  # CHANGE LAYOUTS

    # WINDOWS CONTROLS
    Key([mod], "j", lazy.layout.down()),
    Key([mod], "k", lazy.layout.up()),
    Key([mod, s], "j", lazy.layout.shuffle_down(), lazy.layout.section_down()),
    Key([mod, s], "k", lazy.layout.shuffle_up(), lazy.layout.section_up()),
    Key([mod], "l", lazy.layout.grow_right(), lazy.layout.grow(), lazy.layout.increase_ratio(), lazy.layout.delete()),
    Key([mod], "h", lazy.layout.grow_left(), lazy.layout.shrink(), lazy.layout.decrease_ratio(), lazy.layout.add()),
    Key([mod], "m", lazy.layout.maximize()),
    Key([mod], "f", lazy.window.toggle_floating()),
    Key([mod], "space", lazy.window.toggle_fullscreen()),

    # SWITCH KEYBOARD FOCUS (PROJECTOR/MONITOR)
    Key([mod], "w", lazy.to_screen(0)),
    Key([mod], "e", lazy.to_screen(1)),

    # SWITCH FOCUS (PROJECTOR/MONITOR)
    Key([mod], "period", lazy.next_screen()),
    Key([mod], "comma", lazy.prev_screen()),
]

groups = [
    Group("DEV", layout="monadtall"),
    Group("WEB", layout="monadtall", matches=[Match(wm_class=["Brave-browser","qutebrowser","Vimb","firefox","Brave-browser-dev", "Google-chrome"])]),
    Group("DOC", layout="monadtall", matches=[Match(wm_class=["DesktopEditors"])]),
    Group("SYS", layout="monadtall"),
    Group("VIR", layout="monadtall", matches=[Match(wm_class=["VirtualBox Manager", "Virt-manager"])]),
    Group("MSG", layout="monadtall", matches=[Match(wm_class=["discord", "Thunderbird"])]),
    Group("MUS", layout="monadtall", matches=[Match(wm_class=["Spotify"])]),
    Group("VID", layout="monadtall", matches=[Match(wm_class=["mpv"])]),
]

from libqtile.dgroups import simple_key_binder

dgroups_key_binder = simple_key_binder("mod4")

layout_theme = {
    "border_width": 1,
    "margin": 8,
    "border_focus": "839496",
    "border_normal": "0A0E14",
}

layouts = [
    layout.MonadTall(**layout_theme),
    layout.Max(**layout_theme),
    layout.Floating(**layout_theme),
    layout.Tile(**layout_theme),
]

groups.append(ScratchPad('scratchpad', [
    DropDown('term', terminal, width=0.6, height=0.7, x=0.2, y=0.2),
    DropDown('em', emacs, width=0.5, height=0.8, x=0.3, y=0.2),
]))
keys.extend([
    Key([mod], "w", lazy.group['scratchpad'].dropdown_toggle('term')),
    Key([mod], "e", lazy.group['scratchpad'].dropdown_toggle('em')),
])

colors = [
    ["#0A0E14", "#0A0E14"],  # 0 BG
    ["#01060E", "#686868"],  # 1 BLACK
    ["#B3B1AD", "#B3B1AD"],  # 2 FG
    ["#EA6C73", "#F07178"],  # 3 RED
    ["#91B362", "#C2D94C"],  # 4 GREEN
    ["#F9AF4F", "#FFB454"],  # 5 YELLOW
    ["#53BDFA", "#59C2FF"],  # 6 BLUE
    ["#FAE994", "#FFEE99"],  # 7 MAGENTA
    ["#90E1C6", "#95E6CB"],  # 8 CYAN
]

widget_defaults = dict(
    font="Agave Nerd Font",
    fontsize=12,
    padding=2,
    background=colors[0])

extension_defaults = widget_defaults.copy()


def init_widgets_list():
    widgets_list = [
        widget.GroupBox(
            # font="Agave Nerd Font",
            fontsize=10,
            margin_y=4,
            margin_x=0,
            padding_y=5,
            padding_x=3,
            borderwidth=2,
            active='ffffff',
            inactive='85877C',
            rounded=False,
            highlight_color=colors[0],
            highlight_method="text",
            this_current_screen_border=colors[8],
            this_screen_border=colors[4],
            other_current_screen_border=colors[1],
            other_screen_border=colors[4],
            foreground=colors[2],
            background=colors[0],
        ),
        widget.TextBox(
            text="|",
            font="Ubuntu Mono",
            background=colors[0],
            foreground="474747",
            padding=2,
            fontsize=12,
        ),
        widget.CurrentLayout(
            foreground=colors[2],
            background=colors[0],
            padding=5
        ),
        widget.TextBox(
            text="|",
            font="Ubuntu Mono",
            background=colors[0],
            foreground="474747",
            padding=2,
            fontsize=12,
        ),
        widget.WindowCount(
            text_format="{num}",
            show_zero=True,
            padding=2,
            foreground=colors[6],
            background=colors[0]
        ),
        widget.TextBox(
            text="|",
            font="Ubuntu Mono",
            background=colors[0],
            foreground="474747",
            padding=2,
            fontsize=12,
        ),
        widget.WindowName(
            foreground=colors[2],
            background=colors[0],
            max_chars=40,
            padding=0
        ),
        widget.Sep(
            linewidth=0,
            padding=6,
            foreground=colors[0],
            background=colors[0]
        ),
        widget.TextBox(
            text="|",
            font="Ubuntu Mono",
            background=colors[0],
            foreground="474747",
            padding=2,
            fontsize=12,
        ),
        widget.Sep(
            linewidth=0,
            padding=6,
            foreground=colors[0],
            background=colors[0]
        ),
        widget.TextBox(
            text="",
            font="VictorMono Nerd Font",
            background=colors[0],
            foreground=colors[6],
            padding=3,
            fontsize=16,
        ),
        widget.CheckUpdates(
            update_interval=1800,
            distro="Arch_checkupdates",
            display_format="{updates}",
            foreground=colors[0],
            colour_have_updates=colors[6],
            colour_no_updates=colors[6],
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn(terminal + " -e sudo pacman -Syu")},
            padding=5,
            background=colors[0],
        ),
        widget.TextBox(
            text="|",
            font="Ubuntu Mono",
            background=colors[0],
            foreground="474747",
            padding=2,
            fontsize=12,
        ),
        widget.Pomodoro(
            color_active=colors[4],
            color_break=colors[5],
            color_inactive=colors[2],
            length_long_break=10,
            length_pomodori=50,
            notification_on=True,
            num_pomodori=1,
            prefix_active='stadi ',
            prefix_long_break='BREAK ',
            update_interval=1
        ),
        widget.TextBox(
            text="|",
            font="Ubuntu Mono",
            background=colors[0],
            foreground="474747",
            padding=2,
            fontsize=12,
        ),
        widget.TextBox(
            text="",
            font="VictorMono Nerd Font",
            background=colors[0],
            foreground=colors[2],
            padding=2,
            fontsize=16,
        ),
        widget.DF(
            format="{uf}{m}B",
            visible_on_warn=False,
            foreground=colors[2],
            background=colors[0],
        ),
        widget.TextBox(
            text="|",
            font="Ubuntu Mono",
            background=colors[0],
            foreground="474747",
            padding=2,
            fontsize=12,
        ),
        widget.TextBox(
            text="",
            font="VictorMono Nerd Font",
            background=colors[0],
            foreground=colors[8],
            padding=2,
            fontsize=26,
        ),
        widget.Battery(
            format="{percent:2.0%}",
            show_short_text=False,
            update_interval=50,
            padding=5,
            foreground=colors[8],
            background=colors[0],
        ),
        widget.TextBox(
            text="|",
            font="Ubuntu Mono",
            background=colors[0],
            foreground="474747",
            padding=2,
            fontsize=12,
        ),
        widget.TextBox(
            text="",
            font="VictorMono Nerd Font",
            background=colors[0],
            foreground=colors[2],
            padding=5,
            fontsize=16,
        ),
        widget.Clock(
            foreground=colors[2],
            background=colors[0],
            format="%a, %B %d - %I:%M %p"
        ),
        widget.Sep(
            linewidth=0,
            padding=5,
            foreground=colors[0],
            background=colors[0]
        ),
        widget.Systray(
            background=colors[0],
            icon_size=14,
            padding=4
        ),
    ]
    return widgets_list


def init_widgets_screen1():
    widgets_screen1 = init_widgets_list()
    del widgets_screen1[9:10]
    return widgets_screen1


def init_widgets_screen2():
    widgets_screen2 = init_widgets_list()
    return widgets_screen2


def init_screens():
    return [
        # Screen(),
        # Remove the comments below if you want to use the built-in status bar of qtile
        Screen(bottom=bar.Bar(widgets=init_widgets_screen1(), opacity=0.8, size=24)),
        Screen(bottom=bar.Bar(widgets=init_widgets_screen2(), opacity=0.8, size=30)),
    ]


if __name__ in ["config", "__main__"]:
    screens = init_screens()
    widgets_list = init_widgets_list()
    widgets_screen1 = init_widgets_screen1()
    widgets_screen2 = init_widgets_screen2()


def window_to_prev_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i - 1].name)


def window_to_next_group(qtile):
    if qtile.currentWindow is not None:
        i = qtile.groups.index(qtile.currentGroup)
        qtile.currentWindow.togroup(qtile.groups[i + 1].name)


def window_to_previous_screen(qtile):
    i = qtile.screens.index(qtile.current_screen)
    if i != 0:
        group = qtile.screens[i - 1].group.name
        qtile.current_window.togroup(group)


def window_to_next_screen(qtile):
    i = qtile.screens.index(qtile.current_screen)
    if i + 1 != len(qtile.screens):
        group = qtile.screens[i + 1].group.name
        qtile.current_window.togroup(group)


def switch_screens(qtile):
    i = qtile.screens.index(qtile.current_screen)
    group = qtile.screens[i - 1].group
    qtile.current_screen.set_group(group)


mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_app_rules = []  # type: List
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False

floating_types = ["notification", "toolbar", "splash", "dialog"]
floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(title="Confirmation"),
        Match(wm_class="confirm"),
        Match(wm_class="dialog"),
        Match(wm_class="download"),
        Match(wm_class="error"),
        Match(wm_class="file_progress"),
        Match(wm_class="notification"),
        Match(wm_class="splash"),
        Match(wm_class="toolbar"),
        Match(wm_class="Arandr"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="ssh-askpass"),
        Match(title="branchdialog"),
        Match(title="pinentry"),
        Match(wm_class="pinentry-gtk-2"),
    ], fullscreen_border_width = 0, border_width = 0
)

auto_fullscreen = False
focus_on_window_activation = "focus"
reconfigure_screens = True
auto_minimize = True


@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser("~")
    subprocess.call([home + "/.config/qtile/scripts/autostart.sh"])


wmname = "LG3D"

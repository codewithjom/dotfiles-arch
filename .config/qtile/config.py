# -*- coding: utf-8 -*-
import os
import re
import socket
import subprocess
from libqtile import qtile
from libqtile.config import Click, Drag, Group, KeyChord, Key, Match, Screen
from libqtile.command import lazy
from libqtile import layout, bar, widget, hook
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
from typing import List

mod = "mod4"  # Sets mod key to SUPER/WINDOWS
ctrl = "control"
ret = "Return"
s = "shift"
home = os.path.expanduser("~")

terminal = "alacritty"
browser1 = "qutebrowser"
emacs = "emacs"
editor = terminal + " -e nvim"
file_manager = "pcmanfm"
screenshot = "scrot 'screenshot-%s.jpg' -e 'mv $f $$(xdg-user-dir PICTURES)'"

keys = [
    # APPLICATIONS
    Key([mod], "b", lazy.spawn(browser1)),
    Key([mod], "n", lazy.spawn(editor)),
    Key([mod, s], ret, lazy.spawn(emacs)),
    Key([mod], ret, lazy.spawn(terminal)),
    Key([mod, s], "f", lazy.spawn(file_manager)),
    Key([ctrl], ret, lazy.spawn(screenshot)),

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
    Group("WEB", layout="monadtall", matches=[Match(wm_class=["Brave-browser","qutebrowser","Vimb","firefox",])]),
    Group("SYS", layout="monadtall", matches=[Match(wm_class=["jetbrains-idea-ce", "Subl", "jetbrains-studio"])]),
    Group("DOC", layout="monadtall", matches=[Match(wm_class=["DesktopEditors"])]),
    Group("VIR", layout="monadtall", matches=[Match(wm_class=["VirtualBox Manager", "Virt-manager"])]),
    Group("MSG", layout="monadtall", matches=[Match(wm_class=["discord", "Thunderbird"])]),
    Group("MUS", layout="monadtall", matches=[Match(wm_class=["Spotify"])]),
    Group("VID", layout="monadtall", matches=[Match(wm_class=["mpv"])]),
]

from libqtile.dgroups import simple_key_binder

dgroups_key_binder = simple_key_binder("mod4")

layout_theme = {
    "border_width": 2,
    "margin": 20,
    "border_focus": "2aa198",
    "border_normal": "001b26",
}

layouts = [
    layout.MonadTall(**layout_theme),
    layout.Max(**layout_theme),
    layout.Floating(**layout_theme),
]

colors = [
    ["#001b26", "#001b26"],  # 0 BG
    ["#073642", "#001b26"],  # 1 BLACK
    ["#839496", "#839496"],  # 2 FG
    ["#dc322f", "#cb4b16"],  # 3 RED
    ["#859900", "#586e75"],  # 4 GREEN
    ["#b58900", "#657b83"],  # 5 YELLOW
    ["#268bd2", "#839496"],  # 6 BLUE
    ["#d33682", "#6c71c4"],  # 7 MAGENTA
    ["#2aa198", "#93a1a1"],  # 8 CYAN
]

widget_defaults = dict(
    font="Ubuntu Bold",
    fontsize=10,
    padding=2,
    background=colors[0])

extension_defaults = widget_defaults.copy()


def init_widgets_list():
    widgets_list = [
        widget.GroupBox(
            font="Ubuntu Bold",
            fontsize=9,
            margin_y=4,
            margin_x=0,
            padding_y=5,
            padding_x=3,
            borderwidth=2,
            active=colors[2],
            inactive=colors[7],
            rounded=False,
            highlight_color=colors[0],
            highlight_method="line",
            this_current_screen_border=colors[6],
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
            foreground=colors[6],
            background=colors[0],
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
            text="",
            font="VictorMono Nerd Font",
            background=colors[0],
            foreground=colors[4],
            padding=2,
            fontsize=12,
        ),
        widget.ThermalSensor(
            foreground=colors[4],
            background=colors[0],
            threshold=90,
            fmt="{}",
            padding=5,
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
            text="",
            font="VictorMono Nerd Font",
            background=colors[0],
            foreground=colors[6],
            padding=3,
            fontsize=12,
        ),
        widget.CheckUpdates(
            update_interval=1800,
            distro="Arch_checkupdates",
            display_format="Updates: {updates}",
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
        widget.TextBox(
            text="",
            font="VictorMono Nerd Font",
            background=colors[0],
            foreground=colors[7],
            padding=3,
            fontsize=12,
        ),
        widget.Memory(
            foreground=colors[7],
            background=colors[0],
            mouse_callbacks={"Button1": lambda: qtile.cmd_spawn(terminal + " -e htop")},
            fmt="Mem: {}",
            padding=5,
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
            text="",
            font="VictorMono Nerd Font",
            background=colors[0],
            foreground=colors[5],
            padding=2,
            fontsize=12,
        ),
        widget.Battery(
            format="batt: {percent:2.0%}",
            show_short_text=False,
            update_interval=50,
            padding=5,
            foreground=colors[5],
            background=colors[0],
        ),
        # widget.TextBox(
        #     text = '|',
        #     font = "Ubuntu Mono",
        #     background = colors[0],
        #     foreground = '474747',
        #     padding = 2,
        #     fontsize = 14
        # ),
        # widget.TextBox(
        #     text = '蓼',
        #     font = "VictorMono Nerd Font",
        #     background = colors[0],
        #     foreground = colors[4],
        #     padding = 2,
        #     fontsize = 14
        # ),
        # widget.Volume(
        #     foreground = colors[4],
        #     background = colors[0],
        #     fmt = 'Vol: {}',
        #     padding = 5
        # ),
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
            fontsize=12,
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
            icon_size=20,
            padding=1
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
        # Remove the comments below if you want to use the built-in status bar of qitle
        Screen(top=bar.Bar(widgets=init_widgets_screen1(), opacity=1.0, size=24)),
        Screen(top=bar.Bar(widgets=init_widgets_screen2(), opacity=1.0, size=24)),
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
follow_mouse_focus = False
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
    ]
)

auto_fullscreen = True
focus_on_window_activation = "focus"
reconfigure_screens = True
auto_minimize = True


@hook.subscribe.startup_once
def start_once():
    home = os.path.expanduser("~")
    subprocess.call([home + "/.config/qtile/scripts/autostart.sh"])


wmname = "LG3D"

#!/bin/sh

# Enables dmenu on i3wm with sudo
# bindsym $mod+Shift+d exec "SUDO_ASKPASS=~/scripts/dpass.sh sudo -A $(dmenu_path | dmenu)"

# shellcheck disable=2046
caller="$(ps -o comm= -p $(ps -o ppid= -p $$))"
prompt="${1:-[$caller]}"
promptfg=white promptbg=firebrick hidden=white
font="Ubuntu Mono-12"

dmenu -p "$prompt" -fn "$font" \
  -nf "$hidden" -nb "$hidden" -sf "$promptfg" -sb "$promptbg" <&-

#!/bin/bash

herbstclient keyunbind --all

normalMode="$HOME/.config/herbstluftwm/keybindings.sh"

herbstclient keybind t chain , spawn notify-send "$(date)" , spawn sh "$normalMode"

herbstclient keybind Escape spawn bash "$normalMode"



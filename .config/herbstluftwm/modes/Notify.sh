#!/bin/bash

herbstclient keyunbind --all

normalMode="$HOME/.config/herbstluftwm/keybindings.sh"

herbstclient keybind t chain , spawn "$HOME/.bin/notify_script" "-s" "$HOME/.bin/getdate" , spawn sh "$normalMode"
herbstclient keybind c chain , spawn "$HOME/.bin/notify_script" "-s" "$HOME/.bin/getcal" , spawn sh "$normalMode"

herbstclient keybind Escape spawn bash "$normalMode"



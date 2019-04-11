#!/bin/bash

herbstclient keyunbind --all

normalMode="$HOME/.config/herbstluftwm/keybindings.sh"

herbstclient keybind q chain , spawn "$HOME/.bin/notify" "-e" "$HOME/.bin/getinfo"           , spawn sh "$normalMode"
herbstclient keybind c chain , spawn "$HOME/.bin/notify" "-e" "$HOME/.bin/getcal"            , spawn sh "$normalMode"
herbstclient keybind n chain , spawn "$HOME/.bin/notify" "-e" "$HOME/.bin/getmpdstatus 6600" , spawn sh "$normalMode"
herbstclient keybind m chain , spawn "$HOME/.bin/notify" "-e" "$HOME/.bin/getmpdstatus 6601" , spawn sh "$normalMode"
herbstclient keybind b chain , spawn "$HOME/.bin/notify" "-e" "fortune dhammapada"           , spawn sh "$normalMode"

herbstclient keybind Escape spawn bash "$normalMode"



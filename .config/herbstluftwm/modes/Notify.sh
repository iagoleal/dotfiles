#!/bin/bash

herbstclient keyunbind --all

normalMode="$HOME/.config/herbstluftwm/keybindings.sh"

herbstclient keybind q chain , spawn "$HOME/.bin/notify" "-s" "$HOME/.bin/getinfo" , spawn sh "$normalMode"
herbstclient keybind t chain , spawn "$HOME/.bin/notify" "-s" "$HOME/.bin/getdate" , spawn sh "$normalMode"
herbstclient keybind c chain , spawn "$HOME/.bin/notify" "-s" "$HOME/.bin/getcal" , spawn sh "$normalMode"
herbstclient keybind m chain , spawn "$HOME/.bin/notify" "-s" "$HOME/.bin/getmpdstatus 6600" , spawn sh "$normalMode"
herbstclient keybind y chain , spawn "$HOME/.bin/notify" "-s" "$HOME/.bin/getmpdstatus 6601" , spawn sh "$normalMode"

herbstclient keybind Escape spawn bash "$normalMode"



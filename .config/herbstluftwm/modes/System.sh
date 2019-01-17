#!/bin/bash

herbstclient keyunbind --all

normalMode="$HOME/.config/herbstluftwm/keybindings.sh"


herbstclient keybind 1 chain , spawn "$HOME/.bin/system" "lock"      \
                             , spawn sh "$normalMode"
herbstclient keybind 2 chain , spawn "$HOME/.bin/system" "suspend"
                             , spawn sh "$normalMode"
herbstclient keybind 3 chain , spawn "$HOME/.bin/system" "logout"
                             , spawn sh "$normalMode"
herbstclient keybind 4 chain , spawn "$HOME/.bin/system" "hibernate"
                             , spawn sh "$normalMode"
herbstclient keybind 5 chain , spawn "$HOME/.bin/system" "reboot"
                             , spawn sh "$normalMode"
herbstclient keybind 6 chain , spawn "$HOME/.bin/system" "poweroff"
                             , spawn sh "$normalMode"

herbstclient keybind Escape spawn bash "$normalMode"

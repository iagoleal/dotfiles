#!/bin/bash

herbstclient keyunbind --all

normalMode="$HOME/.config/herbstluftwm/keybindings.sh"


herbstclient keybind 1 chain , spawn sh "$normalMode" \
                             , spawn "$HOME/.bin/system" "lock"
herbstclient keybind 2 chain , spawn sh "$normalMode" \
                             , spawn "$HOME/.bin/system" "suspend"
herbstclient keybind 3 chain , spawn sh "$normalMode" \
                             , spawn "$HOME/.bin/system" "logout"
herbstclient keybind 4 chain , spawn sh "$normalMode" \
                             , spawn "$HOME/.bin/system" "reboot"
herbstclient keybind 5 chain , spawn sh "$normalMode" \
                             , spawn "$HOME/.bin/system" "hibernate"
herbstclient keybind 6 chain , spawn sh "$normalMode" \
                             , spawn "$HOME/.bin/system" "poweroff"

herbstclient keybind Escape spawn bash "$normalMode"

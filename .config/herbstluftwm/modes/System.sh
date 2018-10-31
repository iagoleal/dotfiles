#!/bin/bash

herbstclient keyunbind --all

normalMode="$HOME/.config/herbstluftwm/keybindings.sh"


herbstclient keybind 1 chain , spawn i3lock -c '#000000'                        , spawn sh "$normalMode"
herbstclient keybind 2 chain , spawn i3lock -c '#000000' && systemctl suspend   , spawn sh "$normalMode"
herbstclient keybind 3 chain , quit                                             , spawn sh "$normalMode"
herbstclient keybind 4 chain , spawn i3lock -c '#000000' && systemctl hibernate , spawn sh "$normalMode"
herbstclient keybind 5 chain , spawn systemctl reboot                           , spawn sh "$normalMode"
herbstclient keybind 6 chain , spawn systemctl poweroff -i                      , spawn sh "$normalMode"

herbstclient keybind Escape spawn bash "$normalMode"


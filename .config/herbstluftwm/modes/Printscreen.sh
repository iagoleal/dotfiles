#!/bin/sh

herbstclient keyunbind --all

normalMode="$HOME/.config/herbstluftwm/keybindings.sh"
screenshotsFolder="$HOME/Pictures/Screenshots"

herbstclient keybind Print   chain , spawn "$HOME/.bin/printscreen"       , spawn sh "$normalMode"

herbstclient keybind f       chain , spawn "$HOME/.bin/printscreen"       , spawn sh "$normalMode"
herbstclient keybind Shift+f chain , spawn "$HOME/.bin/printscreen" "-w"  , spawn sh "$normalMode"
herbstclient keybind c       chain , spawn "$HOME/.bin/printscreen" "-c"  , spawn sh "$normalMode"
herbstclient keybind Shift+c chain , spawn "$HOME/.bin/printscreen" "-cw" , spawn sh "$normalMode"

herbstclient keybind Escape spawn sh "$normalMode"


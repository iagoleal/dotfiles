#!/bin/bash

herbstclient keyunbind --all

normalMode="$HOME/.config/herbstluftwm/keybindings.sh"
screenshotsFolder="$HOME/Pictures/Screenshots"

herbstclient keybind Print   chain , spawn import -window root "$screenshotsFolder/$(date +%Y-%m-%d_%H:%M:%S).png" , spawn sh "$normalMode"

herbstclient keybind f       chain , spawn import -window root "$screenshotsFolder/$(date +%Y-%m-%d_%H:%M:%S).png" , spawn sh "$normalMode"
herbstclient keybind Shift+f chain , spawn import -window root  png:- | xclip -selection c -t image/png           , spawn sh "$normalMode" 
herbstclient keybind c       chain , spawn import "$screenshotsFolder/$(date +%Y-%m-%d_%H:%M:%S)_cropped.png"      , spawn sh "$normalMode"
herbstclient keybind Shift+c chain , spawn import png:- | xclip -selection c -t image/png                         , spawn sh "$normalMode"

herbstclient keybind Escape spawn bash "$normalMode"


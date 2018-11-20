#!/bin/bash

herbstclient keyunbind --all

normalMode="$HOME/.config/herbstluftwm/keybindings.sh"

herbstclient keybind m chain , spawn termite -e ncmpcpp           , spawn sh "$normalMode"
herbstclient keybind s chain , spawn termite -e "ncmpcpp -p 6601" , spawn sh "$normalMode"
herbstclient keybind h chain , spawn termite -e htop              , spawn sh "$normalMode"
herbstclient keybind w chain , spawn wicd-client                  , spawn sh "$normalMode"
herbstclient keybind f chain , spawn firefox                      , spawn sh "$normalMode"
herbstclient keybind q chain , spawn qutebrowser                  , spawn sh "$normalMode"
herbstclient keybind p chain , spawn zathura                      , spawn sh "$normalMode"
herbstclient keybind t chain , spawn transmission-gtk             , spawn sh "$normalMode"
herbstclient keybind a chain , spawn anki                         , spawn sh "$normalMode"
herbstclient keybind e chain , spawn pcmanfm                      , spawn sh "$normalMode"

herbstclient keybind Mod4-Return chain , spawn termite , spawn sh "$normalMode"

herbstclient keybind Escape spawn bash "$normalMode"



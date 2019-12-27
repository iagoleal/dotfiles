#!/bin/bash
herbstclient keyunbind --all

normalMode="$HOME/.config/herbstluftwm/keybindings.sh"
exec_on_tag="$HOME/.config/herbstluftwm/scripts/exec_on_tag"
TERMINAL=st

# Exit mod e
herbstclient keybind Escape spawn sh "$normalMode"

# Bind the normal keys
herbstclient keybind w           chain , spawn networkmanager_dmenu                 , spawn sh "$normalMode"
herbstclient keybind e           chain , spawn pcmanfm                              , spawn sh "$normalMode"
herbstclient keybind t           chain , spawn transmission-gtk                     , spawn sh "$normalMode"
herbstclient keybind p           chain , spawn zathura                              , spawn sh "$normalMode"
herbstclient keybind a           chain , spawn anki                                 , spawn sh "$normalMode"
herbstclient keybind s           chain , spawn spotify                              , spawn sh "$normalMode"
herbstclient keybind f           chain , spawn firefox                              , spawn sh "$normalMode"
herbstclient keybind h           chain , spawn "${TERMINAL}" '-e' 'htop'            , spawn sh "$normalMode"
herbstclient keybind n           chain , spawn "${TERMINAL}" '-e' 'ncmpcpp'         , spawn sh "$normalMode"
herbstclient keybind m           chain , spawn "${TERMINAL}" '-e' 'ncmpcpp -p 6601' , spawn sh "$normalMode"
herbstclient keybind Return      chain , spawn "${TERMINAL}"                        , spawn sh "$normalMode"
herbstclient keybind Mod4-Return chain , spawn "${TERMINAL}"                        , spawn sh "$normalMode"

# If you press a number key, the application will be spawned on given workspace
tag_names=( {1..10} )
tag_keys=( {1..9} 0 )

for i in ${!tag_names[@]}; do
    herbstclient keybind "${tag_keys[$i]}" chain \
        '->' keybind w      chain , spawn "$exec_on_tag" "${tag_names[$i]}" wicd-client                        , spawn sh "$normalMode" \
        '->' keybind e      chain , spawn "$exec_on_tag" "${tag_names[$i]}" pcmanfm                            , spawn sh "$normalMode" \
        '->' keybind t      chain , spawn "$exec_on_tag" "${tag_names[$i]}" transmission-gtk                   , spawn sh "$normalMode" \
        '->' keybind p      chain , spawn "$exec_on_tag" "${tag_names[$i]}" zathura                            , spawn sh "$normalMode" \
        '->' keybind a      chain , spawn "$exec_on_tag" "${tag_names[$i]}" anki                               , spawn sh "$normalMode" \
        '->' keybind s      chain , spawn "$exec_on_tag" "${tag_names[$i]}" spotify                            , spawn sh "$normalMode" \
        '->' keybind f      chain , spawn "$exec_on_tag" "${tag_names[$i]}" firefox                            , spawn sh "$normalMode" \
        '->' keybind h      chain , spawn "$exec_on_tag" "${tag_names[$i]}" "${TERMINAL}" -e htop              , spawn sh "$normalMode" \
        '->' keybind n      chain , spawn "$exec_on_tag" "${tag_names[$i]}" "${TERMINAL}" -e ncmpcpp           , spawn sh "$normalMode" \
        '->' keybind m      chain , spawn "$exec_on_tag" "${tag_names[$i]}" "${TERMINAL}" -e 'ncmpcpp -p 6601' , spawn sh "$normalMode" \
        '->' keybind Return chain , spawn "$exec_on_tag" "${tag_names[$i]}" "${TERMINAL}"                      , spawn sh "$normalMode"
done

#!/bin/bash
herbstclient keyunbind --all

normalMode="$HOME/.config/herbstluftwm/keybindings.sh"
exec_on_tag="$HOME/.config/herbstluftwm/scripts/exec_on_tag"
TERMINAL='xterm -uc'


# Exit mod e
herbstclient keybind Escape spawn sh "$normalMode"

# Bind the normal keys
herbstclient keybind e           chain , spawn "$exec_on_tag" "" pcmanfm            , spawn sh "$normalMode"
herbstclient keybind i           chain , spawn "$exec_on_tag" "" inkscape           , spawn sh "$normalMode"
herbstclient keybind p           chain , spawn "$exec_on_tag" "" pavucontrol        , spawn sh "$normalMode"
herbstclient keybind a           chain , spawn "$exec_on_tag" "" anki               , spawn sh "$normalMode"
herbstclient keybind f           chain , spawn "$exec_on_tag" "" firefox            , spawn sh "$normalMode"
herbstclient keybind g           chain , spawn "$exec_on_tag" "" gimp               , spawn sh "$normalMode"
herbstclient keybind h           chain , spawn "$exec_on_tag" "" $TERMINAL -e htop  , spawn sh "$normalMode"
herbstclient keybind n           chain , spawn "$exec_on_tag" "" $TERMINAL -e nmtui , spawn sh "$normalMode"
herbstclient keybind Return      chain , spawn "$exec_on_tag" "" $TERMINAL          , spawn sh "$normalMode"
herbstclient keybind Mod4-Return chain , spawn "$exec_on_tag" "" $TERMINAL          , spawn sh "$normalMode"

# If you press a number key, the application will be spawned on given workspace
tag_names=( {1..10} )
tag_keys=( {1..9} 0 )

for i in ${!tag_names[@]}; do
    herbstclient keybind "${tag_keys[$i]}" chain \
        '->' keybind e      chain , spawn "$exec_on_tag" "${tag_names[$i]}" pcmanfm            , spawn sh "$normalMode" \
        '->' keybind i      chain , spawn "$exec_on_tag" "${tag_names[$i]}" inkspace           , spawn sh "$normalMode" \
        '->' keybind p      chain , spawn "$exec_on_tag" "${tag_names[$i]}" pavucontrol        , spawn sh "$normalMode"
        '->' keybind a      chain , spawn "$exec_on_tag" "${tag_names[$i]}" anki               , spawn sh "$normalMode" \
        '->' keybind s      chain , spawn "$exec_on_tag" "${tag_names[$i]}" spotify            , spawn sh "$normalMode" \
        '->' keybind f      chain , spawn "$exec_on_tag" "${tag_names[$i]}" firefox            , spawn sh "$normalMode" \
        '->' keybind g      chain , spawn "$exec_on_tag" "${tag_names[$i]}" gimp               , spawn sh "$normalMode" \
        '->' keybind h      chain , spawn "$exec_on_tag" "${tag_names[$i]}" $TERMINAL -e htop  , spawn sh "$normalMode" \
        '->' keybind n      chain , spawn "$exec_on_tag" "${tag_names[$i]}" $TERMINAL -e nmtui , spawn sh "$normalMode" \
        '->' keybind Return chain , spawn "$exec_on_tag" "${tag_names[$i]}" $TERMINAL          , spawn sh "$normalMode"
done

#!/bin/bash

herbstclient keyunbind --all

normalMode="$HOME/.config/herbstluftwm/keybindings.sh"

herbstclient keybind Escape spawn bash "$normalMode"

get_window_gap () { 
    echo -n 'echo $(herbstclient get window_gap)' | sh
}
get_frame_gap () { 
    echo  ' echo $(herbstclient get frame_gap)' | sh
}

herbstclient keybind q spawn notify-send $(get_window_gap)


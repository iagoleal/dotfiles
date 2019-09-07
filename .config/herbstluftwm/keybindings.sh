#!/bin/sh

# Folder with scripts to other modes
config_folder="${HOME}/.config/herbstluftwm"
modes_folder="${HOME}/.config/herbstluftwm/modes"

# Keybindings
Super=Mod4    # Use the super key as the main modifier
Alt=Mod1    # Use Alt key when necessary

# At start unbinding all keys
herbstclient keyunbind --all

#System-wide important stuff
herbstclient keybind $Super-Shift-r reload
herbstclient keybind $Super-Shift-q close

# Main spawn shortcuts
herbstclient keybind $Super-Return           spawn termite
herbstclient keybind $Super-Shift-dead_greek spawn termite -e htop

herbstclient keybind $Super-Shift-d          spawn rofi -show drun
herbstclient keybind $Super-Shift-w          spawn rofi -show window
herbstclient keybind $Super-m                spawn "$HOME/.bin/rofi-playsimilar"
herbstclient keybind $Super-XF86AudioPlay    spawn "$HOME/.bin/rofi-chooseplayer"
herbstclient keybind $Super-b                spawn "$HOME/.bin/dmenu-bookfinder"

# Notifications
herbstclient keybind $Super-q       spawn "$HOME/.bin/notify" "-e" "$HOME/.bin/getinfo"
herbstclient keybind $Super-w       spawn "$HOME/.bin/notify" "-e" "$HOME/.bin/hlwm-tags"

# Change mode
herbstclient keybind $Super-Shift-e spawn sh "${modes_folder}/System.sh"
herbstclient keybind $Super-d       spawn sh "${modes_folder}/Launcher.sh"
herbstclient keybind Print          spawn sh "${modes_folder}/Printscreen.sh"
herbstclient keybind $Super-n       spawn sh "${modes_folder}/Notify.sh"

# Bind Media Keys

# increase/decrease/mute sound volume
herbstclient keybind XF86AudioRaiseVolume spawn "$HOME/.bin/volctl" "raise"
herbstclient keybind XF86AudioLowerVolume spawn "$HOME/.bin/volctl" "lower"
herbstclient keybind XF86AudioMute        spawn "$HOME/.bin/volctl" "mute"

# Media player controls
herbstclient keybind XF86AudioPlay spawn "$HOME/.bin/musicctl" "-p" "$(cat $HOME/.local/share/hists/player)" "toggle"
herbstclient keybind XF86AudioStop spawn "$HOME/.bin/musicctl" "-p" "$(cat $HOME/.local/share/hists/player)" "stop"
herbstclient keybind XF86AudioPrev spawn "$HOME/.bin/musicctl" "-p" "$(cat $HOME/.local/share/hists/player)" "prev"
herbstclient keybind XF86AudioNext spawn "$HOME/.bin/musicctl" "-p" "$(cat $HOME/.local/share/hists/player)" "next"

# Toggle touchpad
herbstclient keybind $Super-F6 spawn $HOME/.bin/toggle-touchpad.sh

# Basic movement
# focusing clients
herbstclient keybind $Super-h     focus left
herbstclient keybind $Super-j     focus down
herbstclient keybind $Super-k     focus up
herbstclient keybind $Super-l     focus right

# moving clients on same tag
herbstclient keybind $Super-Shift-h     shift left
herbstclient keybind $Super-Shift-j     shift down
herbstclient keybind $Super-Shift-k     shift up
herbstclient keybind $Super-Shift-l     shift right

# resizing frames
resizestep=0.05
herbstclient keybind $Super-$Alt-h       resize left +$resizestep
herbstclient keybind $Super-$Alt-j       resize down +$resizestep
herbstclient keybind $Super-$Alt-k       resize up +$resizestep
herbstclient keybind $Super-$Alt-l       resize right +$resizestep

# Screen split
herbstclient keybind $Super-Control-h       split   left    0.5
herbstclient keybind $Super-Control-j       split   bottom  0.5
herbstclient keybind $Super-Control-k       split   top     0.5
herbstclient keybind $Super-Control-l       split   right   0.5

herbstclient keybind $Super-e         split   explode
herbstclient keybind $Super-r         remove

# create an empty frame at the specified direction
# herbstclient keybind $Super-u         split   bottom  0.5
# herbstclient keybind $Super-o         split   right   0.5

herbstclient keybind $Super-Left      split   left    0.5
herbstclient keybind $Super-Down      split   bottom  0.5
herbstclient keybind $Super-Up        split   top     0.5
herbstclient keybind $Super-Right     split   right   0.5

## Tags
# get tag names from client
tags_raw="$(herbstclient tag_status | sed 's/\t//g')"
# tags_raw="${tags_raw#?}"
IFS='[.:#]' read -r -a tag_names <<< "${tags_raw#?}"
tag_keys=( {1..9} 0 )

for i in ${!tag_names[@]} ; do
    key="${tag_keys[$i]}"
    if ! [ -z "$key" ] ; then
        # Go to tag i
        herbstclient keybind "$Super-$key" use_index "$i"
        # Move focused window to tag i
        herbstclient keybind "$Super-$Alt-$key" move_index "$i"
        # Move focused window and go to tag i
        herbstclient keybind "$Super-Shift-$key" chain , move_index "$i" , use_index "$i"
    fi
done

# Cycle through tags
herbstclient keybind $Super-period  use_index +1 --skip-visible
herbstclient keybind $Super-comma   use_index -1 --skip-visible

# layouting
herbstclient keybind $Super-Shift-f floating toggle
herbstclient keybind $Super-f       fullscreen toggle
herbstclient keybind $Super-p       pseudotile toggle
# The following cycles through the available layouts within a frame, but skips
# layouts, if the layout change wouldn't affect the actual window positions.
# I.e. if there are two windows within a frame, the grid layout is skipped.
herbstclient keybind $Super-space                                                           \
            or , and . compare tags.focus.curframe_wcount = 2                   \
                     . cycle_layout +1 vertical horizontal max vertical grid    \
               , cycle_layout +1
herbstclient keybind $Super-Shift-space                                                           \
            or , and . compare tags.focus.curframe_wcount = 2                   \
                     . cycle_layout -1 vertical horizontal max vertical grid    \
               , cycle_layout -1

# Focus
herbstclient keybind $Super-BackSpace         cycle_monitor
herbstclient keybind $Super-Tab               cycle_all +1
herbstclient keybind $Super-Shift-Tab         cycle_all -1
herbstclient keybind $Super-$Alt-Tab          cycle_frame +1
herbstclient keybind $Super-$Alt-Shift-Tab    cycle_frame -1
herbstclient keybind $Super-apostrophe        cycle +1
herbstclient keybind $Super-Shift-apostrophe  cycle -1
herbstclient keybind $Super-i                 jumpto urgent

# Gaps
herbstclient keybind $Super-g       cycle_value window_gap 0 5 10 15 20 25 30 35 40 75 100 200
herbstclient keybind $Super-Shift-g cycle_value frame_gap 0 5 10 15 20 25 30 35 40 75 100 200

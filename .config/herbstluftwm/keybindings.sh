#!/bin/sh

# Folder with scripts to other modes
DIR=$(dirname $(realpath "$0"))
MODES="${DIR}/modes"
SCRIPTS="${DIR}/scripts"

TERMINAL="${TERMINAL:-xterm}"

# At start unbinding all keys
herbstclient keyunbind --all

# Submodes
herbstclient keybind Super-Shift-e         spawn sh "${MODES}/System.sh"
herbstclient keybind Super-d               spawn sh "${MODES}/Launcher.sh"
herbstclient keybind Super-n               spawn sh "${MODES}/Notify.sh"

# Main spawn shortcuts
herbstclient keybind Super-Return          spawn $TERMINAL
herbstclient keybind Super-Shift-Escape    spawn $TERMINAL -e htop

# Menus
herbstclient keybind Super-Shift-d         spawn wrapmenu -c TopMenu   -T 'Program Launcher' launcher
herbstclient keybind Super-b               spawn wrapmenu -c FloatMenu -T 'Book Searcher'    searcher "$HOME/Books"
herbstclient keybind Super-Shift-w         spawn wrapmenu -c FloatMenu -T 'Window Switcher'  $SCRIPTS/window-switcher
herbstclient keybind Super-Shift-s         spawn wrapmenu -c FloatMenu -T 'Tag Switcher'     $SCRIPTS/tag-switcher
herbstclient keybind XF86Tools             spawn wrapmenu -c TopMenu   -T 'Config Chooser'   $SCRIPTS/open-config-files

# Notifications
herbstclient keybind Super-q               spawn notify -e getinfo
herbstclient keybind Super-w               spawn "$SCRIPTS/show-tags"

# Screenshots
herbstclient keybind Print                 spawn flameshot gui
herbstclient keybind Super-Print           spawn flameshot full -c -p "$HOME/Pictures/Screenshots"
herbstclient keybind Super-Shift-Print     spawn flameshot full -c
herbstclient keybind Control-Print         spawn pickcolor

# Bind Special Keys

# increase/decrease/mute sound volume
herbstclient keybind XF86AudioMute         spawn volctl mute
herbstclient keybind XF86AudioRaiseVolume  spawn volctl raise
herbstclient keybind XF86AudioLowerVolume  spawn volctl lower
herbstclient keybind XF86AudioMicMute      spawn volctl micmute

herbstclient keybind XF86MonBrightnessUp   spawn xbacklight -inc 5
herbstclient keybind XF86MonBrightnessDown spawn xbacklight -dec 5
herbstclient keybind XF86Display           spawn arandr

# fn+4 == XF84Sleep

# Dunst
herbstclient keybind Alt-apostrophe        spawn dunstctl close
herbstclient keybind Alt-Shift-apostrophe  spawn dunstctl close-all

# Window manager specific

#System-wide important stuff
herbstclient keybind Super-Shift-r chain , spawn xrdb ~/.Xresources , reload


herbstclient keybind Super-Shift-q close

# Basic movement
# focusing clients
herbstclient keybind Super-h           focus left
herbstclient keybind Super-j           focus down
herbstclient keybind Super-k           focus up
herbstclient keybind Super-l           focus right

# Move clients
herbstclient keybind Super-Shift-h     shift left
herbstclient keybind Super-Shift-j     shift down
herbstclient keybind Super-Shift-k     shift up
herbstclient keybind Super-Shift-l     shift right

# resizing frames
resizestep=0.05
herbstclient keybind Super-Alt-h       resize left  +$resizestep
herbstclient keybind Super-Alt-j       resize down  +$resizestep
herbstclient keybind Super-Alt-k       resize up    +$resizestep
herbstclient keybind Super-Alt-l       resize right +$resizestep

# Screen split
herbstclient keybind Super-Control-h   split left    0.5
herbstclient keybind Super-Control-j   split bottom  0.5
herbstclient keybind Super-Control-k   split top     0.5
herbstclient keybind Super-Control-l   split right   0.5

herbstclient keybind Super-e           split   explode
herbstclient keybind Super-r           remove

# create an empty frame at the specified direction
# herbstclient keybind Super-u         split   bottom  0.5
# herbstclient keybind Super-o         split   right   0.5

herbstclient keybind Super-Left      split   left    0.5
herbstclient keybind Super-Down      split   bottom  0.5
herbstclient keybind Super-Up        split   top     0.5
herbstclient keybind Super-Right     split   right   0.5

## Tags
# get tag names from client
tags_raw="$(herbstclient tag_status | sed 's/\t//g')"
# tags_raw="${tags_raw#?}"
IFS='[.:#]' read -r -a tag_names <<< "${tags_raw#?}"
tag_keys=( {1..9} 0 )

for i in ${!tag_names[@]} ; do
    key="${tag_keys[$i]}"
    tag="${tag_names[$i]}"
    if ! [ -z "$key" ] ; then
        # Go to tag i
        herbstclient keybind "Super-$key" use_index "$i"
        # Move focused window to tag i
        herbstclient keybind "Super-Control-$key" move_index "$i"
        # Move focused window and go to tag i
        herbstclient keybind "Super-Shift-$key" chain , move_index "$i" , use_index "$i"
    fi
done

# Cycle through tags
herbstclient keybind Super-period  use_index +1 --skip-visible
herbstclient keybind Super-comma   use_index -1 --skip-visible

# layouting
herbstclient keybind Super-Shift-f set_attr clients.focus.floating toggle
herbstclient keybind Super-f       fullscreen toggle
herbstclient keybind Super-o       pseudotile toggle
# The following cycles through the available layouts within a frame, but skips
# layouts, if the layout change wouldn't affect the actual window positions.
# I.e. if there are two windows within a frame, the grid layout is skipped.
herbstclient keybind Super-space                                               \
            or , and . compare tags.focus.curframe_wcount = 2                   \
                     . cycle_layout +1 vertical horizontal max vertical grid    \
               , cycle_layout +1
herbstclient keybind Super-Shift-space                                         \
            or , and . compare tags.focus.curframe_wcount = 2                   \
                     . cycle_layout -1 vertical horizontal max vertical grid    \
               , cycle_layout -1

# Focus
herbstclient keybind Super-BackSpace         cycle_monitor

herbstclient keybind Super-Tab               cycle_all +1
herbstclient keybind Super-Shift-Tab         cycle_all -1

herbstclient keybind Super-Alt-Tab          cycle_frame +1
herbstclient keybind Super-Alt-Shift-Tab    cycle_frame -1

herbstclient keybind Super-i                 jumpto urgent
herbstclient keybind Super-p                 use_previous

# Gaps
herbstclient keybind Super-g       cycle_value window_gap 0 5 10 15 20 25 30 35 40 50
herbstclient keybind Super-Shift-g cycle_value frame_gap  0 5 10 15 20 25 30 35 40 50

# mousebinds
herbstclient mouseunbind --all
herbstclient mousebind Super-Button1 move
herbstclient mousebind Super-Button2 zoom
herbstclient mousebind Super-Button3 resize

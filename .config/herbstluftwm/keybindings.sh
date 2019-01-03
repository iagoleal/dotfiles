#!/bin/zsh

modes_folder="${HOME}/.config/herbstluftwm/modes"

# At start unbinding all keys
herbstclient keyunbind --all

# Keybindings
Super=Mod4    # Use the super key as the main modifier
Alt=Mod1    # Use Alt key when necessary

#System-wide important stuff
herbstclient keybind $Super-Shift-r reload
herbstclient keybind $Super-Shift-q close

# Main spawn shortcuts
herbstclient keybind $Super-Return       spawn termite # use your $TERMINAL with xterm as fallback
herbstclient keybind $Super-Shift-d      spawn rofi -show drun
herbstclient keybind $Super-Shift-dead_greek spawn termite -e htop
herbstclient keybind $Super-b            spawn "$HOME/.bin/book_finder"


# Notifications
herbstclient keybind $Super-q       spawn "$HOME/.bin/notify_script" "-s" "$HOME/.bin/getinfo"
herbstclient keybind $Super-t       spawn "$HOME/.bin/notify_script" "-s" "$HOME/.bin/getdate"
herbstclient keybind $Super-m       spawn "$HOME/.bin/notify_script" "-s" "$HOME/.bin/getmpdstatus"

# Change mode
herbstclient keybind $Super-Shift-e spawn sh "${modes_folder}/System.sh"
herbstclient keybind $Super-d       spawn sh "${modes_folder}/Launcher.sh"
herbstclient keybind $Super-Shift-g spawn bash "${modes_folder}/Gaps.sh"
herbstclient keybind Print          spawn sh "${modes_folder}/Printscreen.sh"
herbstclient keybind $Super-n       spawn sh "${modes_folder}/Notify.sh"


# Bind Media Keys

# increase/decrease/mute sound volume
herbstclient keybind XF86AudioRaiseVolume spawn pactl set-sink-volume 0 +5%
herbstclient keybind XF86AudioLowerVolume spawn pactl set-sink-volume 0 -5%
herbstclient keybind XF86AudioMute        spawn pactl set-sink-mute 0 toggle

# Media player controls
herbstclient keybind XF86AudioPlay spawn mpc -q toggle
herbstclient keybind XF86AudioStop spawn mpc -q stop
herbstclient keybind XF86AudioPrev spawn mpc -q prev
herbstclient keybind XF86AudioNext spawn mpc -q next

# Toggle touchpad
herbstclient keybind $Super-F6 spawn $HOME/.bin/toggle-touchpad.sh

# Basic movement
# focusing clients
herbstclient keybind $Super-h     focus left
herbstclient keybind $Super-j     focus down
herbstclient keybind $Super-k     focus up
herbstclient keybind $Super-l     focus right

# moving clients
herbstclient keybind $Super-Shift-Left  shift left
herbstclient keybind $Super-Shift-Down  shift down
herbstclient keybind $Super-Shift-Up    shift up
herbstclient keybind $Super-Shift-Right shift right
herbstclient keybind $Super-Shift-h     shift left
herbstclient keybind $Super-Shift-j     shift down
herbstclient keybind $Super-Shift-k     shift up
herbstclient keybind $Super-Shift-l     shift right

herbstclient keybind $Super-Control-h       split   left    0.5
herbstclient keybind $Super-Control-j       split   bottom  0.5
herbstclient keybind $Super-Control-k       split   top     0.5
herbstclient keybind $Super-Control-l       split   right   0.5

# resizing frames
resizestep=0.05
herbstclient keybind $Super-$Alt-h       resize left +$resizestep
herbstclient keybind $Super-$Alt-j       resize down +$resizestep
herbstclient keybind $Super-$Alt-k       resize up +$resizestep
herbstclient keybind $Super-$Alt-l       resize right +$resizestep
herbstclient keybind $Super-$Alt-Left    resize left +$resizestep
herbstclient keybind $Super-$Alt-Down    resize down +$resizestep
herbstclient keybind $Super-$Alt-Up      resize up +$resizestep
herbstclient keybind $Super-$Alt-Right   resize right +$resizestep

# Tags
tag_names=( {1..10} )
tag_keys=( {1..9} 0 )

herbstclient rename default "${tag_names[0]}" || true
for i in ${!tag_names[@]} ; do
    herbstclient add "${tag_names[$i]}"
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

# splitting frames
# create an empty frame at the specified direction
herbstclient keybind $Super-u         split   bottom  0.5
herbstclient keybind $Super-o         split   right   0.5
herbstclient keybind $Super-e         split   explode

herbstclient keybind $Super-Left      split   left    0.5
herbstclient keybind $Super-Down      split   bottom  0.5
herbstclient keybind $Super-Up        split   top     0.5
herbstclient keybind $Super-Right     split   right   0.5
# let the current frame explode in  to subframes
herbstclient keybind $Super-Multi_key split   explode
herbstclient keybind $Super-End       remove
# Remove frame
herbstclient keybind $Super-r       remove

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

# Focus
herbstclient keybind $Super-BackSpace         cycle_monitor
herbstclient keybind $Super-Tab               cycle_all +1
herbstclient keybind $Super-Shift-Tab         cycle_all -1
herbstclient keybind $Super-apostrophe        cycle +1
herbstclient keybind $Super-Shift-apostrophe  cycle -1
herbstclient keybind $Super-c                 cycle
herbstclient keybind $Super-Shift-c           cycle -1
herbstclient keybind $Super-i                 jumpto urgent

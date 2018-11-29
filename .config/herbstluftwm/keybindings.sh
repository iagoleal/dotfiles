#!/bin/zsh

modes_folder="${HOME}/.config/herbstluftwm/modes"

# At start unbinding all keys
herbstclient keyunbind --all

# Keybindings
Mod=Mod4    # Use the super key as the main modifier
Alt=Mod1    # Use Alt key when necessary

#System-wide important stuff
herbstclient keybind $Mod-Shift-r reload
herbstclient keybind $Mod-Shift-q close

# Main spawn shortcuts
herbstclient keybind $Mod-Return       spawn termite # use your $TERMINAL with xterm as fallback
herbstclient keybind $Mod-Shift-d      spawn rofi -show drun
herbstclient keybind $Mod-Shift-dead_greek spawn termite -e htop

# Notifications
herbstclient keybind $Mod-q       spawn notify-send "$($HOME/.bin/getinfo)"
herbstclient keybind $Mod-t       spawn notify-send "$($HOME/.bin/getdate)"


# Change mode
herbstclient keybind $Mod-Shift-e spawn sh "${modes_folder}/System.sh"
herbstclient keybind $Mod-d       spawn sh "${modes_folder}/Launcher.sh"
herbstclient keybind $Mod-Shift-g spawn bash "${modes_folder}/Gaps.sh"
herbstclient keybind Print        spawn sh "${modes_folder}/Printscreen.sh"
herbstclient keybind $Mod-n       spawn sh "${modes_folder}/Notify.sh"


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
herbstclient keybind $Mod-F6 spawn $HOME/.bin/toggle-touchpad.sh

# Basic movement
# focusing clients
herbstclient keybind $Mod-h     focus left
herbstclient keybind $Mod-j     focus down
herbstclient keybind $Mod-k     focus up
herbstclient keybind $Mod-l     focus right

# moving clients
herbstclient keybind $Mod-Shift-Left  shift left
herbstclient keybind $Mod-Shift-Down  shift down
herbstclient keybind $Mod-Shift-Up    shift up
herbstclient keybind $Mod-Shift-Right shift right
herbstclient keybind $Mod-Shift-h     shift left
herbstclient keybind $Mod-Shift-j     shift down
herbstclient keybind $Mod-Shift-k     shift up
herbstclient keybind $Mod-Shift-l     shift right

herbstclient keybind $Mod-Control-h       split   left    0.5
herbstclient keybind $Mod-Control-j       split   bottom  0.5
herbstclient keybind $Mod-Control-k       split   top     0.5
herbstclient keybind $Mod-Control-l       split   right   0.5

# resizing frames
resizestep=0.05
herbstclient keybind $Mod-$Alt-h       resize left +$resizestep
herbstclient keybind $Mod-$Alt-j       resize down +$resizestep
herbstclient keybind $Mod-$Alt-k       resize up +$resizestep
herbstclient keybind $Mod-$Alt-l       resize right +$resizestep
herbstclient keybind $Mod-$Alt-Left    resize left +$resizestep
herbstclient keybind $Mod-$Alt-Down    resize down +$resizestep
herbstclient keybind $Mod-$Alt-Up      resize up +$resizestep
herbstclient keybind $Mod-$Alt-Right   resize right +$resizestep

# Tags
tag_names=( {1..10} )
tag_keys=( {1..9} 0 )

herbstclient rename default "${tag_names[0]}" || true
for i in ${!tag_names[@]} ; do
    herbstclient add "${tag_names[$i]}"
    key="${tag_keys[$i]}"
    if ! [ -z "$key" ] ; then
        # Go to tag i
        herbstclient keybind "$Mod-$key" use_index "$i"
        # Move focused window to tag i
        herbstclient keybind "$Mod-$Alt-$key" move_index "$i"
        # Move focused window and go to tag i
        herbstclient keybind "$Mod-Shift-$key" chain , move_index "$i" , use_index "$i"
    fi
done

# Cycle through tags
herbstclient keybind $Mod-period  use_index +1 --skip-visible
herbstclient keybind $Mod-comma   use_index -1 --skip-visible

# splitting frames
# create an empty frame at the specified direction
herbstclient keybind $Mod-u         split   bottom  0.5
herbstclient keybind $Mod-o         split   right   0.5
herbstclient keybind $Mod-e         split   explode

herbstclient keybind $Mod-Left      split   left    0.5
herbstclient keybind $Mod-Down      split   bottom  0.5
herbstclient keybind $Mod-Up        split   top     0.5
herbstclient keybind $Mod-Right     split   right   0.5
# let the current frame explode in  to subframes
herbstclient keybind $Mod-Multi_key split   explode
herbstclient keybind $Mod-End       remove
# Remove frame
herbstclient keybind $Mod-r       remove

# layouting
herbstclient keybind $Mod-Shift-s floating toggle
herbstclient keybind $Mod-f       fullscreen toggle
herbstclient keybind $Mod-p       pseudotile toggle
# The following cycles through the available layouts within a frame, but skips
# layouts, if the layout change wouldn't affect the actual window positions.
# I.e. if there are two windows within a frame, the grid layout is skipped.
herbstclient keybind $Mod-space                                                           \
            or , and . compare tags.focus.curframe_wcount = 2                   \
                     . cycle_layout +1 vertical horizontal max vertical grid    \
               , cycle_layout +1

# Focus
herbstclient keybind $Mod-BackSpace         cycle_monitor
herbstclient keybind $Mod-Tab               cycle_all +1
herbstclient keybind $Mod-Shift-Tab         cycle_all -1
herbstclient keybind $Mod-apostrophe        cycle +1
herbstclient keybind $Mod-Shift-apostrophe  cycle -1
herbstclient keybind $Mod-c                 cycle
herbstclient keybind $Mod-Shift-c           cycle -1
herbstclient keybind $Mod-i                 jumpto urgent

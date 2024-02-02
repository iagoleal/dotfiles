#!/bin/sh

# Folder with scripts to other modes
DIR=$(dirname $(realpath "$0"))
MODES="${DIR}/modes"
SCRIPTS="${DIR}/scripts"

normalMode="$0"

TERMINAL="${TERMINAL:-xterm}"

# At start unbinding all keys
herbstclient keyunbind --all

# Submodes
herbstclient keybind Super-d               spawn sh "${MODES}/Launcher.sh"

# Notifications
herbstclient keybind Super-q               spawn notify -e getinfo

herbstclient keybind Super-n chain \
 . keyunbind --all \
 . keybind q chain , spawn notify -e getinfo , spawn sh "$normalMode" \
 . keybind c chain , spawn notify -e getcal  , spawn sh "$normalMode" \
 . keybind Escape spawn sh "$normalMode"

# Session management
herbstclient keybind Super-a       spawn $SCRIPTS/window-switcher
herbstclient keybind Super-Shift-s spawn $SCRIPTS/tag-switcher
herbstclient keybind Super-s       spawn $SCRIPTS/tag-switcher sessions

herbstclient keybind Super-w chain \
 . keyunbind --all \
 . keybind w       chain , spawn $SCRIPTS/window-switcher       , spawn sh "$normalMode" \
 . keybind Shift-s chain , spawn $SCRIPTS/tag-switcher          , spawn sh "$normalMode" \
 . keybind s       chain , spawn $SCRIPTS/tag-switcher sessions , spawn sh "$normalMode" \
 . keybind r       chain , spawn $SCRIPTS/rename-tag            , spawn sh "$normalMode" \
 . keybind Super-w chain , spawn $SCRIPTS/show-tags , spawn sh "$normalMode" \
 . keybind e       chain , spawn $SCRIPTS/show-tags , spawn sh "$normalMode" \
 . keybind Escape spawn bash "$normalMode"

# System control
herbstclient keybind Super-Shift-e chain \
 . keybind 1 chain , spawn sh "$normalMode" , spawn system "lock"        \
 . keybind 2 chain , spawn sh "$normalMode" , spawn system "suspend"     \
 . keybind 3 chain , spawn sh "$normalMode" , spawn system "logout"      \
 . keybind 4 chain , spawn sh "$normalMode" , spawn system "reboot"      \
 . keybind 5 chain , spawn sh "$normalMode" , spawn system "hibernate"   \
 . keybind 6 chain , spawn sh "$normalMode" , spawn system "poweroff"    \
 . keybind Escape spawn bash "$normalMode"

# Main spawn shortcuts
herbstclient keybind Super-Return          spawn $TERMINAL
herbstclient keybind Super-Shift-Escape    spawn $TERMINAL -e htop

# Menus
herbstclient keybind Super-Shift-d         spawn launcher
herbstclient keybind Super-b               spawn searcher "$HOME/vault/media/Books/"

# Screenshots
herbstclient keybind Print                 spawn flameshot gui
herbstclient keybind Super-Print           spawn flameshot full -c -p "$HOME/vault/Pictures/Screenshots"
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

herbstclient keybind XF86Tools             spawn $SCRIPTS/open-config-files
herbstclient keybind XF86Favorites         spawn passmenu

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
for key in {1..9} ; do
  # herbstclient keybind "Super-$key" chain . add $tag . use $tag
  # herbstclient keybind "Super-Control-$key" chain . add $tag . move $tag
  # herbstclient keybind "Super-Shift-$key" chain , add $tag , move $tag , use $tag

  # Go to tag i
  herbstclient keybind "Super-$key" spawn $SCRIPTS/sessionctl jump-to "$key"
  # Move focused window to tag i
  herbstclient keybind "Super-Control-$key" spawn $SCRIPTS/sessionctl win-to "$key"
  # Move focused window and go to tag i
  herbstclient keybind "Super-Shift-$key" chain , spawn $SCRIPTS/sessionctl win-to "$key" , spawn $SCRIPTS/sessionctl jump-to $key
done

# Cycle through sessions
# herbstclient keybind Super-apostrophe        $SCRIPTS/sessionctl next
# herbstclient keybind Super-Shift-apostrophe  $SCRIPTS/sessionctl prev
# Quick look at slack tag
herbstclient keybind Super-apostrophe        \
  or , and . compare tags.focus.name = slack \
           . use_previous                    \
     ,       use slack

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
herbstclient keybind Super-space                                                \
            or , and . compare tags.focus.curframe_wcount = 2                   \
                     . cycle_layout +1 vertical horizontal max vertical grid    \
               , cycle_layout +1
herbstclient keybind Super-Shift-space                                          \
            or , and . compare tags.focus.curframe_wcount = 2                   \
                     . cycle_layout -1 vertical horizontal max vertical grid    \
               , cycle_layout -1

# Focus
herbstclient keybind Super-BackSpace         cycle_monitor

herbstclient keybind Super-Tab               cycle_all +1
herbstclient keybind Super-Shift-Tab         cycle_all -1

herbstclient keybind Super-Alt-Tab           cycle_frame +1
herbstclient keybind Super-Alt-Shift-Tab     cycle_frame -1

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

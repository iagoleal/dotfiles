#!/bin/sh

# Define folders and files to read
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f $userresources ]; then
    xrdb -merge "$userresources"
fi

# Set keyboard layout to br-abnt2
# Options are:
# Capslock key function as Esc
# Swap Left Control and Left Alt keys
# Classic Control-Alt-Backspace command to kill X
setxkbmap -layout br \
    -option "caps:escape" \
    -option "ctrl:swap_lalt_lctl" \
    -option "compose:menu" \
    -option "terminate:ctrl_alt_bksp"

# Run the custom changes AFTER selecting the keyboard
if [ -f $usermodmap ]; then
    xmodmap $usermodmap
fi

# Start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# Turn the damm bell sound off
xset b off
# Change the cursor default icon
xsetroot -cursor_name left_ptr

# Set Wallpaper to my beloved duck image
feh --bg-scale ~/Pictures/Wallpapers/duck.jpg &
# Christmas version of my beloved duck image
# feh --bg-scale ~/Pictures/Wallpapers/xmas/duck_xmas.png

# Start Compositor
compton &
# udiskie is a automount daemon
udiskie &
# Redshift uses location / time info to control screen temperature and brightness
redshift &
# Enable CJK support
fcitx &
# Enable screen lock
xautolock -time 10 -corners ----  -locker "slock" &
# Run WM
exec herbstluftwm --locked

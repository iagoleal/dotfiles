#!/bin/sh

userresources=$HOME/.Xresources
userxkbdir=$HOME/.xkb
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

userxkblayout=br
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

if [ -n $userxkbdir ]; then
    # Set keyboard layout to my custom one
    # Options are:
    # Swap Capslock and Esc keys
    # Swap Left Control and Left Alt keys
    # Use Menu key as Compose
    setxkbmap -I $userxkbdir -layout $userxkblayout \
        -option "caps:swapescape" \
        -option "ctrl:swap_lalt_lctl" \
        -option "compose:menu"
else
    # Set keyboard layout to br-abnt2
    setxkbmap -layout br
fi

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

# udiskie is a automount daemon
udiskie &
# Redshift uses location / time info to control screen temperature and brightness
redshift &
#Set Wallpaper to my beloved duck image
feh --bg-scale ~/Pictures/Wallpapers/duck.jpg &
#Enable screen lock
xautolock -time 10 -corners ----  -locker "i3lock -c '#000000'" &

# exec i3
# exec xmonad
# exec bspwm
# exec awesome
exec herbstluftwm --locked

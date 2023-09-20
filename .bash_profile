#
# ~/.bash_profile
#

if [[ -e $HOME/.profile ]]; then
  source $HOME/.profile
fi

[[ -f ~/.bashrc ]] && . ~/.bashrc

if systemctl -q is-active graphical.target && [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx
fi

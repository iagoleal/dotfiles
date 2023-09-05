if [[ -e $HOME/.profile ]]; then
  source $HOME/.profile
fi

if [[ ! $DISPLAY && $XDG_VTNR -eq 1 ]]; then
  exec startx
fi

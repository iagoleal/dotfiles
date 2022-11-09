#----------------------------
# Environment variables
#----------------------------
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_DIRS=/usr/local/share:/usr/share
export XDG_CONFIG_DIRS=/etc/xdg


export EDITOR="nvim -e"
export VISUAL="nvim"
export TERMINAL="xterm"
export BROWSER="firefox"

export JULIA_NUM_THREADS=8
export JULIA_161=julia

# Append extra bin folders to PATH variable
path=("$HOME/.nix-profile/bin"
      "$HOME/bin"
      "$HOME/.bin"
      "$HOME/.local/bin"
      $path)
export PATH
if command -v luarocks &> /dev/null; then
  eval $(luarocks path --bin)
fi
[ -f "/home/iago/.ghcup/env" ] && source "/home/iago/.ghcup/env" # ghcup-env

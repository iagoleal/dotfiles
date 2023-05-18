#----------------------------
# Environment variables
#----------------------------
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_DIRS="/usr/local/share:/usr/share:$HOME/.local/share/applications/"
export XDG_CONFIG_DIRS=/etc/xdg

# pass should paste passwords with middle click
export PASSWORD_STORE_X_SELECTION=primary

export EDITOR="nvim -e"
export VISUAL="nvim"
export TERMINAL="xterm"
export BROWSER="firefox"

export JULIA_NUM_THREADS=8
export JULIA_161='julia +1.6'

# Preview directory on M-c
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"
# Default options
export FZF_DEFAULT_OPTS='-m --cycle --bind=alt-e:preview-down --bind=alt-y:preview-up'
# Use rg as grep tool
if command -v rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
fi

# Append extra bin folders to PATH variable
path=("$HOME/.nix-profile/bin"
      "$HOME/bin"
      "$HOME/.bin"
      "$HOME/.local/bin"
      "$XDG_CONFIG_HOME/herbstluftwm/scripts"
      $path)
export PATH

if command -v luarocks &> /dev/null; then
  eval $(luarocks path --bin)
fi

[ -f "/home/iago/.ghcup/env" ] && source "/home/iago/.ghcup/env" # ghcup-env

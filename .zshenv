#----------------------------
# Environment variables
#----------------------------

# pass should paste passwords with middle click
export PASSWORD_STORE_X_SELECTION=primary

export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="xterm"
export BROWSER="firefox"

export JULIA_NUM_THREADS=8

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

# Lua packages
if command -v luarocks &> /dev/null; then
  eval $(luarocks path --bin)
fi

# Haskell packages
if [ -f "${XDG_CONFIG_DATA}/.ghcup/env" ]; then
  source "${XDG_CONFIG_DATA}/.ghcup/env"
elif [ -f "$HOME/.ghcup/env" ]; then
  source "$HOME/.ghcup/env" # ghcup-env
fi

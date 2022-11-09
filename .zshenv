#----------------------------
# Environment variables
#----------------------------
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

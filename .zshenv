#----------------------------
# Environment variables
#----------------------------
export EDITOR="nvim -e"
export VISUAL="nvim"
export TERMINAL="xterm"
export BROWSER="firefox"

# Always start Julia with 8 threads
export JULIA_NUM_THREADS=8

# Append extra bin folders to PATH variable
path+=("$HOME/.local/bin")
path+=("$HOME/.bin")
path+=("$HOME/bin")
export PATH
if command -v luarocks &> /dev/null; then
  eval $(luarocks path --bin)
fi
[ -f "/home/iago/.ghcup/env" ] && source "/home/iago/.ghcup/env" # ghcup-env

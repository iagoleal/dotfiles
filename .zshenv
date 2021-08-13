#----------------------------
# Environment variables
#----------------------------
export EDITOR="nvim -e"
export VISUAL="nvim"
export TERMINAL="xterm"
export BROWSER="firefox"

# Append extra bin folders to PATH variable
path+=("$HOME/.local/bin")
path+=("$HOME/.bin")
path+=("$HOME/bin")
export PATH
if command -v luarocks &> /dev/null; then
  eval $(luarocks path --bin)
fi

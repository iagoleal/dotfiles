# Load the installed packages
function check_and_source {
  for fname in "$@"; do
    if [[ -f "$fname" ]]; then
      source "$fname"
      break
    fi
  done
}

# Source key-bindings
check_and_source '/usr/share/fzf/key-bindings.zsh' \
                 '/usr/share/doc/fzf/examples/key-bindings.zsh'
# Source completion
check_and_source '/usr/share/fzf/completion.zsh' \
                 '/usr/share/doc/fzf/examples/completion.zsh'

# Directly accept on C-r
fzf-history-widget-accept() {
  fzf-history-widget
  zle accept-line
}
zle     -N     fzf-history-widget-accept
bindkey '^X^R' fzf-history-widget-accept

# Preview directory on M-c
export FZF_ALT_C_OPTS="--preview 'tree -C {} | head -200'"

# Default options
export FZF_DEFAULT_OPTS='-m'

# Use rg as grep tool
if command -v rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
fi

# Load the installed packages
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh

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
if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
fi

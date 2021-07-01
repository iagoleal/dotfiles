# Load the installed packages
fzf_key_bindings=$(find /usr/share -path '**/fzf/**/key-bindings.zsh')
fzf_completion=$(find /usr/share -path '**/fzf/**/completion.zsh')

if [[ -f "$fzf_key_bindings" ]]; then
  source "$fzf_key_bindings"
fi
if [[ -f "$fzf_completion" ]]; then
  source "$fzf_completion"
fi

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

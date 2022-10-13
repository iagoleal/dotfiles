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

# Git completion
source /home/iago/.zsh.d/lib/fzf-git.sh

# use fzf for general tab completion
source $HOME/.zsh.d/lib/fzf-tab/fzf-tab.plugin.zsh

zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'

zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
  'git diff --color=always $word'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
  'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:*' fzf-preview \
  'git help $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
  'case "$group" in
  "commit tag") git show --color=always $word ;;
  *) git show --color=always $word  ;;
  esac'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
  'case "$group" in
  "modified file") git diff --color=always $word ;;
  "recent commit object name") git show --color=always $word ;;
  *) git log --color=always $word ;;
  esac'

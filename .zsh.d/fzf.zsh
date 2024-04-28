# Find where is fzf in the nix store
if [ -n "${commands[fzf]}" ]; then
  eval "$(fzf --zsh)"

  # Directly accept on C-r
  fzf-history-widget-accept() {
    fzf-history-widget
    zle accept-line
  }
  zle     -N     fzf-history-widget-accept
  bindkey '^X^R' fzf-history-widget-accept

  zstyle ':completion:*:descriptions' format '[%d]'
  zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
  zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'

  # Get help
  zstyle ':fzf-tab:complete:(\\|)run-help:*' fzf-preview 'run-help $word'
  zstyle ':fzf-tab:complete:(\\|*/|)man:*' fzf-preview 'man $word'

  # Git
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
else
  echo "fzf executable not found"
fi

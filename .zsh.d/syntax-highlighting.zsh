#---------------------------
# Syntax highlighting
#---------------------------
function check_and_source {
  for fname in "$@"; do
    if [[ -f "$fname" ]]; then
      source "$fname"
      break
    fi
  done
}

check_and_source '/usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' \
                 '/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh'

# Use given highlighters
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
# Define my own patterns
ZSH_HIGHLIGHT_PATTERNS+=('rm *' 'fg=yellow,underline,bold') # To have commands starting with `rm -rf` in red
ZSH_HIGHLIGHT_PATTERNS+=('sudo' 'bold,fg=yellow') # Highlight sudo as blue
ZSH_HIGHLIGHT_PATTERNS+=('sudo *' 'bold') # If a line is a sudo command, it gets underlined

# vim:filetype=zsh

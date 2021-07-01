#---------------------------
# Syntax highlighting
#---------------------------
zsh_syntax_highlighting=$(find /usr/share -name 'zsh-syntax-highlighting.zsh')
if [[ -f "$zsh_syntax_highlighting" ]]; then
  # Source the plugin file
  source "$zsh_syntax_highlighting"

  # Use given highlighters
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
  # Define my own patterns
  ZSH_HIGHLIGHT_PATTERNS+=('rm *' 'fg=yellow,underline,bold') # To have commands starting with `rm -rf` in red
  ZSH_HIGHLIGHT_PATTERNS+=('sudo' 'bold,fg=yellow') # Highlight sudo as blue
  ZSH_HIGHLIGHT_PATTERNS+=('sudo *' 'bold') # If a line is a sudo command, it gets underlined
fi

# vim:filetype=zsh

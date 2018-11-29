#---------------------------
# Syntax highlighting
#---------------------------
if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    # Source the plugin file
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

    # Use given highlighters
    ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
    # Define my own patterns
    ZSH_HIGHLIGHT_PATTERNS+=('rm *' 'fg=yellow,underline,bold') # To have commands starting with `rm -rf` in red
    ZSH_HIGHLIGHT_PATTERNS+=('sudo' 'bold,fg=yellow') # Highlight sudo as blue
    ZSH_HIGHLIGHT_PATTERNS+=('sudo *' 'bold') # If a line is a sudo command, it gets underlined

fi

# vim:filetype=zsh

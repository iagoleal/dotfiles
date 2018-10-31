# Enable syntax highlighting (needs external package)
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
ZSH_HIGHLIGHT_PATTERNS+=('rm *' 'fg=white,bold,bg=red') # To have commands starting with `rm -rf` in red
ZSH_HIGHLIGHT_PATTERNS+=('sudo *' 'bold') # If a line is a sudo command, it gets underlined
ZSH_HIGHLIGHT_PATTERNS+=('sudo' 'fg=blue') # Highlight sudo as blue

# vim:filetype=zsh

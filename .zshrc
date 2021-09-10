#----------------------------
# Keybindings
#----------------------------
# bindkey -v # Vim mode for keybinds
bindkey -e # Emacs mode for keybinds

autoload edit-command-line
zle -N edit-command-line
bindkey '' edit-command-line
bindkey -M vicmd '' edit-command-line
bindkey '^R' history-incremental-search-backward

#----------------------------
# Beep
#----------------------------
#turn this damn thing off
unsetopt beep

#----------------------------
# History related
#----------------------------
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory

# # When going over history,
# # only consider commands which match the written characters until now
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[OA' history-beginning-search-backward
bindkey '^[OB' history-beginning-search-forward

#----------------------------
# Autocompletion
#----------------------------
# zstyle :compinstall filename '/home/iagoleal/.zshrc'
autoload -Uz compinit
compinit

#----------------------------
# Enable prompt theme system
#----------------------------
autoload -Uz promptinit
promptinit

#----------------------------
# Make the cursor blink
#----------------------------
echo -e -n "\x1b[\x33 q"

#----------------------------
# Source additional configs
#----------------------------
# Custom aliases and functions
source $HOME/.zsh.d/aliases.zsh
# Prompt customization
source $HOME/.zsh.d/prompt.zsh
# fzf keybindings and completion
source $HOME/.zsh.d/fzf.zsh
# Enable syntax highlighting
source $HOME/.zsh.d/syntax-highlighting.zsh

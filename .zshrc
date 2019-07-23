#----------------------------
# Keybindings
#----------------------------
bindkey -v # Vim mode for keybinds
# bindkey -e # Emacs mode for keybinds

autoload edit-command-line
zle -N edit-command-line
bindkey '' edit-command-line
bindkey -M vicmd '' edit-command-line

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

# When going over history,
# only consider commands which match the written characters until now
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
[[ -n "$key[Up]"   ]] && bindkey -- "$key[Up]"   up-line-or-beginning-search
[[ -n "$key[Down]" ]] && bindkey -- "$key[Down]" down-line-or-beginning-search

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
# Environment variables
#----------------------------
export EDITOR="nvim -e"
export VISUAL="nvim"
export TERMINAL="termite"

# Append ~/.bin folder to PATH variable
path+=("$HOME/.local/bin")
path+=("$HOME/.bin")
export PATH

#----------------------------
# Source additional configs
#----------------------------
# Custom aliases and functions
source $HOME/.zsh.d/aliases.zsh
# Prompt customization
source $HOME/.zsh.d/prompt.zsh
# Enable syntax highlighting
source $HOME/.zsh.d/syntax-highlighting.zsh

# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory
unsetopt beep
bindkey -v # Vim mode for keybinds
# bindkey -e # Emacs mode for keybinds
# End of lines configured by zsh-newuser-install

# The following lines were added by compinstall
zstyle :compinstall filename '/home/iagoleal/.zshrc' 
autoload -Uz compinit
compinit
# End of lines added by compinstall

#For themes
autoload -Uz promptinit
promptinit


# Environment variables
export EDITOR="vi -e"
export VISUAL="nvim"
export TERMINAL="termite"

source $HOME/.zsh.d/aliases.zsh

source $HOME/.zsh.d/syntax-highlighting.zsh

source $HOME/.zsh.d/prompt.zsh


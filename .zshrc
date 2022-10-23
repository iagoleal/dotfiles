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
setopt inc_append_history
setopt hist_ignore_dups
setopt hist_ignore_space

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

# Path for completion files
fpath=(~/.zsh.d/comp $fpath)

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
# Plugin Manager
#----------------------------

### Bootstrap zinit
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-history-substring-search
zinit light zsh-users/zsh-completions

# Use fzf for tab completion
zinit ice wait lucid
zinit light Aloxaf/fzf-tab

# Keybindings for git objects using fzf
zinit ice wait'1' lucid
zinit snippet https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh


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

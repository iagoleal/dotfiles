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


zinit wait lucid light-mode for \
 atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
    @zdharma-continuum/fast-syntax-highlighting \
 blockf \
    @zsh-users/zsh-completions

# Use fzf for tab completion
zinit wait lucid light-mode for \
  @Aloxaf/fzf-tab \
  @https://raw.githubusercontent.com/junegunn/fzf-git.sh/main/fzf-git.sh


#----------------------------
# Set Options & Env Variables
#----------------------------

#turn this damn thing off
unsetopt beep

# History related
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000

setopt append_history
setopt share_history
setopt extended_history
setopt hist_ignore_dups
setopt hist_ignore_space

setopt extended_glob

# display PID when suspending processes
setopt longlistjobs

# report the status of backgrounds jobs immediately
setopt notify

# whenever a command completion is attempted, make sure the entire command path is hashed first.
setopt hash_list_all

# not just at the end
setopt completeinword

# Don't send SIGHUP to background processes when the shell exits.
setopt nohup

# make cd push the old directory onto the directory stack.
setopt auto_pushd

# don't push the same dir twice.
setopt pushd_ignore_dups

# * shouldn't match dotfiles. ever.
setopt noglobdots

# don't error out when unset parameters are used
setopt unset

# use zsh style word splitting
setopt noshwordsplit

#----------------------------
# Keybindings
#----------------------------
bindkey -e # Emacs mode for keybinds

autoload edit-command-line
zle -N edit-command-line
bindkey '' edit-command-line
bindkey -M vicmd '' edit-command-line

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
# Source additional configs
#----------------------------
# Custom aliases and functions
source $HOME/.zsh.d/aliases.zsh
# Prompt customization
source $HOME/.zsh.d/prompt.zsh
# fzf keybindings and completion
source $HOME/.zsh.d/fzf.zsh

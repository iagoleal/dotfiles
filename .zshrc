#----------------------------
# Plugin Manager
#----------------------------

source $HOME/.zsh.d/plugin-manager.zsh

plugin-load romkatv/zsh-defer \
            zsh-users/zsh-completions \
            spwhitt/nix-zsh-completions \
            Aloxaf/fzf-tab \
            zsh-users/zsh-syntax-highlighting \
            junegunn/fzf-git.sh


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

# try to correct misspelt commands
setopt correct

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

# allow comments on interactive shell
setopt interactive_comments

# Auto send SIGCONT to disowned jobs
setopt auto_continue

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
bindkey '^[[A' history-beginning-search-backward # arrow up
bindkey '^[[B' history-beginning-search-forward  # arrow down

# Restore last background job to foreground.
# Useful in order to hit C-z twice to quickly see the alternate screen.
# This was adpated from grml zsh confg.
function go-to-fg {
  if (( ${#jobstates} )); then
    zle .push-input
    [[ -o hist_ignore_space ]] && BUFFER=' ' || BUFFER=''
    BUFFER="${BUFFER}fg"
    zle .accept-line
  else
    zle -M 'No background jobs. Doing nothing.'
  fi
}
zle -N go-to-fg

bindkey '^z' go-to-fg



#----------------------------
# Autocompletion
#----------------------------
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
  compinit;
else
  compinit -C;
fi;

# Informative completion to kill command
zstyle ':completion:*:processes' command "ps -u $USER -o pid,stat,%cpu,%mem,cputime,command"

# Provide more processes in completion of programs like killall:
zstyle ':completion:*:processes-names' command 'ps c -u ${USER} -o command | uniq'

# Path for completion files
# fpath=(~/.zsh.d/comp $fpath)

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

# Hooks to set xterm title only on X session
if [[ $DISPLAY ]]; then
  source $HOME/.zsh.d/wintitle.zsh
fi

setopt PROMPT_SUBST
# Prompt customization
autoload -Uz vcs_info
precmd() {vcs_info}

# zstyle ':vcs_info:*' formats '%F{white}[%F{2}%b%F{white}]%f '
zstyle ':vcs_info:*' formats '[%F{green}%b%f] '

# I only use git, after all
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*+start-up:*' hooks vcs_prompt
zstyle ':vcs_info:*+no-vcs:*' hooks no_vcs_prompt

function +vi-no_vcs_prompt() {
    PS1="$(_prompt)"
    RPS1="$(_rprompt)"
}

function +vi-vcs_prompt() {
    PS1="$(_prompt)"
    RPS1="$(_rprompt)"
}

function _prompt {
    # Show error msg only if return != 0
    local error_code='%(?..Exit Code: %B%F{red}%?%f%b
)'
    # Show different symbols for normal user or root
    local user_symbol='%(?.%F{118}.%F{160})%B❯%b%f'
    local prompt_symbol="%(!.%F{red}#%f.$user_symbol) "
    echo -n $error_code$prompt_symbol
}

function _rprompt {
    # Show current directory
    local curr_dir='%B%F{yellow}%40<...<%~%f%b'
    # Show number of running jobs
    local jobs_info='%(1j.[%F{blue}%j%f].)'
    # Info about git branch
    local git_info="${vcs_info_msg_0_}"
    echo -n $git_info$curr_dir$jobs_info
}

# Export the prompt per se

prompt walters

# vim:filetype=zsh

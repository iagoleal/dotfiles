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
  echo -n $error_code

  if [[ -n "$IN_NIX_SHELL" ]]; then
    echo -n "(nix)"
  fi

  if [[ -n "$VIRTUAL_ENV" ]]; then
    echo -n "(py)"
  fi

  if [ -n "$GUIX_ENVIRONMENT" ]; then
    echo -n "(guix)"
  fi

  # When are we in ssh?
  if [[ -n $SSH_CLIENT ]]; then
    echo -n "%n@%m"
  fi

  # Show different symbols for normal user or root
  local user_symbol='%(?.%F{118}.%F{160})%B❯%b%f'
  local prompt_symbol="%(!.%F{red}#%f.$user_symbol) "
  echo -n $prompt_symbol
}

function _rprompt {
  # Info about git branch
  echo -n "${vcs_info_msg_0_}"
  # Show current directory
  echo -n '%B%F{yellow}%40<...<%~%f%b'
  # Show number of running jobs
  echo -n '%(1j. [%F{blue}%j%f].)'
}

# Export the prompt per se

prompt walters

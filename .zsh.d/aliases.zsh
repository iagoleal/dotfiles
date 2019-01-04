# Use command `vi` to open neovim.
# It's only two characters long, after all...
# vi can still be used via `/bin/vi` or `\vi`
alias vi=nvim
alias view="nvim -R"

# herbstclient is too big to keep writing...
alias hc=herbstclient

# Git command to manage dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles-gitdir/ --work-tree=$HOME'

# Get weather information
weather() { curl wttr.in/"$*"; }

# Custom notification sender
alias notify="$HOME/.bin/notify"

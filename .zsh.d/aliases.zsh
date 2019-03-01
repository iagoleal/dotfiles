# Use command `vi` to open neovim.
# It's only two characters long, after all...
# vi can still be used via `/bin/vi` or `\vi`
alias vi=nvim
alias view="nvim -R"

# herbstclient is too big to keep writing...
alias hc=herbstclient

# Git command to manage dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles-gitdir/ --work-tree=$HOME'

# Get weather information
function weather { curl wttr.in/"$*"; }

# Open pdf or ebook files
function zth { zathura "$@" &}

# Custom notification sender
alias notify="$HOME/.bin/notify"

# Run mpc with mopidy
port=6601
alias mpcy="mpc -p ${port}"
alias ncmpcppy="ncmpcpp -p ${port}"

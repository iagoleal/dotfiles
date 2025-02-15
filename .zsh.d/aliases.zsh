# Show folder
alias ls='ls --color=auto -F'

# Editor
alias vi=nvim

# Smaller versions of commands with big names
alias hc=herbstclient
alias zth='zathura --fork'
alias hl='hledger --infer-market-prices --infer-equity'

# Git command to manage dotfiles
alias dotfiles='git --git-dir="${XDG_DATA_HOME:-$HOME/.local/state}/dotfiles-gitdir/" --work-tree=$HOME'
alias dtf=dotfiles

alias nix-reload='nix-env -riA nixpkgs.myPackages'

# Get weather information
function weather { curl wttr.in/"$*?m"; }

# Check if a given command exists in the path
function hascmd { (( $+commands[$1] )) }

# Update everything
# function update {
#   if hascmd yay ;then
#     echo 'Updating pacman and AUR...'
#     yay -Syu --noconfirm
#   elif hascmd pacman ;then
#     echo 'Updating pacman... (No AUR helper found)'
#     sudo pacman -Syu --noconfirm
#   elif hascmd apt-get ;then
#     echo 'Updating apt...'
#     sudo apt-get update && sudo apt-get upgrade
#   else
#     echo "What distribution are you running?"
#     return
#   fi
#
#   if hascmd nix; then
#     echo '\n\nNix Nix Nix\n\n'
#     nix-channel --update
#     nix-env -i 'my-packages'
#     nix-env -u '*'
#   fi
#
#   # if hascmd guix; then
#   #   echo '\n\nGuix Guix Guix\n\n'
#   #   guix pull
#   #   guix upgrade
#   # fi
#
#   echo "Updating zsh..."
#   plugin-update
#
#   echo 'Updating NeoVim...'
#   local PACKER_DUMP=$(mktemp --suffix='_PACKER')
#   nvim \
#     +"autocmd User PackerComplete UpdateRemotePlugins | sleep 1 | write! $PACKER_DUMP | TSUpdateSync | quitall" \
#     +PackerSync
#   cat $PACKER_DUMP
#
#   echo "\nUpdating Haskell...\n"
#   ghcup upgrade
#   cabal update
#
#   echo "\nUpdating Julia...\n"
#   juliaup update
#
#   notify-send -u normal "Updated" "C'est fini"
# }

function trash { mv -i $@ ${XDG_DATA_HOME:-$HOME/.local/share}/Trash }

function doi2bib {
  curl -sLH "Accept: application/x-bibtex" "https://dx.doi.org/$@" | sed -r -e '1s/, /,\n  /' -e 's/}, /},\n  /g' -e '$s/}}/}\n}/' -e '1s/^[[:space:]]*//'
}

# Convert a mac address to corresponding local ip
function mac2ip {
  local fline=$(ip neigh | grep "$1");
  echo ${fline%% *}
}

function extract {
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2) tar xjvf $1 ;;
      *.tar.gz)  tar xzvf $1 ;;
      *.tar.xz)  tar xJvf $1 ;;
      *.bz2)     bunzip2 $1 ;;
      *.rar)     unrar xv $1 ;;
      *.gz)      gunzip $1 ;;
      *.tar)     tar xvf $1 ;;
      *.tbz2)    tar xjvf $1 ;;
      *.tgz)     tar xzvf $1 ;;
      *.zip)     unzip $1 ;;
      *.7z)      7z $1 ;;
      *.xz)      xz -vd $1 ;;
      *)         echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}
zstyle ":completion:*:*:extract:*" file-patterns "*.{tar.bz2,tar.gz,tar.xz,bz2,rar,gz,tar,tbz2,tgz,zip,7z,xz}"

function countdown {
  local date1=$((`date +%s` + $1));
  while [ "$date1" -ge `date +%s` ]; do
    ## Is this more than 24h away?
    days=$(($(($(( $date1 - $(date +%s))) * 1 ))/86400))
    echo -ne "$days day(s) and $(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)\r";
    sleep 0.1
  done
  hascmd notify && notify "Finished countdown"
}

function stopwatch {
  local date1=`date +%s`;
  while true; do
    days=$(( $(($(date +%s) - date1)) / 86400 ))
    echo -ne "$days day(s) and $(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r";
    sleep 0.1
  done
}

# Random integer generator.
# Generate numbers between $1 and $2 inclusive.
function rand {
  local OFFSET=${1}
  local BASE=$(( ${2} - ${OFFSET} + 1 ))
  echo $[${RANDOM}%${BASE}+${OFFSET}]
}

# Create only path portion of filename
function mkparent {
  mkdir -p "$(dirname "$1")"
}

function timev {
  local TIMEFMT=$'command: %J
=======================
    Time Statistics
=======================
CPU:    \t%P
  user  \t%*U s
  system\t%*S s
  total \t%*E s
Memory:
  avg shared  \t%X KB
  avg unshared\t%D KB
  total       \t%K KB
  max memory  \t%M MB
Page Faults:
  disk: \t%F
  other:\t%R'
  time "$@"
}

# Open different file formats by extension
alias -s {pdf,ps,xps,djvu,epub}=zathura
alias -s {jpg,jpeg,png,bmp,gif}=imv-folder
alias -s {avi,mkv,webm,mp4}=mpv
alias -s svg=inkview

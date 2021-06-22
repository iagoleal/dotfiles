# Show folder
alias ls='ls --color'

# Editor
alias vi=nvim

# herbstclient is too big to keep writing...
alias hc=herbstclient

# Git command to manage dotfiles
alias dotfiles='git --git-dir=$HOME/.dotfiles-gitdir/ --work-tree=$HOME'
alias dtf=dotfiles

# For Haskell
alias ghc='stack ghc'
alias ghci='stack ghci'
alias runhaskell='stack runhaskell'

# Custom notification sender
alias notify="$HOME/.bin/notify"

# Get weather information
function weather { curl wttr.in/"$*"; }

# Update everything
function update {
  yay -Syu --noconfirm
  nvim --headless +PackerSync +PackerCompile +qall
  stack upgrade && stack update
}

# Open pdf or ebook files
function zth { zathura "$@" &}
zstyle ":completion:*:*:zth:*" file-patterns "*.{pdf,djvu,epub,ps,xps}"

function trash { mv -i $@ ~/.trash }

function doi2bib {
    curl -LH "Accept: text/bibliography; style=bibtex" "http://dx.doi.org/$@" | sed -r -e '1s/, /,\n  /' -e 's/}, /},\n  /g' -e '$s/}}/}\n}/' -e '1s/^[[:space:]]*//'
}


extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjvf $1 ;;
            *.tar.gz)    tar xzvf $1 ;;
            *.tar.xz)    tar xJvf $1 ;;
            *.bz2)       bunzip2 $1 ;;
            *.rar)       unrar xv $1 ;;
            *.gz)        gunzip $1 ;;
            *.tar)       tar xvf $1 ;;
            *.tbz2)      tar xjvf $1 ;;
            *.tgz)       tar xzvf $1 ;;
            *.zip)       unzip $1 ;;
            *.7z)        7z $1 ;;
            *.xz)        xz -vd $1 ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}
zstyle ":completion:*:*:extract:*" file-patterns "*.{tar.bz2,tar.gz,tar.xz,bz2,rar,gz,tar,tbz2,tgz,zip,7z,xz}"

countdown(){
    date1=$((`date +%s` + $1));
    while [ "$date1" -ge `date +%s` ]; do
    ## Is this more than 24h away?
    days=$(($(($(( $date1 - $(date +%s))) * 1 ))/86400))
    echo -ne "$days day(s) and $(date -u --date @$(($date1 - `date +%s`)) +%H:%M:%S)\r";
    sleep 0.1
    done
}

stopwatch(){
    date1=`date +%s`;
    while true; do
    days=$(( $(($(date +%s) - date1)) / 86400 ))
    echo -ne "$days day(s) and $(date -u --date @$((`date +%s` - $date1)) +%H:%M:%S)\r";
    sleep 0.1
    done
}

# Open different file formats by extension
alias -s {pdf,ps,xps,djvu,epub}=zathura
alias -s {jpg,jpeg,png,bmp}=feh
alias -s gif=firefox
alias -s {avi,mkv,webm,mp4}=mpv
alias -s svg=display

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
zstyle ":completion:*:*:zth:*" file-patterns "*.{pdf,djvu,epub,ps,xps}"

# Custom notification sender
alias notify="$HOME/.bin/notify"

# Run mpc with mopidy
port=6601
alias mpcy="mpc -p ${port}"
alias ncmpcppy="ncmpcpp -p ${port}"

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

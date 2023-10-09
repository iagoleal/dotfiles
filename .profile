#----------------------------
# XDG compliance
#----------------------------

# The XDG paths themselves
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_DATA_DIRS="/usr/local/share:/usr/share:$HOME/.local/share/applications/"
export XDG_CONFIG_DIRS=/etc/xdg

# History files
export HISTFILE="${XDG_STATE_HOME}/bash/history"
export LESSHISTFILE="${XDG_STATE_HOME}/less/history"
export SQLITE_HISTORY="${XDG_STATE_HOME}/sqlite/history"
export NODE_REPL_HISTORY="${XDG_STATE_HOME}/node/history"

# Nix
export NIX_PATH="${XDG_STATE_HOME}/nix/defexpr/channels:${NIX_PATH}"

# Haskell
export GHCUP_USE_XDG_DIRS=true
export CABAL_CONFIG="$XDG_CONFIG_HOME"/cabal/config
export CABAL_DIR="$XDG_DATA_HOME"/cabal
export STACK_XDG=1

export GTK2_RC_FILES="$XDG_CONFIG_HOME"/gtk-2.0/gtkrc

export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME"/jupyter


# readline
export INPUTRC="$XDG_CONFIG_HOME"/readline/inputrc

# TeX
export TEXMFHOME="$XDG_DATA_HOME/texmf"
export TEXMFVAR="$XDG_CACHE_HOME/texlive/texmf-var"
export TEXMFCONFIG="$XDG_CONFIG_HOME/texlive/texmf-config"

export W3M_DIR="$XDG_DATA_HOME"/w3m

# pass
export PASSWORD_STORE_DIR="$XDG_DATA_HOME"/pass

export XCURSOR_PATH=/usr/share/icons:$XDG_DATA_HOME/icons

#----------------------------
# For Package Managers
#----------------------------

# Nix needs this to find the proper locale
export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive

GUIX_PROFILE="$HOME/.guix-profile"
. "$GUIX_PROFILE/etc/profile"

GUIX_PROFILE="$HOME/.config/guix/current"
. "$GUIX_PROFILE/etc/profile"

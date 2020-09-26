# My Linux packages and configurations

## Operational System: **Arch Linux**


## Applications Overview

| Action            | Program       |
|-------------------|---------------|
| Operational System| Arch Linux    |
| Shell             | zsh           |
| Window Manager    | herbstluftwm  |
| Terminal Emulator | st            |
| App Launcher      | dmenu         |
| Text Editor       | nvim          |
| Browser           | firefox       |
| File Manager      | pcmanfm       |
| Network Manager   | wicd          |
| Music Player      | mpd + ncmpcpp |
| Video Player      | mpv           |
| Image Viewer      | feh           |
| PDF   Viewer      | zathura       |
| Screen Locker     | slock         |
| Font              | Source Pro    |


## Packages

Everything is going to  be referenced by its _pacman_ package name.

* base and base-devel packages
	* `# pacman -S base base-devel`
	* A system without _gcc_ is no system for me

### Shell
* zsh
	* `# pacman -S zsh`

* grml's zsh setup
	* `# pacman -S grml-zsh-config`
	* Turns zsh into the one from arch install disk

* Syntax highlighting
* `# pacman -S zsh-syntax-highlighting`
	* Needs to add the line `source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh` to `~/.zshrc`
	* Enables Fish-like syntax highlighting on the shell

### Internet Configuration
* Dialog, iw, WPA
	* `# pacman -S dialog iw wpa_supplicant`
	* MUST BE INSTALLED DURING SYSTEM INSTALLATION
	* We need these packages to properly run a wi-fi connection

* Wicd
	* `# pacman -S wicd`

### Managing permissions
* Polkit
	* `# pacman -S polkit`
	* still have to learn how to properly use it

### GPU Drivers
* Intel
	* `# pacman -S xf86-video-intel`

* Nvidia (open source)
	* `# pacman -S xf86-video-nouveau`

### External Media
#### Automount
* Udisks
	* `# pacman -S udisks2`

* udiskie
	* `# pacman -S udiskie`
	* Daemon to control udisks
	* Must be started

#### Read / write access to NTFS
* ntfs-3g
	* `# pacman -S ntfs-3g`
	* Linux kernel only comes with read-only support for ntfs drivers.
	* This allows `mount` to also have write capabilites.

#### MTP file transfer
* Android File Transfer
	* `# pacman -S android-file-transfer`
	* Mount MTP devices (with focus on android)

### Audio (low-level)
* Alsa
	* `# pacman -S alsa-utils`
	* test with `alsamixer` and press `m` to unmute
	* `speaker-text -c2` to test stereo audio

* Pulseaudio
	* `# pacman -S pavucontrol`
	* Includes gui control interface and installs dependencies


### The Programming side

#### Haskell
* GHC compiler
	* `# pacman -S ghc`
	* Well well well, so we've come to this ( :D )

* Hoogle
	* `# pacman -S hoogle`
		* A search tool for haskell functions, types, etc.
		* Should run `hoogle generate` after installation

#### Julia
* Julia
	* `# pacman -S julia`

#### Python
* The Scipy connundrum
	* `# pacman -S python-numpy python-scipy python-matplotlib`
		* At first, I only have these three
		* _cvxpy_ is installed from **pip**, not **aur**. Maybe I should change that.

* Pip
	* `# pacman -S python-pip`
	* yeah really

* cvxpy
	* `pip install cvxpy`
	* maybe I should change to **aur**...

#### Lua
* Lua
	* `# pacman -S lua`

#### Notebooks
* Jupyter Notebook
	* `# pacman -S jupyter-notebook`

#### LaTeX
* Texlive
	* `# pacman -S texlive-most texlive-lang`
	* `aur/texlive-most-docs`
	* Everything. When it comes to latex, it's better to have *everything* installed.

#### Typesetting Music
* LilyPond
	* `community/lilypond`
	* software for score writing

### The CLI side

#### Process Manager
* Htop
	* `# pacman -S htop`
	* A great process and memory usage viewer
	* Substitute for `top`

#### Text editors
* Neovim
	* `# pacman -S neovim`
	* everyone must take a side someday
	* Vim plugs are on `.vimrc`
	* `alias vi=nvim`

#### Media Players

* mpd (Media Player Daemon)
	* `# pacman -S mpd mpc ncmpcpp`
	* Server for music. Allows remote access and has lots of features
	* Important note, it is bounded to _systemd_ as an user
	* `$ systemctl --user enable mpd.service`
	* mpc: Minimalist CLI to control mpd
	* ncmpcpp: Nice media player client for mpd

* mpv
	* `# pacman -S mpv`
	* CLI controlled video player (mplayer sucessor)

* mpsyt (mps-youtube)
	* `# pacman -S mps-youtube`
	* CLI app that allows direct access to youtube
	* ( much less RAM usage :D )

#### Chinese input support
* fcitx
	* `# pacman -S fcitx fcitx-im fcitx-configtool`
	* `fcitx` is a module to input non-latin characters
	* `fcitxi-im` adds support to gtk and qt applications
	* `fcitx-configtools` is a gtk application to configure `fcitx`

#### File managing
* ranger
	* `# pacman -S ranger`
	* CLI file manager with vim bindings

* Dropbox
	* `# yay -S dropbox dropbox-cli`
	* It's always important to store some files online
	* Enabled at login via
	* `$ systemctl --user enable dropbox.service`

### The GUI side

#### Xorg per se (X11)
* Xorg
	* `# pacman -S xorg xorg-server xorg-xinit`
	* All the dependencies for a running X server
	* Edit config file at `/etc/X11/xorg.conf`

* Xdotool
	* `# pacman -S xdotool`
	* Command-line tool for X11 automation

* xkbset
	* `aur/xkbset`
	* Enables accessiblity tools for xkb
	* Really good for sticky keys

* Xclip
	* `# pacman -S xclip`
	* CLI tool to interact with the X Clipboard

#### Controlling blue light
* Redshift
	* `# pacman -S redshift`
	* Software to control screen temperature
	* according to time of the day
	* Autostart via `$ systemctl --user enable redshift.service`

#### Window Manager
* Herbstluftwm
	* `community/herbstluftwm`
	* Manual tiling window manager. Oh god, it's amazing!

#### Lock screen
* slock
	* `# pacman -S slock`
	* locker for when I'm away of my screen

* xautolock
	* `# pacman -S xautolock`
	* Enable lock when screen is inactive

#### Compositor
* Compton
	* `# pacman -S compton`
	* X compositor, for that sexy looking effects

#### Application Laucher
* dmenu
	* `# pacman -S dmenu`

#### Terminal Emulator
* st

* xterm
	* `# pacman -S xterm`
	* Config file is `~/.Xresources`.
	* After editing, run it with `xrdb ~/.Xresources` for refresing configs.

#### Notifications
* Dunst
	* `# pacman -S dunst`
	* A notification daemon

#### Browsing the internet
* w3m _(CLI)_
	* `# pacman -S w3m`
	* still need to learn how to use

* Firefox _(GUI)_
	* `# pacman -S firefox`
	* A memory hungry monster, but the best browser I know at the moment
	* Style config file is at `~/.mozilla/firefox/1aytccip.default/chrome/userChrome.css`

#### Pdf viewer
* zathura
	* `pacman -S zathura zathura-cb zathura-djvu zathura-pdf-mupdf zathura-ps`
	* zathura + file-specific plugins


#### Dealing with images
* feh
	* `# pacman -S feh`
	* A GUI based image viewer

* ImageMagick
	* `# pacman -S imagemagick`
	* A CLI tool for editing and dealing with image

* Pinta
	* `# pacman -S pinta`
	* A simple image editor. Extremely simpler than gimp

* Gimp
	* `# pacman -S gimp`
	* A not so simple image editor. Someday, I should learn how to properly use it

### MISC

#### Spaced Repetition
* Anki
	* `# pacman -S anki`
	* A nice flashcards application.
	* It syncs with my android phone and allows html / latex on cards.
	* The only downside is that the interface is nothing like minimal :(

#### Games
* Nethack
	* `# pacman -S nethack`
* Dwarf fortress
	* `# pacman -S dwarffortress`

### Fonts
For styles use: `fc-list | grep _title_`

* Source Code Pro
	* `# pacman -S adobe-source-code-pro-fonts`
	* Nice family of monospaced fonts by adobe. Includes lots of styles.

* Inconsolata, Hack, mononoki, Fantasque Sans Mono
	* `# pacman -S ttf-inconsolata ttf-hack`
	* `$ yay -S ttf-monoki ttf-fantasque-sans-mono`
	* Other monospaced fonts

* Roboto family
	* `# pacman -S ttf-roboto`
	* Pack with a lot, really a lotta lot of fonts

* Adobe Source Han Sans / Serif
	* `# pacman -S adobe-source-han-serif-otc-fonts adobe-source-han-sans-otc-fonts`
	* Pack with fonts for CJK languages

* Material Design Icons
	* `aur/ttf-material-design-icons-git`
	* Icons font, really good
	* Manual located at:
	* https://cdn.materialdesignicons.com

# My Linux packages and configurations

## Operational System: **Arch Linux**

## Filesystem (on a 500GB HDD)

```
> lsblk
NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
sda      8:0    0 465.8G  0 disk
├─sda1   8:1    0   512M  0 part /boot
├─sda2   8:2    0  97.7G  0 part /
├─sda3   8:3    0 348.1G  0 part /home
└─sda4   8:4    0  19.5G  0 part [SWAP]
```

## Applications Overview

| Action            | Program       |
|-------------------|---------------|
| Shell             | zsh           |
| Window Manager    | herbstluftwm  |
| Terminal Emulator | termite       |
| App Launcher      | rofi          |
| Text Editor       | nvim          |
| Browser           | firefox       |
| File Manager      | pcmanfm       |
| Music Player      | mpd + ncmpcpp |
| Video Player      | mpv           |
| Image Viewer      | feh           |
| PDF   Viewer      | zathura       |


## Keyboard layout

* `br-abnt2`

Over this layout, I am also using some custom modifications on
`xkb` and `xmodmap`.

My main options are:

* `Capslock` key acts as `Escape`
* Swap `Left Control` and `Left Alt` keys
* `Menu` key acts as `Compose`
* Classic `Control-Alt-Backspace` command to kill X
* `Escape` and `AltGr-g` act as `dead_greek`

Command used to set layout:

```
setxkbmap -layout br \
    -option "caps:escape" \
    -option "ctrl:swap_lalt_lctl" \
    -option "compose:menu" \
    -option "terminate:ctrl_alt_bksp";
xmodmap ~/.Xmodmap
```

#### Why a Greek key?
As a mathematician,
a great amount of my time on the computer is spent writing in Latex.
Besides that, I also program a lot in Julia,
a language with full Unicode support.
With this in mind and having heard all the legends
about the Space-cadet keyboard
from the golden age of the Lisp machines
(not an emacs user, I swear!),
I decided to try and see how much my Greek would speed up.

A simple
`cat '/usr/share/X11/locale/en_US.UTF-8/Compose' | grep 'greek'`
shows that the xkb system already comes with an interface to handle a Greek dead key.
From that, a simple remapping allows me to save a few keystrokes
when writing any text full of Greek characters.
It also requires a few Latex packages to handle the Unicode input,
but it is well worth it.

A dead key to directly input special map symbols,
mirroring the `Top` key on the old Space-cadet,
would also be really nice.
But, as there is no preconfigured default,
I still need to find the time to edit the `xkb` files.


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
	* Is it better than netctl?

### Managing permissions
* Polkit
	* `# pacman -S polkit`
	* still have to learn how to properly use it

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
	* `# pacman -S mpd`
	* Server for music. Allows remote access and has lots of features
	* Important note, it is bounded to _systemd_ as an user
	* `$ systemctl --user enable mpd.service`

* Mopidy + Spotify
	* `# pacman -S mopidy`
	* `# yaourt -S mopidy-spotify`
	* MPD or HTTP server with support to various streaming services.
	* In my case, I use essentially for Spotify.

* mpc
	* `# pacman -S mpc`
	* Minimalist CLI to control mpd

* ncmpcpp
	* `# pacman -S ncmpcpp`
	* Nice media player client for mpd

* cava
	* `yaourt -S cava`
	* Audio visualizer. Really pretty
	* specially alongside ncmppp
	* (get its input directly from alsa, not mpd)

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
	* `# yaourt -S dropbox dropbox-cli`
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

* i3
	* `# pacman -S i3-gaps i3blocks i3lock i3status` or `# pacman -S i3` to dowloand entire group
	* Tiling window manager. First experience with something like it
	* (besides tmux)
* Alternatives: bspwm, awesome, xmonad, herbstluftwm, spectrwm

 * sxhkd
	* `# pacman -S sxhkd`
	* Daemon to set and control custom keybindings
	* Really useful with something like bspwm

#### Lock screen
* i3lock
	* `# pacman -S i3lock`
	* locker for when I'm away of my screen

* xautolock
	* `# pacman -S xautolock`
	* Enable lock when screen is inactive

#### Compositor
* Compton
	* `# pacman -S compton`
	* X compositor, for that sexy looking effects

#### Application Laucher
* Rofi
	* `# pacman -S rofi`
	* A dmenu substitute.
	* Good as an applcation / window switcher
	* currently mapped to `Super+Shift+d`
	* Still need to learn how to really use it
	* Config file at `~/.config/rofi/config.rasi`

#### Terminal Emulator
* Termite
	* `# pacman -S termite`
	* Config file is `~/.config/termite/config`.
* Alternatives: urxvt, termite, xterm, st

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


#### Screenshooter
* import
	* A tool included on imagemagick

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
	* `$ yaourt -S ttf-monoki ttf-fantasque-sans-mono`
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


### Must finish the gpu part D:

## Comments on wms
### i3
Easy to use but limited. What it does, it does flawlessly but what it doesn't... is a real pain to get.
Modes are divine and the config is really well organized.
### bspwm
Config is great and it is very powerful but the window spawning layout is *horrible*
### herbstluft
Config is great, layout is wonderful but no floating??? D:
### Xmonad
Aah the power of Haskell! Gotta sit someday and really configure it


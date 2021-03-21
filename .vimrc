
" Load language specific plugin and indentation files
filetype plugin indent on
set nocompatible

"""""""""""
" Plugins "
"""""""""""

" Verify if vim-plug exists and download it if not
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Initialize vim-plug
call plug#begin('~/.vim/bundle')

" Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'monkoose/fzf-hoogle.vim', {'for': 'haskell'}

Plug 'b3nj5m1n/kommentary'                            " Toggle commentary
Plug 'tpope/vim-surround'                             " Edit surrounding objects
Plug 'tpope/vim-dispatch'                             " Async make
Plug 'chrisbra/Colorizer' , { 'on': 'ColorToggle' }   " Show colors from code

"" Filetype specific

" Latex
Plug 'lervag/vimtex', { 'for': 'tex' }
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_compiler_progname = 'nvr'
let g:vimtex_quickfix_mode=2
let g:vimtex_quickfix_autoclose_after_keystrokes=2
let g:vimtex_quickfix_open_on_warning=1
let g:vimtex_indent_enabled=0
let g:vimtex_indent_delims = {}

" Markdown
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }
let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_conceal = 0
let g:vim_markdown_fenced_languages = ['c++=cpp', 'viml=vim', 'bash=sh', 'ini=dosini']
let g:vim_markdown_math = 1
let g:vim_markdown_frontmatter = 1
let g:vim_markdown_new_list_item_indent = 4

Plug 'JuliaEditorSupport/julia-vim', { 'for': 'julia'   }
Plug 'neovimhaskell/haskell-vim',    { 'for': 'haskell' }
Plug 'bakpakin/fennel.vim',          { 'for': 'fennel'  }
Plug 'wlangstroth/vim-racket',       { 'for': 'racket'  }
Plug 'tikhomirov/vim-glsl'

"" Themes
Plug 'ayu-theme/ayu-vim'
Plug 'savq/melange'

"" NeoVim specific
if has("nvim")
  " REPLs
  Plug 'hkupty/iron.nvim'

  Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update"
  Plug 'p00f/nvim-ts-rainbow'

  Plug 'luochen1990/rainbow', { 'on': ['RainbowToggleOn', 'RainbowToggle'] } " Colorize parentheses
  let g:rainbow_active = 0
endif

" Color picker
Plug 'KabbAmine/vCoolor.vim'

" Stop plugin system
call plug#end()

if has("nvim")
  luafile $HOME/.config/nvim/plugins.lua
endif

"""""""""""""""""""
" Plugin Settings "
"""""""""""""""""""

let g:haskell_enable_quantification   = 1   " to enable highlighting of `forall`
let g:haskell_enable_recursivedo      = 1   " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax      = 1   " to enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1   " to enable highlighting of `pattern`
let g:haskell_enable_typeroles        = 1   " to enable highlighting of type roles
let g:haskell_enable_static_pointers  = 1   " to enable highlighting of `static`
let g:haskell_backpack                = 1   " to enable highlighting of backpack keywords
let g:haskell_indent_case_alternative = 1
let g:haskell_indent_if = 1
let g:haskell_indent_case = 2
let g:haskell_indent_let = 4
let g:haskell_indent_where = 10
let g:haskell_indent_before_where = 1
let g:haskell_indent_after_bare_where = 1
let g:haskell_indent_do = 3
let g:haskell_indent_in = 0
let g:haskell_indent_guard = 2


"""""""""""""""
" Keybindings "
"""""""""""""""

" <leader> key is Space
let mapleader="\<Space>"

" Exit terminal with ESC
tnoremap <Esc> <C-\><C-n>

" Disable search highlighting (until next search)
nnoremap <leader><Space> :nohlsearch<CR>

" Spell checks previous mistake and corrects to first suggestion
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

"" Building keymaps
nnoremap <leader>m :w<CR>:Dispatch<CR>
nnoremap <leader>M :w<CR>:Dispatch!<CR>
nnoremap <F12> :w<CR>:Dispatch!<CR>

" Toggle Color Highlight
nnoremap <leader>cc :ColorToggle<CR>
nnoremap <leader>cf :ColorSwapFgBg<CR>
" Toggle Rainbow Parentheses
nnoremap <leader>cr :RainbowToggle<CR>

" Toggle quickfix
function! ToggleQuickfix()
  let l:nr =  winnr("$")
  if l:nr == 1
    copen
  else
    cclose
  endif
endfunction
nnoremap <leader>q :call ToggleQuickfix()<CR>

" FZF
nnoremap <leader>fe :Files<CR>
nnoremap <leader>fb :Buffers<CR>

" Iron REPL
let g:iron_map_defaults=0
let g:iron_map_extended=1
nnoremap <leader>it    <Plug>(iron-send-motion)
vnoremap <leader>iv    <Plug>(iron-visual-send)
nnoremap <leader>i.    <Plug>(iron-repeat-cmd)
nnoremap <leader>i<Space> <Plug>(iron-send-line)
nnoremap <leader>ii    <Plug>(iron-send-line)
nnoremap <leader>i<CR> <Plug>(iron-cr)
nnoremap <leader>ic    <plug>(iron-interrupt)
nnoremap <leader>iq    <Plug>(iron-exit)
nnoremap <leader>il    <Plug>(iron-clear)
nnoremap <leader>ip    <Plug>(iron-send-motion)ip
nnoremap <leader>is :IronRepl<CR>
nnoremap <leader>ir :IronRestart<CR>
nmap <leader>if <Cmd>lua require("iron").core.send(vim.api.nvim_buf_get_option(0,"ft"), vim.api.nvim_buf_get_lines(0, 0, -1, false))<Cr>

"""""""""
" Theme "
"""""""""

" Enable syntax highlighting
syntax enable

set synmaxcol=180
set nowrap

set laststatus=2
set showmode
set showcmd
set ruler
set conceallevel=0

if has("termguicolors")
  set termguicolors
  set background=dark
  let ayucolor="mirage"
  colorscheme melange
endif

augroup CursorLine
  autocmd!
  autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline cursorcolumn
  autocmd WinLeave * setlocal nocursorline nocursorcolumn
augroup END

augroup Ident
  autocmd!
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup END

set list                  " Show trailing {spaces, tabs}
set listchars=tab:├─,trail:۰,nbsp:☻,extends:⟩,precedes:⟨

set number                " show line numbers
set relativenumber        " Show line numbers relative to current line
set numberwidth=3         " set minimum width of numbers bar
set showmatch             " highlight matching parentheses (useful as hell)

"" Highlights
" Head of a Fold
highlight Folded ctermbg=Black guibg=Black
" Trailing spaces
highlight Whitespace ctermfg=magenta guifg=magenta
" Matching Parentheses
highlight MatchParen guibg=none guifg=magenta ctermfg=magenta gui=Bold,Underline cterm=underline
" Spell checker colors
if (v:version >= 700)
  highlight SpellBad   ctermfg=Red     cterm=Underline guifg=LightRed   gui=Underline guisp=LightRed
  highlight SpellCap   ctermfg=Blue    cterm=Underline guifg=LightBlue  gui=Underline guisp=Blue
  highlight SpellLocal ctermfg=Green   cterm=Underline guifg=LightGreen gui=Underline guisp=Green
  highlight SpellRare  ctermfg=Yellow  cterm=underline guifg=Orange     gui=Underline guisp=Orange
endif

""""""""
" MISC "
""""""""

" Search
set incsearch               " search as characters are entered
set hlsearch                " highlight matches
set ignorecase              " case-insensitive searchs / substitutions
set smartcase               " If terms are all lowercase, ignore case. Consider case otherwise.

set wildmenu                " visual menu for command autocompletion
set wildmode=full,list,full " first autocomplete the word, afterwards run across the list

set splitright              " Vertical split to the right (default is left)

" Spaces and Tabs, settling the war
set tabstop=2               " n spaces per tab visually
set softtabstop=2           " n spaces per tab when editing
set shiftwidth=2            " n spaces for autoindent
set expandtab               " If active, tabs are converted to spaces
set smarttab

" Indentation
set autoindent

" Set backup files
set backup
set backupdir=~/.vim/tmp,~/.tmp,~/tmp,/var/tmp,/tmp,.
set backupskip=/tmp/*,/private/tmp/*
set directory=~/.vim/tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set writebackup

" Set Thesaurus file
set thesaurus+=~/.vim/thesaurus/mthesaur.txt

" Filetype specific
augroup Langs
  autocmd!
  autocmd FileType scheme   setlocal softtabstop=2 shiftwidth=2 lisp autoindent
  autocmd FileType haskell  let b:dispatch = 'stack build'
  autocmd FileType markdown setlocal spell
  autocmd FileType latex    setlocal spell
  autocmd FileType make     setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=0
  autocmd FileType fennel   let b:dispatch = 'love %:p:h'
augroup END

augroup HoogleMaps
  autocmd!
  autocmd FileType haskell nnoremap <buffer> <space>hh :Hoogle <C-r><C-w><CR>
  autocmd FileType haskell setlocal keywordprg=:Hoogle
augroup END

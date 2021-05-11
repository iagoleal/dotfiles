" Load language specific plugin and indentation files
filetype plugin indent on
set nocompatible

"""""""""""
" Plugins "
"""""""""""

" Verify if vim-plug exists and download it if not
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Initialize vim-plug
call plug#begin('~/.config/nvim/bundle')
" Treesitter
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'p00f/nvim-ts-rainbow'

" LSP
Plug 'neovim/nvim-lspconfig'

" REPL
Plug 'hkupty/iron.nvim'

" Fuzzy Search
" Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
let g:fzf_command_prefix = 'FZF'
Plug 'monkoose/fzf-hoogle.vim', {'for': 'haskell'}

" Major utilities
Plug 'terrortylor/nvim-comment'                       " Toggle commentary
Plug 'tpope/vim-surround'                             " Edit surrounding objects (vimscript)
Plug 'tpope/vim-dispatch'                             " Async make      (vimscript)
Plug 'junegunn/vim-easy-align'                        " Alignment utils (vimscript)
Plug 'norcalli/nvim-colorizer.lua'                    " Colorize color codes
Plug 'luochen1990/rainbow', { 'on': ['RainbowToggleOn', 'RainbowToggle'] } " Colorize parentheses
let g:rainbow_active = 0

" Color picker
" Can I remake this in lua with floating windows?
Plug 'KabbAmine/vCoolor.vim'

"" Filetype specific
Plug 'lervag/vimtex',                { 'for': 'tex'      }
Plug 'plasticboy/vim-markdown',      { 'for': 'markdown' }
Plug 'JuliaEditorSupport/julia-vim', { 'for': 'julia'    }
Plug 'neovimhaskell/haskell-vim',    { 'for': 'haskell'  }
Plug 'bakpakin/fennel.vim',          { 'for': 'fennel'   }
Plug 'wlangstroth/vim-racket',       { 'for': 'racket'   }
Plug 'tikhomirov/vim-glsl'
" Plug 'derekelkins/agda-vim'

"" Themes
Plug 'ayu-theme/ayu-vim'
Plug 'savq/melange'
" Plug 'rktjmp/lush.nvim'

" Stop plugin system
call plug#end()

"""""""""
" Theme "
"""""""""

" Enable syntax highlighting
syntax enable

set synmaxcol=180
set nowrap

set showcmd
set ruler
set conceallevel=0

if has("termguicolors")
  set termguicolors
  set background=dark
  let ayucolor="mirage"
  colorscheme ayu
endif

" augroup CursorLine
"   autocmd!
"   autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline cursorcolumn
"   autocmd WinLeave * setlocal nocursorline nocursorcolumn
" augroup END

augroup Ident
  autocmd!
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o
augroup END

" No need for numbers and cursors on terminal lines
augroup Terminal
  autocmd!
  autocmd TermOpen * setlocal nonumber norelativenumber nocursorline nocursorcolumn
augroup END

set list                  " Show trailing {spaces, tabs}
set listchars=tab:├─,trail:۰,nbsp:☻,extends:⟩,precedes:⟨

set number                " show line numbers
set relativenumber        " Show line numbers relative to current line
set numberwidth=2         " set minimum width of numbers bar
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

" Configure statusline
lua require("statusline")
lua require("tabline")

""""""""
" MISC "
""""""""

" Search
set incsearch               " search as characters are entered
set hlsearch                " highlight matches
set ignorecase              " case-insensitive searchs / substitutions
set smartcase               " If terms are all lowercase, ignore case. Consider case otherwise.

" Find files on subfolders
set path+=**

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

" Set undo
set undodir=~/.tmp,~/tmp,/var/tmp,/tmp,$XDG_DATA_HOME/nvim/undo,.
set undofile

" Set Thesaurus file
set thesaurus+=~/.config/nvim/thesaurus/mthesaur.txt

"""""""""""""""""""
" Plugin Settings "
"""""""""""""""""""
lua require("plugins")
lua require("lsp")

lua require('nvim_comment').setup({comment_empty = false})

" Vimtex
let g:tex_flavor                                 = 'latex'
let g:vimtex_view_method                         = 'zathura'
let g:vimtex_compiler_progname                   = 'nvr'
let g:vimtex_quickfix_mode                       = 2
let g:vimtex_quickfix_autoclose_after_keystrokes = 2
let g:vimtex_quickfix_open_on_warning            = 1
let g:vimtex_indent_enabled                      = 0
let g:vimtex_indent_delims                       = {}

" Vim Markdown
let g:vim_markdown_folding_disabled     = 1
let g:vim_markdown_conceal              = 0
let g:vim_markdown_fenced_languages     = ['c++=cpp', 'viml=vim', 'bash=sh', 'ini=dosini']
let g:vim_markdown_math                 = 1
let g:vim_markdown_frontmatter          = 1
let g:vim_markdown_new_list_item_indent = 4

" Nvim Haskell
let g:haskell_enable_quantification   = 1   " to enable highlighting of `forall`
let g:haskell_enable_recursivedo      = 1   " to enable highlighting of `mdo` and `rec`
let g:haskell_enable_arrowsyntax      = 1   " to enable highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1   " to enable highlighting of `pattern`
let g:haskell_enable_typeroles        = 1   " to enable highlighting of type roles
let g:haskell_enable_static_pointers  = 1   " to enable highlighting of `static`
let g:haskell_backpack                = 1   " to enable highlighting of backpack keywords
let g:haskell_indent_case_alternative = 1
let g:haskell_indent_if               = 1
let g:haskell_indent_case             = 2
let g:haskell_indent_let              = 4
let g:haskell_indent_where            = 10
let g:haskell_indent_before_where     = 1
let g:haskell_indent_after_bare_where = 1
let g:haskell_indent_do               = 3
let g:haskell_indent_in               = 0
let g:haskell_indent_guard            = 2

"""""""""""""""
" Keybindings "
"""""""""""""""

" <leader> key is Space
let mapleader="\<Space>"

" Exit terminal with ESC
tnoremap <Esc> <C-\><C-n>

" Disable search highlighting (until next search)
nnoremap <leader><Space> :nohlsearch<CR>

" Highlight cross around cursor
nnoremap <leader>cl :set cursorline! cursorcolumn!<CR>

" Spell checks previous mistake and corrects to first suggestion
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

"" Navigation
" Quickfix
nnoremap ]q :cnext<cr>zz
nnoremap [q :cprev<cr>zz
nnoremap ]l :lnext<cr>zz
nnoremap [l :lprev<cr>zz
" Buffers
nnoremap ]b :bnext<cr>
nnoremap [b :bprev<cr>
" Tabs
nnoremap ]t :tabn<cr>
nnoremap [t :tabp<cr>

"" Building keymaps
nnoremap <silent> <leader>m :Make<CR>
" nnoremap <leader>M :w<CR>:Dispatch!<CR>

" Toggle Color Highlight
nnoremap <leader>cc :ColorizerToggle<CR>
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
nnoremap <leader>fe :FZFFiles<CR>
nnoremap <leader>fb :FZFBuffers<CR>

" Alignment
nmap <leader>a <Plug>(EasyAlign)
xmap <leader>a <Plug>(EasyAlign)

" Iron REPL
let g:iron_map_defaults=0
let g:iron_map_extended=1
nmap <leader>it       <Plug>(iron-send-motion)
vmap <leader>i<Space> <Plug>(iron-visual-send)
nmap <leader>i.       <Plug>(iron-repeat-cmd)
nmap <leader>i<Space> <Plug>(iron-send-line)
nmap <leader>ii       <Plug>(iron-send-line)
nmap <leader>i<CR>    <Plug>(iron-cr)
nmap <leader>ic       <plug>(iron-interrupt)
nmap <leader>iq       <Plug>(iron-exit)
nmap <leader>il       <Plug>(iron-clear)
nmap <leader>ip       <Plug>(iron-send-motion)ip
nmap <leader>is       :IronRepl<CR>
nmap <leader>ir       :IronRestart<CR>
nmap <leader>if       <Cmd>lua require("iron").core.send(vim.api.nvim_buf_get_option(0,"ft"), vim.api.nvim_buf_get_lines(0, 0, -1, false))<Cr>


"""""""""""""""""""""
" Filetype specific "
"""""""""""""""""""""

augroup Langs
  autocmd!
  autocmd FileType scheme   setlocal softtabstop=2   shiftwidth=2 lisp autoindent
  autocmd FileType haskell  let b:dispatch = 'stack build'
  autocmd FileType haskell  nnoremap <buffer> <space>hh :Hoogle <C-r><C-w><CR>
  autocmd FileType markdown setlocal spell
  autocmd FileType latex    setlocal spell
  autocmd FileType make     setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=0
  autocmd FileType fennel   let b:dispatch = 'love %:p:h'
augroup END

" Reload this file
augroup ReloadRC
  autocmd!
  autocmd BufWritePost $MYVIMRC source $MYVIMRC | redraw | echo "Reloaded init.vim"
augroup END

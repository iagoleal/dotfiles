" Load language specific plugin and indentation files
filetype plugin indent on

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

Plug 'nelstrom/vim-visual-star-search'           " Search highlighted text
Plug 'tpope/vim-commentary'                      " Toggle commentary
Plug 'tpope/vim-surround'                        " Edit surrounding objects
Plug 'tpope/vim-dispatch'                        " Async make
Plug 'godlygeek/tabular'                         " Align tables
Plug 'chrisbra/Colorizer', {'on': 'ColorToggle'} " Show colors from code

Plug 'jalvesaq/vimcmdline'                       " Send line to REPl
" vimcmdline mappings
let cmdline_map_start          = '<LocalLeader>s'
let cmdline_map_send           = '<LocalLeader><Space>'
let cmdline_map_send_and_stay  = '<LocalLeader><S-Space>'
let cmdline_map_source_fun     = '<LocalLeader>f'
let cmdline_map_send_paragraph = '<LocalLeader>p'
let cmdline_map_send_block     = '<LocalLeader>b'
let cmdline_map_quit           = '<LocalLeader>q'

" Snippets
Plug 'SirVer/ultisnips'
let g:UltiSnipsUsePythonVersion = 3
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsSnippetDirectories=[$HOME."/.vim/snips"]

"" Filetype specific

" Latex
Plug 'lervag/vimtex', { 'for': 'tex'}
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_compiler_progname = 'nvr'
let g:vimtex_quickfix_mode=2
let g:vimtex_quickfix_autoclose_after_keystrokes=2
let g:vimtex_quickfix_open_on_warning=1
let g:vimtex_indent_enabled=0
let g:vimtex_indent_delims = {}

" Julia
Plug 'JuliaEditorSupport/julia-vim', {'for': 'julia'}

"" Themes
Plug 'ayu-theme/ayu-vim'

" Stop plugin system
call plug#end()

"""""""""""""""
" Keybindings "
"""""""""""""""

" <leader> key is Space
let mapleader="\<Space>"

" Disable search highlighting (until next search)
nnoremap <leader><Space> :nohlsearch<CR>
" Select all text on file
nnoremap <leader>a ggvG$

" Spell checks previous mistake and corrects to first suggestion
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

"" Filetype-specific keymaps
nnoremap <leader>m :w<CR>:Make<CR>
nnoremap <leader>M :w<CR>:Make!<CR>
" augroup ftSpecific
"     autocmd!
"     " Saves file and run haskell interpreter
"     autocmd FileType haskell nnoremap <buffer> <leader>m :!runhaskell %<CR>
"     " Saves file and run python interpreter
"     autocmd FileType python  nnoremap <buffer> <leader>m :!python %<CR>
" augroup END

" Toggle Color Highlight
nnoremap <leader>cc :ColorToggle<CR>
nnoremap <leader>cf :ColorSwapFgBg<CR>
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

"""""""""
" Theme "
"""""""""

" Enable syntax highlighting
syntax enable

set laststatus=1
set showmode
set showcmd
set noruler

if has("termguicolors")
    set termguicolors
    let ayucolor="dark"
    colorscheme ayu
endif

" augroup CursorLine
"       autocmd!
"       autocmd VimEnter,WinEnter,BufWinEnter * setlocal cursorline cursorcolumn
"       autocmd WinLeave * setlocal nocursorline nocursorcolumn
" augroup END

set list                  " Show trailing {spaces, tabs}
set listchars=tab:├─,trail:۰,nbsp:☻,extends:⟩,precedes:⟨

set number                " show line numbers
set numberwidth=3         " set minimum width of numbers bar
set showmatch             " highlight matching parentheses (useful as hell)

"" Highlights
" Head of a Fold
highlight Folded ctermbg=Black guibg=Black
" Trailing spaces
highlight Whitespace ctermfg=magenta guifg=magenta
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
set incsearch             " search as characters are entered
set hlsearch              " highlight matches
set ignorecase            " case-insensitive searchs / substitutions
set smartcase             " If terms are all lowercase, ignore case. Consider case otherwise.

set wildmode=longest,full " first autocomplete the word, afterwards run across the list
set wildmenu              " visual menu for command autocompletion

set splitright            " Vertical split to the right (default is left)

" Spaces and Tabs, settling the war
set tabstop=4             " n spaces per tab visually
set softtabstop=4         " n spaces per tab when editing
set shiftwidth=4          " n spaces for autoindent
set expandtab             " If active, tabs are converted to spaces
set smarttab

" Indentation
set autoindent

" Set backup files
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp,.
set backupskip=/tmp/*,/private/tmp/*
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set writebackup

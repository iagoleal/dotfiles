" Enable syntax highlighting
syntax enable

" Spaces and Tabs, settling the war
set tabstop=4                " n spaces per tab visually
set softtabstop=4            " n spaces per tab when editing
set shiftwidth=4             " n spaces for autoindent
set expandtab                " If active, tabs are converted to spaces
set smarttab

" Show trailing {spaces, tabs}
set list
set listchars=tab:├─,trail:۰,nbsp:☻

" Indentation
set autoindent
" Load language specific plugin and indentation files
filetype plugin indent on

" UI visual settings
set number                   " show line numbers
set numberwidth=2            " set minimum width of numbers bar

set showcmd                  " show last command at bottom right
" set cursorline             " highlight the current line
set wildmode=longest,full    " first autocomplete the word, after run across the list
set wildmenu                 " visual menu for command autocompletion

set showmatch                " highlight matching parentheses (useful as hell)

set splitright               " Vertical split to the right (default is left)

" Search settings
set incsearch                " search as characters are entered
set hlsearch                 " highlight matches
set ignorecase               " case-insensitive searchs / substitutions
set smartcase                " If terms are all lowercase, ignore case. Consider case otherwise.

" Set backup files
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp,.
set backupskip=/tmp/*,/private/tmp/*
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set writebackup

" " Persistent folds
" augroup AutoSaveFolds
"   autocmd!
"   autocmd BufWinLeave * mkview
"   autocmd BufWinEnter * silent! loadview
" augroup END


""" Key bindings

" <leader> key is comma
let mapleader="\<Space>"

" Disable search highlighting (until next search)
nnoremap <leader><Space> :nohlsearch<CR>
" Highlight last inserted text
nnoremap <leader>V '[v']
" Select all text on file
nnoremap <leader>a ggVG
"Convert line to Title Case
nnoremap <leader>~ :s/\v\C<([A-ZÀ-Ý])([A-ZÀ-Ý]+)>/\u\1\L\2/g

"" Filetype-specific keymaps
" Saves file and run haskell interpreter
autocmd FileType haskell nnoremap <buffer> <leader>m :w<CR> :!runhaskell %<CR>

" Toggle Color Highlight
map <leader>cc :ColorToggle<CR>
map <leader>cf :ColorSwapFgBg<CR>

" Initialize vim-plug
call plug#begin('~/.vim/bundle')

" Beautifuler statusbar
Plug 'itchyny/lightline.vim'

" Search highlighted text
Plug 'nelstrom/vim-visual-star-search'

" Toggle commentary
" gcc for a line / gc + motion for target
Plug 'tpope/vim-commentary'

" Edit surrounding objects
Plug 'tpope/vim-surround'

" Show colors from code
Plug 'chrisbra/Colorizer', {'on': 'ColorToggle'}

"" Filetype specific
" Plugin to manage latex files
Plug 'lervag/vimtex', { 'for': 'tex'}

" Themes
Plug 'bluz71/vim-moonfly-colors'
" Plug 'dracula/vim', {'as': 'dracula'}

" Julia Support
Plug 'JuliaEditorSupport/julia-vim', {'for': 'julia'}

" Stop plugin system
call plug#end()

"" Vimtex
" Enable synctex with zathura
let g:vimtex_view_method       = 'zathura'
let g:vimtex_compiler_progname = 'nvr'
let g:tex_flavor               = 'latex'

" For lightline plugin:
" disable mode bar below status bar (with lightline, there's no need for it)
if !has("nvim")
    set laststatus=2
end
set noshowmode

""" Theme settings
if has("termguicolors")
    set termguicolors
    colorscheme hyrule-contrast
else
    colorscheme moonfly
endif

" Highlight color for the head line of a fold
highlight Folded ctermbg=Black guibg=Black
" Used for trailing spaces
highlight Whitespace ctermfg=magenta guifg=magenta

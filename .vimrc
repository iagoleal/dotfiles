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

""" Key bindings

" <leader> key is comma
let mapleader="\<Space>"

" Disable search highlighting (until next search)
nnoremap <leader><Space> :nohlsearch<CR>
" Select all text on file
nnoremap <leader>a ggVG

" Spell checks previous mistake and corrects to first suggestion
inoremap <C-l> <c-g>u<Esc>[s1z=`]a<c-g>u

"" Filetype-specific keymaps
augroup ftSpecific
    autocmd!
    " Saves file and run haskell interpreter
    autocmd FileType haskell nnoremap <buffer> <leader>m :w<CR> :!runhaskell %<CR>
    " Saves file and run python interpreter
    autocmd FileType python nnoremap <buffer> <leader>m :w<CR> :!python %<CR>
augroup END

" Toggle Color Highlight
map <leader>cc :ColorToggle<CR>
map <leader>cf :ColorSwapFgBg<CR>

" Initialize vim-plug
call plug#begin('~/.vim/bundle')

Plug 'nelstrom/vim-visual-star-search'           " Search highlighted text
Plug 'tpope/vim-commentary'                      " Toggle commentary
Plug 'tpope/vim-surround'                        " Edit surrounding objects
Plug 'chrisbra/Colorizer', {'on': 'ColorToggle'} " Show colors from code

" Beautifuler statusbar
Plug 'itchyny/lightline.vim'
if !has("nvim")
    set laststatus=2
end
set noshowmode

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

" Julia
Plug 'JuliaEditorSupport/julia-vim', {'for': 'julia'}

"" Themes
Plug 'bluz71/vim-moonfly-colors'
Plug 'ayu-theme/ayu-vim'

" Stop plugin system
call plug#end()

"" Theme settings
if has("termguicolors")
    set termguicolors
    " colorscheme hyrule-contrast
    let ayucolor="dark"
    colorscheme ayu
else
    colorscheme moonfly
endif

" Highlight color for the head line of a fold
highlight Folded ctermbg=Black guibg=Black
" Used for trailing spaces
highlight Whitespace ctermfg=magenta guifg=magenta
" Spell checker colors
if (v:version >= 700)
    highlight SpellBad   ctermfg=Red     cterm=Underline guifg=LightRed   gui=Underline guisp=LightRed
    highlight SpellCap   ctermfg=Blue    cterm=Underline guifg=LightBlue  gui=Underline guisp=Blue
    highlight SpellLocal ctermfg=Green   cterm=Underline guifg=LightGreen gui=Underline guisp=Green
    highlight SpellRare  ctermfg=Yellow  cterm=underline guifg=Orange     gui=Underline guisp=Orange
endif

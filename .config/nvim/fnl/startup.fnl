;; Import utilities
(local vim vim)
(local ut (require :utils))
(local fmt string.format)

(import-macros {: option
                : ex
                : viml
                : map
                : augroup
                : autocmd
                : vlua-fmt
                : vlua}
               :macros)

;; Welcome to the XXI century
(ex syntax :enable)

 ;;; Lazy load packer on file change
(viml
   "command! PackerInstall  lua require('plugins').install()
    command! PackerUpdate   lua require('plugins').update()
    command! PackerSync     lua require('plugins').sync()
    command! PackerClean    lua require('plugins').clean()
    command! -nargs=* PackerCompile  lua require('plugins').compile(<q-args>)
    command! PackerStatus   lua require('plugins').status()
    command! PackerProfile  lua require('plugins').profile_output()
    command! -nargs=+ -complete=customlist,v:lua.require'packer'.loader_complete PackerLoad lua require('plugins').loader(<q-args>)")

; Auto reload plugins on startup
 (local plugins-path (.. (vim.fn.stdpath :config) "/fnl/plugins.lua"))
 (augroup PluginManager
   (autocmd :BufWritePost plugins-path ":PackerCompile profile=true"))

 ;-----------------------
 ; Theme and colors
 ;-----------------------

 ;;; Special Highlights
(global personal-highlights (fn []
  ; Trailing spaces
  (ut.highlight :Whitespace {:ctermfg "Magenta" :guifg "Magenta"})
  ;; Spell checker colors
  (ut.highlight :SpellBad
                {:ctermfg "Red"
                 :cterm   "Underline"
                 :guifg   "LightRed"
                 :gui     "Underline"
                 :guisp   "LightRed"})
  (ut.highlight :SpellCap
                {:ctermfg "Blue"
                 :cterm   "Underline"
                 :guifg   "LightBlue"
                 :gui     "Underline"
                 :guisp   "Blue"})
  (ut.highlight :SpellLocal
                {:ctermfg "Green"
                 :cterm   "Underline"
                 :guifg   "LightGreen"
                 :gui     "Underline"
                 :guisp   "Green"})
  (ut.highlight :SpellRare
                {:ctermfg "Yellow"
                 :cterm   "underline"
                 :guifg   "Orange"
                 :gui     "Underline"
                 :guisp   "Orange"})
  ;; Reload color dependent files
  (ex runtime! :plugin/statusline.lua)
  (ex runtime! :plugin/tabline.lua)))

(augroup Highlights
  (autocmd :Colorscheme "*" (vlua-fmt "call %s" personal-highlights)))

(when (ut.has :termguicolors)
  (option termguicolors)
  (option background :dark)
  (local colo :tokyonight)
  (local (status err) (pcall ut.colorscheme colo))
  (when (not status)
    (ut.echoerr err)))

;------------------------
; Theme Options
;------------------------

(option synmaxcol 179)
(option wrap false)

(option showcmd)
(option ruler)
(option conceallevel 0)

(option list) ; Show trailing {spaces, tabs}
(option listchars {:tab      "├─"
                   :trail    "۰"
                   :nbsp     "☻"
                   :extends  "⟩"
                   :precedes "⟨"})

(option number)             ; show line numbers
(option relativenumber)     ; Show line numbers relative to current line
(option numberwidth 2)      ; set minimum width of numbers bar
(option signcolumn :number) ; show (lsp) signs over number bar

(option showmatch)          ; highlight matching parentheses (useful as hell)

(option formatoptions remove [:o :c :r])  ; Don't auto insert comments

; No need for numbers and cursors on terminal lines
(augroup Terminal
  (autocmd :TermOpen "*" "setlocal nonumber norelativenumber nocursorline nocursorcolumn"))

; Highlight text on yank
(augroup :Yank
  (autocmd :TextYankPost "*" "silent! lua vim.highlight.on_yank({higroup=”IncSearch”, timeout=150, on_visual=false})"))

;-------------------------
;-- MISC options
;-------------------------

(option lazyredraw)             ; Don't redraw screen during macros or register operations

;; Search
(option incsearch)              ; search as characters are entered
(option hlsearch)               ; highlight matches
(option ignorecase)             ; case-insensitive search / substitution
(option smartcase)              ; If terms are all lowercase, ignore case. Consider case otherwise.

(option inccommand :nosplit)    ; Show result of :s incrementally on buffer

;; Find files on subfolders
(option path append "**")

(option wildmenu)                       ; visual menu for command autocompletion
(option wildmode [:full :list :full])   ; first autocomplete the word, afterwards run across the list

;; Vertical split to the right (default is left
(option splitright)

;; Spaces and Tabs, settling the war
(option tabstop     2)
(option softtabstop 2)
(option shiftwidth  2)
(option expandtab)
(option smarttab false)

;; Indentation
(option autoindent)

;; Indentation
(option backup)
(option backupdir  ["~/.vim/tmp" "~/.tmp" "~/tmp" "/var/tmp" "/tmp" "."])
(option backupskip ["/tmp/*" "/private/tmp/*"])
(option directory  ["~/.vim/tmp" "~/.tmp" "~/tmp" "/var/tmp" "tmp"])
(option writebackup)


;; Set undo
(option undodir ["~/.tmp" "~/tmp" "/var/tmp" "/tmp" "$XDG_DATA_HOME/nvim/undo" "."])
(option undofile)

;; Set backup files
(option thesaurus append "~/.config/nvim/thesaurus/mthesaur.txt")


;; Use ripgrep for :grep if possible
(when (ut.has_executable "rg")
  (option grepprg    "rg --vimgrep --no-heading")
  (option grepformat "%f:%l:%c:%m,%f:%l:%m"))


;---------------------
;-- Keymaps
;---------------------

;; Set Thesaurus file
(map "" :<Space> :<Nop> {:noremap true :silent true})
(set vim.g.mapleader " ")
; (set vim.g.maplocalleader "\\")

;; Terminal mappins
; Exit terminal with ESC
(map :t :<Esc> "<C-\\><C-n>")
; And use the default keybind to send ESC (This must be norecursive!!!)
(map :t "<C-\\><C-n>" :<Esc>)

; Disable search highlighting (until next search)
(map :n :<leader>/ "<cmd>set hlsearch!<CR>")

; Highlight cross around cursor
(map :n :<leader>cl "<cmd>set cursorline! cursorcolumn!<CR>")

; Zoom window at new tab
(map :n :<leader>tz "<cmd>tab split<CR>")

; Close tab
(map :n :<leader>tc :<cmd>tabclose<CR>)

; Spell checks previous mistake and corrects to first suggestion
(map :i :<C-l> "<c-g>u<Esc>[s1z=`]a<c-g>u")

; Search in visual mode
(map :v "*" "y/\\V<C-R>=escape(@\",'/\\')<CR><CR>")

; Enter path to current file on command mode
(map :c :<A-p> "getcmdtype() == ':' ? expand('%:h').'/' : ''" {:expr true})


;;; Toggle quickfix window on the bottom of screen
(global toggle-quickfix (fn []
  (let [windows (vim.fn.getwininfo)]
    (each [_ win (pairs windows) ]
      (when (= win.quickfix 1)
        (vim.cmd :cclose)
        (lua "return nil")))
    (vim.cmd "botright copen"))))

(map :n :<leader>q toggle-quickfix)

;;;; Navigation
(fn unimpaired [key cmd]
  (set-forcibly! cmd (or cmd key))
  (map :n (.. "[" (key:lower)) (fmt ":<C-U>exe v:count1 '%sprevious'<CR>" cmd))
  (map :n (.. "]" (key:lower)) (fmt ":<C-U>exe v:count1 '%snext'<CR>"     cmd))
  (map :n (.. "[" (key:upper)) (fmt ":<C-U>exe v:count1 '%sfirst'<CR>"    cmd))
  (map :n (.. "]" (key:upper)) (fmt ":<C-U>exe v:count1 '%slast'<CR>"     cmd)))

(unimpaired :q :c) ; Quickfix
(unimpaired :l :l) ; Location list
(unimpaired :b :b) ; Buffers
(unimpaired :t :t) ; Tabs


;; Toggle quickfix window on the bottom of screen
(map "" :<Up>    :<Nop>)
(map "" :<Down>  :<Nop>)
(map "" :<Left>  :<Nop>)
(map "" :<Right> :<Nop>)


;; Plugin related

; Toggle quickfix window on the bottom of screen
(map :n :gx "<cmd>call netrw#BrowseX(expand((exists(\"g:netrw_gx\")? g:netrw_gx : '<cfile>')),netrw#CheckIfRemote())<cr>")

;; Building keymaps
(map :n :<leader>m ":Dispatch<CR>")
(map :n :<leader>M ":Dispatch!<CR>")

; Toggle Color Highlight
(map :n :<leader>cc ":ColorizerToggle<CR>")
; Toggle Rainbow Parentheses
(map :n :<leader>cr ":RainbowToggle<CR>")

; FZF
(map :n :<leader>fe ":FZFFiles<cr>")
(map :n :<leader>fb ":FZFBuffers<cr>")

; Easy Align
(map :n :<leader>a "<Plug>(EasyAlign)" {:noremap false})
(map :x :<leader>a "<Plug>(EasyAlign)" {:noremap false})

;-----------------------
;-- Filetype Specific
;-----------------------

(augroup Langs
  (autocmd :FileType
    "scheme,racket,fennel"
    "setlocal softtabstop=2 shiftwidth=2 lisp autoindent")
  (autocmd :FileType
    :haskell
    "nnoremap <buffer> <space>hh :Hoogle <C-r><C-w><CR>")
  (autocmd :FileType
    "markdown,latex,gitcommit"
    "setlocal spell")
  (autocmd :FileType
    :make
    "setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=0")
  (autocmd :FileType
    "lua,fennel"
    "nnoremap <buffer> <F12> :wa<cr>:!love . &<cr>"))

;-----------------------------
;-- Disable Built-in plugins
;-----------------------------

(local disabled-built-ins [:gzip
                           :zip
                           :zipPlugin
                           :tar
                           :tarPlugin
                           :getscript
                           :getscriptPlugin
                           :vimball
                           :vimballPlugin
                           :2html_plugin
                           :logipat
                           :rrhelper
                           :spellfile_plugin
                           ; :matchit
                           ; :matchparen
                           ; :netrw
                           ; :netrwPlugin
                           ; :netrwSettings
                           ; :netrwFileHandlers
                           ])
(each [_ plugin (ipairs disabled-built-ins)]
  (tset vim.g (.. "loaded_" plugin) 1))


; Netrw defaults to tree view
(set vim.g.netrw_liststyle 3)

;; Import utilities
(local fmt string.format)

(local {: autocmd
        : colorscheme
        : echoerror
        : executable-exists?
        : has?
        : highlight
        : keymap
        &as ut} (require :futils))

(import-macros {: option
                : ex
                : viml
                : augroup
                : pug}
               :macros)

(global dump ut.dump)
(tset _G :force_require ut.force-require)

;; Welcome to the XXI century
(ex syntax :enable)

 ;;; Lazy load packer on file change
(viml
   "command! PackerInstall  lua require('plugins').install()
    command! PackerUpdate   lua require('plugins').update()
    command! PackerSync     lua require('plugins').sync()
    command! PackerClean    lua require('plugins').clean()
    command! -nargs=* PackerCompile  lua force_require('plugins').compile(<q-args>)
    command! PackerStatus   lua require('plugins').status()
    command! PackerProfile  lua require('plugins').profile_output()
    command! -nargs=+ -complete=customlist,v:lua.require'packer'.loader_complete PackerLoad lua require('plugins').loader(<q-args>)")

; Auto reload plugins on startup
 (local plugins-path (.. (vim.fn.stdpath :config) "/fnl/plugins.fnl"))
 (augroup :PluginManager
   (autocmd :BufWritePost plugins-path ":PackerCompile profile=true"))

 ;-----------------------
 ; Theme and colors
 ;-----------------------

 ;;; Special Highlights
(fn personal-highlights []
  ; Trailing spaces
  (highlight :Whitespace
             :ctermfg "Magenta"
             :guifg   "Magenta")
  ;; Spell checker colors
  (highlight :SpellBad
             :ctermfg "Red"
             :cterm   "Underline"
             :guifg   "LightRed"
             :gui     "Underline"
             :guisp   "LightRed")
  (highlight :SpellCap
             :ctermfg "Blue"
             :cterm   "Underline"
             :guifg   "LightBlue"
             :gui     "Underline"
             :guisp   "Blue")
  (highlight :SpellLocal
             :ctermfg "Green"
             :cterm   "Underline"
             :guifg   "LightGreen"
             :gui     "Underline"
             :guisp   "Green")
  (highlight :SpellRare
             :ctermfg "Yellow"
             :cterm   "underline"
             :guifg   "Orange"
             :gui     "Underline"
             :guisp   "Orange")
  ;; Reload color dependent files
  (ex runtime! "plugin/statusline.lua")
  (ex runtime! "plugin/tabline.lua"))

(augroup :Highlights
  (autocmd :Colorscheme "*" personal-highlights))

;; Set colorscheme
(when (has? :termguicolors)
  (option :termguicolors)
  (option :background :dark)
  (local colo :tokyonight)
  (local (status err) (pcall colorscheme colo))
  (when (not status)
    (echoerror err)))

;------------------------
; Theme Options
;------------------------

(option :synmaxcol 179)
(option :wrap false)

(option :showcmd)
(option :ruler)
(option :conceallevel 0)

(option :list) ; Show trailing {spaces, tabs}
(option :listchars {:tab      "├─"
                    :trail    "۰"
                    :nbsp     "☻"
                    :extends  "⟩"
                    :precedes "⟨"})
 
(option :number)             ; show line numbers
(option :relativenumber)     ; Show line numbers relative to current line

(option :numberwidth 2)      ; set minimum width of numbers bar
(option :signcolumn :number) ; show (lsp) signs over number bar

(option :showmatch)          ; highlight matching parentheses (useful as hell)

(option :formatoptions remove [:o :c :r])  ; Don't auto insert comments

; No need for numbers and cursors on terminal lines
(augroup :Terminal
  (autocmd :TermOpen "*" "setlocal nonumber norelativenumber nocursorline nocursorcolumn"))

; Highlight text on yank
(augroup :Yank
  (autocmd :TextYankPost "*" #(vim.highlight.on_yank {:higroup "IncSearch" :timeout 150 :on_visual false})))
  ; (autocmd :TextYankPost "*" "silent! lua vim.highlight.on_yank({higroup=”IncSearch”, timeout=150, on_visual=false})"))

;-------------------------
;-- MISC options
;-------------------------

(option :lazyredraw)             ; Don't redraw screen during macros or register operations

;; Search
(option :incsearch)              ; search as characters are entered
(option :hlsearch)               ; highlight matches
(option :ignorecase)             ; case-insensitive search / substitution
(option :smartcase)              ; If terms are all lowercase, ignore case. Consider case otherwise.

(option :inccommand "nosplit")    ; Show result of :s incrementally on buffer

;; Find files on subfolders
(option :path append "**")

(option :wildmenu)                       ; visual menu for command autocompletion
(option :wildmode [:full :list :full])   ; first autocomplete the word, afterwards run across the list
(option :wildignorecase)

;; Vertical split to the right (default is left)
(option :splitright)

;; Spaces and Tabs, settling the war
(global set-spaces-per-tab (fn [n]
  (set vim.opt.tabstop n)
  (set vim.opt.softtabstop n)
  (set vim.opt.shiftwidth n)
  (set vim.opt.expandtab true)))

(option :tabstop     2)
(option :softtabstop 2)
(option :shiftwidth  2)
(option :expandtab)
(option :smarttab false)


(vim.cmd (string.format "command! -nargs=? SpacesPerTab :lua %s(tonumber(<f-args>))"
                        (pug set-spaces-per-tab)))

;; Indentation
(option :autoindent)

;; Indentation
(option :backup)
(option :backupdir  ["~/.vim/tmp" "~/.tmp" "~/tmp" "/var/tmp" "/tmp" "."])
(option :backupskip ["/tmp/*" "/private/tmp/*"])
(option :directory  ["~/.vim/tmp" "~/.tmp" "~/tmp" "/var/tmp" "tmp"])
(option :writebackup)


;; Set undo
(option :undodir ["~/.tmp" "~/tmp" "/var/tmp" "/tmp" "$XDG_DATA_HOME/nvim/undo" "."])
(option :undofile)

;; Set backup files
(option :thesaurus append (.. (vim.fn.stdpath :config)
                              "/thesaurus/mthesaur.txt"))


;; Use ripgrep for :grep if possible
(when (executable-exists? "rg")
  (option :grepprg    "rg --vimgrep --no-heading")
  (option :grepformat "%f:%l:%c:%m,%f:%l:%m"))


;---------------------
;-- Keymaps
;---------------------

;; Set Thesaurus file
(keymap "" "<Space>" "<Nop>"
        :silent true)
(set vim.g.mapleader " ")
; (set vim.g.maplocalleader "\\")

; Rebind Y on normal mode to copy until end of line
(keymap :n "Y" "y$")
; Make CTRL-L also clean highlights
(keymap :n "<C-l>" "<cmd>nohlsearch<CR><C-l>")

;; Terminal mappins
; Exit terminal with ESC
(keymap :t "<Esc>" "<C-\\><C-n>")
; And use the default keybind to send ESC (This must be norecursive!!!)
(keymap :t "<C-\\><C-n>" "<Esc>")

; Disable search highlighting (until next search)
(keymap :n "<leader>/" "<cmd>nohlsearch<CR>")

; Highlight cross around cursor
(keymap :n "<leader>cl" "<cmd>set cursorline! cursorcolumn!<CR>")

; Zoom window at new tab
(keymap :n "<leader>tz" "<cmd>tab split<CR>")

; Close tab
(keymap :n "<leader>tc" "<cmd>tabclose<CR>")

; Spell checks previous mistake and corrects to first suggestion
(keymap :i "<C-l>" "<c-g>u<Esc>[s1z=`]a<c-g>u")

; Search word under cursor on whole project
(keymap :n "<M-*>" ":grep '<C-r><C-w>' **/*")

; Search visual selection
(keymap :v "*" "y/\\V<C-R>=escape(@\",'/\\')<CR><CR>")

; Search visual selection text on whole project
(keymap :v "<M-*>" "y:grep '<C-R>=escape(@\",'/\\')<CR>' **/*")

; While indenting/dedenting, stay on visual mode
(keymap :x "<" "<gv")
(keymap :x ">" ">gv")

; Enter path to current file on command mode
(keymap :c "<A-p>" "getcmdtype() == ':' ? expand('%:h').'/' : ''"
        :expr true)


;;; Helper function for toggling a list
(fn toggle-*list [win-type cmd-open cmd-close]
  #(let [tabnr   (vim.fn.tabpagenr)
         windows (. (vim.fn.gettabinfo tabnr) 1 :windows)]
    (each [_ winid (pairs windows)]
      (local win (. (vim.fn.getwininfo winid) 1))
      (when (= (. win win-type) 1)
        (vim.cmd cmd-close)
        (lua "return nil")))
    (vim.cmd cmd-open)))

; Toggle quickfix window on the bottom of screen
(global toggle-quickfix
  (toggle-*list :quickfix "botright copen" "cclose"))
; Toggle locationlist window on the bottom of buffer
(global toggle-locationlist
  (toggle-*list :loclist  "lopen" "lclose"))

(keymap :n "<leader>q" toggle-quickfix)
(keymap :n "<leader>Q" toggle-locationlist)

;;;; Navigation
(fn unimpaired [key cmd]
  (keymap :n (.. "[" (key:lower)) (fmt ":<C-U>exe v:count1 '%sprevious'<CR>" cmd))
  (keymap :n (.. "]" (key:lower)) (fmt ":<C-U>exe v:count1 '%snext'<CR>"     cmd))
  (keymap :n (.. "[" (key:upper)) (fmt ":<C-U>exe v:count1 '%sfirst'<CR>"    cmd))
  (keymap :n (.. "]" (key:upper)) (fmt ":<C-U>exe v:count1 '%slast'<CR>"     cmd)))

(unimpaired :q :c) ; Quickfix
(unimpaired :l :l) ; Location list
(unimpaired :b :b) ; Buffers
(unimpaired :t :t) ; Tabs


;; Open :ptag on a vertical split (Like "<C-w>}")
(fn ptag-vertical []
  (let [backup-previewheight vim.o.previewheight        ; The current/default previewheight
        window-width         (vim.fn.winwidth 0)        ; The current window's width
        current-word         (vim.fn.expand "<cword>")] ; The word under the cursor
    ; Divide the current window in half
    (set vim.o.previewheight (math.floor (/ window-width 2)))
    ; Open tag on vertical preview window
    (vim.cmd (fmt "vert ptag %s" current-word))
    ; Restore option to default
    (set vim.o.previewheight backup-previewheight)))

(keymap :n "<C-w>{" ptag-vertical)

;; Disable arrows
(keymap "" "<Up>"    "")
(keymap "" "<Down>"  "")
(keymap "" "<Left>"  "")
(keymap "" "<Right>" "")


;; Plugin related

; Toggle quickfix window on the bottom of screen
(keymap :n "gx" "<cmd>call netrw#BrowseX(expand((exists(\"g:netrw_gx\")? g:netrw_gx : '<cfile>')),netrw#CheckIfRemote())<cr>")

;; Building keymaps
(keymap :n "<leader>m" ":Dispatch<CR>")
(keymap :n "<leader>M" ":Dispatch!<CR>")

; Toggle Color Highlight
(keymap :n "<leader>cc" ":ColorizerToggle<CR>")
; Toggle Rainbow Parentheses
(keymap :n "<leader>cr" ":RainbowToggle<CR>")

; FZF
(keymap :n "<leader>fe" ":FZFFiles<cr>")
(keymap :n "<leader>fb" ":FZFBuffers<cr>")

; Easy Align
(keymap :n "<leader>a" "<Plug>(EasyAlign)"
        :noremap false)
(keymap :x "<leader>a" "<Plug>(EasyAlign)"
        :noremap false)

; UndoTree
(keymap :n "<leader>tu" "<cmd>UndotreeToggle<CR>")

;-----------------------
;-- Filetype Specific
;-----------------------

(augroup :Langs
  (autocmd :FileType
           [:scheme :racket :fennel]
           "setlocal tabstop=2 softtabstop=2 shiftwidth=2 lisp autoindent")
  (autocmd :FileType
           :haskell
           "nnoremap <buffer> <space>hh <cmd>Hoogle <C-r><C-w><CR>")
  (autocmd :FileType
           [:markdown :latex :gitcommit]
           "setlocal spell")
  (autocmd :FileType
           :make
           "setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=0")
  (autocmd :FileType
           [:lua :fennel]
           "nnoremap <buffer> <F12> :wa<cr>:!love . &<cr>"))

;-----------------------------
;-- Disable Built-in plugins
;-----------------------------

(local disabled-built-ins [:gzip
                           ; :zip
                           ; :zipPlugin
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
                           :matchit
                           :matchparen
                           ; :netrw
                           ; :netrwPlugin
                           ; :netrwSettings
                           ; :netrwFileHandlers
                           ])
(each [_ plugin (ipairs disabled-built-ins)]
  (tset vim.g (.. "loaded_" plugin) 1))


; Netrw defaults to tree view
(set vim.g.netrw_liststyle 3)

;; Hide sponsor information from Conjure
(augroup :ConjureRemoveSponsor
  (autocmd :BufWinEnter "conjure-log-*" "silent s/; Sponsored by @.*//e"))

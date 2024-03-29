;; Import utilities
(local fmt string.format)

(local {: autocmd
        : executable-exists?
        : has?
        : hi-link
        : keymap
        &as ed} (require :editor))

(import-macros {: option
                : ex
                : viml
                : augroup
                : def-command
                : highlight
                : require-use}
               :macros)

(tset _G :dump ed.dump)
(tset _G :force_require (require-use :core :force-require))


;;; Lazy load packer on file change.
;; Adapt the built-in packer commands to use my plugin file.
(def-command :PackerInstall #((require-use :plugins :install)))
(def-command :PackerUpdate  #((require-use :plugins :update)))
(def-command :PackerClean   #((require-use :plugins :clean)))
(def-command :PackerStatus  #((require-use :plugins :status)))
(def-command :PackerProfile #((require-use :plugins :profile_output)))
(def-command :PackerSync    #((require-use :plugins :sync)))

(def-command :PackerCompile
  (fn [arg]
    (let [compiler (. (force_require :plugins) :compile)]
     (compiler arg.args)))
  :nargs :?)

(viml "command! -nargs=+ -complete=customlist,v:lua.require'packer'.loader_complete PackerLoad lua require('plugins').loader(<q-args>)")

;; Recompile plugins every time the plugin file changes.
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
             :fg   "Magenta")
  ;; Spell checker colors
  (highlight :SpellBad
             :fg        "LightRed"
             :underline true)
  (highlight :SpellCap
             :fg        "LightBlue"
             :sp        "Blue"
             :underline true)
  (highlight :SpellLocal
             :fg        "LightGreen"
             :sp        "Green"
             :underline true)
  (highlight :SpellRare
             :fg        "Orange"
             :sp        "Orange"
             :underline true)
  ;; For plugins
  (highlight :EyelinerPrimary
             :fg        "Orange"
             :sp        "Orange"
             :bold      true)
  (highlight :EyelinerSecondary
             :fg        "#5ae271"
             :bold      true)
  (hi-link :LspCodeLens :WarningMsg)
  ;; Reload color dependent files
  (ex runtime! "plugin/statusline.lua")
  (ex runtime! "plugin/tabline.lua"))

(augroup :Highlights
  (autocmd :Colorscheme "*" personal-highlights))

;; Set colorscheme
(when (has? :termguicolors)
  (option :termguicolors)
  (option :background :dark)
  (vim.cmd.colorscheme :everforest))

;------------------------
; Theme Options
;------------------------

(option :synmaxcol 179)
(option :wrap false)
(option :linebreak true)

(option :list) ; Show trailing {spaces, tabs}
(option :listchars {:tab      "├─"
                    :trail    "۰"
                    :nbsp     "☻"
                    :extends  "⟩"
                    :precedes "⟨"})

(option :showmatch)          ; highlight matching parentheses (useful as hell)

(option :formatoptions remove [:o :c :r])  ; Don't auto insert comments

; No need for numbers and cursors on terminal lines
(augroup :Terminal
  (autocmd :TermOpen "*" "setlocal nonumber norelativenumber nocursorline nocursorcolumn"))

; Highlight text on yank
(augroup :Yank
  (autocmd :TextYankPost "*" #(vim.highlight.on_yank {:higroup "IncSearch" :timeout 150 :on_visual false})))


;; Configure diagnostics (for all servers)
(vim.diagnostic.config {:virtual_text     false
                        :signs            true
                        :underline        false
                        :update_in_insert false
                        :severity_sort    true})

;-------------------------
;-- MISC options
;-------------------------

(option :lazyredraw)              ; Don't redraw screen during macros or register operations

;; Search
(option :ignorecase)              ; case-insensitive search / substitution
(option :smartcase)               ; If terms are all lowercase, ignore case. Consider case otherwise.

;; Find files on subfolders
(option :path append "**")

;; Completion
(option :wildmode [:full :list :full])   ; first autocomplete the word, afterwards run across the list
(option :wildignorecase)

(option :completeopt "menuone")

;; Vertical split to the right (default is left)
(option :splitright)

;; Spaces and Tabs, settling the war
(fn set-spaces-per-tab [n]
  (set vim.opt.tabstop     n)
  (set vim.opt.softtabstop n)
  (set vim.opt.shiftwidth  n)
  (set vim.opt.expandtab   true))

;; Expose it as a command
(def-command :SpacesPerTab
  #(set-spaces-per-tab (tonumber $1.args))
  :nargs 1
  :desc "Define how many spaces a <tab> represents")


; By default, use 2 spaces to indent
(set-spaces-per-tab 2)
(option :smarttab false)


;; Session
; Remember options (local and global) and all tabpages in a single session file
(option :sessionoptions append [:options :tabpages])

;; Backup
(option :backup)
(option :undofile)
(option :backupdir ["/var/tmp" "/tmp" "$XDG_STATE_HOME/nvim/backup//"])
(option :directory ["/tmp" "/var/tmp" "$XDG_STATE_HOME/nvim/swap//"])
(option :undodir   ["/var/tmp" "/tmp" "$XDG_STATE_HOME/nvim/undo"])


(option :dictionary append "/usr/share/dict/words")
(option :thesaurus  append (.. (vim.fn.stdpath :data)
                               "/thesaurus/mthesaur.txt"))

;; Use ripgrep for :grep if possible
(when (executable-exists? "rg")
  (option :grepprg    "rg --vimgrep --no-heading")
  (option :grepformat "%f:%l:%c:%m,%f:%l:%m"))


;====================================
;            Keymaps
;====================================

(set vim.g.mapleader      " ")
(set vim.g.maplocalleader "ç")    ; br-abnt2

;;; Disable undesirable behaviour
;;;---------------------
(each [_ key (ipairs ["<Up>" "<Down>" "<Left>" "<Right>" "<Space>" "ZZ" "ZQ"])]
  (keymap ["" "v"] key "<Nop>"))


;;; Redefined behaviour
;;;---------------------
;;; Modifications on vim's traditional keybidings for ergonomic reasons.

;; Terminal mappings
; Exit terminal with ESC
(keymap :t "<Esc>" "<C-\\><C-n>")
; And use the default keybind to send ESC (This must be norecursive!!!)
(keymap :t "<C-\\><C-n>" "<Esc>")

; While indenting/dedenting, stay on visual mode
(keymap :x "<" "<gv")
(keymap :x ">" ">gv")


;;; Additional behaviour
;;;---------------------

; Zoom window at new tab
(keymap :n "<leader>tz" "<cmd>tab split<CR>")

; Close tab
(keymap :n "<leader>tc" "<cmd>tabclose<CR>")

; Search word under cursor on whole project
(keymap :n "<M-*>" ":grep '<C-r><C-w>' **/*")

; Search visual selection
(keymap :v "*" "y/\\V<C-R>=escape(@\",'/\\')<CR><CR>")
(keymap :v "#" "y?\\V<C-R>=escape(@\",'/\\')<CR><CR>")

; Search visual selection text on whole project
(keymap :v "<M-*>" "y:grep '<C-R>=escape(@\",'/\\')<CR>' **/*")

; Toggle quickfix window on the bottom of screen
(keymap :n "<leader>q" "empty(filter(getwininfo(), 'v:val.quickfix')) ? ':botright copen<CR>' : ':cclose<CR>'"
  {:expr true})
; Toggle locationlist window on the bottom of buffer
(keymap :n "<leader>Q" "empty(filter(getwininfo(), 'v:val.loclist')) ? ':lopen<CR>' : ':lclose<CR>'"
  {:expr true})


;;;; Navigation
(fn unimpaired [key cmd]
  (keymap :n (.. "[" (key:lower)) (fmt ":<C-U>exe v:count1 '%sprevious'<CR>" cmd))
  (keymap :n (.. "]" (key:lower)) (fmt ":<C-U>exe v:count1 '%snext'<CR>"     cmd))
  (keymap :n (.. "[" (key:upper)) (fmt ":<C-U>exe v:count1 '%sfirst'<CR>"    cmd))
  (keymap :n (.. "]" (key:upper)) (fmt ":<C-U>exe v:count1 '%slast'<CR>"     cmd)))

(unimpaired :q :c)   ; Quickfix
(unimpaired :l :l)   ; Location list
(unimpaired :b :b)   ; Buffers
(unimpaired :t :tab) ; Tabs

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


(keymap :n "<C-w>[" "<cmd>vert wincmd ]<CR>")
(keymap :n "<C-w>{" ptag-vertical)

;; Scroll the preview window
(keymap :n "<M-e>" "'<C-w>P' . v:count1 . '<C-e><C-w>p'"
  {:expr true})
(keymap :n "<M-y>" "'<C-w>P' . v:count1 . '<C-y><C-w>p'"
  {:expr true})

; Spell check previous mistake and correct to first suggestion
(keymap :i "<C-l>" "<c-g>u<Esc>[s1z=`]a<c-g>u")

; Add semicolon to end of line iff it's not already there
(keymap :i "<A-;>"
  #(let [current (vim.fn.getline ".")]
     (when (~= (current:sub -1) ";")
       (vim.fn.setline "." (.. current ";"))))
  {:desc "Append semicolon to end of current line if it is not already there"})

;; Save insert mode undo history before pasting something
(keymap :i "<C-r>" "<C-g>u<C-r>")

;;; Make life easier on command mode

;; Emacs-like keybindings for cmd mode
; back one word
(keymap :c "<M-b>" "<S-Left>")
; forward one word
(keymap :c "<M-f>" "<S-Right>")

; Enter path to current file on command mode
(keymap :c "<M-x>p" "getcmdtype() == ':' ? expand('%:h').'/' : ''"
  {:expr true})

;--------------------------
;;; LSP
;--------------------------

;; Diagnostics
(keymap :n "<leader>e"  vim.diagnostic.open_float
  {:desc "Open diagnostics popup"})
(keymap :n "[d"         vim.diagnostic.goto_prev
  {:desc "Previous diagnostic"})
(keymap :n "]d"         vim.diagnostic.goto_next
  {:desc "Next diagnostic"})
(keymap :n "<leader>dq" vim.diagnostic.setloclist
  {:desc "Put diagnostics on location list"})


;--------------------------
;;; Plugin related
;--------------------------

;; Building keymaps
(keymap :n "<leader>m" ":Dispatch<CR>")
(keymap :n "<leader>M" ":Dispatch!<CR>")

; Highlight cross around cursor
(keymap :n "<leader>chl" "<cmd>set cursorline! cursorcolumn!<CR>")

; UndoTree
(keymap :n "<leader>tu" "<cmd>UndotreeToggle<CR>")

;-----------------------
;-- Commands
;-----------------------

(fn make-scratch-buffer [mods]
  "Create a new scratch buffer in a split window."
  (vim.cmd (.. mods " new"))
  (set vim.bo.buftype   :nofile)
  (set vim.bo.bufhidden :wipe)
  (set vim.bo.buflisted false)
  (set vim.bo.swapfile  false))

(def-command :View
  (fn [arg]
    (make-scratch-buffer arg.mods)
    (vim.cmd (fmt "put=execute('%s')" arg.args)))
  :nargs    :*
  :complete :command
  :desc     "Output ex command into new split.")

(def-command :Skeleton
  (fn [arg]
    (let [line (- (vim.fn.line ".") 1)
          ft   (or (. arg.fargs 1) vim.bo.filetype)]
      (vim.cmd.read {:args  [(.. (vim.fn.stdpath :config) "/skeleton/" ft)]
                     :range [line]})))
  :nargs    :?
  :complete :filetype
  :desc     "Load skeleton template for a given filetype (current by default).")


;-----------------------
;-- Filetype Specific
;-----------------------

(augroup :Langs
  (autocmd :FileType
           [:scheme :racket :fennel]
           "setlocal tabstop=2 softtabstop=2 shiftwidth=2 lisp autoindent")
  (autocmd :FileType
           :haskell
           #(keymap :n "<leader>hh" "<cmd>Hoogle <C-r><C-w><CR>" {:buffer true}))
  (autocmd :FileType
           :julia
           #(vim.opt_local.iskeyword:append "!"))
  (autocmd :FileType
           [:lhaskell :markdown :tex :latex :gitcommit]
           "setlocal spell")
  (autocmd :FileType
           :make
           "setlocal noexpandtab tabstop=4 shiftwidth=4 softtabstop=0")
  (autocmd :FileType
           [:bash :zsh :sh]
           #(vim.opt_local.iskeyword:append "$"))
  (autocmd :FileType
           [:lua :fennel]
           #(do
             (if (ed.directory? "src")
                 (keymap :n "<F12>" ":wa<cr>:!love --fuseomod src &<cr>")
                 (keymap :n "<F12>" ":wa<cr>:!love --fused . &<cr>"))
             (vim.opt_local.iskeyword:remove "."))))


; Quick access to last open files of each type
(augroup :FiletypeMarks
  (autocmd :BufLeave ["*.md" "*.md.lhs"]   "mark M")
  (autocmd :BufLeave ["*.hs" "*.lhs"]      "mark H")
  (autocmd :BufLeave ["*.lua" "*.fnl"]     "mark L")
  (autocmd :BufLeave ["*.jl"]              "mark J")
  (autocmd :BufLeave ["*.py"]              "mark P")
  (autocmd :BufLeave ["*.c" "*.cpp" "*.h"] "mark C"))

;; Control built-in ftplugins
(set vim.g.markdown_recommended_style 0)

;-----------------------------
;-- Disable Built-in plugins
;-----------------------------

(local disabled-built-ins [; :gzip
                           ; :zip
                           ; :zipPlugin
                           ; :tar
                           ;:tarPlugin
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
                           :netrw
                           :netrwPlugin
                           :netrwSettings
                           :netrwFileHandlers])

(each [_ plugin (ipairs disabled-built-ins)]
  (tset vim.g (.. "loaded_" plugin) 1))


; Netrw defaults to tree view
(set vim.g.netrw_liststyle 3)

(viml "
  func! Thesaur(findstart, base)
    if a:findstart
      return searchpos('\\<', 'bnW', line('.'))[1] - 1
    else
      let res = []
      let h = ''
      for l in systemlist('aiksaurus '.shellescape(a:base))
        if l[:3] == '=== '
          let h = '('.substitute(l[4:], ' =*$', ')', '')
        elseif l ==# 'Alphabetically similar known words are: '
          let h = '\\U0001f52e'
        elseif l[0] =~ '\\a' || (h ==# '\\U0001f52e' && l[0] ==# '\\t')
          call extend(res, map(split(substitute(l, '^\\t', '', ''), ', '), {_, val -> {'word': val, 'menu': h}}))
        endif
      endfor
      return res
    endif
  endfunc

  if executable('aiksaurus')
    set thesaurusfunc=Thesaur
  endif
")


;; Hide sponsor information from Conjure
(augroup :ConjureRemoveSponsor
  (autocmd :BufWinEnter "conjure-log-*" "silent s/. Sponsored by @.*//e"))

; Macros and utilities
(import-macros {:packer-use use : keymap : augroup : ex} :macros)
(local {: autocmd : executable-exists? &as ut} (require :futils))

;; Plugin management
(vim.cmd "packadd packer.nvim")
(local packer (require :packer))

;; Packer configuration table
(local config {:disable_commands true
               :compile_on_sync  true
               :max_jobs         9
               :profile          {:enable true}})

(macro require-use [pkg ...]
  `(. (require ,pkg) ,...))

;;; Initialize the just defined configuration
(packer.init config)
(packer.reset)

;;;; Add and manage packages
;;;; Here we load all packages of interest.

;; The plugin manager itself
(use "wbthomason/packer.nvim"
      :opt true)

;; Fennel support for nvim
(use "rktjmp/hotpot.nvim"
      :config #(require :hotpot))

;; Cache lua modules
(use "lewis6991/impatient.nvim")

;;;
;;; Treesitter
;;;

(use "nvim-treesitter/nvim-treesitter"
      :run    ":TSUpdate"
      :config #(require :plugins.treesitter))

; Semantically based text objects (such as functions, classes etc.)
(use "nvim-treesitter/nvim-treesitter-textobjects"
     :requires "nvim-treesitter/nvim-treesitter")

(use "RRethy/nvim-treesitter-textsubjects"
     :requires "nvim-treesitter/nvim-treesitter")

;;;
;;; Language Server Protocol
;;;

(use "neovim/nvim-lspconfig"
     :config #(require :lsp))
; Query LSP for tag files.
; It Allows me to use built-in tag commands with LSP.
(use "weilbith/nvim-lsp-smag")

; Hook external linters/formaters into LSP
(use "jose-elias-alvarez/null-ls.nvim"
  :requires "nvim-lua/plenary.nvim"
  :config #(let [null-ls (require :null-ls)]
            (null-ls.setup
              {:sources [;null-ls.builtins.diagnostics.trail_space
                         null-ls.builtins.hover.dictionary]
               :on_attach (require-use :lsp :on-attach)})))

;;;
;;; Utilities
;;;

;; Manage REPLs
(use "hkupty/iron.nvim"
     :commit "bc9c596d6a97955f0306d2abcc10d9c35bbe2f5b"
     :config (fn []
               (set vim.g.iron_map_defaults 0)
               (set vim.g.iron_map_extended 0)
               (require :plugins.iron)))

;; Better REPL management for Lisps
(use "Olical/conjure"
     :ft [:scheme :racket :clojure :fennel :julia :lisp]
     :config (fn []
               (tset vim.g :conjure#extract#tree_sitter#enabled        true)
               (tset vim.g :conjure#highlight#enabled                  true)
               (tset vim.g :conjure#log#hud#border                     "double")
               (tset vim.g :conjure#highlight#enabled                  :IncSearch)
               (tset vim.g :conjure#client#scheme#stdio#command        "racket -il scheme")
               (tset vim.g :conjure#client#scheme#stdio#prompt_pattern "\n?[\"%w%-./_]*> ")
               (tset vim.g :conjure#filetype#fennel                    "conjure.client.fennel.stdio")
               (tset vim.g :conjure#client#fennel#stdio#command        "fennel")))

; Auto-layouting for Lisp parentheses
(use "gpanders/nvim-parinfer")

;; Highly improved wildmenu.
;; Includes niceties such as fuzzy search.
;; Unfortunately, it is a python remote plugin...
;; so there is some headache when updating.
;; TODO: I should find a substitute for this
(use "gelguy/wilder.nvim"
     ; In case of errors, disable with "call wilder#disable()"
     :event    [:CursorHold :CmdlineEnter]
     :rocks    ["luarocks-fetch-gitrec" "pcre2"]
     :requires ["romgrk/fzy-lua-native"]
     :run      [":call UpdateRemotePlugins()"]
     :config #(ex source (.. (vim.fn.stdpath :config)
                             "/viml/wilder.vim")))

(use "anuvyklack/hydra.nvim"
  :config #(require :plugins.hydra))

; Tree view buffer for undo history
(use "mbbill/undotree")

; Diff mode for directories
(use "cossonleo/dirdiff.nvim")

(use "NMAC427/guess-indent.nvim"
  :disable true
  :config #((require-use :guess-indent :setup) {}))

;;;
;;; Should be built-in
;;;

; Title case operator
(use "christoomey/vim-titlecase")

; Add commands to (un)comment text objects
(use "numToStr/Comment.nvim"
     :config #((require-use :Comment :setup) {:ignore "^$"}))

; Edit surrounding objects
(use "kylechui/nvim-surround"
     :config #((require-use :nvim-surround :setup) {}))


; Improved matchparen and matchit
(use "andymass/vim-matchup"
     :config (fn []
               (set vim.g.loaded_matchit 1)
               (set vim.g.matchup_matchparen_offscreen {:method :popup})
               (set vim.g.matchup_matchparen_hi_surround_always 1)
               (set vim.g.matchup_matchparen_deferred_show_delay 150)
               (set vim.g.matchup_override_vimtex 0)
               (set vim.g.matchup_matchpref {:html
                                              {:tagnameonly 1}})))
; Async make      (vimscript)
(use "tpope/vim-dispatch"
     :cmd [:Make :Dispatch])
; Reopen file with sudo

; Allow writing file with sudo
; even if I open nvim as a normal user
(when (executable-exists? "sudo")
  (use "lambdalisue/suda.vim"
       :cmd [:SudaRead :SudaWrite]))

; Alignment utils (vimscript)
(use "junegunn/vim-easy-align"
      :config #(set vim.g.easy_align_delimiters
                    {">" {:pattern "=>\\|->\\|>\\|→"
                          :delimiter_align :r}
                     "<" {:pattern "<-\\|<=\\|<\\|←"
                          :delimiter_align :l}
                     "r" {:pattern "{\\|}\\|,"     ; Lua / Haskell style Records
                          :delimiter_align :r}}))

;;;
;;; Colors
;;;

(use "norcalli/nvim-colorizer.lua"
      :cmd [:ColorizerToggle :ColorizerReloadAllBuffers :ColorizerAttachToBuffer]
      :config #((. (require :colorizer) :setup)))

;; Color picker
(use "KabbAmine/vCoolor.vim"         ; NOTE: Can I remake this in lua with floating windows?
      :config (fn []
                (set vim.g.vcoolor_disable_mappings 1)
                (keymap :n "<leader>ce" "<cmd>VCoolor<cr>")))

;-------------------------
;;; Filetype specific
;-------------------------

(use "lervag/vimtex"
     :ft :tex
     :config #(do (set vim.g.tex_flavor :latex)
                  (set vim.g.vimtex_view_method :zathura)))

(when (executable-exists? "jq")
  (use "monkoose/fzf-hoogle.vim"))

(use "neovimhaskell/haskell-vim"
      :ft :haskell
      :config (fn []
                (set vim.g.haskell_enable_quantification   1)  ; enable highlighting of `forall`
                (set vim.g.haskell_enable_recursivedo      1)  ; enable highlighting of `mdo` and `rec`
                (set vim.g.haskell_enable_arrowsyntax      1)  ; enable highlighting of `proc`
                (set vim.g.haskell_enable_pattern_synonyms 1)  ; enable highlighting of `pattern`
                (set vim.g.haskell_enable_typeroles        1)  ; enable highlighting of type roles
                (set vim.g.haskell_enable_static_pointers  1)  ; enable highlighting of `static`
                (set vim.g.haskell_backpack                1)  ; enable highlighting of backpack keywords
                (set vim.g.haskell_indent_case_alternative 1)
                (set vim.g.haskell_indent_if               1)
                (set vim.g.haskell_indent_case             2)
                (set vim.g.haskell_indent_let              4)
                (set vim.g.haskell_indent_where            10)
                (set vim.g.haskell_indent_before_where     1)
                (set vim.g.haskell_indent_after_bare_where 1)
                (set vim.g.haskell_indent_do               3)
                (set vim.g.haskell_indent_in               0)
                (set vim.g.haskell_indent_guard            2)))

;; (use "JuliaEditorSupport/julia-vim")

(use "bakpakin/fennel.vim"
     :ft :fennel)

(use "wlangstroth/vim-racket")

(use "tikhomirov/vim-glsl"
     :ft :glsl)

(use "edwinb/idris2-vim")

;;;
;;; Themes
;;;
(use "rktjmp/lush.nvim")

(use "pbrisbin/vim-colors-off")
(use "YorickPeterse/vim-paper")
(use "Shatur/neovim-ayu"
  :config #((require-use :ayu :setup) {:mirage true}))
(use "sainnhe/everforest")

;; Return packer itself to allow chaining commands
packer

; Macros and utilities
(import-macros {:packer-use use
                :require-setup setup
                : require-use
                : augroup
                : restoring-cursor
                : ex}
               :macros)
(local {: autocmd : executable-exists?} (require :editor))

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

;;;----------------------------------------------------------------------------
;;; Bootstrapped behaviour
;;;----------------------------------------------------------------------------

;; The plugin manager itself
(use "wbthomason/packer.nvim"
      :opt true)

;; Fennel support for nvim
(use "rktjmp/hotpot.nvim"
      :config #(require :hotpot))


;;;----------------------------------------------------------------------------
;;; Treesitter
;;;----------------------------------------------------------------------------

(use "nvim-treesitter/nvim-treesitter"
  :run    ":TSUpdate"
  :config #(require :plugins.treesitter))

;; Semantically based text objects (such as functions, classes etc.)
(use "nvim-treesitter/nvim-treesitter-textobjects"
  :requires "nvim-treesitter/nvim-treesitter")

;; Split and join nodes treesitter
(use "Wansmer/treesj"
  :config #(do
            (setup :treesj
              :use_default_keymaps false
              :max_join_length     140)
            (vim.keymap.set :n "<space>j" (require-use :treesj :toggle))))

(use "danymat/neogen"
  :config #(do
             (setup :neogen)
             (vim.keymap.set :n "<space>gd" (require-use :neogen :generate)))
  :requires "nvim-treesitter/nvim-treesitter")

;;;----------------------------------------------------------------------------
;;; Language Server Protocol
;;;----------------------------------------------------------------------------

(use "neovim/nvim-lspconfig"
     :config #(require :lsp))

; Hook external linters/formaters into LSP
(use "nvimtools/none-ls.nvim"
  :requires "nvim-lua/plenary.nvim"
  :config #(let [null-ls (require :null-ls)]
            (null-ls.setup
              {:sources [null-ls.builtins.code_actions.gitsigns
                         null-ls.builtins.hover.dictionary
                         null-ls.builtins.hover.printenv]})))

;;;----------------------------------------------------------------------------
;;; Should be built-in
;;;----------------------------------------------------------------------------

; Allow writing file with sudo
; even if I open nvim as a normal user
(when (executable-exists? "sudo")
  (use "lambdalisue/suda.vim"
    :cmd [:SudaRead :SudaWrite]))

;; Title case operator
(use "christoomey/vim-titlecase")

;; Add commands to (un)comment text objects
(use "numToStr/Comment.nvim"
  :config #(setup :Comment :ignore "^$"))

;; Edit surrounding objects
(use "kylechui/nvim-surround"
  :config #(setup :nvim-surround))

;; Additional text operators
(use "wellle/targets.vim")

;; Improved matchparen and matchit
(use "andymass/vim-matchup"
  :config (fn []
           (set vim.g.loaded_matchit 1)
           (set vim.g.matchup_matchparen_offscreen {:method :popup})
           (set vim.g.matchup_matchparen_hi_surround_always 1)
           (set vim.g.matchup_matchparen_deferred_show_delay 150)
           (set vim.g.matchup_override_vimtex 0)
           (set vim.g.matchup_matchpref {:html {:tagnameonly 1}})))

; Alignment utils (vimscript)
(use "junegunn/vim-easy-align"
  :config (fn []
            (vim.keymap.set [:n :x] "<leader>a" "<Plug>(LiveEasyAlign)"
              {:remap true})
            (set vim.g.easy_align_delimiters
              {";" {:pattern ";"
                    :delimiter_align :l}
               ">" {:pattern "=>\\|->\\|>\\|→"
                    :delimiter_align :r}
               "<" {:pattern "<-\\|<=\\|<\\|←"
                    :delimiter_align :l}
               "r" {:pattern "{\\|}\\|,"     ; Lua / Haskell style Records
                    :delimiter_align :r}})))

; Better marks management
(use "chentoast/marks.nvim"
  :config #(setup :marks))

; Open links without netrw
(use "chrishrb/gx.nvim"
  :requires "nvim-lua/plenary.nvim"
  :config #(setup :gx))

;;;----------------------------------------------------------------------------
;;; Extra functionalities
;;;----------------------------------------------------------------------------

;; Manage REPLs
(use "hkupty/iron.nvim"
  :commit "bc9c596d6a97955f0306d2abcc10d9c35bbe2f5b"
  :config (fn []
            (set vim.g.iron_map_defaults 0)
            (set vim.g.iron_map_extended 0)
            (require :plugins.iron)))

;; Better REPL management for Lisps
(use "Olical/conjure"
  :ft [:fennel :racket :scheme :lisp]
  :config (fn []
            (tset vim.g :conjure#extract#tree_sitter#enabled        true)
            (tset vim.g :conjure#highlight#enabled                  true)
            (tset vim.g :conjure#log#hud#border                     "double")
            (tset vim.g :conjure#highlight#enabled                  :IncSearch)
            ;; scheme
            (tset vim.g :conjure#filetype#scheme                    "conjure.client.guile.socket")
            (tset vim.g :conjure#client#scheme#stdio#command        "racket -il scheme")
            (tset vim.g :conjure#client#scheme#stdio#prompt_pattern "\n?[\"%w%-./_]*> ")
            (tset vim.g :conjure#client#guile#socket#pipename       "/tmp/guile-repl.socket")
            ;; fennel
            (tset vim.g :conjure#filetype#fennel                    "conjure.client.fennel.stdio")
            (tset vim.g :conjure#client#fennel#stdio#command        "fennel")))

; Auto-layouting for Lisp parentheses
(use "gpanders/nvim-parinfer"
  :config #(set vim.g.parinfer_no_maps 1))

;; Highly improved wildmenu.
;; Includes niceties such as fuzzy search.
(use "gelguy/wilder.nvim"
     ; In case of errors, disable with "call wilder#disable()"
  :event    [:CmdlineEnter]
  :requires ["romgrk/fzy-lua-native"]
  :config   #(require :plugins.wilder))

;; Search everything with fzf
(use "ibhagwan/fzf-lua"
  :config (fn []
            (vim.keymap.set :n "<leader>ff" (require-use :fzf-lua :files))
            (vim.keymap.set :n "<leader>fb" (require-use :fzf-lua :buffers))
            (vim.keymap.set :n "<leader>fh" (require-use :fzf-lua :help_tags))
            (vim.keymap.set :i "<C-x><C-f>" (require-use :fzf-lua :complete_path))
            (vim.keymap.set :i "<C-x><C-l>" (require-use :fzf-lua :complete_line))))

; Async make      (vimscript)
(use "tpope/vim-dispatch"
  :cmd [:Make :Dispatch])

(use "tpope/vim-abolish")

; View **undo history** as a nice tree (with diffs!)
(use "mbbill/undotree"
  :config #(vim.keymap.set :n "<leader>tu" "<cmd>UndotreeToggle<CR>"))

;; Diff mode for directories
(use "cossonleo/dirdiff.nvim")

(use "NMAC427/guess-indent.nvim"
  :opt true
  :config #(setup :guess-indent))

;; Auto-close hidden / unedited buffers
(use "axkirillov/hbac.nvim")

;; File explorer (netrw substitute)
(use "stevearc/oil.nvim"
  :config #(do
             (setup :oil
               :columns [:icon :permission :size :mtime])
             (vim.keymap.set :n "-" "<CMD>Oil<CR>"
               {:desc "Open parent directory"})))

;; This and the following plugins should be substitute by dial.nvim or something similar
(use "nat-418/boole.nvim"
  :config #(setup :boole
            :mappings {:increment "<C-a>"
                       :decrement "<C-x>"}
            :additions [["LT" "EQ" "GT"]
                        [">"  "<"]
                        [">=" "<="]]))

(use "tpope/vim-speeddating")


(use "rgroli/other.nvim"
  :config #(setup :other-nvim
            :mappings
              ["golang"
               ; Site
               { :pattern "content/(.-)%..+$"
                :target
                  [{:target  "build/%1/index.html"
                    :context "build"}
                   {:target  "static/%1/figures.js"
                    :context "js"}]}]))

;;;----------------------------------------------------------------------------
;;; External Integrations
;;;----------------------------------------------------------------------------

;; Git
(use "lewis6991/gitsigns.nvim"
  :config #(require :plugins.gitsigns))

;;;----------------------------------------------------------------------------
;;; Prettier
;;;----------------------------------------------------------------------------

;; Align quickfix
(use "https://gitlab.com/yorickpeterse/nvim-pqf"
  :config #(setup :pqf))

;;;----------------------------------------------------------------------------
;;; Colors
;;;----------------------------------------------------------------------------

;; Highlighting and color manipulation
(use "uga-rosa/ccc.nvim"
  :cmd [:CccPick :CccHighlighterToggle]
  :config #(let [ccc (require :ccc)]
             (setup :ccc
                :outputs [ccc.output.hex
                          ccc.output.css_rgb
                          ccc.output.css_hsl
                          ccc.output.float])
             (vim.keymap.set :n "<leader>ce" "<cmd>CccPick<CR>")
             (vim.keymap.set :n "<leader>cc" "<cmd>CccHighlighterToggle<CR>")))

;; I like my colorschemes green and warm
(use "sainnhe/everforest"
  :config #(do
             (set vim.g.everforest_disable_italic_comment 1)
             (set vim.g.everforest_better_performance     1)
             (set vim.g.everforest_spell_foreground       1)
             (set vim.g.everforest_sign_column_background 1)))


(use "rktjmp/lush.nvim"
  :disable true)

(use "pbrisbin/vim-colors-off")

;;;----------------------------------------------------------------------------
;;; Filetype specific
;;;----------------------------------------------------------------------------

(use "lervag/vimtex"
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

(use "mrcjkb/haskell-tools.nvim"
  :disable true
  :requires "nvim-lua/plenary.nvim"
  :ft [:haskell :lhaskell :cabal :cabalproject])

(use "bakpakin/fennel.vim"
  :ft :fennel)

(use "wlangstroth/vim-racket")

(use "tikhomirov/vim-glsl"
  :ft :glsl)

(use "edwinb/idris2-vim")

(use "ledger/vim-ledger"
  :config (fn []
            (set vim.g.ledger_bin             :hledger)
            (set vim.g.ledger_is_hledger      true)
            (set vim.g.ledger_date_format     "%Y-%m-%d")
            (set vim.g.ledger_align_at        50)
            (set vim.g.ledger_align_commodity 1)    ; Align on R$ instead of decimal dot
            (set vim.g.ledger_commodity_sep   " ")
            (set vim.g.ledger_extra_options   "--strict ordereddates payees uniqueleafnames")
            ;; Change transition date to today
            (vim.keymap.set :n "<leader>dd" "<CMD>call ledger#transaction_date_set(line('.'), 'primary')<CR>"
              {:desc "Change transaction date to today"})
            ;; Align all posts on current paragraph (I use one transaction per paragraph)
            (vim.keymap.set :n "<leader>da"
              #(restoring-cursor (vim.cmd "'{,'}LedgerAlign"))
              {:desc "Align postings on current transaction"})))

;; Return packer itself to allow chaining commands
packer

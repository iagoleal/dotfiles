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
  :branch :main)

(use "nvim-treesitter/nvim-treesitter"
  :run    ":TSUpdate"
  :config #(require :plugins.treesitter))

;; Configure language servers
(use "neovim/nvim-lspconfig"
     :config #(require :lsp))

; Hook external linters/formaters into LSP
(use "nvimtools/none-ls.nvim"
  :requires "nvim-lua/plenary.nvim"
  :config #(let [null-ls (require :null-ls)]
            (null-ls.setup
              {:sources [null-ls.builtins.hover.dictionary
                         null-ls.builtins.hover.printenv]})))

(use "mfussenegger/nvim-dap"
  :config #(require :plugins.dap))

(use "mfussenegger/nvim-dap-python"
  :config #((require-use :dap-python :setup) "python"))

(use "rcarriga/nvim-dap-ui"
  :requires ["mfussenegger/nvim-dap"
             "nvim-neotest/nvim-nio"]
  :config #(setup :dapui))

(use "nvim-neotest/neotest"
  :requires ["nvim-neotest/nvim-nio"
             "nvim-lua/plenary.nvim"
             ; Adapters
             "mrcjkb/neotest-haskell"
             "nvim-neotest/neotest-python"
             "rcasia/neotest-bash"
             "nvim-treesitter/nvim-treesitter"]
  :config
    (fn []
      (setup :neotest
        :adapters [(require :neotest-haskell)
                   (require :neotest-python)
                   (require :neotest-bash)]
       )))

;;;----------------------------------------------------------------------------
;;; Text editing
;;;----------------------------------------------------------------------------
;; Provide new ways to edit and manipulate text,
;; such as text objects or operators.

;; Manipulate delimiter pairs "'[({})]'"
(use "kylechui/nvim-surround"
  :config #(setup :nvim-surround))

;; Operator exchanging text object by "0 register
(use "gbprod/substitute.nvim"
  :config
    (fn []
      (setup :substitute)
      ;; Substitute
      (vim.keymap.set :n "gs"  (require-use :substitute :operator))
      (vim.keymap.set :n "gss" (require-use :substitute :line))
      (vim.keymap.set :n "gS"  (require-use :substitute :eol))
      (vim.keymap.set :x "gs"  (require-use :substitute :visual))
      ;; Exchange
      (vim.keymap.set :n "cx"  (require-use :substitute.exchange :operator))
      (vim.keymap.set :n "cxx" (require-use :substitute.exchange :line))
      (vim.keymap.set :x "cx"  (require-use :substitute.exchange :visual))
))

;; Semantical text objects
;; (such as functions, classes etc.)
(use "nvim-treesitter/nvim-treesitter-textobjects"
  :requires "nvim-treesitter/nvim-treesitter")

;; Title case operator
;; Adds `gz` command turn text from {lower,UPPER}-case to Title Case
(use "christoomey/vim-titlecase")

;; Split and join paramaters, lists, etc.
(use "Wansmer/treesj"
  :config #(do
            (setup :treesj
              :use_default_keymaps false
              :max_join_length     140)
            (vim.keymap.set :n "<leader>j" (require-use :treesj :toggle))))

;; Alignment utils (vimscript)
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

;; Substitute the built-in C-a / C-x.
;; Also adds support for cycling through patterns and constants
(use "monaqa/dial.nvim"
  :config
    (fn []
        (vim.keymap.set :n "<C-a>"  #((require-use :dial.map :manipulate) "increment" "normal"))
        (vim.keymap.set :n "<C-x>"  #((require-use :dial.map :manipulate) "decrement" "normal"))
        (vim.keymap.set :n "g<C-a>" #((require-use :dial.map :manipulate) "increment" "gnormal"))
        (vim.keymap.set :n "g<C-x>" #((require-use :dial.map :manipulate) "decrement" "gnormal"))
        (vim.keymap.set :v "<C-a>"  #((require-use :dial.map :manipulate) "increment" "visual"))
        (vim.keymap.set :v "<C-x>"  #((require-use :dial.map :manipulate) "decrement" "visual"))
        (vim.keymap.set :v "g<C-a>" #((require-use :dial.map :manipulate) "increment" "gvisual"))
        (vim.keymap.set :v "g<C-x>" #((require-use :dial.map :manipulate) "decrement" "gvisual"))))



;;;----------------------------------------------------------------------------
;;; Interface | Experience
;;;----------------------------------------------------------------------------
;; UI improvements such as file explorer, undo trees, colors, pickers.

;; Allow writing file with sudo even if I open nvim as a normal user
(when (executable-exists? "sudo")
  (use "lambdalisue/suda.vim"
    :cmd [:SudaRead :SudaWrite]))


;; View **undo history** as a nice tree (with diffs!)
(use "mbbill/undotree"
  :config #(vim.keymap.set :n "<leader>tu" "<cmd>UndotreeToggle<CR>"))

;; File explorer (netrw substitute)
(use "stevearc/oil.nvim"
  :config #(do
             (setup :oil
               :columns [:icon :permission :size :mtime])
             (vim.keymap.set :n "-" "<CMD>Oil<CR>"
               {:desc "Open parent directory"})))

;; Improved matchparen and matchit
(use "andymass/vim-matchup"
  :config (fn []
           (set vim.g.matchup_matchparen_offscreen {:method :popup})
           (set vim.g.matchup_matchpref {:html {:tagnameonly 1}})))
           (set vim.g.matchup_matchparen_hi_surround_always  1)
           (set vim.g.matchup_matchparen_deferred_show_delay 150)
           (set vim.g.matchup_override_vimtex    0)
           (set vim.g.matchup_transmute_enabled  1)

;; Async make      (vimscript)
(use "tpope/vim-dispatch"
  :cmd [:Make :Dispatch])


;;;
;;; Prettier interfaces
;;;

;; Align quickfix
(use "https://gitlab.com/yorickpeterse/nvim-pqf"
  :config #(setup :pqf))

; Better marks management
(use "chentoast/marks.nvim"
  :config #(setup :marks))


;;;----------------------------------------------------------------------------
;;; Extra functionality
;;;----------------------------------------------------------------------------
;; Plugins that I don't use this much but provide useful perks and features.

;; Diff mode for directories
(use "cossonleo/dirdiff.nvim")

(use "NMAC427/guess-indent.nvim"
  :opt true
  :config #(setup :guess-indent))

;; Auto-close hidden / unedited buffers
(use "axkirillov/hbac.nvim")

(use "rgroli/other.nvim"
  :config #(let [hotpot-cache ((require-use :hotpot :api :cache :cache-prefix))]
            (setup :other-nvim
              :mappings
                ["golang"
                 ; Hotpot
                 {:pattern (.. (vim.fn.expand "$HOME") "/.config/nvim/fnl/(.+).fnl")
                 ; /home/iago/.cache/nvim/hotpot/compiled/nvim/lua/startup.lua
                  :target  (.. hotpot-cache "/nvim/lua/%1.lua")
                  :context "compiled"}
                 {:pattern (.. (vim.fn.expand "$HOME") "/.config/nvim/(.+)/(.+).fnl")
                  :target  (.. hotpot-cache "/hotpot-runtime-nvim/lua/hotpot-runtime-%1/%2.lua")}
                 ; Site
                 {:pattern "content/(.-)%..+$"
                  :target
                    [{:target  "build/%1/index.html"
                      :context "build"}
                     {:target  "static/%1/figures.js"
                      :context "js"}]}])))

;; Generate documentation for functions, classes, etc.
(use "danymat/neogen"
  :config #(do
             (setup :neogen)
             (vim.keymap.set :n "<leader>gd" (require-use :neogen :generate)))
  :requires "nvim-treesitter/nvim-treesitter")

;;;
;;; Lispsy lisps
;;;

; Auto-layouting for Lisp parentheses
(use "gpanders/nvim-parinfer"
  :config #(set vim.g.parinfer_no_maps 1))

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

;;;
;;; To remove
;;;

;; Highly improved wildmenu.
;; Includes niceties such as fuzzy search.
; TODO: get rid of this
(use "gelguy/wilder.nvim"
     ; In case of errors, disable with "call wilder#disable()"
  :event    [:CmdlineEnter]
  :requires ["romgrk/fzy-lua-native"]
  :config   #(require :plugins.wilder))

;; Manage REPLs
; TODO: Remove
(use "hkupty/iron.nvim"
  :commit "bc9c596d6a97955f0306d2abcc10d9c35bbe2f5b"
  :config (fn []
            (set vim.g.iron_map_defaults 0)
            (set vim.g.iron_map_extended 0)
            (require :plugins.iron)))


;;;----------------------------------------------------------------------------
;;; External Integrations
;;;----------------------------------------------------------------------------

;; Git
(use "lewis6991/gitsigns.nvim"
  :config #(require :plugins.gitsigns))

;; FZF
(use "ibhagwan/fzf-lua"
  :config (fn []
            (vim.keymap.set :n "<leader>ff" (require-use :fzf-lua :files))
            (vim.keymap.set :n "<leader>fb" (require-use :fzf-lua :buffers))
            (vim.keymap.set :n "<leader>fd" (require-use :fzf-lua :dap_commands))
            (vim.keymap.set :n "<leader>fh" (require-use :fzf-lua :help_tags))
            (vim.keymap.set :i "<C-x><C-f>" (require-use :fzf-lua :complete_path))
            (vim.keymap.set :i "<C-x><C-l>" (require-use :fzf-lua :complete_line))))

;; AI helpers
(use "zbirenbaum/copilot.lua"
  :cmd   :Copilot
  :event :InsertEnter
  :config #(setup :copilot
             :suggestion {:auto_trigger false}))

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

(use "ledger/vim-ledger") ; config on ftplugin/ledger.fnl

;; Return packer itself to allow chaining commands
packer

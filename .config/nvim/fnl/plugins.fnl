; Macros and utilities
(import-macros {:packer-use use : keymap : augroup : ex} :macros)
(local {: autocmd &as ut} (require :futils))

;; Plugin management
(vim.cmd "packadd packer.nvim")
(local packer (require :packer))

;; Packer configuration table
(local config {:disable_commands true
               :compile_on_sync  true
               :max_jobs         9
               :profile          {:enable true}})

;;; Add and manage packages
(fn startup []
  ;; The plugin manager itself
  (use "wbthomason/packer.nvim"
        :opt true)
  ;; Fennel support for nvim
  (use "rktjmp/hotpot.nvim"
        :config #(require :hotpot))
  ;; Session Management
  (use "rmagatti/auto-session")

  ;; Treesitter
  (use "nvim-treesitter/nvim-treesitter"
        :run ":TSUpdate"
        :config #(require :plugins.treesitter))
  ; Semantically based text objects (such as functions, classes etc.)
  (use "nvim-treesitter/nvim-treesitter-textobjects"
       :requires "nvim-treesitter/nvim-treesitter")

  ;; LSP
  (use "neovim/nvim-lspconfig"
       :config #(require :lsp))
  ; Query LSP for tag files.
  ; It Allows me to use built-in tag commands with LSP.
  (use "weilbith/nvim-lsp-smag")

  ;; REPL
  (use "hkupty/iron.nvim"
       :config (fn []
                 (set vim.g.iron_map_defaults 0)
                 (set vim.g.iron_map_extended 1)
                 (require :plugins.iron)))
  (use "Olical/conjure"
       :ft [:scheme :racket :clojure]
       :config (fn []
                 (tset vim.g :conjure#client#scheme#stdio#command        "racket -il scheme")
                 (tset vim.g :conjure#client#scheme#stdio#prompt_pattern "\n?[\"%w%-./_]*> ")))
                 ; vim.g["conjure#filetype#fennel"] = 'conjure.client.fennel.stdio'
                 ; vim.g["conjure#client#fennel#stdio#command"] = 'fennel'

  ;; Fuzzy Search
  (use "junegunn/fzf.vim"
       :config (fn []
                 (set vim.g.fzf_command_prefix "FZF")))
  (use "gelguy/wilder.nvim"
       ; In case of errors, disable with "call wilder#disable()"
       :event    [:CursorHold :CmdlineEnter]
       :rocks    ["luarocks-fetch-gitrec" "pcre2"]
       :requires ["romgrk/fzy-lua-native"]
       :config #(ex source (.. (vim.fn.stdpath :config)
                               "/viml/wilder.vim")))
  ; Integrate with fzf plugin to search Hoogle database
  (use "monkoose/fzf-hoogle.vim"
       :ft :haskell)

  ;; Major utilities
  ; Add commands to (un)comment text objects
  (use "terrortylor/nvim-comment"
       :config #((. (require :nvim_comment) :setup) {:comment_empty false}))
  ; Edit surrounding objects (vimscript)
  (use "tpope/vim-surround")
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
  (when (ut.executable-exists? "sudo")
    (use "lambdalisue/suda.vim"
         :cmd [:SudaRead :SudaWrite]))
  ; Alignment utils (vimscript)
  (use "junegunn/vim-easy-align"
        :config (fn []
                    (set vim.g.easy_align_delimiters
                         {">" {:pattern "=>\\|->\\|>\\|→"
                              :delimiter_align :r}
                          "<" {:pattern "<-\\|<=\\|<\\|←"
                              :delimiter_align :l}
                          "r" {:pattern "{\\|}\\|,"     ; Lua / Haskell style Records
                              :delimiter_align :r}})))
  ; Tree view buffer for undo history
  (use "mbbill/undotree")

  ;; Colors
  (use "norcalli/nvim-colorizer.lua"
        :cmd [:ColorizerToggle :ColorizerReloadAllBuffers :ColorizerAttachToBuffer]
        :config #((. (require :colorizer) :setup)))
  ; Color picker
  ; NOTE: Can I remake this in lua with floating windows?
  (use "KabbAmine/vCoolor.vim"
        :config (fn []
                  (set vim.g.vcoolor_disable_mappings 1)
                  (keymap :n "<leader>ce" "<cmd>VCoolor<cr>")))
  (use "amadeus/vim-convert-color-to"
       :cmd :ConvertColorTo)
  ;; Let those paretheses ~~**shine**~~
  (use "p00f/nvim-ts-rainbow"
       :requires "nvim-treesitter/nvim-treesitter")
  ; TODO: Ditch this for treesitter one
  (use "luochen1990/rainbow"
       :disable true
       :cmd     [:RainbowToggle :RainbowToggleOn]
       :config (fn []
                 (set vim.g.rainbow_active 0)))

  ;;; Filetype specific
  (use "lervag/vimtex"
       :ft :tex
       :config (fn []
                 (set vim.g.tex_flavor :latex)
                 (set vim.g.vimtex_view_method :zathura)))
  (use "plasticboy/vim-markdown"
       :ft :markdown
       :config (fn []
                 (set vim.g.vim_markdown_folding_disabled     1)
                 (set vim.g.vim_markdown_conceal              0)
                 (set vim.g.vim_markdown_fenced_languages
                      ["c++=cpp" "viml=vim" "bash=sh" "ini=dosini"])
                 (set vim.g.vim_markdown_math                 1)
                 (set vim.g.vim_markdown_frontmatter          1)
                 (set vim.g.vim_markdown_new_list_item_indent 4)))
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
  (use "JuliaEditorSupport/julia-vim"
       :opt false)
  (use "bakpakin/fennel.vim"
       :ft :fennel)
  (use "wlangstroth/vim-racket")
  (use "tikhomirov/vim-glsl"
       :ft :glsl)
  ; use 'derekelkins/agda-vim'

  ;; Themes
  (use "folke/tokyonight.nvim")
  (use "mcchrish/zenbones.nvim")
  ;; Specific for Ubuntu WSL
  (when vim.env.WSLENV
    (use "kabouzeid/nvim-lspinstall"
         :requires "neovim/nvim-lspconfig"))
)


(packer.init config)
(packer.reset)
(startup)
;; Return packer itself to allow chaining commands
packer

;--------------------------
;;;; Configure Treesitter
;--------------------------
(local nvim-treesitter-configs (require :nvim-treesitter.configs))

(nvim-treesitter-configs.setup
 {:ensure_installed
    ["bash" "bibtex" "c" "comment" "cpp" "css" "dot" "haskell" "html" "javascript" "json" "julia" "lua" "markdown" "python" "scheme" "yaml"]
  ;; Improved Syntax highlighting
  :highlight
    {:enable false
     :additional_vim_regex_highlighting false}
  ;; Scope based text sleection
  :incremental_selection
    {:enable  true
     :keymaps {:init_selection    "<M-v>"
               :node_incremental  "<M-j>"
               :scope_incremental "<CR>"
               :node_decremental  "<M-k>"}}
  ;; Use Treesitter for indentation
  :indent
    {:enable true}

  ;;; External plugins

  ;; ~~**Colorful**~~ parentheses ((()))
  :rainbow
    {:enable false}
  :matchup
    {:enable false} ; This causes extreme lag, disable by now
  ;; Custom semantically based text objects
  ;; and operations on them
  :textobjects
    {:select {:enable    true
              :lookahead true
              :keymaps {"af" "@function.outer"
                        "if" "@function.inner"
                        "ac" "@class.outer"
                        "ic" "@class.inner"}}

     :move {:enable    true
            :set_jumps true
            :goto_next_start
               {"]m" "@function.outer"
                "]]" "@class.outer"}
            :goto_next_end
               {"]M" "@function.outer"
                "][" "@class.outer"}
            :goto_previous_start
               {"[m" "@function.outer"
                "[[" "@class.outer"}
            :goto_previous_end
               {"[M" "@function.outer"
                "[]" "@class.outer"}}

     :include_surrounding_whitespace true

     :lsp_interop {:enable true
                   :peek_definition_code {"<leader>pf" "@function.outer"
                                          "<leader>pc" "@class.outer"}}}
  :textsubjects
    {:enable true
     :keymaps {"<CR>" "textsubjects-smart"
               ";"    "textsubjects-container-outer"}}})

;--------------------------
;;;; Configure Treesitter
;--------------------------
(local nvim-treesitter-configs (require :nvim-treesitter.configs))

(nvim-treesitter-configs.setup
 {:ensure_installed
    ["bash" "bibtex" "c" "comment" "cpp" "css" "dot" "fennel" "haskell" "html" "javascript" "json" "julia" "lua" "markdown" "python" "scheme" "yaml"]
  ;; Improved Syntax highlighting
  ;; Scope based text sleection
  :incremental_selection
    {:enable  true
     :keymaps {:init_selection    "<M-v>"
               :node_incremental  "<M-j>"
               :scope_incremental "<CR>"
               :node_decremental  "<M-k>"}}
  ;; Use Treesitter for indentation
  :indent {:enable true}

  ;;; External plugins
  ;;;-----------------

  :matchup
    {:enable false} ; This causes extreme lag, disable by now

  :refactor
    {:highlight_current_scope {:enable true}}

  ;; Custom semantically based text objects and operations on them
  :textobjects
    {:select {:enable    true
              :lookahead true
              :keymaps
                {"af" "@function.outer"
                 "if" "@function.inner"
                 "ac" "@class.outer"
                 "ic" "@class.inner"
                 "iç" {:query "@scope" :query_group "locals" :desc "Select current scope"}}
              :include_surrounding_whitespace
                #($1.query_string:find "outer")}

     :move {:enable    true
            :set_jumps true
            :goto_next_start
               {"]m" "@function.outer"
                "]]" "@class.outer"
                "]ç" {:query "@scope" :query_group "locals" :desc "Next scope"}}
            :goto_next_end
               {"]M" "@function.outer"
                "][" "@class.outer"}
            :goto_previous_start
               {"[m" "@function.outer"
                "[[" "@class.outer"
                "[ç" {:query "@scope" :query_group "locals" :desc "Next scope"}}
            :goto_previous_end
               {"[M" "@function.outer"
                "[]" "@class.outer"}}

     :swap {:enable true
            :swap_next
             {"<leader>s" "@parameter.inner"}
            :swap_previous
             {"<leader>S" "@parameter.inner"}}


     :lsp_interop {:enable true
                   :peek_definition_code {"<leader>pf" "@function.outer"
                                          "<leader>pc" "@class.outer"}}}})

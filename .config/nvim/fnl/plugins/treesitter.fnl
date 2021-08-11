((. (require :nvim-treesitter.configs) :setup)
 {:ensure_installed
    ["bash" "bibtex" "c" "comment" "cpp" "css" "fennel" "haskell" "html" "javascript" "json" "julia" "latex" "lua" "python" "yaml"]
  :highlight {:enable true
              :additional_vim_regex_highlighting false}
  :incremental_selection {:enable  true
                          :keymaps {:init_selection    "gnn"
                                    :node_incremental  "grn"
                                    :scope_incremental "grc"
                                    :node_decremental  "grm"}}
  :indent
    {:enable true}
  ;; External plugins
  :rainbow
    {:enable false}
  :matchup
    {:enable false}
  :textobjects {:select {:enable    true
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
                :lsp_interop {:enable true
                              :peek_definition_code {"<leader>pf" "@function.outer"
                                                     "<leader>pc" "@class.outer"}}}})	

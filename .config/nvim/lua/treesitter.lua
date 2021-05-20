-- Configure Treesitter
require'nvim-treesitter.configs'.setup {
  ensure_installed = {"bash", "bibtex", "c", "comment", "cpp", "css", "fennel", "haskell", "html", "javascript", "json", "julia", "latex", "lua", "python", "yaml"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true,
    -- https://www.reddit.com/r/neovim/comments/n9aupn/set_spell_that_only_considers_code_comments/
    additional_vim_regex_highlighting = true
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection    = "gnn",
      node_incremental  = "grn",
      scope_incremental = "grc",
      node_decremental  = "grm",
    },
  },
  indent = {
    enable = true
  },
  -- External plugins
  rainbow = {
    enable = false,
  },
  matchup = {
    enable = false
    -- disable = { },  -- optional, list of language that will be disabled
  },
}



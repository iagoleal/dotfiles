-- Configure Trreesitter

local tscfg = require'nvim-treesitter.configs'

tscfg.setup {
  ensure_installed = {"bash", "c", "css", "fennel", "json", "julia", "lua", "python"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      node_incremental = "grn",
      scope_incremental = "grc",
      node_decremental = "grm",
    },
  },
  indent = {
    enable = true
  },
  rainbow = {
    enable = true,
    disable = {'bash'} -- please disable bash until I figure #1 out
  },
}

---- Don't highlight braces
---- Needed for compatibility with rainbow.vim
--require "nvim-treesitter.highlight"
--local hlmap = vim.treesitter.highlighter.hl_map
----Misc
--hlmap.error = nil
--hlmap["punctuation.delimiter"] = "Delimiter"
--hlmap["punctuation.bracket"] = nil

-- Configure Iron Repl

local iron = require('iron')

iron.core.add_repl_definitions {
  fennel = {
    love = {
      command = {"love", "."}
    }
  },
  haskell = {
    stack = {
      command = {"stack", "ghci"},
      open = ":{",
      close = {":}", ""}
    }
  },
  scheme = {
    chez = { command = {"scheme"} },
    racket = { command = {"racket", "il", "scheme"} }
  }
}

iron.core.set_config {
  preferred = {
    fennel  = "fennel",
    haskell = "stack",
    python  = "python",
    scheme  = "racket",
  },
  repl_open_cmd = "rightbelow 66 vsplit"
}

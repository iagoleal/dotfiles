-- Configure Trreesitter

local tscfg = require'nvim-treesitter.configs'

tscfg.setup {
  ensure_installed = {"bash", "c", "css", "fennel", "haskell", "html", "json", "julia", "lua", "python"}, -- one of "all", "maintained" (parsers with maintainers), or a list of languages
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
  },
}

-- Configure Iron Repl

local iron = require('iron')

iron.core.add_repl_definitions {
  lua    = {
    luajit = { command = {"luajit"} },
    lua53 = { command = {"lua5.3"} }
  },
  fennel = {
    love = { command = {"love", "."} }
  },
  haskell = {
    stack = {
      command = {"stack", "ghci"},
      open    = ":{",
      close   = {":}", ""}
    }
  },
  scheme = {
    chez = { command = {"scheme"} },
    racket = { command = {"racket", "-il", "scheme"} }
  }
}

iron.core.set_config {
  preferred = {
    lua     = "lua53",
    fennel  = "fennel",
    haskell = "stack",
    python  = "python",
    scheme  = "racket",
  },
  repl_open_cmd = "rightbelow 66 vsplit"
}


-- Configure Colorizer

local colorizer = require'colorizer'
colorizer.setup()

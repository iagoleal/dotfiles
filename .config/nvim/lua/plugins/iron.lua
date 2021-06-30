--------------------------
-- Configure Iron REPL
--------------------------

local iron = require 'iron'
local utils = require 'utils'

iron.core.add_repl_definitions {
  lua = {
    luajit = { command = {"luajit"} },
    lua51  = { command = {"lua5.1"} },
    lua52  = { command = {"lua5.2"} },
    lua53  = { command = {"lua5.3"} },
    lua54  = { command = {"lua5.4"} },
    love   = { command = {"love", "."} }
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
    chez   = { command = {"scheme"} },
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

function iron_set_preferred(repl)
  local ft = vim.bo.filetype
  if repl == nil then
    local repls = vim.tbl_map(function(v) return v[1] end,
                              iron.core.list_definitions_for_ft(ft))
    table.sort(repls)
    local prompts = {}
    for k, v in ipairs(repls) do
      prompts[k] = string.format("%d. %s", k, v)
    end
    local choice = vim.fn.inputlist(prompts)
    repl = repls[choice]
  end
  iron.core.set_config {preferred = {[ft] = repl}}
end

---------------------
-- Editor Commands
---------------------

utils.viml [[command -nargs=? IronSetPreferred :lua iron_set_preferred(<f-args>)]]

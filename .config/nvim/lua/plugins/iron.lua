--------------------------
-- Configure Iron REPL
--------------------------

local iron = require 'iron'
local visibility = require 'iron.visibility'
local utils = require 'utils'

iron.core.add_repl_definitions {
  lua = {
    luajit = { command = {"luajit"} },
    lua51  = { command = {"lua5.1"} },
    lua52  = { command = {"lua5.2"} },
    lua53  = { command = {"lua5.3"} },
    lua54  = { command = {"lua5.4"} },
    love   = { command = {"love", "--console", "."} }
  },
  fennel = {
    love = { command = {"love", "--console", "."} }
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
  repl_open_cmd = 'rightbelow 66 vsplit',
  visibility = visibility.toggle
}

----------------------
-- Utility Functions
----------------------

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

local hidden = function(bufid, showfn)
  local was_hidden = false
  local window = vim.fn.bufwinnr(bufid)
  if window == -1 then
    was_hidden = true
    window = vim.fn.win_id2win(showfn())
  end
  return window, was_hidden
end

visibility.blink = function(bufid, showfn)
  local window, was_hidden = hidden(bufid, showfn)
  if not was_hidden then
    vim.api.nvim_command(window .. "wincmd c")
    window = vim.fn.win_id2win(showfn())
    vim.api.nvim_command(window .. "wincmd p")
  else
    vim.api.nvim_command(window .. "wincmd p")
  end
end

function iron_split_open(orientation)
  local old_config = iron.config.repl_open_cmd
  if old_config == orientation then
    iron.core.repl_for(vim.api.nvim_buf_get_option(0,'filetype'))
  else
    local old_visibility = iron.config.visibility
    iron.core.set_config {repl_open_cmd = orientation,
                          visibility = visibility.blink}
    iron.core.repl_for(vim.api.nvim_buf_get_option(0,'filetype'))
    iron.core.set_config {visibility = old_visibility}
  end
end

---------------------
-- Editor Commands
---------------------

utils.viml [[command! -nargs=? IronSetPreferred :lua iron_set_preferred(<f-args>)]]


---------------------
-- Mappings
---------------------
-- REPL
utils.map('n', "<leader>it",       "<Plug>(iron-send-motion)",   {noremap = false})
utils.map('v', "<leader>i<Space>", "<Plug>(iron-visual-send)",   {noremap = false})
utils.map('n', "<leader>i.",       "<Plug>(iron-repeat-cmd)",    {noremap = false})
utils.map('n', "<leader>i<Space>", "<Plug>(iron-send-line)",     {noremap = false})
utils.map('n', "<leader>ii",       "<Plug>(iron-send-line)",     {noremap = false})
utils.map('n', "<leader>i<CR>",    "<Plug>(iron-cr)",            {noremap = false})
utils.map('n', "<leader>ic",       "<Plug>(iron-interrupt)",     {noremap = false})
utils.map('n', "<leader>iq",       "<Plug>(iron-exit)",          {noremap = false})
utils.map('n', "<leader>il",       "<Plug>(iron-clear)",         {noremap = false})
utils.map('n', "<leader>ip",       "<Plug>(iron-send-motion)ip", {noremap = false})
utils.map('n', "<leader>ir",       ":IronRestart<CR>")
-- Open REPL on bottom split
utils.map('n', "<leader>is", function()
  iron_split_open('botright 12 split')
end)
utils.map('n', "<leader>iS", function()
  iron_split_open('belowright 12 split')
end)
-- Open REPL on right split
utils.map('n', "<leader>iv", function()
  iron_split_open('botright 66 vsplit')
end)
utils.map('n', "<leader>iV", function()
  iron_split_open('belowright 66 vsplit')
end)
-- Send entire file
utils.map('n', "<leader>if", function()
  require('iron').core.send(vim.bo.filetype, vim.api.nvim_buf_get_lines(0, 0, -1, false))
end)

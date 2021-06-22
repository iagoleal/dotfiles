-- Typical module boilerplate
local M = {_G = _G}
local vim = vim
setmetatable(M, {__index = _G})
setfenv(1, M)

-- Set options using same scope rules as vimscript's ":set"
local function set_option(opt, value)
  local info = vim.api.nvim_get_option_info(opt)
  if info.scope ~= 'win' or info.global_local then
    vim.api.nvim_set_option(opt, value)
  end
  if not info.global_local then
    if info.scope == 'win' then
      vim.wo[opt] = value
    elseif info.scope == 'buf' then
      vim.bo[opt] = value
    else
      vim.api.nvim_set_option(opt, value)
    end
  end
end

local function process_autocmd(aucmd)
  if type(aucmd[1]) == "table" then
    aucmd[1] = table.concat(aucmd[1], ',')
  end
  return table.concat(aucmd, ' ')
end

--------------------------------
-- Vimscript like interface
--------------------------------

function augroup(name, autocmds)
  vim.cmd('augroup ' .. name)
  vim.cmd('autocmd!')
  for _, autocmd in ipairs(autocmds) do
      vim.cmd('autocmd ' .. process_autocmd(autocmd))
  end
  vim.cmd('augroup END')
end

-- Keymaps
-- This is 'norecursive' by default, differently from vimscript
_mapped_functions = {} -- Store lua functions that are mapped to some key
function map(mode, keys, cmd, opts)
  -- Default options
  opts = opts or {}
  if opts.noremap == nil then
    opts.noremap = true
  end
  if type(cmd) == 'function' then
    table.insert(_mapped_functions, cmd)
    local idx = #_mapped_functions
    cmd = string.format("<cmd>lua _mapped_functions[%d]()<CR>", idx)
  end
  vim.api.nvim_set_keymap(mode, keys, cmd, opts)
end

-- Change colorscheme
function colorscheme(name)
  vim.api.nvim_command("colorscheme " .. name)
end

-- Check whether this version of nvim has a certain option
function has(opt)
  return vim.fn.has(opt) == 1 or vim.fn.has(opt) == true
end

-- Check whether an executable exists on the PATH
function has_executable(expr)
  return vim.fn.executable(expr) == 1
end

-- Set highlight group
-- Accept an additional option 'default' to use 'hi default'
function highlight(mode, opts)
  local hi = {"highlight"}
  if opts.default then
    table.insert(hi, "default")
    opts.default = nil
  end
  table.insert(hi, mode)
  for k, v in pairs(opts) do
    table.insert(hi, k .. "=" .. v)
  end
  vim.cmd(table.concat(hi, ' '))
end

function hi_link(from, to, opts)
  local hi = {
    opts.bang and "highlight!" or "highlight",
    opts.default and "default" or "",
    "link",
    from,
    to
  }
  vim.cmd(table.concat(hi, ' '))
end

-- Set an option following vimscript style and scope
function option(opt, value)
  if value == nil then
    value = true
  end
  vim.opt[opt] = value
end

-- Set several options at the same time
function options(...)
  local opts = {...}
  for _, v in ipairs(opts) do
    if type(v) == "string" then
      option(v, true)
    end
    if type(v) == "table" then
      local len = #v
      if len == 1 then
        option(v[1], true)
      elseif len == 2 then
        option(v[1], v[2])
      else
        error(string.format("Options can only have one value, but option '%s' got %d", v[1], len-1))
      end
    end
  end
end

-- Print a message with an optional highlight group
function echohl(text, hl)
  hl = hl or ""
  -- local emsg = vim.fn.escape(text, '"')
  vim.cmd('echohl ' .. hl .. ' | redraw')
  print(text)
  vim.cmd('echohl NONE')
end

------------------------
-- Global utilities
------------------------

-- Execute a string of vimscript
function vimscript(s)
  return vim.api.nvim_exec(s, true)
end
viml = vimscript

-- Pretty print information about lua objects
function dump(...)
  local input = {...}
  local output = {}
  for i = 1, select('#', ...) do
    output[i] = vim.inspect(input[i])
  end
  print(unpack(output))
end

function force_require(pkg)
  package.loaded[pkg] = nil
  return require(pkg)
end

-- Require a package and pollute the global environment with it
-- If the argument is a table, add its elements to the global environment.
-- If the argument is a string, require the module and add its elements to the global environment.
function using(pkgname)
  local pkg
  if type(pkgname) == "string" then
    pkg = require(pkgname)
  elseif type(pkgname) == "table" then
    pkg = pkgname
  end
  local env = getfenv(0)
  for k, v in pairs(pkg) do
    env[k] = v
  end
  return pkg
end

return M

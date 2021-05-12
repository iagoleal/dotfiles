local api = {}

function api.highlight(mode, opts)
  local hi = {"highlight " .. mode}
  for k, v in pairs(opts) do
    table.insert(hi, " " .. k .. "=" .. v)
  end
  vim.cmd(table.concat(hi))
end

function api.augroup(name, autocmds)
    vim.cmd('augroup ' .. name)
    vim.cmd('autocmd!')

    for _, autocmd in ipairs(autocmds) do
        vim.cmd('autocmd ' .. table.concat(autocmd, ' '))
    end

    vim.cmd('augroup END')
end

function api.opt_scope(opt)
  local info = vim.api.nvim_get_option_info(opt)
  local stbl
  if info.scope == "buf" then
    stbl = "bo"
  elseif info.scope == "win" then
    stbl = "wo"
  else
    stbl = "o"
  end
  return stbl
end

function api.option(opt, value, scope)
  if scope == nil then
    scope = api.opt_scope(opt)
  end
  vim[scope][opt] = value
end

function goption(opt, value)
  api.option(opt, value, 'o')
end

-- Keymaps
-- This is 'norecursive', different from vimscript
function map(mode, keys, cmd, opts)
  -- Default options
  opts = opts or {}
  if opts.noremap == nil then
    opts.noremap = true
  end
  vim.api.nvim_set_keymap(mode, keys, cmd, opts)
end

-- Change colorscheme
function colorscheme(name)
  vim.api.nvim_command("colorscheme " .. name)
end

function dump(...)
  local t = table.pack(...)
  for i = 1, #t do
    t[i] = vim.inspect(t[i])
  end
  print(unpack(t))
end

function has(opt)
  return vim.fn.has(opt) == 1 or vim.fn.has(opt) == true
end

return api

local function highlight(mode, opts)
  local hi = {"highlight " .. mode}
  for k, v in pairs(opts) do
    table.insert(hi, " " .. k .. "=" .. v)
  end
  vim.cmd(table.concat(hi))
end

local function cursor_mode()
    local mode_name = {
        ['n']  = 'Normal',
        ['v']  = 'Visual',
        ['V']  = 'V-Line',
        [''] = 'V-Block',
        ['i']  = 'Insert',
        ['R']  = 'Replace',
        ['Rv'] = 'V-Replace',
        ['c']  = 'Command',
        ['s']  = 'Select',
        ['S']  = 'S-Line',
        [''] = 'S-Block',
        ['t']  = 'Terminal',
    }
    local mode = vim.fn.mode()

    return "%-10( " .. (mode_name[mode] or mode) .. "%)"
end

function statusline()
  local sl = table.concat(
    { "%#StatusMode#"
    , cursor_mode()
    , "%#StatusLine#"
    , " %-t %-m %-r"
    , "%= %c, %l:%L "
    , "%#StatusLang#"
    , " %{luaeval('vim.bo.filetype')} "
    })
  return sl
end

highlight("StatusMode", {gui = "bold", guifg = "Black", guibg = "White"})
highlight("StatusLang", {gui = "bold", guifg = "Black", guibg = "#81A3FA"})

vim.o.laststatus = 2
vim.o.showmode   = false
vim.o.statusline = "%!luaeval('statusline()')"

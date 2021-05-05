-- TODO: change color when RO or modified
local function highlight(mode, opts)
  local hi = {"highlight " .. mode}
  for k, v in pairs(opts) do
    table.insert(hi, " " .. k .. "=" .. v)
  end
  vim.cmd(table.concat(hi))
end

local function augroup(name, autocmds)
    vim.cmd('augroup ' .. name)
    vim.cmd('autocmd!')

    for _, autocmd in ipairs(autocmds) do
        vim.cmd('autocmd ' .. table.concat(autocmd, ' '))
    end

    vim.cmd('augroup END')
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
    return "%-10(%#StatusMode# " .. (mode_name[mode] or mode) .. "%)"
end

local function filetype()
  if vim.bo.filetype ~= "" then
    return "%#StatusLang# " .. vim.bo.filetype .. " "
  end
  return ""
end

-- Get number of diagnostics for each type
-- from https://github.com/nvim-lua/lsp-status.nvim/blob/master/lua/lsp-status/diagnostics.lua
local function get_lsp_diagnostics(bufnr)
  bufnr = bufnr or 0
  local result = {}
  local levels = { errors   = "Error"
                 , warnings = "Warning"
                 , info     = "Information"
                 , hints    = "Hint"
                 }
  for k, level in pairs(levels) do
    result[k] = vim.lsp.diagnostic.get_count(bufnr, level)
  end
  return result
end

local function diagnostics()
  if #vim.lsp.buf_get_clients() == 0 then
    return ""
  end
  local num = get_lsp_diagnostics()
  return table.concat({"%-24("
    , "%#LspDiagnosticsDefaultError#"        , "E:" , num.errors   , "%#StatusLine# | "
    , "%#LspDiagnosticsDefaultWarning#"      , "W:" , num.warnings , "%#StatusLine# | "
    , "%#LspDiagnosticsDefaultInformation#"  , "I:" , num.info     , "%#StatusLine# | "
    , "%#LspDiagnosticsDefaultHints#"        , "H:" , num.hints    , "%#StatusLine# "
    , "%)"})
end

function statusline()
  local sl = table.concat(
    { cursor_mode()
    , "%#StatusLine#"
    , " %-t %-m %-r"
    , "%="
    , diagnostics()
    , "%=%c, %l:%L "
    , filetype()
    })
  return sl
end


-- Generate the statusline
highlight("StatusMode", {gui = "bold", guifg = "Black", guibg = "White"})
highlight("StatusLang", {gui = "bold", guifg = "Black", guibg = "#81A3FA"})
vim.o.laststatus = 2
vim.o.showmode   = false
vim.o.statusline = "%!v:lua.statusline()"
-- Guarantee that correct buffer is used
augroup('StatusLine',
        { {'WinEnter,BufEnter', '*', 'set statusline<'}
        , {'WinLeave,BufLeave', '*', 'lua vim.wo.statusline=statusline()'}
        })

-- TODO: change color when RO or modified
local api = require "api"

-- Test whether the current buffer is the focused one
local function is_buffer_active()
  return vim.g.statusline_winid == vim.fn.win_getid()
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
    if is_buffer_active() then
      return "%-(%#StatusMode# " .. (mode_name[mode] or mode) .. " %)"
    else
      return ""
    end
end

function filetype()
  local color = vim.bo.modified and "%#StatusModified#" or "%#StatusLang#"
  local ft = vim.bo.filetype
  return table.concat{color, " ", ft, " "}
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
  return table.concat({"%21("
    , "%#LspDiagnosticsDefaultError#"        , "E:" , num.errors   , "%#StatusLine# "
    , "%#LspDiagnosticsDefaultWarning#"      , "W:" , num.warnings , "%#StatusLine# "
    , "%#LspDiagnosticsDefaultInformation#"  , "I:" , num.info     , "%#StatusLine# "
    , "%#LspDiagnosticsDefaultHint#"         , "H:" , num.hints    , "%#StatusLine# "
    , "%)"})
end

function statusline()
  local sl = table.concat(
    { cursor_mode()
    , "%#StatusLine#"
    , " %-t %-m %-r"
    , "%="
    , diagnostics()
    , "%2(%c%), %l:%L "
    , filetype()
    })
  return sl
end

-- Generate the statusline
api.highlight("StatusMode",     {gui = "bold", guifg = "Black", guibg = "White"})
api.highlight("StatusLang",     {gui = "bold", guifg = "Black", guibg = "#81A3FA"})
api.highlight("StatusModified", {gui = "bold", guifg = "Black", guibg = "#FF6B6B"})
api.highlight("StatusMixed",    {gui = "bold", guifg = "Black", guibg = "#A36BF0"})

vim.o.laststatus = 2
vim.o.showmode   = false
vim.o.statusline = "%!v:lua.statusline()"
-- Guarantee that correct buffer is used
api.augroup('StatusLine',
            { {'WinEnter,BufEnter', '*', 'set statusline<'}
            , {'WinLeave,BufLeave', '*', 'lua vim.wo.statusline=statusline()'}
            })

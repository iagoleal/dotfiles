-- TODO: change color when RO or modified
require "utils"

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
    , "%#StatusLspDiagnosticsError#"        , " E:" , num.errors   , " %#StatusLine#"
    , "%#StatusLspDiagnosticsWarning#"      , " W:" , num.warnings , " %#StatusLine#"
    , "%#StatusLspDiagnosticsInformation#"  , " I:" , num.info     , " %#StatusLine#"
    , "%#StatusLspDiagnosticsHint#"         , " H:" , num.hints    , " %#StatusLine#"
    , " %)"})
end

function statusline()
  local sl = table.concat(
    { cursor_mode()
    , "%#StatusLine#"
    , " %-t %-m %-r"
    , "%="
    , diagnostics()
    , "%2(%c%), %2(%l%):%L "
    , filetype()
    })
  return sl
end

highlight("StatusLspDiagnosticsError",       {gui = "bold", guifg = "Black", guibg = "#CC2A1F"})
highlight("StatusLspDiagnosticsWarning",     {gui = "bold", guifg = "Black", guibg = "#EF981C"})
highlight("StatusLspDiagnosticsInformation", {gui = "bold", guifg = "Black", guibg = "#93DCF4"})
highlight("StatusLspDiagnosticsHint",        {gui = "bold", guifg = "Black", guibg = "#E2E5E6"})


-- Generate the statusline
highlight("StatusMode",     {gui = "bold", guifg = "Black", guibg = "White"})
highlight("StatusLang",     {gui = "bold", guifg = "Black", guibg = "#81A3FA"})
highlight("StatusModified", {gui = "bold", guifg = "Black", guibg = "#FF6B6B"})
highlight("StatusMixed",    {gui = "bold", guifg = "Black", guibg = "#A36BF0"})


vim.o.laststatus = 2
vim.o.showmode   = false
vim.o.statusline = "%!v:lua.statusline()"
-- Guarantee that correct buffer is used
augroup('StatusLine',
        { {'WinEnter,BufEnter', '*', 'set statusline<'}
        , {'WinLeave,BufLeave', '*', 'lua vim.wo.statusline=statusline()'}
        })

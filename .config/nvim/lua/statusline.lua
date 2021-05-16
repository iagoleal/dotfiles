require "utils"

--  Get/Set option value for the buffer where the statusline is being drawn
local sl_buf = {}
setmetatable(sl_buf,
  { __index =  function(table, option)
      return vim.api.nvim_buf_get_option(vim.fn.winbufnr(vim.g.statusline_winid), option)
    end
  , __newindex = function(table, option, value)
      vim.api.nvim_buf_set_option(vim.fn.winbufnr(vim.g.statusline_winid), option, value)
    end
  })
local sl_win = {}
-- Get/Set option value for the window where the statusline is being drawn
setmetatable(sl_win,
  { __index =  function(table, option)
      return vim.api.nvim_win_get_option(vim.g.statusline_winid, option)
    end
  , __newindex = function(table, option, value)
      vim.api.nvim_win_set_option(vim.g.statusline_winid, option, value)
    end
  })

-- Test whether the current buffer is the focused one
local function is_buffer_active()
  return vim.g.statusline_winid == vim.fn.win_getid()
end

local function cursormode()
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

local function filetype()
  local ft = sl_buf.filetype
  local color
  if not sl_buf.modifiable then
    color = "%#StatusUnmodifiable#"
  elseif sl_buf.modified then
    color = "%#StatusModified#"
  else
    color = "%#StatusLang#"
  end
  return string.format('%s %s ', color, ft)
end

-- Get number of diagnostics for each type
-- from https://github.com/nvim-lua/lsp-status.nvim/blob/master/lua/lsp-status/diagnostics.lua
local function get_lsp_diagnostics(bufnr)
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

local function diagnostics(bufnr)
  bufnr = bufnr or vim.fn.winbufnr(vim.g.statusline_winid)
  if #vim.lsp.buf_get_clients(bufnr) == 0 then
    return ""
  end
  local num = get_lsp_diagnostics(bufnr)
  return table.concat({"%21("
    , "%#StatusLspDiagnosticsError#"        , " E:" , num.errors   , " "
    , "%#StatusLspDiagnosticsWarning#"      , " W:" , num.warnings , " "
    , "%#StatusLspDiagnosticsInformation#"  , " I:" , num.info     , " "
    , "%#StatusLspDiagnosticsHint#"         , " H:" , num.hints    , " "
    , "%)"})
end

function statusline()
  local sl = table.concat(
    { cursormode()
    , sl_buf.readonly and "%#StatusReadonly#" or "%#StatusLine#"
    , " %-t"
    , "%="
    , diagnostics()
    , "%#StatusLine#"
    , " %2(%c%), %2(%l%):%L "
    , filetype()
    })
  return sl
end


-- Generate the statusline
do
  highlight("StatusMode",                      { gui = "bold", guifg = "Black", guibg = "White"   })
  highlight("StatusLang",                      { gui = "bold", guifg = "Black", guibg = "#81A3FA" })
  highlight("StatusModified",                  { gui = "bold", guifg = "Black", guibg = "#FF6B6B" })
  highlight("StatusUnmodifiable",              { gui = "bold", guifg = "Black", guibg = "#C4CBCF" })
  vim.cmd [[highlight default link StatusReadonly StatusUnmodifiable]]
  highlight("StatusMixed",                     { gui = "bold", guifg = "Black", guibg = "#A36BF0" })
  highlight("StatusLspDiagnosticsError",       { gui = "bold", guifg = "Black", guibg = "#CC2A1F" })
  highlight("StatusLspDiagnosticsWarning",     { gui = "bold", guifg = "Black", guibg = "#EF981C" })
  highlight("StatusLspDiagnosticsInformation", { gui = "bold", guifg = "Black", guibg = "#93DCF4" })
  highlight("StatusLspDiagnosticsHint",        { gui = "bold", guifg = "Black", guibg = "#E2E5E6" })

  vim.o.laststatus = 2
  vim.o.showmode   = false
  vim.o.statusline = "%!v:lua.statusline()"
end

return statusline

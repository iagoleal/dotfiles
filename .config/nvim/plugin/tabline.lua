-- require "statusline" -- Needed for highlight groups
local utils = require 'utils'

-- Buffer name or default
local function buffername(bufnr)
  local name = vim.fn.fnamemodify(vim.fn.bufname(bufnr), ':t')
  if not name or name == "" then
    return " [No Name] "
  else
    return string.format(" %s ", name)
  end
end

-- Is any buffer in given tab modified?
local function ismodified(tabnr)
  local buflist = vim.fn.tabpagebuflist(tabnr)
  for _, buf in ipairs(buflist) do
    if vim.fn.getbufvar(buf, "&mod") == 1 then
      return true
    end
  end
  return false
end

-- Which color to use in cell
local function cellcolor(tabnr)
  local color
  if ismodified(tabnr) and (tabnr == vim.fn.tabpagenr()) then
    color = "%#TabLineMixed#"
  elseif ismodified(tabnr) then
    color = "%#TabLineModified#"
  elseif tabnr == vim.fn.tabpagenr() then
    color = "%#TabLineSel#"
  else
    color = "%#TabLine#"
  end
  return color
end

-- Generate the tabline cell for a given tabpage
local function tabline_cell(tabnr)
  local winnr = vim.fn.tabpagewinnr(tabnr)
  local buflist = vim.fn.tabpagebuflist(tabnr)
  local bufnr = buflist[winnr]
  local num_bufs = vim.fn.tabpagewinnr(tabnr, '$')
  local hasvar, title = pcall(vim.api.nvim_tabpage_get_var, tabnr, 'title')
  if hasvar then
    title = string.format(" %s ", title)
  else
    title = buffername(bufnr)
  end

  tline = { '%' .. tabnr .. 'T'
          -- Color cell if selected
          , cellcolor(tabnr)
          , " " .. tabnr
          -- Show how many buffers in tab
          , num_bufs > 1 and (":" .. num_bufs) or ""
          , title
          , "%T%#TabLineFill#"
          }
  return table.concat(tline)
end

-- Generate tabline
function tabline()
  local tabs = {}
  for tabnr = 1, vim.fn.tabpagenr('$') do
    tabs[tabnr] = tabline_cell(tabnr)
  end
  return table.concat(tabs)
end

-- Allow user to give each tab a custom name
-- First argument is the tab number. Use 0 for current tab.
-- If the second argument is nil, it deletes the current name
-- and uses the focused buffer in its place.
function tabname(tabnr, name)
  local tpage
  if tabnr == 0 then
    tpage = vim.api.nvim_get_current_tabpage()
  else
    local tabpages = vim.api.nvim_list_tabpages()
    tpage = tabpages[tabnr]
  end
  if name == nil then
    vim.api.nvim_tabpage_del_var(tpage, 'title')
  else
    vim.api.nvim_tabpage_set_var(tpage, 'title', name)
  end
  vim.cmd("redrawtabline")
end

-- Use same colors as statusline
utils.hi_link("TabLine",         "StatusLine",     { default = true })
utils.hi_link("TabLineFill",     "StatusLine",     { default = true })
utils.hi_link("TabLineSel",      "StatusLang",     { default = true })
utils.hi_link("TabLineMixed",    "StatusMixed",    { default = true })
utils.hi_link("TabLineModified", "StatusModified", { default = true })

vim.api.nvim_command [[command! -nargs=? -count=0 -addr=tabs TabName :call v:lua.tabname(<count>, <f-args>)]]
vim.g.showtabline = 1
vim.o.tabline = "%!v:lua.tabline()"

return tabline

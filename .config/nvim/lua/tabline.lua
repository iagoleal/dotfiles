require "statusline" -- Needed for highlight groups

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

  tline = { '%' .. tabnr .. 'T'
          -- Color cell if selected
          , cellcolor(tabnr)
          , " " .. tabnr
          -- Show how many buffers in tab
          , num_bufs > 1 and (":" .. num_bufs) or ""
          , buffername(bufnr)
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
  return table.concat(tabs, "|")
end

-- Use same colors as statusline
vim.cmd "highlight default link TabLine StatusLine"
vim.cmd "highlight default link TabLineFill StatusLine"
vim.cmd "highlight default link TabLineSel StatusLang"
vim.cmd "highlight default link TabLineMixed StatusMixed"
vim.cmd "highlight default link TabLineModified StatusModified"

vim.g.showtabline = 1
vim.o.tabline = "%!v:lua.tabline()"

return tabline

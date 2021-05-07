local api = require "api"

-- api.highlight("TabLine",     {gui = "bold", guifg =  "#81A3FA", guibg = "Black"})
-- api.highlight("TabLineFill", {gui = "bold", guibg = "Black"})
api.highlight("TabLineSel",  {gui = "bold", guifg = "Black", guibg = "#81A3FA"})

vim.cmd("highlight! default link TabLine StatusLine")
vim.cmd("highlight! default link TabLineFill StatusLine")

-- Buffer name or default
local function buffername(n)
  local name = vim.fn.fnamemodify(vim.fn.bufname(n), ':t')
  if not name or name == "" then
    return " [No Name] "
  else
    return string.format(" %s ", name)
  end
end

-- Is any buffer in given tab modified?
local function is_modified(tabnr)
  local buflist = vim.fn.tabpagebuflist(tabnr)
  for _, buf in ipairs(buflist) do
    if vim.fn.getbufvar(buf, "&mod") == 1 then
      return true
    end
  end
  return false
end

function tabline()
  local tline = ""
  local tabs = {}
  -- Create label for each tabpage
  for tabnr = 1, vim.fn.tabpagenr('$') do
    local winnr = vim.fn.tabpagewinnr(tabnr)
    local buflist = vim.fn.tabpagebuflist(tabnr)
    local bufnr = buflist[winnr]

    tline = tline .. '%' .. tabnr .. 'T'
    if tabnr == vim.fn.tabpagenr() then
      tline = tline .. "%#TabLineSel#"
    else
      tline = tline .. "%#TabLine#"
    end
    tline = tline .. " " .. tabnr

    -- Show how many buffers in tab
    local n = vim.fn.tabpagewinnr(tabnr, '$')
    if n > 1 then
      tline = tline .. ":" .. n
    end

    tline = tline .. buffername(bufnr)

    -- Add modified flag  if any buffer in tab is modified
    if is_modified(tabnr) then
      tline = tline .. "+ "
    end

    tline = tline .. "%T"
  end
  -- End of tabs
  tline = tline .. "%#TabLineFill#"
  return tline
end

vim.g.showtabline = 1
vim.o.tabline = [[%!v:lua.tabline()]]

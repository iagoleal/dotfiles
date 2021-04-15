function CursorMode()
    local mode_map = {
        ['n']  = 'Normal   ',
        ['v']  = 'Visual   ',
        ['V']  = 'V-Line   ',
        [''] = 'V-Block  ',
        ['i']  = 'Insert   ',
        ['R']  = 'Replace  ',
        ['Rv'] = 'V-replace',
        ['c']  = 'Command  ',
    }

    return mode_map[vim.fn.mode()]
end

function StatusLine()
    local sl = table.concat(
      { [[%-{luaeval("CursorMode()")}]]
      , [[ %-t %-m %-r]]
      , [[%{get(b:,'gitsigns_head','')}]]
      , [[ %{get(b:,'gitsigns_status','')}]]
      , [[ %= %y %c, %l:%L]]
      })
    return sl
end

vim.o.laststatus = 2
vim.o.showmode   = false
vim.o.statusline = StatusLine()
